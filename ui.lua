local UI = {
  health_color           = { 200/255, 0, 0 },
  health_color_highlight = { 2555/255, 30/255, 0 },
  fury_color             = { 1, 80/255, 0 },
  fury_color_highlight   = { 1, 100/255, 0 }
}
local Utils = require("lib.utils")


function UI.draw(hero, enemies)
  local health_ratio = hero.health / hero.max_health
  local fury_ratio   = hero.fury / hero.max_fury

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, 800, 50)

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Roger", 10, 10)

  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", 120, 10, 201, 13)
  love.graphics.print("Santé", 70, 10-2)
  if 0 < health_ratio then
    love.graphics.setColor(UI.health_color)
    love.graphics.rectangle("fill", 120, 10, 200 * health_ratio, 12)
    love.graphics.setColor(UI.health_color_highlight)
    love.graphics.rectangle("fill", 121, 11, 200 * health_ratio - 2, 3)
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", 120, 30, 201, 13)
  love.graphics.print("Fureur", 70, 30-2)
  if 0 < fury_ratio then
    love.graphics.setColor(UI.fury_color)
    love.graphics.rectangle("fill", 120, 30, 200 * fury_ratio, 12)
    love.graphics.setColor(UI.fury_color_highlight)
    love.graphics.rectangle("fill", 121, 31, 200 * fury_ratio - 2, 3)
  end

  love.graphics.setColor(1, 1, 1)
  local enemies_count = Utils.count(enemies)

  if 1 == enemies_count then
    love.graphics.print("Il reste encore un ennemi en vie !", 400, 10)
  elseif 0 < enemies_count then
    love.graphics.print(enemies_count .. " ennemis encore en vie.", 400, 10)
  end
end


return UI