local Animation = {}
local JSON      = require("lib.json")


function Animation.new(sprite, name, frame_duration, frames)
  _frames = {}
  for i, frame in ipairs(frames) do
    _frames[i] = {
      image     = love.graphics.newQuad(frame.rectangle.x, frame.rectangle.y, frame.rectangle.width, frame.rectangle.height,  sprite:getDimensions()),
      origin    = frame.origin,
      hitboxes  = frame.hitboxes,
      hurtboxes = frame.hurtboxes,
      moveboxes = frame.moveboxes
    }
  end
  
  return {
    name     = name,
    duration = frame_duration,
    frames   = _frames
  }
end


-- Change the animation (and reset it) only if it's not the current animation.
function Animation.replace(entity, animation_name)
  if entity.animation.name ~= animation_name then
    entity.animation.timer = 0
    entity.animation.name  = animation_name
    entity.animation.frame = 1
  end
end



function Animation.animate_entities(entities, delta)
  for _, entity in pairs(entities) do
    entity.animation.timer = entity.animation.timer + delta
    local duration = entity.animations[entity.animation.name].duration
    
    if entity.animation.timer >= duration then
      entity.animation.timer = entity.animation.timer - duration
    end
    
    entity.animation.frame = math.floor(entity.animation.timer / duration * #entity.animations[entity.animation.name].frames) + 1
  end
end


function Animation.attach(entity, animation)
  entity.animations = entity.animations or {}  
  entity.animations[animation.name] = animation
  
  if entity.animation == nil then
    entity.animation = {
      name  = animation.name,
      timer = 0,
      frame = 1,
      flip  = false
    }
  end
end


function Animation.load_json(filepath)
  local file = io.open(filepath, "rb")
  
  if file then
    local content = file:read("*a") -- *a or *all reads the whole file
    file:close()
    return JSON.decode(content)
  end
end


return Animation
