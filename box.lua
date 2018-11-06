local Box = {}


function Box.coordinates(entity, box)
  if entity.animation.flip then
    return { x = entity.x - box.x - box.width, y = entity.y + box.y, width = box.width, height = box.height }
  else
    return { x = entity.x + box.x, y = entity.y + box.y, width = box.width, height = box.height }
  end
end


-- a and b are rectangles: they respond to x, y, width, height.
function Box.collides(a, b) 
  return a.x < b.x + b.width
     and a.x + a.width > b.x
     and a.y < b.y + b.height
     and a.height + a.y > b.y
end


return Box
  