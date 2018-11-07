local Enemy = {}
local UUID = require("lib.uuid")
local Utils = require("lib.utils")
local STATE = {
  IDLE     = "idle",
  HUNTING  = "hunting",
  FIGHTING = "fighting"
}


function Enemy.new(x, y, options)
  local sprite     = love.graphics.newImage("images/hero.png")
  local animations = Animation.load_json("metadata/hero.json")
  local id         = options.name or UUID.uuid("enemy")
  local enemy      = Entity.new(id, sprite, {
    x        = x,
    y        = y,
    group    = "enemy",
    velocity = 60
  })
    
  for name, animation in pairs(animations) do
    Animation.attach(enemy, Animation.new(enemy.sprite, name, .5, animation.frames))
  end
  
  enemy.state        = STATE.IDLE
  enemy.aggro_radius = 150
  enemy.attack_range = 40

  return enemy
end



function Enemy.update(hero, enemy,delta)
  Enemy.think(hero, enemy)

  if enemy.state == STATE.HUNTING then
    Enemy.move(hero, enemy, delta)

  elseif enemy.state == STATE.FIGHTING then
    Enemy.attack(hero, enemy, delta)

  elseif enemy.state == STATE.IDLE then
    Animation.replace(enemy, "idle")
  end
end

  
function Enemy.attack(hero, enemy, delta)
  local enemy_frame = enemy.animations[enemy.animation.name].frames[enemy.animation.frame]
  local last_frame  = #enemy.animations[enemy.animation.name].frames

  if enemy_frame.hitboxes then
    local real_hitbox  = Box.coordinates(enemy, enemy_frame.hitboxes[1])
    local hero_frame   = hero.animations[hero.animation.name].frames[hero.animation.frame]
    local hero_movebox = hero_frame.moveboxes[1]

    if enemy.attack_targets[hero.name] then

    elseif enemy.y < hero.y - hero_movebox.height then 

    elseif hero.y < enemy.y - hero_movebox.height then

    else
      local hero_real_hurtbox = Box.coordinates(hero, hero_frame.hurtboxes[1])

      if Box.collides(real_hitbox, hero_real_hurtbox) then
        enemy.attack_targets[hero.name] = true
        Entity.wound(enemy, hero)
      end
    end
  end
  
  Animation.replace(enemy, "attack1")
  
  if enemy.animation.frame == last_frame then
    enemy.attacking      = false
    enemy.attack_targets = {}
  end
end  
  

function Enemy.move(hero, enemy, delta)
  local angle = Utils.angle( enemy.x, enemy.y, hero.x, hero.y)
  local velocity_x = math.cos(angle) * enemy.velocity * delta
  local velocity_y = math.sin(angle) * enemy.velocity * delta

  enemy.x = enemy.x + velocity_x 
  enemy.y = enemy.y + velocity_y
  enemy.animation.flip = velocity_x < 0
  
  Animation.replace(enemy, "walk")
end

  
function Enemy.think(hero, enemy)
  local distance =  Utils.dist(hero.x, hero.y, enemy.x, enemy.y)

  if distance < enemy.aggro_radius then
    enemy.state = STATE.HUNTING

    if distance < enemy.attack_range then
      enemy.state = STATE.FIGHTING
    end
  else
    enemy.state = STATE.IDLE
  end
end
  

return Enemy