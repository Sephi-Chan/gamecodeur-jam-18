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
local layerClass = require("layers")



--Layers
-----
layers1 = love.graphics.newImage("images/layers/1.png")
layers2 = love.graphics.newImage("images/layers/2.png")
layers3 = love.graphics.newImage("images/layers/3.png")
layers4 = love.graphics.newImage("images/layers/4.png")
layers5 = love.graphics.newImage("images/layers/5.png")
layers6 = love.graphics.newImage("images/layers/6.png")






function love.load()
  width = love.graphics.getWidth()
  height =love.graphics.getHeight()
  
  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  hero = Hero.new(200, 200)
  Enemy.new(300, 200, { name = "foo" })
  Enemy.new(400, 400, { name = "bar" })
  
  
  
  local la1 = layerClass.new(0,0,layers1,0.416,0.45,6)
  local la2 = layerClass.new(0,0,layers2,0.416,0.45,5)
  local la3 = layerClass.new(0,0,layers3,0.416,0.45,4)
  local la4 = layerClass.new(0,0,layers4,0.416,0.45,3)
  local la5 = layerClass.new(0,0,layers5,0.416,0.45,2)
  local la6 = layerClass.new(0,0,layers6,0.416,0.45,1)
  
  EntityManager  = {}
  function EntityManager.draw()
      Entity.draw(Entity.sortByY(Entity.entities()))
  end
  
  camera:MustFollow(hero)
  camera:AddToObjects(1,EntityManager)
  camera:AddToObjects(6,la1)
  camera:AddToObjects(5,la2)
  camera:AddToObjects(4,la3)
  camera:AddToObjects(3,la4)
  camera:AddToObjects(2,la5)
  camera:AddToObjects(1,la6)
  
  listLayers = {}
  table.insert(listLayers,la1)
  table.insert(listLayers,la2)
  table.insert(listLayers,la3)
  table.insert(listLayers,la4)
  table.insert(listLayers,la5)
  table.insert(listLayers,la6)
  
end


function love.update(delta)
  Animation.animate_entities(Entity.entities(), delta)
  --Hero.update(hero, Entity.enemies(), delta)
  Entity.update(hero, Entity.enemies(), delta)
  camera:update(delta)
  for _, layer in ipairs(listLayers) do
    layer:Update(delta,camera)
  end
  
  
end


function love.draw()

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
