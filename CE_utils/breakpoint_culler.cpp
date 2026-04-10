/*
 * bp_culler.exe — Breakpoint Culling Tool
 *
 * COMEPILE INSTRUCTIONS:
 * cl main.cpp /std:c++17 /EHsc /O2 /Fe:bp_culler.exe /link psapi.lib user32.lib
 *
 * PURPOSE:
 *   Attaches to a running game process as a debugger and installs INT3
 *   breakpoints at every address in a provided offset list. When any
 *   breakpoint is hit it is immediately removed and logged. After performing
 *   actions in the game that are UNRELATED to the function you want to
 *   isolate, press F11 to dump all addresses that were NEVER hit — those
 *   are your surviving candidates. This is intended to cull large address
 *   lists produced by Cheat Engine's code filter / "find what addresses
 *   this code accesses" tools.
 *
 * USAGE:
 *   bp_culler.exe <PID> <offsets_file> [log_file]
 *
 *   PID          — decimal process ID of the target game process
 *   offsets_file — path to a plain-text file of module offsets (see below)
 *   log_file     — optional path for the output log
 *                  default: bp_culler_log.txt
 *
 * OFFSETS FILE FORMAT:
 *   One hex offset per line, relative to the main module base.
 *   Leading "0x" / "0X" prefix is accepted but not required.
 *   Blank lines and Windows-style CR LF line endings are ignored.
 *
 *   Example:
 *     0x100F510
 *     0x20A3BC0
 *     3F10000
 *
 * CONTROLS (work without console focus):
 *   F10 — Print all breakpoints that have NOT been hit yet
 *   F11 — Remove all remaining breakpoints, print the final survivor list,
 *          and detach cleanly (game keeps running)
 */

#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#include <stdio.h>
#include <stdint.h>
#include <string>
#include <unordered_map>
#include <vector>
#include <thread>
#include <atomic>
#include <algorithm>
#include <fstream>

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

struct BpEntry {
    uintptr_t addr;
    BYTE      originalByte;
    bool      active;
};

// ─────────────────────────────────────────────────────────────────────────────
// Globals
// ─────────────────────────────────────────────────────────────────────────────

static HANDLE                                  g_hProcess  = NULL;
static uintptr_t                               g_base      = 0;
static std::unordered_map<uintptr_t, BpEntry>  g_bps;
static std::unordered_map<DWORD, uintptr_t>    g_singleStep; // threadId → bp addr mid-restore
static std::atomic<bool>                       g_printNow  { false };
static std::atomic<bool>                       g_clearNow  { false };
static std::atomic<bool>                       g_running   { true };
static CRITICAL_SECTION                        g_cs;
static int                                     g_hitCount  = 0;
static FILE*                                   g_log       = nullptr;

// ─────────────────────────────────────────────────────────────────────────────
// Logging — writes to console AND log file simultaneously
// ─────────────────────────────────────────────────────────────────────────────

static void logPrint(const char* fmt, ...) {
    va_list args;

    va_start(args, fmt);
    vprintf(fmt, args);
    va_end(args);

    if (g_log) {
        va_start(args, fmt);
        vfprintf(g_log, fmt, args);
        va_end(args);
        fflush(g_log);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Process helpers
// ─────────────────────────────────────────────────────────────────────────────

static uintptr_t getModuleBase(DWORD pid, const char* modName) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, pid);
    if (snap == INVALID_HANDLE_VALUE) return 0;

    MODULEENTRY32 me = { sizeof(me) };
    uintptr_t base = 0;

    if (Module32First(snap, &me)) {
        do {
            if (_stricmp(me.szModule, modName) == 0) {
                base = (uintptr_t)me.modBaseAddr;
                break;
            }
        } while (Module32Next(snap, &me));
    }

    CloseHandle(snap);
    return base;
}

// ─────────────────────────────────────────────────────────────────────────────
// Breakpoint helpers
// ─────────────────────────────────────────────────────────────────────────────

static bool writeByte(uintptr_t addr, BYTE b) {
    DWORD old = 0;
    if (!VirtualProtectEx(g_hProcess, (LPVOID)addr, 1, PAGE_EXECUTE_READWRITE, &old))
        return false;
    SIZE_T written = 0;
    bool ok = WriteProcessMemory(g_hProcess, (LPVOID)addr, &b, 1, &written);
    VirtualProtectEx(g_hProcess, (LPVOID)addr, 1, old, &old);
    return ok && written == 1;
}

