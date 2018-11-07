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


function love.load()  
  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  camera = Camera.initialize(love.graphics.getWidth(), love.graphics.getHeight())
  hero   = Hero.new(400, 200)
  foo    = Enemy.new(200, 200, { name = "foo" })
  foo    = Enemy.new(600, 200, { name = "bar" })

  Soundbox.register_sound("sword_hit", "sounds/hit.wav")
  Soundbox.register_sound("sword_miss", "sounds/miss.wav")
  
  layers = {
    Layer.new(0, 0, love.graphics.newImage("images/layers/1.png"), 0.416, 0.45, 6),
    Layer.new(0, 0, love.graphics.newImage("images/layers/2.png"), 0.416, 0.45, 5),
    Layer.new(0, 0, love.graphics.newImage("images/layers/3.png"), 0.416, 0.45, 4),
    Layer.new(0, 0, love.graphics.newImage("images/layers/4.png"), 0.416, 0.45, 3),
    Layer.new(0, 0, love.graphics.newImage("images/layers/5.png"), 0.416, 0.45, 2),
    Layer.new(0, 0, love.graphics.newImage("images/layers/6.png"), 0.416, 0.45, 1)
  }
  
  Camera.follow(camera, hero)
  Camera.attach(camera, 1, function() Entity.draw(Entity.sortByY(Entity.entities())) end)
  Camera.attach(camera, 5, layers[2])
  Camera.attach(camera, 4, layers[3])
  Camera.attach(camera, 3, layers[4])
  Camera.attach(camera, 2, layers[5])
  Camera.attach(camera, 6, layers[1])
  Camera.attach(camera, 1, layers[6])
end


function love.update(delta)
  Animation.animate_entities(Entity.entities(), delta)
  Entity.update(hero, Entity.enemies(), delta)
  Camera.update(camera, delta)

  for _, layer in ipairs(layers) do
    Layer.update(layer, camera, delta)
  end
end


function love.draw()
  Camera.draw(camera)
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
