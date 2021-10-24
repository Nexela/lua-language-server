local function tochar(code)
    return string.char((code >> 8) & 0xFF, code & 0xFF)
end

local function tobyte(s, i)
    local h, l = string.byte(s, i, i+1)
    return (h << 8) | l
end

local function char(code)
    if code <= 0xffff then
        return tochar(code)
    end
    code = code - 0x10000
    return tochar(0xD800 + (code >> 10))..tochar(0xDC00 + (code & 0x3FF))
end

local m = {}

function m.encode(s)
    local r = {}
    for _, c in utf8.codes(s) do
        r[#r+1] = char(c)
    end
    return table.concat(r)
end

function m.decode(s)
    local r = {}
    local i = 1
    while i < #s do
        local code1 = tobyte(s, i)
        if code1 < 0xD800 then
            r[#r+1] = utf8.char(code1)
        else
            i = i + 2
            local code2 = tobyte(s, i)
            local code = 0x10000 + ((code1 - 0xD800) << 10) + ((code2 - 0xDC00) & 0x3FF)
            r[#r+1] = utf8.char(code)
        end
        i = i + 2
    end
    return table.concat(r)
end

return m