static bool readByte(uintptr_t addr, BYTE& out) {
    SIZE_T read = 0;
    return ReadProcessMemory(g_hProcess, (LPVOID)addr, &out, 1, &read) && read == 1;
}

static bool installBreakpoint(BpEntry& entry) {
    if (!readByte(entry.addr, entry.originalByte)) return false;
    if (!writeByte(entry.addr, 0xCC))              return false;
    entry.active = true;
    return true;
}

static void removeBreakpoint(BpEntry& entry) {
    if (!entry.active) return;
    writeByte(entry.addr, entry.originalByte);
    entry.active = false;
}

// Set or clear the Trap Flag on a thread's EFLAGS
static void setTrapFlag(HANDLE hThread, bool enable) {
    CONTEXT ctx = {};
    ctx.ContextFlags = CONTEXT_CONTROL;
    if (!GetThreadContext(hThread, &ctx)) return;
    if (enable)
        ctx.EFlags |=  0x100;  // set TF
    else
        ctx.EFlags &= ~0x100;  // clear TF
    SetThreadContext(hThread, &ctx);
}

// Rewind RIP by 1 (back over the 0xCC) and arm the Trap Flag in one call
static void rewindAndArm(HANDLE hThread) {
    CONTEXT ctx = {};
    ctx.ContextFlags = CONTEXT_CONTROL;
    if (!GetThreadContext(hThread, &ctx)) return;
    ctx.Rip   -= 1;      // back up over the INT3
    ctx.EFlags |= 0x100; // set Trap Flag — fires EXCEPTION_SINGLE_STEP after 1 instruction
    SetThreadContext(hThread, &ctx);
}

// ─────────────────────────────────────────────────────────────────────────────
// Hotkey thread — polls F10 / F11, does NOT need console focus
// ─────────────────────────────────────────────────────────────────────────────

