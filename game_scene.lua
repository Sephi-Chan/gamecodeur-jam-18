local GameScene = {}


function GameScene.load()
  shader_manager    = Shadermanager.initialize()
  particule_manager = Particulemanager.initialize()

  camera = Camera.initialize(love.graphics.getWidth(), love.graphics.getHeight())
  hero   = Hero.new(250, 450)
  level  = Level.one(camera, hero)

  Soundbox.register_sound("sword_hit", "sounds/hit.wav")
  Soundbox.register_sound("sword_miss", "sounds/miss.wav")
  Soundbox.register_sound("hilltop_asylum", "sounds/spiky_whimsical-fantasy_hilltop-asylum.mp3")
  Soundbox.play_music("hilltop_asylum", 0.6)
end


function GameScene.update(delta)
  Animation.animate_entities(level.enemies, hero, delta)
  Entity.update(hero, level, delta)
  Level.trigger_waves(level, hero, camera)
  Camera.update(camera, delta)

  for _, layer in ipairs(level.layers) do
    Layer.update(layer, camera, delta)
  end

  Particulemanager.update(particule_manager, delta)
end


function GameScene.draw()
  Shadermanager.set(shader_manager.active_shader)
  Shadermanager.send(shader_manager)
  Camera.draw(camera)

  Shadermanager.unset()
  UI.draw(hero, level)
  Particulemanager.draw(particule_manager)
end


function GameScene.keypressed(key)
  if key == "escape" then
    change_scene(Scenes.Menu)

  elseif key == "space" then
    Hero.start_attack(hero)

  elseif key == "b" then
    Hero.use_bullet_time_power(hero, level)

  elseif key == "h" then
    Hero.use_heal_power(hero)

  elseif key == "d" or key == "q" then
    Hero.update_dash_controls(hero, level)
  end
end


function GameScene.unload(next_scene_module)
end


return GameScene