io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end


Animation = require("animation")
Entity    = require("entity")
Hero      = require("hero")
Enemy     = require("enemy")
Box       = require("box")
Camera    = require("camera")
Layer     = require("layers")
Soundbox  = require("soundbox")
Level     = require("level")
UI        = require("ui")
Shadermanager = require("shadermanager")
Particulemanager = require("particulemanager")



function love.load()
  math.randomseed(os.time())

  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  Soundbox.register_sound("sword_hit", "sounds/hit.wav")
  Soundbox.register_sound("sword_miss", "sounds/miss.wav")
  Soundbox.register_sound("hilltop_asylum", "sounds/spiky_whimsical-fantasy_hilltop-asylum.mp3")
  Soundbox.play_music("hilltop_asylum", 0.6)


  shader_manager = Shadermanager.initialize()
  particule_manager = Particulemanager.initialize()
  
  camera = Camera.initialize(love.graphics.getWidth(), love.graphics.getHeight())
  hero   = Hero.new(250, 450)
  level  = Level.one(camera, hero)
  
end


function love.update(delta)
  Animation.animate_entities(level.enemies, hero, delta)
  Entity.update(hero, level, delta)
  Level.trigger_waves(level, hero, camera)
  Camera.update(camera, delta)

  for _, layer in ipairs(level.layers) do
    Layer.update(layer, camera, delta)
  end
  Particulemanager.update(particule_manager, delta)
end


function love.draw()
  Shadermanager.set(shader_manager.active_shader)
  Shadermanager.send(shader_manager)
  Camera.draw(camera)
  
  Shadermanager.unset()
  UI.draw(hero, level.enemies)
  Particulemanager.draw(particule_manager)
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()

  elseif key == "space" then
    Hero.start_attack(hero)

  elseif key == "b" then
    Hero.use_bullet_time_power(hero, level)

  elseif key == "h" then
    Hero.use_heal_power(hero)
  elseif key == "p" then   
     Particulemanager.add_particule_effect(particule_manager, "heal", hero)
  end
end
