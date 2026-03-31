-- Cull breakpoints that is not related
local offsets = {
    0x302750,
    -- Offsets here
}

local base = getAddress("CrimsonDesert.exe")
if base == 0 then
    print("ERROR: CrimsonDesert.exe not found")
    return
end

local activeBreakpoints = {}
local hitCount = 0

for _, offset in ipairs(offsets) do
    local addr = base + offset
    activeBreakpoints[addr] = offset

    -- each closure captures its own addr via upvalue
    local capturedAddr = addr
    local capturedOffset = offset

    local ok, err = pcall(function()
        debug_setBreakpoint(capturedAddr, function()
            if activeBreakpoints[capturedAddr] ~= nil then
                hitCount = hitCount + 1
                print(string.format("[%d] Removed: CrimsonDesert.exe+0x%X",
                    hitCount, capturedOffset))
                activeBreakpoints[capturedAddr] = nil
                debug_removeBreakpoint(capturedAddr)
            end
            return true
        end)
    end)

    if not ok then
        print(string.format("FAILED at +0x%X: %s", offset, tostring(err)))
        activeBreakpoints[addr] = nil
    end
end

print(string.format("Started: %d breakpoints set", #offsets))

local PRINT_KEY = 0x79
local CLEAR_KEY = 0x7A
local prevPrintDown = false
local prevClearDown = false

local timer = createTimer(nil, false)
timer.Interval = 100
timer.OnTimer = function()
    local printDown = isKeyPressed(PRINT_KEY)
    if printDown and not prevPrintDown then
        local remaining = {}
        for addr, offset in pairs(activeBreakpoints) do
            table.insert(remaining, offset)
        end
        table.sort(remaining)
        if #remaining == 0 then
            print("No breakpoints remaining - trigger FAIL now")
        else
            print(string.format("Remaining: %d candidates", #remaining))
            for i, offset in ipairs(remaining) do
                print(string.format("  [%d] CrimsonDesert.exe+0x%X", i, offset))
            end
        end
    end
    prevPrintDown = printDown

    local clearDown = isKeyPressed(CLEAR_KEY)
    if clearDown and not prevClearDown then
        local c = 0
        for addr, _ in pairs(activeBreakpoints) do
            debug_removeBreakpoint(addr)
            activeBreakpoints[addr] = nil
            c = c + 1
        end
        print(string.format("Cleared %d remaining breakpoints", c))
        timer.Enabled = false
    end
    prevClearDown = clearDown
end
timer.Enabled = true

print("F10 = print remaining  |  F11 = clear all")
