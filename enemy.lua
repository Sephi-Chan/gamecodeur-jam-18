local Enemy = {
  states = {
    IDLE       = "idle",
    STAGGERED  = "staggered",
    HUNTING    = "hunting",
    ATTACKING  = "attacking",
    RECOVERING = "recovering",
  }
}
local UUID = require("lib.uuid")
local Utils = require("lib.utils")

local hero_sprite     = love.graphics.newImage("images/hero.png")
local hero_animations = Animation.load_json("metadata/hero.json")


function Enemy.new(x, y, options)
  local options    = options or {}
  local sprite     = hero_sprite
  local animations = hero_animations
  local id         = options.name or UUID.uuid("enemy")
  local enemy      = Entity.new(id, sprite, {
    x          = x,
    y          = y,
    state      = Enemy.states.IDLE,
    group      = "enemy",
    velocity_x = 120,
    velocity_y = 120 * 0.6,
    module     = Enemy
  })

  for name, animation in pairs(animations) do
    Animation.attach(enemy, Animation.new(enemy.sprite, name, .5, animation.frames))
  end

  enemy.aggro_radius = 200
  enemy.attack_range = 50

  return enemy
end



function Enemy.update(enemy, hero, delta)
  Enemy.think(enemy, hero)

  if enemy.state == Enemy.states.STAGGERED then
    Entity.staggered(enemy)

  elseif enemy.state == Enemy.states.RECOVERING then
    Enemy.recover(enemy)

  elseif enemy.state == Enemy.states.HUNTING then
    Enemy.move(enemy, hero, delta)

  elseif enemy.state == Enemy.states.ATTACKING then
    Enemy.attack(enemy, hero, delta)

  elseif enemy.state == Enemy.states.IDLE then
    Animation.replace(enemy, "idle")
  end
end


function Enemy.attack(enemy, hero, delta)
  local enemy_frame = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
  local last_frame  = #enemy.animations[enemy.animation.name].frames

  if enemy_frame.hitboxes then
    local has_hit      = false
    local real_hitbox  = Box.coordinates(enemy, enemy_frame.hitboxes[1])
    local hero_frame   = hero.animations[hero.animation.name].frames[hero.animation.frame]
    local hero_movebox = hero_frame.moveboxes[1]

    if enemy.attack_targets[hero.name] then
      -- wound an enemy only once per attack.

    elseif enemy.y < hero.y - hero_movebox.height or hero.y < enemy.y - hero_movebox.height then
      -- only hit the targets with around the same Y: enemy is either too far or too near on the screen.

    else
      local hero_real_hurtbox = Box.coordinates(hero, hero_frame.hurtboxes[1])

      if Box.collides(real_hitbox, hero_real_hurtbox) then
        enemy.attack_targets[hero.name] = true
        Enemy.wound(enemy, hero)
        has_hit = true
      else
        foo()
      end
    end

    if enemy.attack_sound_played == false then
      local sound = has_hit and "sword_hit" or "sword_miss"
      Soundbox.play_sound(sound, .5)
      enemy.attack_sound_played = true
    end
  end

  Animation.replace(enemy, "attack1")

  if enemy.animation.frame == last_frame then
    Enemy.start_recovering(enemy)
    enemy.attack_targets      = {}
    enemy.attack_sound_played = false
  end
end


function Enemy.move(enemy, hero, delta)
  local angle = Utils.angle( enemy.x, enemy.y, hero.x, hero.y)
  local velocity_x = math.cos(angle) * enemy.velocity_x * delta
  local velocity_y = math.sin(angle) * enemy.velocity_y * delta

  enemy.animation.flip = velocity_x < 0
  enemy.vx = velocity_x < 0 and -1 or 1
  enemy.vy = velocity_y < 0 and -1 or 1

  enemy.x = enemy.x + velocity_x
  Entity.resolve_horizontal_collision(enemy, { hero })

  enemy.y = enemy.y + velocity_y
  Entity.resolve_vertical_collision(enemy, { hero })

  Animation.replace(enemy, "walk")
end

function Enemy.start_recovering(enemy)
  enemy.state             = Enemy.states.RECOVERING
  enemy.recovering_frames = 50
end


function Enemy.recover(enemy)
  Animation.replace(enemy, "idle")

  enemy.recovering_frames = enemy.recovering_frames - 1

  if enemy.recovering_frames == 0 then
    enemy.recovering_frames = nil
    enemy.state             = Enemy.states.IDLE
  end
end


function Enemy.think(enemy, hero)
  if enemy.state == Enemy.states.STAGGERED then
    return

  elseif enemy.state == Enemy.states.RECOVERING then
    return

  else
    local distance =  Utils.dist(hero.x, hero.y, enemy.x, enemy.y)

    if distance < enemy.aggro_radius then
      enemy.state = Enemy.states.HUNTING

      if distance < enemy.attack_range then
        enemy.state = Enemy.states.ATTACKING
      end
    else
      enemy.state = Enemy.states.IDLE
    end
  end
end


function Enemy.wound(enemy, hero, level)
  Entity.wound(enemy, hero)

  if hero.health <= 0 then
    Level.game_over(level)
  end
end


return Enemy
