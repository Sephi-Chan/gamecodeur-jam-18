local Hero = {
  BULLET_TIME_DURATION           = 5,
  DASH_DELAY_BETWEEN_KEY_PRESSES = 0.3,
  DASH_MAX_DISTANCE              = 250,

  states = {
    DASHING = "dashing"
  }
}
local Utils = require("lib.utils")


function Hero.update(hero, level, delta)
  update_bullet_time_timer(hero, delta)
  update_dash_timer(hero, delta)
  Entity.update_stagger_timer(hero, delta)

  if hero.state == Entity.states.STAGGERED then
    Entity.staggered(hero)

  elseif hero.state == Hero.states.DASHING then

  elseif hero.state == Entity.states.ATTACKING then
    Hero.attack(hero, level.enemies, delta)

  elseif hero.state == Entity.states.IDLE then
    Hero.move(hero, level.enemies, level, delta)
  end
end


function Hero.move(hero, enemies, level, delta)
  hero.vy = 0
  hero.vx = 0

  if love.keyboard.isDown("z") and not love.keyboard.isDown("s") then
    hero.vy = Entity.UP
  elseif love.keyboard.isDown("s") and not love.keyboard.isDown("z") then
    hero.vy = Entity.DOWN
  end

  if love.keyboard.isDown("q") and not love.keyboard.isDown("d") then
    hero.vx = Entity.LEFT
    hero.animation.flip = true
  elseif love.keyboard.isDown("d") and not love.keyboard.isDown("q") then
    hero.vx = Entity.RIGHT
    hero.animation.flip = false
  end

  if hero.vx == 0 and hero.vy == 0 then
    Animation.replace(hero, "idle")
  else
    Animation.replace(hero, "walk")
  end

  if hero.vx ~= 0 or hero.vy ~= 0 then
    hero.x = hero.x + (hero.velocity_x * delta * hero.vx)
    hero.x = Utils.clamp(hero.x, 50, level.width - 50)
    Entity.resolve_horizontal_collision(hero, enemies)

    hero.y = Utils.clamp(hero.y + (hero.velocity_y * delta * hero.vy), level.min_y, level.max_y)
    Entity.resolve_vertical_collision(hero, enemies)
  end
end


function Hero.start_attack(hero)
  if hero.state == Entity.states.STAGGERED then return end
  hero.state = Entity.states.ATTACKING
end


function Hero.attack(hero, enemies, delta)
  local hero_frame = hero.animations[hero.animation.name].frames[hero.animation.frame]
  local last_frame = #hero.animations[hero.animation.name].frames

  if hero_frame.hitboxes then
    local has_hit     = false
    local real_hitbox = Box.coordinates(hero, hero_frame.hitboxes[1])

    for _, enemy in pairs(enemies) do
      local enemy_frame   = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
      local enemy_movebox = enemy_frame.moveboxes[1]

      if hero.attack_targets[enemy.name] then
        -- wound an enemy only once per attack.

      elseif hero.y < enemy.y - enemy_movebox.height or enemy.y < hero.y - enemy_movebox.height then
        -- only hit the targets with around the same Y: hero is either too far or too near on the screen.

      else
        local enemy_real_hurtbox = Box.coordinates(enemy, enemy_frame.hurtboxes[1])

        if Box.collides(real_hitbox, enemy_real_hurtbox) then
          hero.attack_targets[enemy.name] = true
          Hero.wound(hero, enemy, level, enemies)
          has_hit = true
        end
      end
    end

    if hero.attack_sound_played == false then
      local sound = has_hit and "sword_hit" or "sword_miss"
      Soundbox.play_sound(sound, .5)
      hero.attack_sound_played = true
    end
  end

  Animation.replace(hero, "attack1")

  if hero.animation.frame == last_frame then
    hero.state               = Entity.states.IDLE
    hero.attack_targets      = {}
    hero.attack_sound_played = false
  end
end


