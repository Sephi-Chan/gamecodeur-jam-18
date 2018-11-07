local Utils = {}


function Utils.clamp(i, min, max)
    return i < min and min
        or (i > max and max or i)
end


function Utils.dist(x1, y1, x2, y2)
    return ((x2 - x1)^2 + (y2 - y1)^2)^0.5
end 


function Utils.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end



return Utils