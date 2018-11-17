io.stdout:setvbuf('no')
if arg[#arg] == "-debug" then require("mobdebug").start() end


Animation = require("animation")
Entity    = require("entity")
Hero      = require("hero")
Enemy     = require("enemy")
Boss      = require("boss")
Box       = require("box")
Camera    = require("camera")
Layer     = require("layers")
Soundbox  = require("soundbox")
Level     = require("level")
UI        = require("ui")
Shadermanager    = require("shadermanager")
Particulemanager = require("particulemanager")

Scenes = {
  Menu     = require("menu_scene"),
  Game     = require("game_scene"),
  Victory  = require("victory_scene"),
  GameOver = require("game_over_scene"),
}


function love.load()
  math.randomseed(os.time())

  love.mouse.setVisible(false)
  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.graphics.setLineWidth(1)

  Soundbox.register_sound("sword_hit", "sounds/hit.wav")
  Soundbox.register_sound("sword_miss", "sounds/miss.wav")
  Soundbox.register_sound("hilltop_asylum", "sounds/spiky_whimsical-fantasy_hilltop-asylum.mp3")

  change_scene(Scenes.Menu)
end


function love.update(delta)
  scene.update(delta)
end


function love.draw()
  scene.draw()
  _show_dump(10, 60)
end


function love.keypressed(key)
  scene.keypressed(key)
end


_dumped_values = {}
function _track(key, string)
  _dumped_values[key] = tostring(string)
end


function _show_dump(x, y)
  love.graphics.setColor(1, 1, 1)
  local i = 0
  for key, value in pairs(_dumped_values) do
    i = i + 1
    love.graphics.print(key .. " : " .. value, x, y + 15 * i)
  end
end


function change_scene(scene_module, args)
  if scene then scene.unload(scene_module) end
  scene = scene_module
  scene_module.load(unpack(args or {}))
end