function Hero.new(x, y)
  local sprite     = love.graphics.newImage("images/hero.png")
  local animations = Animation.load_json("metadata/hero.json")
  local hero       = Entity.new("Roger", sprite, {
    x          = x,
    y          = y,
    velocity_x = 220,
    velocity_y = 130,
    health     = 100,
    module     = Hero
  })

  hero.fury     = 100
  hero.max_fury = 100

  hero.dash_timer = 0

  for name, animation in pairs(animations) do
    Animation.attach(hero, Animation.new(hero.sprite, name, 0.5, animation.frames))
  end

  return hero
end


function Hero.wound(hero, enemy, level)
  Entity.wound(hero, enemy)
  Particulemanager.add_particule_effect(particule_manager, "blood", enemy)
  if enemy.health <= 0 then
    hero.fury = Utils.clamp(hero.fury + 15, 0, hero.max_fury)
    Level.remove_enemy(level, enemy)

  else
    hero.fury = Utils.clamp(hero.fury + 5, 0, hero.max_fury)
  end
end


function Hero.use_heal_power(hero)
  if hero.fury == hero.max_fury and hero.health < hero.max_health then
    Particulemanager.add_particule_effect(particule_manager, "heal", hero)
    hero.fury   = 0
    hero.health = Utils.clamp(hero.health + 50, 10, hero.max_health)
  end
end


function Hero.use_bullet_time_power(hero, level)
  if hero.fury == hero.max_fury then
    hero.fury              = 0
    hero.bullet_time       = true
    hero.bullet_time_timer = Hero.BULLET_TIME_DURATION
  end
end


function update_bullet_time_timer(hero, delta)
  if hero.bullet_time then
    camera.isShaking = true
    hero.bullet_time_timer = hero.bullet_time_timer - delta

    if hero.bullet_time_timer <= 0 then

      hero.bullet_time = false
    end
  end
  Shadermanager.update_bullet_time(shader_manager, hero, delta)
end


function update_dash_timer(hero, delta)
  hero.dash_timer = Utils.clamp(hero.dash_timer - delta, 0, 100)
end


function Hero.update_dash_controls(hero, level)
  if 0 < hero.dash_timer and hero.last_horizontal_movement == Entity.LEFT and love.keyboard.isDown("q") then
    start_dash(hero, level, Entity.LEFT)
  elseif 0 < hero.dash_timer and hero.last_horizontal_movement == Entity.RIGHT and love.keyboard.isDown("d") then
    start_dash(hero, level, Entity.RIGHT)
  end

  if love.keyboard.isDown("q") and not love.keyboard.isDown("d") then
    hero.last_horizontal_movement = Entity.LEFT
    hero.dash_timer               = Hero.DASH_DELAY_BETWEEN_KEY_PRESSES
  elseif love.keyboard.isDown("d") and not love.keyboard.isDown("q") then
    hero.last_horizontal_movement = Entity.RIGHT
    hero.dash_timer               = Hero.DASH_DELAY_BETWEEN_KEY_PRESSES
  end
end


function start_dash(hero, level, vx)
  local enemy, distance = Enemy.nearest(level.enemies, hero, vx)

  if enemy and distance <= Hero.DASH_MAX_DISTANCE then
    local hero_frame         = hero.animations[hero.animation.name].frames[hero.animation.frame]
    local hero_movebox       = hero_frame.moveboxes[1]
    local enemy_frame        = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
    local enemy_movebox      = enemy_frame.moveboxes[1]
    local enemy_real_movebox = Box.coordinates(enemy, enemy_movebox)

    Entity.stagger(enemy)

    hero.y          = enemy.y
    hero.dash_timer = 0
    hero.state      = Hero.states.DASHING

    if vx == Entity.LEFT then
      hero.x              = enemy_real_movebox.x - (hero_movebox.width + hero_movebox.x) - 10
      hero.vx             = Entity.LEFT
      hero.animation.flip = false

    else
      local enemy_movebox_x2 = enemy.x + (enemy.animation.flip and -enemy_movebox.x or enemy_movebox.x + enemy_movebox.width)
      hero.x              = enemy_movebox_x2 + hero_movebox.width + hero_movebox.x + 10
      hero.vx             = Entity.RIGHT
      hero.animation.flip = true
    end

    hero.x = Utils.clamp(hero.x, 50, level.width - 50)
    Entity.resolve_horizontal_collision(hero, level.enemies)
  end
end


return Hero
