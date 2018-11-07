local Enemy = {}
local UUID = require("lib.uuid")


function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end 
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

STATE = {}
STATE.IDLE = "idle"
STATE.HUNTING = "hunting"
STATE.FIGHTING = "fighting"

function Enemy.new(x, y, options)
  local sprite     = love.graphics.newImage("images/hero.png")
  local animations = Animation.load_json("metadata/hero.json")
  local id         = options.name or UUID.uuid("enemy")
  local enemy      = Entity.new(id, sprite, { x = x, y = y, group = "enemy" })
  
  
  
  for name, animation in pairs(animations) do
    Animation.attach(enemy, Animation.new(hero.sprite, name, .5, animation.frames))
  end
  
  enemy.distanceDetection = 150
  enemy.distanceHit = 40
  enemy.state = STATE.IDLE
  enemy.speed = 10
  return enemy
end



function Enemy.update(hero, enemy,delta)
  Enemy.isCloseToHero(hero, enemy)
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
  local last_frame = #enemy.animations[enemy.animation.name].frames

  if enemy_frame.hitboxes then
    local real_hitbox = Box.coordinates(enemy, enemy_frame.hitboxes[1])

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
  

function Enemy.move(hero, enemy, delta )

  local angle = math.angle( enemy.x, enemy.y, hero.x, hero.y )
  local velocity = {x=0,y=0}
  velocity.x = math.cos(angle) *enemy.speed *delta
  velocity.y = math.sin(angle) *enemy.speed *delta
  enemy.x = enemy.x + velocity.x 
  enemy.y = enemy.y + velocity.y
  
  
  if velocity.x < 0 then
    enemy.animation.flip = true
  else
    enemy.animation.flip = false
  end
  
  Animation.replace(enemy, "walk")
  
end
  
function Enemy.isCloseToHero(hero, enemy)
  if math.dist(hero.x, hero.y, enemy.x, enemy.y) < enemy.distanceDetection then
    enemy.state = STATE.HUNTING
    --print(enemy.name.." is hunting")
    if  math.dist(hero.x, hero.y, enemy.x, enemy.y) < enemy.distanceHit then
      enemy.state = STATE.FIGHTING
    end
  else
    enemy.state = STATE.IDLE
  end
end
  

return Enemy