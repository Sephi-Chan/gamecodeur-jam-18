local Menu = {
  width      = love.graphics.getWidth(),
  title_font = love.graphics.newFont(48),
  font       = love.graphics.newFont(13)
}

function Menu.load()
  Soundbox.stop()
end


function Menu.update(delta)
end


function Menu.draw()
  local text = "Grimwood"
  love.graphics.setFont(Menu.title_font)
  love.graphics.printf(text, 0, 100, Menu.width, "center")

  local text = "Comment jouer ?\n\n"
    .. "Bougez avec les touches ZQSD : Z (haut), Q (gauche), S (bas) et D (droite).\n\n"
    .. "Frappez avec ESPACE pour terrasser vos ennemis et charger votre jauge de Fureur.\n\n"
    .. "Téléportez-vous derrière un ennemi en appuyant 2 fois rapidement\ndans sa direction (à gauche avec Q, à droite avec D). Frappez sans attendre !\n\n"
    .. "Quand votre jauge de Fureur est pleine, libérez-la !\nSoignez-vous (avec H) ou ralentissez l'écoulement du temps (avec B)."
  love.graphics.setFont(Menu.font)
  love.graphics.printf(text, 0, 180, Menu.width, "center")


  local text = "-- Appuyer sur ESPACE pour commencer --"
  love.graphics.setFont(Menu.font)
  love.graphics.printf(text, 0, 400, Menu.width, "center")
end


function Menu.keypressed(key)
  if key == "escape" then
    love.event.quit()

  elseif key == "space" then
    change_scene(Scenes.Game)
  end
end


function Menu.unload()
end


return Menu