local Camera = {}
local Utils = require("lib.utils")


function Camera.attach(camera, depth, layer_or_callback)
  local object = {
    depth    = depth,
    layer    = type(layer_or_callback) ~= "function" and layer_or_callback or nil,
    callback = type(layer_or_callback) == "function" and layer_or_callback or nil
  }
  table.insert(camera.objects, object)
  table.sort(camera.objects, function(a, b) return a.depth > b.depth end)
end


function Camera.follow(camera, entity)
  camera.followed_object = entity
end


function Camera.bind(camera, level)
  camera.bounds.x2 = level.width
end


function Camera.update(camera, delta)
  local x = camera.followed_object.x - math.floor(camera.width/3)
  local y = camera.followed_object.y - math.floor(camera.height/3)
  
  camera.x = Utils.clamp(x, camera.bounds.x1, camera.bounds.x2)
  camera.y = Utils.clamp(y, camera.bounds.y1, camera.bounds.y2)
end


function Camera.draw(camera)
  for _, object in pairs(camera.objects) do
      camera.offset_x = camera.x * 1/object.depth
      camera.offset_y = camera.y * 1/object.depth
      
      love.graphics.push()
      love.graphics.translate(-camera.offset_x, - camera.offset_y)

      if object.layer then
        Layer.draw(object.layer)
      else
        object.callback()
      end

      love.graphics.pop()
  end
end


function Camera.initialize(width, height)
  return {
    x        = 0,
    y        = 0,
    offset_x = 0,
    offset_y = 0,
    width    = width,
    height   = height,
    objects  = {},
    bounds   = {
      x1 = 0,
      y1 = 0,
      x2 = 0,
      y2 = 0
    }
  }
end


return Camera 