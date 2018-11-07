local Utils = {}


function Utils.clamp(i, min, max)
    return i < min and min
        or (i > max and max or i)
end


return Utils