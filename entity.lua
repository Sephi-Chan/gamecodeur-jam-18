local Utils = require("lib.utils")
local Entity = {
  LEFT  = -1,
  RIGHT = 1,
  UP    = -1,
  DOWN  = 1,

  default_draw_options = {
    draw_boxes  = false,
    print_state = false
  },

  states = {
    IDLE      = "idle",
    ATTACKING = "attacking",
    STAGGERED = "staggered"
  },

  sprites = {
    elf_green  = love.graphics.newImage("images/elf_green.png"),
    elf_purple = love.graphics.newImage("images/elf_purple.png"),
    druid      = love.graphics.newImage("images/druid.png")
  },

  animations = {
    elf   = Animation.load_json("metadata/elf.json"),
    druid = Animation.load_json("metadata/druid.json"),
  }
}




function Entity.new(name, sprite, options)
  return {
    name       = name,
    sprite     = sprite,
    state      = options.state or Entity.states.IDLE,
    x          = options.x or 0,
    y          = options.y or 0,
    vx         = options.vx or 0,
    vy         = options.vy or 0,
    velocity_x = options.velocity_x or 160,
    velocity_y = options.velocity_y or 160 * 0.6,
    group      = options.group,
    health     = options.health or 25,
    max_health = options.health or 25,
    module     = options.module or Entity,

    attack_targets      = {},
    attack_sound_played = false,
    stagger_timer       = 0
  }
end


function Entity.sortByY(hero, enemies)
  local list = Entity.asArray(enemies)
  table.insert(list, hero)
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


function Entity.update(hero, level, delta)
  Hero.update(hero, level, delta)
  for _, enemy in pairs(level.enemies) do
    enemy.module.update(enemy, hero, delta)
  end
end


function Entity.draw(entities, options)
  love.graphics.setColor(1, 1, 1)

  for _, entity in ipairs(entities) do
    local frames  = entity.animations[entity.animation.name].frames
    local frame   = frames[entity.animation.frame] or frames[1]
    local scale_x = entity.animation.flip and -1 or 1

    love.graphics.draw(entity.sprite, frame.image, entity.x, entity.y, 0, scale_x, 1, frame.origin.x, frame.origin.y)

    if (options or Entity.default_draw_options).print_state then
      love.graphics.print(entity.state, entity.x, entity.y)
      love.graphics.print(entity.animation.name .. " " .. entity.animation.frame .. "/" .. #frames, entity.x, entity.y + 15)
    end

    if (options or Entity.default_draw_options).draw_boxes then
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
   love.graphics.setColor(1, 1, 1)
end


function Entity.resolve_horizontal_collision(entity, others)
  local entity_frame        = entity.animations[entity.animation.name].frames[entity.animation.frame]
  local entity_movebox      = entity_frame.moveboxes[1]
  local entity_real_movebox = Box.coordinates(entity, entity_movebox)

  for _, other in pairs(others) do
    local other_frame        = other.animations[other.animation.name].frames[other.animation.frame]
    local other_movebox      = other_frame.moveboxes[1]
    local other_real_movebox = Box.coordinates(other, other_movebox)

    if Box.collides(entity_real_movebox, other_real_movebox) then
      if entity.vx == Entity.RIGHT then
        entity.x = other_real_movebox.x - (entity_movebox.width + entity_movebox.x)

      elseif entity.vx == Entity.LEFT then
        local other_movebox_x2 = other.x + (other.animation.flip and -other_movebox.x or other_movebox.x + other_movebox.width)
        entity.x = other_movebox_x2 + entity_movebox.width + entity_movebox.x
      end
    end
  end
end


function Entity.resolve_vertical_collision(entity, others)
  local entity_frame        = entity.animations[entity.animation.name].frames[entity.animation.frame]
  local entity_movebox      = entity_frame.moveboxes[1]
  local entity_real_movebox = Box.coordinates(entity, entity_movebox)

  for _, other in pairs(others) do
    local other_frame        = other.animations[other.animation.name].frames[other.animation.frame]
    local other_real_movebox = Box.coordinates(other, other_frame.moveboxes[1])

    if Box.collides(entity_real_movebox, other_real_movebox) then
      if entity.vy == 1 then
        entity.y = other.y - other_real_movebox.height - 1
      elseif entity.vy == -1 then
        entity.y = other.y + entity_movebox.height + 1
      end
    end
  end
end


function Entity.wound(attacker, target)
  target.health = target.health - 10
  Entity.stagger(target)
end


function Entity.stagger(entity)
  entity.state         = Entity.states.STAGGERED
  entity.stagger_timer = entity.module.STAGGER_DURATION
end


function Entity.staggered(entity)
  Animation.replace(entity, "staggered")

  if entity.stagger_timer == 0 then
    entity.state = Entity.states.IDLE
  end
end


function Entity.update_stagger_timer(entity, delta)
  entity.stagger_timer = Utils.clamp(entity.stagger_timer - delta, 0, 100)
end


return Entity
