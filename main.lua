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


function love.load()
  math.randomseed(os.time())

  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  Soundbox.register_sound("sword_hit", "sounds/hit.wav")
  Soundbox.register_sound("sword_miss", "sounds/miss.wav")
  Soundbox.register_sound("hilltop_asylum", "sounds/spiky_whimsical-fantasy_hilltop-asylum.mp3")
  Soundbox.play_music("hilltop_asylum", 0.6)

  camera = Camera.initialize(love.graphics.getWidth(), love.graphics.getHeight())
  hero   = Hero.new(250, 450)
  level  = Level.one(camera, hero)
end


function love.update(delta)
  enemies = Entity.enemies()

  Animation.animate_entities(Entity.entities(), delta)
  Entity.update(hero, enemies, level, delta)
  Level.trigger_waves(level, hero, camera)
  Camera.update(camera, delta)

  for _, layer in ipairs(level.layers) do
    Layer.update(layer, camera, delta)
  end
end


function love.draw()
  Camera.draw(camera)
  UI.draw(hero, enemies)
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()

  elseif key == "space" then
    Hero.start_attack(hero)

  elseif key == "r" then
    love.load()
  end
end
