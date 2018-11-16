local Victory = {
  width      = love.graphics.getWidth(),
  title_font = love.graphics.newFont(48),
  font       = love.graphics.newFont(13)
}

function Victory.load(level)
end


function Victory.update(delta)
end


function Victory.draw()
  local text = "Félicitations !"
  love.graphics.setFont(Victory.title_font)
  love.graphics.printf(text, 0, 100, Victory.width, "center")

  local text = "Merci d'avoir joué !!"
  love.graphics.setFont(Victory.font)
  love.graphics.printf(text, 0, 180, Victory.width, "center")

  local text = "-- Appuyez sur ECHAP pour retourner au menu --"
  love.graphics.setFont(Victory.font)
  love.graphics.printf(text, 0, 240, Victory.width, "center")
end


function Victory.keypressed(key)
  if key == "escape" then
    change_scene(Scenes.Menu)
  end
end


function Victory.unload()
end


return Victory