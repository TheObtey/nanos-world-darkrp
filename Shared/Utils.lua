--[[

    Utils functions

--]]

function PrintTable(t, indent, done)
    indent = indent or 0
    done = done or {}

    if type(t) ~= "table" then
        print(string.rep("\t", indent) .. tostring(t))
        return
    end

    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end

    table.sort(keys, function(a, b)
        if type(a) == "number" and type(b) == "number" then
            return a < b
        end
        return tostring(a) < tostring(b)
    end)

    done[t] = true

    for _, key in ipairs(keys) do
        local value = t[key]
        local formattedKey = type(key) == "string" and "[\"" .. key .. "\"]" or "[" .. tostring(key) .. "]"
        local prefix = string.rep("\t", indent)

        if type(value) == "table" and not done[value] then
            print(prefix .. formattedKey .. " = {")
            done[value] = true
            PrintTable(value, indent + 1, done)
            print(prefix .. "}")
        else
            print(prefix .. formattedKey .. " = " .. tostring(value))
        end
    end
end