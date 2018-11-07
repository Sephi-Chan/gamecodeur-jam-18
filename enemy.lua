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



function Enemy.update(pHero, pEnemy,delta)
  Enemy.isCloseToHero(pHero, pEnemy)
  if pEnemy.state == STATE.HUNTING then
    Enemy.move(pHero, pEnemy, delta)
  elseif pEnemy.state == STATE.FIGHTING then
    Enemy.attack(pHero, pEnemy, delta)
  elseif pEnemy.state == STATE.IDLE then
    Animation.replace(pEnemy, "idle")
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
  

function Enemy.move(pHero, pEnemy, delta )

  local angle = math.angle( pEnemy.x, pEnemy.y, pHero.x, pHero.y )
  local velocity = {x=0,y=0}
  velocity.x = math.cos(angle) *pEnemy.speed *delta
  velocity.y = math.sin(angle) *pEnemy.speed *delta
  pEnemy.x = pEnemy.x + velocity.x 
  pEnemy.y = pEnemy.y + velocity.y
  
  
  if velocity.x < 0 then
    pEnemy.animation.flip = true
  else
    pEnemy.animation.flip = false
  end
  
  Animation.replace(pEnemy, "walk")
  
end
  
function Enemy.isCloseToHero(pHero, pEnemy)
  if math.dist(pHero.x, pHero.y, pEnemy.x, pEnemy.y) < pEnemy.distanceDetection then
    pEnemy.state = STATE.HUNTING
    --print(pEnemy.name.." is hunting")
    if  math.dist(pHero.x, pHero.y, pEnemy.x, pEnemy.y) < pEnemy.distanceHit then
      pEnemy.state = STATE.FIGHTING
    end
  else
    pEnemy.state = STATE.IDLE
  end
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


return Enemy