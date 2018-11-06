local Hero = {}


function Hero.update(hero, enemies, delta)
  Hero.attack(hero, enemies, delta)
  Hero.move(hero, enemies, delta)
end


function Hero.move(hero, enemies, delta)
  if hero.attacking then return end
  
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
  
  hero.x = hero.x + hero.velocity * delta * hero.vx
  Hero.resolve_horizontal_collision(hero, enemies)
  
  hero.y = hero.y + hero.velocity * delta * hero.vy
  Hero.resolve_vertical_collision(hero, enemies)
end


function Hero.start_attack(hero)
  hero.attacking = true
end


function Hero.attack(hero, enemies, delta)
  if not hero.attacking then return end

  local hero_frame = hero.animations[hero.animation.name].frames[hero.animation.frame]
  local last_frame = #hero.animations[hero.animation.name].frames

  if hero_frame.hitboxes then
    local real_hitbox = Box.coordinates(hero, hero_frame.hitboxes[1])

    for _, enemy in pairs(enemies) do
      if not hero.attack_targets[enemy.name] then -- wound an enemy only once per attack.
        local enemy_frame        = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
        local enemy_real_hurtbox = Box.coordinates(enemy, enemy_frame.hurtboxes[1])

        if Box.collides(real_hitbox, enemy_real_hurtbox) then
          hero.attack_targets[enemy.name] = true
          Entity.wound(hero, enemy)
        end
      end
    end
  end
  
  Animation.replace(hero, "attack1")
  
  if hero.animation.frame == last_frame then
    hero.attacking      = false
    hero.attack_targets = {}
  end
end


function Hero.resolve_horizontal_collision(hero, enemies)
  local hero_frame        = hero.animations[hero.animation.name].frames[hero.animation.frame]
  local hero_movebox      = hero_frame.moveboxes[1]
  local hero_real_movebox = Box.coordinates(hero, hero_movebox)
  
  if hero.vx ~= 0 or hero.vy ~= 0 then -- if moving...
    for _, enemy in pairs(enemies) do 
      local enemy_frame        = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
      local enemy_real_movebox = Box.coordinates(enemy, enemy_frame.moveboxes[1])

      if Box.collides(hero_real_movebox, enemy_real_movebox) then
        if hero.vx == 1 then
          hero.x = enemy_real_movebox.x - (hero_movebox.width + hero_movebox.x) - 1
        elseif hero.vx == -1 then
          hero.x = enemy.x + hero_movebox.width + 1
        end
      end
    end
  end
end


function Hero.resolve_vertical_collision(hero, enemies)
  local hero_frame        = hero.animations[hero.animation.name].frames[hero.animation.frame]
  local hero_movebox      = hero_frame.moveboxes[1]
  local hero_real_movebox = Box.coordinates(hero, hero_movebox)
  
  if hero.vx ~= 0 or hero.vy ~= 0 then -- if moving...
    for _, enemy in pairs(enemies) do
      local enemy_frame        = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
      local enemy_real_movebox = Box.coordinates(enemy, enemy_frame.moveboxes[1])
      
      if Box.collides(hero_real_movebox, enemy_real_movebox) then
        if hero.vy == 1 then
          hero.y = enemy.y - enemy_real_movebox.height - 1
        elseif hero.vy == -1 then
          hero.y = enemy.y + hero_movebox.height + 1
        end
      end
    end
  end
end


function Hero.new(x, y)  
  local sprite     = love.graphics.newImage("images/hero.png")
  local animations = Animation.load_json("metadata/hero.json")
  local hero       = Entity.new("hero", sprite, { x = x, y = y, velocity = 120 })
  
  for name, animation in pairs(animations) do
    Animation.attach(hero, Animation.new(hero.sprite, name, .5, animation.frames))
  end

  return hero
end


return Hero
