local Enemy = {}
local UUID = require("lib.uuid")


function Enemy.new(x, y, options)
  local sprite     = love.graphics.newImage("images/hero.png")
  local animations = Animation.load_json("metadata/hero.json")
  local id         = options.name or UUID.uuid("enemy")
  local enemy      = Entity.new(id, sprite, { x = 300, y = 200, group = "enemy" })
  
  Animation.attach(enemy, Animation.new(enemy.sprite, "idle", .5, animations["idle"].frames))
  
  return enemy
end


return Enemy