local UI = {
  health_color           = { 200/255, 0, 0 },
  health_color_highlight = { 2555/255, 30/255, 0 },
  fury_color             = { 1, 80/255, 0 },
  fury_color_highlight   = { 1, 100/255, 0 },
  heal_color             = { 40/255, 150/255, 30/255 },
  bullet_time_color      = { 100/255, 210/255, 240/255 },
  disabled_power_color   = { 0.5, 0.5, 0.5 }
}
local Utils = require("lib.utils")


function UI.draw(hero, level)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, 800, 50)

  draw_bars(hero, 8, 7)
  draw_powers(hero, 230, 7)
  print_mission(level, 400, 7)
end


local BAR_WIDTH   = 150
local LABEL_WIDTH = 50
function draw_bars(hero, x, y)
  local health_ratio = hero.health / hero.max_health
  local fury_ratio   = hero.fury / hero.max_fury

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Santé", x, y - 2)
  draw_bar(x + LABEL_WIDTH, y, BAR_WIDTH + 1, 13, health_ratio, UI.health_color, UI.health_color_highlight)

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Fureur", x, y + 20 - 2)
  draw_bar(x + LABEL_WIDTH,  y + 20, BAR_WIDTH + 1, 13, fury_ratio, UI.fury_color, UI.fury_color_highlight)
end


local POWER_SIDE = 36
function draw_powers(hero, x, y)
  local power_2_x = x + POWER_SIDE + 10
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", x, y, POWER_SIDE, POWER_SIDE)
  love.graphics.rectangle("line", power_2_x, y, POWER_SIDE, POWER_SIDE)

  if hero.fury == hero.max_fury then -- show colored buttons for heal and bullet time.
    love.graphics.setColor(UI.heal_color)
    love.graphics.rectangle("fill", x, y, POWER_SIDE - 1, POWER_SIDE - 1)

    love.graphics.setColor(UI.bullet_time_color)
    love.graphics.rectangle("fill", power_2_x, y, POWER_SIDE - 1, POWER_SIDE - 1)

  else -- show disabled buttons.
    love.graphics.setColor(UI.disabled_power_color)
    love.graphics.rectangle("fill", x, y, POWER_SIDE - 1, POWER_SIDE - 1)
    love.graphics.rectangle("fill", power_2_x, y, POWER_SIDE - 1, POWER_SIDE - 1)
  end

  -- show the keyboard shortcut for powers.
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("H", x + POWER_SIDE/2 - 5, y + POWER_SIDE/2 - 7)
  love.graphics.print("B", power_2_x + POWER_SIDE/2 - 5, y + POWER_SIDE/2 - 7)

  -- show the bullet time is active.
  if hero.bullet_time then
    love.graphics.setColor(UI.bullet_time_color)
    love.graphics.circle("fill", power_2_x + POWER_SIDE/2, y + 5, 3)
  end
end


function print_mission(level, x, y)
  local boss = Level.boss(level)

  if boss then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("BOSS", x, y - 2)
    local health_ratio = boss.health / boss.max_health
    draw_bar(x + LABEL_WIDTH, y, BAR_WIDTH + 1, 13, health_ratio, UI.health_color, UI.health_color_highlight)

  else
    love.graphics.setColor(1, 1, 1)
    local enemies_count = Utils.count(level.enemies)

    if 1 == enemies_count then
      love.graphics.print("Il reste encore un ennemi en vie !", x, y)
    elseif 0 < enemies_count then
      love.graphics.print(enemies_count .. " ennemis encore en vie.", x, y)
    end
  end
end


function draw_bar(x, y, width, height, ratio, color, highlight_color)
  love.graphics.setColor({ 1, 1, 1 })
  love.graphics.rectangle("line", x, y, width + 1, height)

  if 0 < ratio then
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width * ratio, height - 1)

    if highlight_color then
      love.graphics.setColor(highlight_color)
      love.graphics.rectangle("fill", x + 1, y + 1, width * ratio - 2, 3)
    end
  end
end


return UI