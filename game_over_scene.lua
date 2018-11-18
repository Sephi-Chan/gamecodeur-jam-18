local GameOver = {
  width      = love.graphics.getWidth(),
  title_font = love.graphics.newFont(48),
  font       = love.graphics.newFont(13)
}

function GameOver.load(level)
end


function GameOver.update(delta)
end


function GameOver.draw()
  local text = "Game over"
  love.graphics.setFont(GameOver.title_font)
  love.graphics.printf(text, 0, 100, GameOver.width, "center")

  local text = "L'archidruide et ses sbires corrompus ont eu raison de vous.\n\nVous étiez le dernier espoir des habitants de ces lieux, mais vous avez échoué..."
  love.graphics.setFont(GameOver.font)
  love.graphics.printf(text, 0, 180, GameOver.width, "center")

  local text = "Appuyez sur ECHAP pour retourner au menu."
  love.graphics.setFont(GameOver.font)
  love.graphics.printf(text, 0, 270, GameOver.width, "center")
end


function GameOver.keypressed(key)
  if key == "escape" then
    change_scene(Scenes.Menu)
  end
end


function GameOver.unload()
end


return GameOver