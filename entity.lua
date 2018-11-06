local Entity = {
  _entities = {},
  _default_draw_options = {
    draw_boxes = true
  }
}


function Entity.new(name, sprite, options)
  Entity._entities[name] = {
    name       = name,
    sprite     = sprite,
    x          = options.x or 0,
    y          = options.y or 0,
    vx         = options.vx or 0,
    vy         = options.vy or 0,
    velocity   = options.velocity or 160,
    group      = options.group,
    health     = options.health or 25,
    max_health = options.health or 25,

    attacking      = false,
    attack_targets = {}
  }
  
  return Entity._entities[name]
end


function Entity.entities()
  return Entity._entities
end


function Entity.enemies()
  local enemies = {}
  for name, entity in pairs(Entity._entities) do
    if entity.group == "enemy" then
      enemies[name] = entity
    end
  end
  return enemies
end


function Entity.get(name)
  return Entity._entities[name]
end


function Entity.sortByY(entities)
  local list = Entity.asArray(entities)
  table.sort(list, function(a, b) return a.y < b.y end)
  return list
end


function Entity.asArray(entities)
  local list = {}
  for _, entity in pairs(entities) do
    table.insert(list, entity)
  end
  return list
end


function Entity.draw(entities, options)
  for _, entity in ipairs(entities) do
    local frame   = entity.animations[entity.animation.name].frames[entity.animation.frame]
    local scale_x = entity.animation.flip and -1 or 1

    if entity.group == "enemy" then
      love.graphics.setColor(1, .7, .7)
    else
      love.graphics.setColor(1, 1, 1)
    end
    love.graphics.draw(entity.sprite, frame.image, entity.x, entity.y, 0, scale_x, 1, frame.origin.x, frame.origin.y)

    if (options or Entity._default_draw_options).draw_boxes then
      love.graphics.print(entity.animation.frame, entity.x, entity.y)
      love.graphics.setColor(1, 0, 0, .7)
      love.graphics.circle("line", entity.x, entity.y, 1)
      
      for _, hitbox in pairs(frame.hitboxes or {}) do
        local box = Box.coordinates(entity, hitbox)
        love.graphics.setColor(1, 1, 0, .7)
        love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
      end
      
      for _, hurtbox in pairs(frame.hurtboxes or {}) do
        local box = Box.coordinates(entity, hurtbox)
        love.graphics.setColor(0, 0, 1, .7)
        love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
      end

      for _, movebox in pairs(frame.moveboxes or {}) do
        local box = Box.coordinates(entity, movebox)
        love.graphics.setColor(0, 1, 0, .7)
        love.graphics.rectangle("line", box.x, box.y, box.width, box.height)
      end
    end
  end
end


function Entity.wound(attacker, target)
  target.health = target.health - 10

  if target.health <= 0 then
    Entity._entities[target.name] = nil
  end
end

  
return Entity
