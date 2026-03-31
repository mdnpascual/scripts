-- Function args mapper
local offsets = {
    0x302750,
    -- Offsets here
}

local base = getAddress("CrimsonDesert.exe")
if base == 0 then
    print("ERROR: CrimsonDesert.exe not found")
    return
end

-- Register names and their read functions
local registers = {
    { name = "RAX", read = function() return RAX end },
    { name = "RBX", read = function() return RBX end },
    { name = "RCX", read = function() return RCX end },
    { name = "RDX", read = function() return RDX end },
    { name = "RSI", read = function() return RSI end },
    { name = "RDI", read = function() return RDI end },
    { name = "RSP", read = function() return RSP end },
    { name = "RBP", read = function() return RBP end },
    { name = "R8",  read = function() return R8  end },
    { name = "R9",  read = function() return R9  end },
    { name = "R10", read = function() return R10 end },
    { name = "R11", read = function() return R11 end },
    { name = "RIP", read = function() return RIP end },
}

-- Try to read a value at an address safely
local function safeRead(addr)
    if addr == nil or addr == 0 then return nil end
    local ok, val = pcall(readQword, addr)
    if ok and val ~= nil then return val end
    return nil
end

-- Snapshot all register values, return as table
local function snapshotRegisters()
    local snap = {}
    for _, reg in ipairs(registers) do
        local ok, val = pcall(reg.read)
        snap[reg.name] = ok and val or nil
    end
    return snap
end

-- Try to read stack args beyond the 4 register args
-- RSP+0x20 = 5th arg (shadow space ends), RSP+0x28 = 6th, etc.
local function readStackArgs(rsp, count)
    local args = {}
    if rsp == nil or rsp == 0 then return args end
    for i = 1, count do
        local stackAddr = rsp + 0x20 + (i - 1) * 8
        local val = safeRead(stackAddr)
        args[i] = val
    end
    return args
end

-- Find which register holds a given value
local function findRegister(snap, value)
    if value == nil then return nil end
    local matches = {}
    for _, reg in ipairs(registers) do
        if snap[reg.name] == value then
            table.insert(matches, reg.name)
        end
    end
    if #matches > 0 then
        return table.concat(matches, "/")
    end
    return nil
end

-- Per-address hit log (only log once per address)
local logged = {}

local function makeHandler(capturedAddr, capturedOffset)
    return function()
        if logged[capturedAddr] then
            return true
        end
        logged[capturedAddr] = true

        local snap = snapshotRegisters()
        local rsp = snap["RSP"]

        -- x64 __fastcall: first 4 args in RCX, RDX, R8, R9
        local regArgs = {
            { name = "RCX", value = snap["RCX"] },
            { name = "RDX", value = snap["RDX"] },
            { name = "R8",  value = snap["R8"]  },
            { name = "R9",  value = snap["R9"]  },
        }

        -- Read 4 extra stack args
        local stackArgs = readStackArgs(rsp, 4)

        print(string.format("=== HIT: CrimsonDesert.exe+0x%X ===", capturedOffset))

        -- Print register args
        print("  Register args (x64 fastcall):")
        for i, arg in ipairs(regArgs) do
            if arg.value ~= nil then
                -- Try to read as string pointer
                local strVal = ""
                local ok, s = pcall(readString, arg.value, 64)
                if ok and s and #s > 0 and #s < 64 then
                    strVal = string.format(" -> \"%s\"", s)
                end
                print(string.format("    arg%d: %s = 0x%X%s",
                    i, arg.name, arg.value, strVal))
            end
        end

        -- Print stack args
        if #stackArgs > 0 then
            print("  Stack args (RSP+0x20+):")
            for i, val in ipairs(stackArgs) do
                if val ~= nil then
                    local regMatch = findRegister(snap, val)
                    local label = regMatch
                        and string.format(" (same as %s)", regMatch)
                        or  ""
                    local strVal = ""
                    local ok, s = pcall(readString, val, 64)
                    if ok and s and #s > 0 and #s < 64 then
                        strVal = string.format(" -> \"%s\"", s)
                    end
                    print(string.format("    stack_arg%d: 0x%X%s%s",
                        i, val, label, strVal))
                end
            end
        end

        -- Print all registers
        print("  All registers:")
        for _, reg in ipairs(registers) do
            local val = snap[reg.name]
            if val ~= nil then
                print(string.format("    %s = 0x%X", reg.name, val))
            end
        end

        print(string.format("=== END HIT: +0x%X ===", capturedOffset))

        return true
    end
end

-- Set breakpoints
local count = 0
for _, offset in ipairs(offsets) do
    local addr = base + offset
    local ok, err = pcall(function()
        debug_setBreakpoint(addr, makeHandler(addr, offset))
    end)
    if ok then
        count = count + 1
    else
        print(string.format("FAILED at +0x%X: %s", offset, tostring(err)))
    end
end

print(string.format("Started: %d breakpoints set", count))
print("Each address logs once then stays silent")
