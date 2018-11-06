io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end


function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end


Animation = require("animation")
Entity    = require("entity")
Hero      = require("hero")
Enemy     = require("enemy")
Box       = require("box")

local cameraClass = require("camera")
camera = cameraClass.new()

--Layers
-----
layers1 = {}
layers1.img = love.graphics.newImage("images/layers/1.png")
layers2 = {}
layers2.img = love.graphics.newImage("images/layers/2.png")
layers3 = {}
layers3.img = love.graphics.newImage("images/layers/3.png")
layers4 = {}
layers4.img = love.graphics.newImage("images/layers/4.png")
layers5 = love.graphics.newImage("images/layers/5.png")
layers6 = love.graphics.newImage("images/layers/6.png")


function layers1.draw()
  love.graphics.draw(layers1.img,0,0,0,0.41,0.45)
end
function layers2.draw()
  love.graphics.draw(layers2.img,0,0,0,0.41,0.45)
end
function layers3.draw()
  love.graphics.draw(layers3.img,0,0,0,0.41,0.45)
end

function layers4.draw()
  love.graphics.draw(layers4.img,0,0,0,0.41,0.45)
end




function love.load()
  width = love.graphics.getWidth()
  height =love.graphics.getHeight()
  
  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  hero = Hero.new(200, 200)
  Enemy.new(300, 200, { name = "foo" })
  
  camera:MustFollow(hero)
  camera:AddToLayers(1,Entity)
  camera:AddToLayers(5,layers1)
  camera:AddToLayers(4,layers2)
  camera:AddToLayers(3,layers3)
  --camera:AddToLayers(2,layers4)
  
  -----
  
  
  
  
  
  
  
  
  
  
  
end


function love.update(delta)
  Animation.animate_entities(Entity.entities(), delta)
  Hero.update(hero, Entity.enemies(), delta)
  camera:update(delta)
  
  
end


function love.draw()
  Entity.draw(Entity.sortByY(Entity.entities()))
  camera:Draw()
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
