local Layer = {}


function Layer.draw(layer)
  love.graphics.draw(layer.img, layer.x - layer.width, layer.y, 0, layer.scale_x, layer.scale_y)
  love.graphics.draw(layer.img, layer.x, layer.y, 0, layer.scale_x, layer.scale_y)
  love.graphics.draw(layer.img, layer.x + layer.width, layer.y, 0, layer.scale_x, layer.scale_y)
end



function Layer.update(layer, camera, delta)
  if camera.x/layer.repetition_factor < (layer.x-layer.width) then
    layer.x = camera.x / layer.repetition_factor
  end

  if camera.x/layer.repetition_factor > layer.x + (layer.width) then  
    layer.x = camera.x/layer.repetition_factor
  end
end


function Layer.new(image, repetition_factor, options)
  local options = options or {}

  return {
    img               = image,
    repetition_factor = repetition_factor,
    x                 = options.x or 0,
    y                 = options.y or 0,
    scale_x           = options.scale_x or 1,
    scale_y           = options.scale_y or 1,
    width             = image:getWidth() * (options.scale_x or 1),
    height            = image:getHeight() * (options.scale_y or 1)
  }
end


return Layer 