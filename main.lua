io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end


Animation = require("animation")
Entity    = require("entity")
Hero      = require("hero")
Enemy     = require("enemy")
Box       = require("box")


function love.load()
  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  hero = Hero.new(200, 200)
  Enemy.new(300, 200, { name = "foo" })
end


function love.update(delta)
  Animation.animate_entities(Entity.entities(), delta)
  Hero.update(hero, Entity.enemies(), delta)
end


function love.draw()
  Entity.draw(Entity.sortByY(Entity.entities()))
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
