local Hero = {}


function Hero.update(hero, enemies, delta)
  if hero.state == Entity.states.STAGGERED then
    Entity.staggered(hero)
    
  elseif hero.state == Entity.states.ATTACKING then
    Hero.attack(hero, enemies, delta)
    
  elseif hero.state == Entity.states.IDLE then
    Hero.move(hero, enemies, delta)
  end
end


function Hero.move(hero, enemies, delta)
  hero.vy = 0
  hero.vx = 0
  
  if love.keyboard.isDown("z") and not love.keyboard.isDown("s") then
    hero.vy = -1 -- up
  elseif love.keyboard.isDown("s") and not love.keyboard.isDown("z") then
    hero.vy = 1 -- down
  end
  
  if love.keyboard.isDown("q") and not love.keyboard.isDown("d") then
    hero.vx = -1 -- left
    hero.animation.flip = true
  elseif love.keyboard.isDown("d") and not love.keyboard.isDown("q") then
    hero.vx = 1 -- right
    hero.animation.flip = false
  end
  
  if hero.vx == 0 and hero.vy == 0 then
    Animation.replace(hero, "idle")
  else
    Animation.replace(hero, "walk")
  end
  
  if hero.vx ~= 0 or hero.vy ~= 0 then
    hero.x = hero.x + hero.velocity * delta * hero.vx
    Entity.resolve_horizontal_collision(hero, enemies)
    
    hero.y = hero.y + hero.velocity * delta * hero.vy
    Entity.resolve_vertical_collision(hero, enemies)
  end
end


function Hero.start_attack(hero)
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
          hero.module.wound(hero, enemy)
          has_hit = true
        end
      end
    end
    
    if hero.attack_sound_played == false then
      if has_hit then Soundbox.play_sound("sword_hit") else Soundbox.play_sound("sword_miss") end
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
    x        = x,
    y        = y,
    velocity = 120,
    module   = Hero
  })
  
  for name, animation in pairs(animations) do
    Animation.attach(hero, Animation.new(hero.sprite, name, .5, animation.frames))
  end

  return hero
end


function Hero.wound(hero, enemy)
  Entity.wound(hero, enemy)
  if enemy.health <= 0 then
    Entity._entities[enemy.name] = nil
  end
end


return Hero
