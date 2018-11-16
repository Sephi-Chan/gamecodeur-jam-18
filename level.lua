local Level = {}
local LEFT  = 1
local RIGHT = 2
local Utils = require("lib.utils")


function Level.trigger_waves(level, hero, camera)
  local next_wave, trigger_x, trigger = next_wave(level)

  if next_wave and trigger_x < hero.x then
    level.last_triggered_trigger = trigger
    spawn_wave(level, next_wave, camera)
  end
end


function next_wave(level)
  local index = (level.last_triggered_trigger or 0) + 1
  local x     = level.wave_triggers[index]
  local wave  = level.waves[index]

  return wave, x, index
end



function check_victory_conditions(level)
  local next_wave, trigger_x, trigger = next_wave(level)
  if Utils.count(level.enemies) == 0 and next_wave == nil then
    change_scene(Scenes.Victory)
  end
end


function spawn_wave(level, wave, camera)
  for i, spawn in ipairs(wave) do
    if spawn.enemy_type == "boss" then
      spawn_boss(level, camera)

    else
      spawn_enemy(level, spawn.enemy_type, spawn.side, camera)
    end
  end
end


function spawn_enemy(level, enemy_type, side, camera)
  local y = math.random(level.min_y, level.max_y)

  if side == LEFT then
    local enemy = Enemy.new(camera.x + math.random(100, 150), y)
    level.enemies[enemy.name] = enemy

  else
    local enemy = Enemy.new(camera.x + camera.width - math.random(100, 150), y)
    enemy.animation.flip = true
    level.enemies[enemy.name] = enemy
  end
end


function spawn_boss(level, camera)
  local boss = Boss.new(camera.x + camera.width - 150, 450)
  level.enemies["boss"] = boss
  boss.animation.flip = true
  Animation.replace(boss, "aoe")
end



function Level.remove_enemy(level, enemy)
  level.enemies[enemy.name] = nil
  check_victory_conditions(level)
end


function Level.game_over(level)
  change_scene(Scenes.GameOver, { level })
end


function Level.boss(level)
  return level.enemies["boss"]
end


function Level.one(camera, hero)
    local front_herbs           = Layer.new(love.graphics.newImage("images/layers/10-front-herbs.png"), 1)
    local road                  = Layer.new(love.graphics.newImage("images/layers/20-road.png"), 1)
    local front_trees           = Layer.new(love.graphics.newImage("images/layers/30-front-trees.png"), 3)
    local background_herbs      = Layer.new(love.graphics.newImage("images/layers/40-background-herbs.png"), 4)
    local background_trees      = Layer.new(love.graphics.newImage("images/layers/50-background-trees.png"), 5)
    local more_background_herbs = Layer.new(love.graphics.newImage("images/layers/60-more-background-herbs.png"), 6)
    local sky_background_top    = Layer.new(love.graphics.newImage("images/layers/70-sky-background-top.png"), 7)
    local more_background_trees = Layer.new(love.graphics.newImage("images/layers/80-more-background-trees.png"), 8)
    local sky_background        = Layer.new(love.graphics.newImage("images/layers/90-sky-background.png"), 9)

    local wave_triggers = {
      500,
      1000,
      1600
    }

    local waves = {
      {
        { enemy_type = "elf", side = RIGHT },
        { enemy_type = "elf", side = RIGHT },
        { enemy_type = "elf", side = RIGHT }
      },
      {
        { enemy_type = "elf", side = RIGHT },
        { enemy_type = "elf", side = RIGHT },
        { enemy_type = "elf", side = RIGHT },
        { enemy_type = "elf", side = LEFT },
        { enemy_type = "elf", side = LEFT }
      },
      {
        { enemy_type = "elf", side = LEFT },
        { enemy_type = "boss", side = RIGHT },
      }
    }

    local level = {
      width  = 8000,
      min_y  = 380,
      max_y  = 530,

      enemies = {},

      last_triggered_trigger = nil,
      wave_triggers          = wave_triggers,
      waves                  = waves,

      layers = {
        front_herbs,
        road,
        front_trees,
        background_herbs,
        background_trees,
        more_background_herbs,
        sky_background_top,
        more_background_trees,
        sky_background
      }
    }

    Camera.follow(camera, hero)
    Camera.bind(camera, level)

    Camera.attach(camera, 9, sky_background)
    Camera.attach(camera, 8, more_background_trees)
    Camera.attach(camera, 7, sky_background_top)
    Camera.attach(camera, 6, more_background_herbs)
    Camera.attach(camera, 5, background_trees)
    Camera.attach(camera, 4, background_herbs)
    Camera.attach(camera, 3, front_trees)
    Camera.attach(camera, 1, function() Entity.draw(Entity.sortByY(hero, level.enemies)) end)
    Camera.attach(camera, 1, road)
    Camera.attach(camera, 1, front_herbs)

    return level
end


return Level
