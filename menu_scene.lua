local Menu = {
  width      = love.graphics.getWidth(),
  title_font = love.graphics.newFont(48),
  font       = love.graphics.newFont(13),

  selected_character = "Roger",
  box_width          = 100,
  box_height         = 100
}

function Menu.load()
  Soundbox.stop()

  local sprite     = love.graphics.newImage("images/elf_green.png")
  local animations = Animation.load_json("metadata/elf.json")
  Menu.roger       = Entity.new("Roger", sprite, { x = 0, y = 0 })

  local sprite     = love.graphics.newImage("images/elf_purple.png")
  local animations = Animation.load_json("metadata/elf.json")
  Menu.marcel      = Entity.new("Marcel", sprite, { x = 0, y = 0 })

  for name, animation in pairs(animations) do
    Animation.attach(Menu.roger, Animation.new(Menu.roger.sprite, name, 0.5, animation.frames))
    Animation.attach(Menu.marcel, Animation.new(Menu.marcel.sprite, name, 0.5, animation.frames))
  end

  Menu.marcel.animation.flip = true
end


function Menu.update(delta)
  if Menu.selected_character == "Roger" then
    Animation.replace(Menu.roger, "attack1")
    Animation.replace(Menu.marcel, "idle")
  else
    Animation.replace(Menu.roger, "idle")
    Animation.replace(Menu.marcel, "attack1")
  end

  Animation.animate_entities({ Menu.marcel }, Menu.roger, delta)
end


function Menu.draw()
  local text = "Grimwood"
  love.graphics.setFont(Menu.title_font)
  love.graphics.printf(text, 0, 50, Menu.width, "center")

  local text = "Comment jouer ?\n\n"
    .. "Bougez avec les touches ZQSD : Z (haut), Q (gauche), S (bas) et D (droite).\n\n"
    .. "Frappez avec ESPACE pour terrasser vos ennemis et charger votre jauge de Fureur.\n\n"
    .. "Téléportez-vous derrière un ennemi en appuyant 2 fois rapidement\ndans sa direction (à gauche avec Q, à droite avec D). Frappez sans attendre !\n\n"
    .. "Quand votre jauge de Fureur est pleine, libérez-la !\nSoignez-vous (avec H) ou ralentissez l'écoulement du temps (avec B)."
  love.graphics.setFont(Menu.font)
  love.graphics.printf(text, 0, 130, Menu.width, "center")


  draw_character_box(Menu.width/2 - 10 - Menu.box_width, 400, Menu.roger, Menu.selected_character == "Roger")
  draw_character_box(Menu.width/2 + 10, 400, Menu.marcel, Menu.selected_character == "Marcel")

  local text = "-- Choisissez un personnage (Q ou D) et appuyez sur ESPACE pour commencer --"
  love.graphics.setFont(Menu.font)
  love.graphics.printf(text, 0, 350, Menu.width, "center")
end


function Menu.keypressed(key)
  if key == "escape" then
    love.event.quit()

  elseif key == "right" or key == "left" or key == "q" or key == "d" then
    if Menu.selected_character == "Roger" then
      Menu.selected_character = "Marcel"
    else
      Menu.selected_character = "Roger"
    end

  elseif key == "space" then
    local skin = Menu.selected_character == "Roger" and "green" or "purple"
    change_scene(Scenes.Game, { skin })
  end
end


function Menu.unload()
end


function draw_character_box(x, y, character, selected)
  local frames  = character.animations[character.animation.name].frames
  local frame   = frames[character.animation.frame] or frames[1]
  local scale_x = character.animation.flip and -1 or 1
  character.x = x + frame.origin.x - 25
  character.y = y + frame.origin.y - 10

  love.graphics.setColor(selected and { 1, 1, 0 } or { 1, 1, 1 })
  love.graphics.rectangle("line", x, y, 80, 100)

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(character.sprite, frame.image, character.x, character.y, 0, scale_x, 1, frame.origin.x, frame.origin.y)
end


return Menu