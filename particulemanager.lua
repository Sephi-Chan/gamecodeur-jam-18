local Particule_Manager = {}





function Particule_Manager.update(particule_manager, delta)
  local particule_effect_to_remove = {}
  for i=1, #particule_manager.effects_active do
    if particule_manager.effects_active[i].effect.timer >= particule_manager.effects_active[i].effect.duration then
      table.insert(particule_effect_to_remove, i)
    else
      local factor =  hero.bullet_time and particule_manager.BULLET_TIME_VELOCITY_FACTOR  or 1
      particule_manager.effects_active[i].effect.timer = particule_manager.effects_active[i].effect.timer +delta*factor
      particule_manager.effects_active[i].effect.system:update(delta*factor)
    end
  end

  Particule_Manager.remove_efficient(particule_manager.effects_active,particule_effect_to_remove )

end

function Particule_Manager.draw(particule_manager)
  love.graphics.setColor(1, 1, 1)
  for i=1, #particule_manager.effects_active do
    local position = { x =  particule_manager.effects_active[i].object_to_draw_on.x, y =particule_manager.effects_active[i].object_to_draw_on.y}
     love.graphics.draw(particule_manager.effects_active[i].effect.system, position.x -camera.x, position.y -camera.y)
  end


end


function Particule_Manager.add_particule_effect(particule_manager, particule_effect, object_to_draw_on, sprite, frame)
  local active_system = {}
  if particule_effect == "heal" then
    active_system.effect = Particule_Manager.create_new_health_particule()
  elseif particule_effect == "aoe" then
    active_system.effect =  Particule_Manager.create_aoe_particule()
  elseif particule_effect == "elf" then
    active_system.effect = Particule_Manager.create_elf_particule(sprite, frame)
  else
    active_system.effect = Particule_Manager.create_new_blood_particule()
  end


  active_system.object_to_draw_on = object_to_draw_on

  table.insert(particule_manager.effects_active, active_system)
end

function Particule_Manager.create_new_health_particule()
  local health_particule = {}
  health_particule.img = love.graphics.newImage("images/health_particule.png")
  health_particule.timer= 0
  health_particule.duration= 3

  health_particule.system = love.graphics.newParticleSystem(health_particule.img, 32)
  health_particule.system:setParticleLifetime(1, 2) -- Particles live at least 2s and at most 5s.
  health_particule.system:setEmissionArea( "normal", 20, 20, 0, false )
  health_particule.system:setPosition( 0, -20 )
  health_particule.system:setEmitterLifetime( 1 )
	health_particule.system:setEmissionRate(10)
	health_particule.system:setSizeVariation(1)

	health_particule.system:setLinearAcceleration(0, -40, 0, -40) -- Random movement in all directions.
  health_particule.system:setSizes(0.4)
	health_particule.system:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.



  return health_particule
end

function Particule_Manager.create_aoe_particule()
  local aoe_particule = {}
   aoe_particule.img = love.graphics.newImage("images/aoe_particule.png")
   aoe_particule.timer= 0
   aoe_particule.duration= 3

   aoe_particule.system = love.graphics.newParticleSystem(aoe_particule.img, 1)
   aoe_particule.system:setSizes(1.5)
   aoe_particule.system:setParticleLifetime(1,3)
   --aoe_particule.system:setPosition( 10, -20 )
   aoe_particule.system:setEmitterLifetime(1)
  -- aoe_particule.system:setEmissionArea( "normal", 0, 3, 0, false )
   aoe_particule.system:setEmissionRate(100)
   --aoe_particule.system:setRadialAcceleration(15,30)
   aoe_particule.system:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

  return aoe_particule
  
end

function Particule_Manager.create_elf_particule(sprite, frame)
    local elf_tp = {}
   --elf_tp.img = love.graphics.newImage(frame)
   elf_tp.timer= 0
   elf_tp.duration= 0.5
   
   x, y, w, h = frame:getViewport()
   local canvas = love.graphics.newCanvas(w, h)
   love.graphics.setCanvas(canvas)
   love.graphics.draw(sprite, frame,0,0)
   love.graphics.setCanvas()
   
   elf_tp.system = love.graphics.newParticleSystem(canvas, 1)
   elf_tp.system:setSizes(0.9)
   elf_tp.system:setParticleLifetime(1,1)
   --aoe_particule.system:setPosition( 10, -20 )
   elf_tp.system:setEmitterLifetime(1)
  -- aoe_particule.system:setEmissionArea( "normal", 0, 3, 0, false )
   elf_tp.system:setEmissionRate(100)
   --aoe_particule.system:setRadialAcceleration(15,30)
   elf_tp.system:setColors(25, 25, 255, 255, 25, 25, 255, 0) -- Fade to transparency.

  return elf_tp
  
  
  
end




function Particule_Manager.create_new_blood_particule()

   local blood_particule = {}
   blood_particule.img = love.graphics.newImage("images/blood_particule.png")
   blood_particule.timer= 0
   blood_particule.duration= 2

   blood_particule.system = love.graphics.newParticleSystem(blood_particule.img, 32)
   blood_particule.system:setSizes(0.5)
   blood_particule.system:setTangentialAcceleration(100,100)
   blood_particule.system:setDirection( math.rad(-50) )
   blood_particule.system:setSpeed(120,150)
   blood_particule.system:setLinearAcceleration(-5, 80, -5, 80)


   blood_particule.system:setParticleLifetime(1, 0.5)
   blood_particule.system:setPosition( 10, -20 )
   blood_particule.system:setEmitterLifetime( 1 )
   blood_particule.system:setEmissionArea( "normal", 3, 3, 0, false )
   --blood_particule.system:setLinearAcceleration(30, 25, 30, 25)
   blood_particule.system:setEmissionRate(7)
   blood_particule.system:setRadialAcceleration(15,30)
   blood_particule.system:setColors(255, 255, 255, 255, 0, 0, 0, 0) -- Fade to transparency.

  return blood_particule
end





function Particule_Manager.remove_efficient(table, table_remove)
local input = table
local remove = table_remove

local n=#input
local r=#remove

for i=1,r do
  input[remove[i]]=nil
end

local j=0
for i=1,n do
  if input[i]~=nil then
    j=j+1
    input[j]=input[i]
  end
end
for i=j+1,n do
  input[i]=nil
end

end


function Particule_Manager:initialize()
  local new_particule_manager = {}
  new_particule_manager.BULLET_TIME_VELOCITY_FACTOR = 0.25
  new_particule_manager.effects_active = {}
  return new_particule_manager
end








return Particule_Manager