local Layer = {}


function Layer.draw(layer)
  love.graphics.draw(layer.img, layer.x - layer.width, layer.y, 0, layer.scale_x, layer.scale_y)
  love.graphics.draw(layer.img, layer.x, layer.y, 0, layer.scale_x, layer.scale_y)
  love.graphics.draw(layer.img, layer.x + layer.width, layer.y, 0, layer.scale_x, layer.scale_y)
end


function Layer.update(layer, camera, delta)
  if  camera.x < layer.x - (layer.width * layer.depth) then
    layer.x = camera.x
  end
  if  camera.x > layer.x + (layer.width * layer.depth) then
    layer.x = camera.x
  end
end


function Layer.new(x, y, image, scale_x, scale_y, depth)
   return {
    x       = x,
    y       = y,
    img     = image,
    scale_x = scale_x,
    scale_y = scale_y,
    width   = image:getWidth() * scale_x,
    height  = image:getHeight() * scale_y,
    depth   = depth
   }
end


return Layer 