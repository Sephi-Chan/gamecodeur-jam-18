local Enemy = {
  GROUP                       = "enemy",
  VELOCITY                    = 120,
  FRAME_DURATION              = 0.5,
  BULLET_TIME_VELOCITY_FACTOR = 0.25,
  BULLET_TIME_FRAME_DURATION  = 1.5,
  AGGRO_RADIUS                = 200,
  ATTACK_RANGE                = 50,
  RECOVERING_DURATION         = 1,
  STAGGER_DURATION            = 0.4,

  states = {
    IDLE       = "idle",
    STAGGERED  = "staggered",
    HUNTING    = "hunting",
    ATTACKING  = "attacking",
    RECOVERING = "recovering",
  },

  types = {
    elf = {
      sprites = {
        green  = Entity.sprites.elf_green,
        purple = Entity.sprites.elf_purple,
      },
      animations = Entity.animations.elf
    }
  }
}
local UUID = require("lib.uuid")
local Utils = require("lib.utils")


function Enemy.new(x, y, options)
  local options    = options or {}
  local sprite     = Enemy.types.elf.sprites[options.skin]
  local animations = Enemy.types.elf.animations
  local id         = options.name or UUID.uuid("enemy")
  local enemy      = Entity.new(id, sprite, {
    x          = x,
    y          = y,
    state      = Enemy.states.IDLE,
    group      = Enemy.GROUP,
    velocity_x = Enemy.VELOCITY,
    velocity_y = Enemy.VELOCITY * 0.6,
    module     = Enemy
  })

  for name, animation in pairs(animations) do
    Animation.attach(enemy, Animation.new(enemy.sprite, name, Enemy.FRAME_DURATION, animation.frames))
  end

  enemy.aggro_radius = Enemy.AGGRO_RADIUS
  enemy.attack_range = Enemy.ATTACK_RANGE

  enemy.recovering_timer = 0

  return enemy
end



function Enemy.update(enemy, hero, delta)
  Entity.update_stagger_timer(enemy, delta)
  update_recovering_timer(enemy, delta)
  enemy.module.think(enemy, hero)

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
  -- Face hero.
  local angle          = Utils.angle(enemy.x, enemy.y, hero.x, hero.y)
  local velocity_x     = math.cos(angle) * enemy.velocity_x
  enemy.animation.flip = velocity_x < 0

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
  local angle  = Utils.angle(enemy.x, enemy.y, hero.x, hero.y)
  local factor = hero.bullet_time and Enemy.BULLET_TIME_VELOCITY_FACTOR or 1
  local velocity_x = math.cos(angle) * enemy.velocity_x * factor * delta
  local velocity_y = math.sin(angle) * enemy.velocity_y * factor * delta

  enemy.animation.flip = velocity_x < 0
  enemy.vx = velocity_x < 0 and Entity.LEFT or Entity.RIGHT
  enemy.vy = velocity_y < 0 and Entity.UP or Entity.DOWN

  enemy.x = enemy.x + velocity_x
  Entity.resolve_horizontal_collision(enemy, { hero })

  enemy.y = enemy.y + velocity_y
  Entity.resolve_vertical_collision(enemy, { hero })

  Animation.replace(enemy, "walk")
end

function Enemy.start_recovering(enemy)
  enemy.state            = Enemy.states.RECOVERING
  enemy.recovering_timer = Enemy.RECOVERING_DURATION
end


function Enemy.recover(enemy)
  Animation.replace(enemy, "idle")

  if enemy.recovering_timer == 0 then
    enemy.state = Enemy.states.IDLE
  end
end


function update_recovering_timer(enemy, delta)
  enemy.recovering_timer = Utils.clamp(enemy.recovering_timer - delta, 0, 100)
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

      if distance < enemy.attack_range and math.abs( hero.y - enemy.y)<=10 then
        enemy.state = Enemy.states.ATTACKING
      end
    else
      enemy.state = Enemy.states.IDLE
    end
  end
end


function Enemy.wound(enemy, hero, level)
  Entity.wound(enemy, hero)
  Particulemanager.add_particule_effect(particule_manager, "blood", hero)
  camera.isShaking = true
  if hero.health <= 0 then
    Level.game_over(level)
  end
end


function Enemy.nearest(enemies, hero, vx)
  local min_distance = 999999
  local nearest      = nil

  for _, enemy in pairs(enemies) do
    if vx == Entity.LEFT and enemy.x < hero.x then
      local distance = Utils.dist(hero.x, hero.y, enemy.x, enemy.y)

      if distance < min_distance then
        min_distance = distance
        nearest      = enemy
      end
    elseif vx == Entity.RIGHT and hero.x < enemy.x then
      local distance = Utils.dist(hero.x, hero.y, enemy.x, enemy.y)

      if distance < min_distance then
        min_distance = distance
        nearest      = enemy
      end
    end
  end

  return nearest, min_distance
end



return Enemy