static void hotkeyThread() {
    bool prevF10 = false;
    bool prevF11 = false;

    while (g_running.load()) {
        bool f10 = (GetAsyncKeyState(VK_F10) & 0x8000) != 0;
        bool f11 = (GetAsyncKeyState(VK_F11) & 0x8000) != 0;

        if (f10 && !prevF10) g_printNow.store(true);
        if (f11 && !prevF11) g_clearNow.store(true);

        prevF10 = f10;
        prevF11 = f11;
        Sleep(50);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Print remaining (unhit) breakpoints
// ─────────────────────────────────────────────────────────────────────────────

static void printRemaining() {
    EnterCriticalSection(&g_cs);

    std::vector<uintptr_t> remaining;
    remaining.reserve(g_bps.size());

    for (auto it = g_bps.begin(); it != g_bps.end(); ++it) {
        if (it->second.active) {
            remaining.push_back(it->first);
        }
    }

    std::sort(remaining.begin(), remaining.end());

    if (remaining.empty()) {
        logPrint("[F10] No breakpoints remaining.\n");
    } else {
        logPrint("[F10] Remaining (not yet hit): %zu\n", remaining.size());
        for (uintptr_t addr : remaining) {
            uintptr_t offset = addr - g_base;
            logPrint("  CrimsonDesert.exe+0x%llX\n", (unsigned long long)offset);
        }
    }

    LeaveCriticalSection(&g_cs);
}

// ─────────────────────────────────────────────────────────────────────────────
// Remove all breakpoints and print final summary
// ─────────────────────────────────────────────────────────────────────────────

static void clearAll() {
    EnterCriticalSection(&g_cs);

    std::vector<uintptr_t> survivors;

    for (auto it = g_bps.begin(); it != g_bps.end(); ++it) {
        if (it->second.active) {
            survivors.push_back(it->first);
            removeBreakpoint(it->second);
        }
    }

    std::sort(survivors.begin(), survivors.end());

    logPrint("\n=== Final Summary ===\n");
    logPrint("Total hit (removed during session): %d\n", g_hitCount);
    logPrint("Survivors (never hit):              %zu\n", survivors.size());
    logPrint("\nSurvivor offsets:\n");

    for (uintptr_t addr : survivors) {
        uintptr_t offset = addr - g_base;
        logPrint("  CrimsonDesert.exe+0x%llX\n", (unsigned long long)offset);
    }

    logPrint("=====================\n");

    LeaveCriticalSection(&g_cs);

    g_running.store(false);
}

// ─────────────────────────────────────────────────────────────────────────────
// Load offsets from file
// ─────────────────────────────────────────────────────────────────────────────

static std::vector<uintptr_t> loadOffsets(const char* path) {
    std::vector<uintptr_t> offsets;
    std::ifstream f(path);
    if (!f.is_open()) {
        printf("ERROR: Cannot open offset file: %s\n", path);
        return offsets;
    }

    std::string line;
    while (std::getline(f, line)) {
        while (!line.empty() && (line.back() == '\r' || line.back() == '\n' || line.back() == ' '))
            line.pop_back();
        if (line.empty()) continue;

        const char* s = line.c_str();
        if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) s += 2;

        uintptr_t offset = (uintptr_t)strtoull(s, nullptr, 16);
        if (offset != 0) {
            offsets.push_back(offset);
        }
    }

    return offsets;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main debug loop
// ─────────────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: bp_culler.exe <PID> <offsets_file> [log_file]\n");
        printf("  F10 = print remaining (unhit) offsets\n");
        printf("  F11 = remove all BPs, detach, print final summary\n");
        return 1;
    }

    DWORD pid          = (DWORD)atoi(argv[1]);
    const char* offsetFile = argv[2];
    const char* logFile    = (argc >= 4) ? argv[3] : "bp_culler_log.txt";

    g_log = fopen(logFile, "w");
    if (!g_log) {
        printf("WARNING: Could not open log file '%s', console only.\n", logFile);
    } else {
        printf("Logging to: %s\n", logFile);
    }

    std::vector<uintptr_t> offsets = loadOffsets(offsetFile);
    if (offsets.empty()) {
        printf("ERROR: No offsets loaded.\n");
        return 1;
    }
    logPrint("Loaded %zu offsets from file.\n", offsets.size());

    if (!DebugActiveProcess(pid)) {
        logPrint("ERROR: DebugActiveProcess failed (GLE=%lu). Run as Administrator?\n",
                 GetLastError());
        return 1;
    }

    DebugSetProcessKillOnExit(FALSE);

    g_hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!g_hProcess) {
        logPrint("ERROR: OpenProcess failed (GLE=%lu).\n", GetLastError());
        DebugActiveProcessStop(pid);
        return 1;
    }

    g_base = getModuleBase(pid, "CrimsonDesert.exe");
    if (g_base == 0) {
        logPrint("ERROR: Could not find CrimsonDesert.exe module base.\n");
        CloseHandle(g_hProcess);
        DebugActiveProcessStop(pid);
        return 1;
    }
    logPrint("Module base: 0x%llX\n", (unsigned long long)g_base);

    // Consume the initial loader breakpoint Windows fires on attach
    {
        DEBUG_EVENT de = {};
        WaitForDebugEvent(&de, 5000);
        ContinueDebugEvent(de.dwProcessId, de.dwThreadId, DBG_CONTINUE);
        logPrint("Consumed initial attach breakpoint.\n");
    }

    InitializeCriticalSection(&g_cs);

    logPrint("Installing %zu breakpoints...\n", offsets.size());
    int installed = 0;
    int failed    = 0;

    for (uintptr_t offset : offsets) {
        uintptr_t addr = g_base + offset;
        BpEntry entry  = { addr, 0x00, false };

        if (installBreakpoint(entry)) {
            g_bps[addr] = entry;
            ++installed;
        } else {
            ++failed;
        }
    }

    logPrint("Installed: %d  |  Failed: %d\n", installed, failed);
    logPrint("\nF10 = print remaining  |  F11 = remove all & detach\n");
    logPrint("(hotkeys work even without console focus)\n\n");

    std::thread hkThread(hotkeyThread);

    // ── Debug event loop ──────────────────────────────────────────────────────
    while (g_running.load()) {

        if (g_printNow.exchange(false)) {
            printRemaining();
        }

        // NOTE: g_clearNow is intentionally NOT acted on here while the process
        // is running freely. We handle it below after WaitForDebugEvent returns,
        // i.e. while all game threads are suspended by the debug event.

        DEBUG_EVENT de = {};
        DWORD status   = DBG_CONTINUE;

        if (!WaitForDebugEvent(&de, 100)) {
            continue;
        }

        // Process is now suspended — safe moment to remove all breakpoints.
        if (g_clearNow.exchange(false)) {
            clearAll();
            ContinueDebugEvent(de.dwProcessId, de.dwThreadId, DBG_CONTINUE);
            break;
        }

        if (de.dwDebugEventCode == EXCEPTION_DEBUG_EVENT) {
            EXCEPTION_RECORD& rec = de.u.Exception.ExceptionRecord;

            if (rec.ExceptionCode == EXCEPTION_BREAKPOINT) {
                uintptr_t bpAddr = (uintptr_t)rec.ExceptionAddress;

                EnterCriticalSection(&g_cs);
                auto it = g_bps.find(bpAddr);

                if (it != g_bps.end()) {
                    // Our breakpoint address (active OR already-removed by another thread).
                    // Either way: the original byte is/was restored by us, so we must
                    // rewind RIP and continue — never pass as unhandled.
                    if (it->second.active) {
                        removeBreakpoint(it->second);
                        ++g_hitCount;

                        uintptr_t offset = bpAddr - g_base;
                        logPrint("[%d] Hit & removed: +0x%llX\n",
                                 g_hitCount, (unsigned long long)offset);
                    }
                    // else: a second thread raced to the same INT3 after we already
                    // restored the byte — still our event, still need to rewind RIP.

                    HANDLE hThread = OpenThread(
                        THREAD_GET_CONTEXT | THREAD_SET_CONTEXT,
                        FALSE, de.dwThreadId);

                    if (hThread) {
                        rewindAndArm(hThread);
                        // Record this thread as mid-restore so SINGLE_STEP
                        // knows it belongs to us
                        g_singleStep[de.dwThreadId] = bpAddr;
                        CloseHandle(hThread);
                    }

                    LeaveCriticalSection(&g_cs);
                    status = DBG_CONTINUE;

                } else {
                    // Not our BP — pass through to the game
                    LeaveCriticalSection(&g_cs);
                    status = DBG_EXCEPTION_NOT_HANDLED;
                }

            } else if (rec.ExceptionCode == EXCEPTION_SINGLE_STEP) {
                // Check if this is our single-step from a BP restore
                EnterCriticalSection(&g_cs);
                auto it = g_singleStep.find(de.dwThreadId);

                if (it != g_singleStep.end()) {
                    // Ours — clear TF and remove from pending map
                    g_singleStep.erase(it);

                    HANDLE hThread = OpenThread(
                        THREAD_GET_CONTEXT | THREAD_SET_CONTEXT,
                        FALSE, de.dwThreadId);
                    if (hThread) {
                        setTrapFlag(hThread, false); // defensive TF clear
                        CloseHandle(hThread);
                    }

                    LeaveCriticalSection(&g_cs);
                    status = DBG_CONTINUE;

                } else {
                    // Not ours (game uses TF itself, e.g. its own debugger checks)
                    LeaveCriticalSection(&g_cs);
                    status = DBG_EXCEPTION_NOT_HANDLED;
                }

            } else {
                // Any other exception — pass through to the game
                status = DBG_EXCEPTION_NOT_HANDLED;
            }

        } else if (de.dwDebugEventCode == EXIT_PROCESS_DEBUG_EVENT) {
            logPrint("Game process exited.\n");
            g_running.store(false);
            ContinueDebugEvent(de.dwProcessId, de.dwThreadId, DBG_CONTINUE);
            break;
        }

        ContinueDebugEvent(de.dwProcessId, de.dwThreadId, status);
    }

    // ── Cleanup ───────────────────────────────────────────────────────────────
    g_running.store(false);
    hkThread.join();

    EnterCriticalSection(&g_cs);
    for (auto it = g_bps.begin(); it != g_bps.end(); ++it) {
        if (it->second.active) {
            removeBreakpoint(it->second);
        }
    }
    LeaveCriticalSection(&g_cs);

    DeleteCriticalSection(&g_cs);

    DebugActiveProcessStop(pid);
    CloseHandle(g_hProcess);

    logPrint("Detached cleanly. Game continues running.\n");

    if (g_log) fclose(g_log);

    return 0;
}
