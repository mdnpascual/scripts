-- Put breakpoints given offsets
local offsets = {
    0x1A3F820,
    -- your offsets here
}

local base = getAddress("CrimsonDesert.exe")
if base == 0 then
    print("ERROR: CrimsonDesert.exe not found")
    return
end

local count = 0
for _, offset in ipairs(offsets) do
    local ok, err = pcall(function()
        debug_setBreakpoint(base + offset)
    end)
    if ok then
        count = count + 1
    else
        print(string.format("FAILED at +0x%X: %s", offset, tostring(err)))
    end
end

print(string.format("Done: %d breakpoints set", count))
