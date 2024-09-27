--[[Script to dump the rough layout of the current floor for PMD Sky EU ROM]]--




local floor_start = 0x021BE754
local write_to_file = true
local output_path = "floor.txt"


-- Lua 5.1 didn't include a pack function yet
local function pack(...)
    return {n = select("#", ...), ...}
end

-- Nor bit op functions
OR, XOR, AND = 1, 3, 4
local function bitoper(a, b, oper)
    local r, m, s = 0, 2^31
    repeat
        s,a,b = a+b+m, a%m, b%m
        r,m = r + m*oper%(s-a-b), m/2
    until m < 1
    return r
end

output = ""
addrs = {}
i = 1
curr = floor_start
repeat
    addrs[i] = curr
    curr = curr + 20
    i = i + 1
until i > 56*32 -1

for idx, addr in ipairs(addrs) do
    if (idx % 56 == 0) then
        output = output .. "\n"
    end

    val = memory.readbyte(addr)
    terrain_type = bitoper(val, 3, AND)
    is_shop = bitoper(val, 32, AND)
    is_mh = bitoper(val, 64, AND)
    val = memory.readbyte(addr+1)
    is_stairs = bitoper(val, 2, AND)

    tile_str = "U "
    if (is_stairs ~= 0) then
        tile_str = "S "
    elseif (is_shop ~= 0) then
        tile_str = "$ "
    elseif (is_mh ~= 0) then
        tile_str = "! "
    elseif (terrain_type == 2 or terrain_type == 3) then
        tile_str = "W "
    elseif (terrain_type == 1) then
        tile_str = "  "
    elseif (terrain_type == 0) then
        tile_str = "* "
    end

    output = output .. tile_str --.. val
end

if write_to_file then
    f = assert(io.open(output_path, "w"))
    f:write(output)
    f:close()
    print("Wrote to file: " .. output_path)
else
    print(output)
end
