local Boss = {
  GROUP = "boss",
  AGGRO_RADIUS = 800,
  FRAME_DURATION  = 0.5,
  VELOCITY = 60,
  ATTACK_RANGE = 50,
  BULLET_TIME_VELOCITY_FACTOR = 0.25,
  BULLET_TIME_FRAME_DURATION  = 1.5,
  TIMER_CASTING_AOE = 2,
  RADIUS_AOE = 300,
  RADIUS_AOE_SPEED_TIMER = 0.25,
  RADIUS_AOE_SPEED = 75,
  RECOVERING_DURATION  = 1,
  STAGGER_DURATION    = 0.4,
  HEALTH = 200,
  states = {
    IDLE       = "idle",
    STAGGERED  = "staggered",
    HUNTING    = "hunting",
    ATTACKING  = "attacking",
    RECOVERING = "recovering",
    CASTING = "casting",
    AEOING = "aoeing",
  }
}
local Utils = require("lib.utils")
local boss_sprite     = love.graphics.newImage("images/druid.png")
local boss_animations = Animation.load_json("metadata/druid.json")


function Boss.new(x, y)
  local boss = Entity.new("boss", boss_sprite, {
    x          = x,
    y          = y,
    state      = Boss.states.IDLE,
    group      = Boss.GROUP,
    velocity_x = Boss.VELOCITY,
    velocity_y = Boss.VELOCITY * 0.6,
    module     = Boss,
    health     = Boss.HEALTH,

  })
  boss.phase = 1
  boss.radius_aoe_delta = 0
  boss.timer_casting = 0
  boss.timer_aoe = 0
  boss.aggro_radius = Boss.AGGRO_RADIUS
  boss.attack_range = Boss.ATTACK_RANGE
  boss.isImuneStagered = true


  boss.recovering_timer = 0
  for name, animation in pairs(boss_animations) do
    Animation.attach(boss, Animation.new(boss.sprite, name, Boss.FRAME_DURATION, animation.frames))
  end

  return boss
end

function Boss.attack(boss, hero, delta)
  local boss_frame = boss.animations[boss.animation.name].frames[boss.animation.frame]
  local last_frame  = #boss.animations[boss.animation.name].frames

  if boss_frame.hitboxes then
    local has_hit      = false
    local real_hitbox  = Box.coordinates(boss, boss_frame.hitboxes[1])
    local hero_frame   = hero.animations[hero.animation.name].frames[hero.animation.frame]
    local hero_movebox = hero_frame.moveboxes[1]

    if boss.attack_targets[hero.name] then
      -- wound an boss only once per attack.

    elseif boss.y < hero.y - hero_movebox.height or hero.y < boss.y - hero_movebox.height then
      -- only hit the targets with around the same Y: boss is either too far or too near on the screen.

    else
      local hero_real_hurtbox = Box.coordinates(hero, hero_frame.hurtboxes[1])

      if Box.collides(real_hitbox, hero_real_hurtbox) then
        boss.attack_targets[hero.name] = true
        Boss.wound(boss, hero)
        has_hit = true
      end
    end

    if boss.attack_sound_played == false then
      local sound = has_hit and "sword_hit" or "sword_miss"
      Soundbox.play_sound(sound, .5)
      boss.attack_sound_played = true
    end
  end

  --Animation.replace(boss, "attack1")
--[[
  if boss.animation.frame == last_frame then
    Boss.start_recovering(boss)
    boss.attack_targets      = {}
    boss.attack_sound_played = false
  end
  --]]
end


function Boss.start_recovering(boss)
  boss.state             = Boss.states.RECOVERING
  boss.recovering_frames = 80
end

function Boss.recover(boss)
  Animation.replace(boss, "idle")


  if boss.recovering_timer == 0 then
    boss.state = Boss.states.IDLE
  end
end

function update_recovering_timer(boss, delta)
  boss.recovering_timer = Utils.clamp(boss.recovering_timer - delta, 0, 100)
end




function Boss.move(boss, hero, delta)
  local angle  = Utils.angle( boss.x, boss.y, hero.x, hero.y)
  local factor = hero.bullet_time and Boss.BULLET_TIME_VELOCITY_FACTOR or 1
  local velocity_x = math.cos(angle) * boss.velocity_x * factor * delta
  local velocity_y = math.sin(angle) * boss.velocity_y * factor * delta

  boss.animation.flip = velocity_x < 0
  boss.vx = velocity_x < 0 and Entity.LEFT or Entity.RIGHT
  boss.vy = velocity_y < 0 and Entity.UP or Entity.DOWN

  boss.x = boss.x + velocity_x
  Entity.resolve_horizontal_collision(boss, { hero })

  boss.y = boss.y + velocity_y
  Entity.resolve_vertical_collision(boss, { hero })

  Animation.replace(boss, "walk")
end




function Boss.attack(boss, hero, delta)
  local boss_frame = boss.animations[boss.animation.name].frames[boss.animation.frame]
  local last_frame  = #boss.animations[boss.animation.name].frames

  if boss_frame.hitboxes then
    local has_hit      = false
    local real_hitbox  = Box.coordinates(boss, boss_frame.hitboxes[1])
    local hero_frame   = hero.animations[hero.animation.name].frames[hero.animation.frame]
    local hero_movebox = hero_frame.moveboxes[1]

    if boss.attack_targets[hero.name] then
      -- wound an boss only once per attack.

    elseif boss.y < hero.y - hero_movebox.height or hero.y < boss.y - hero_movebox.height then
      -- only hit the targets with around the same Y: boss is either too far or too near on the screen.

    else
      local hero_real_hurtbox = Box.coordinates(hero, hero_frame.hurtboxes[1])

      if Box.collides(real_hitbox, hero_real_hurtbox) then
        boss.attack_targets[hero.name] = true
        Boss.wound(boss, hero)
        has_hit = true
      end
    end

    if boss.attack_sound_played == false then
      local sound = has_hit and "sword_hit" or "sword_miss"
      Soundbox.play_sound(sound, .5)
      boss.attack_sound_played = true
    end
  end

  --Animation.replace(boss, "attack1")
--[[
  if boss.animation.frame == last_frame then
    Boss.start_recovering(boss)
    boss.attack_targets      = {}
    boss.attack_sound_played = false
  end
  --]]
end




function Boss.think(boss, hero)
  if boss.state == Boss.states.STAGGERED then
    return

  elseif boss.state == Boss.states.RECOVERING then
    return

  elseif boss.state == Boss.states.CASTING then
    return
  elseif boss.state == Boss.states.AEOING then
    return
  else
    local distance =  Utils.dist(hero.x, hero.y, boss.x, boss.y)

    if distance < boss.aggro_radius then
      boss.state = Boss.states.HUNTING

      if distance < boss.attack_range then
        local rand_choice = math.random(1,100)
        if rand_choice >85 then
          Animation.replace(boss, "aoe")
          boss.state = Boss.states.CASTING
        else
          boss.state = Boss.states.ATTACKING
        end
      end
    else
      boss.state = Boss.states.IDLE
    end
  end
end


function Boss.casting(boss, hero, delta)
  if boss.timer_casting >= Boss.TIMER_CASTING_AOE then
    boss.state = Boss.states.AEOING
    boss.timer_casting = 0
  else
    boss.timer_casting = boss.timer_casting + delta
  end
end

function Boss.aoe(boss, hero, delta)
  local distance =  Utils.dist(hero.x, hero.y, boss.x, boss.y)
    if boss.timer_aoe >= Boss.RADIUS_AOE_SPEED_TIMER then
      if boss.radius_aoe_delta >= Boss.RADIUS_AOE then
        boss.radius_aoe_delta = 0
        boss.timer_aoe = 0
        boss.state = Boss.states.RECOVERING
        return
      end


      boss.radius_aoe_delta = boss.radius_aoe_delta + Boss.RADIUS_AOE_SPEED

      local mesure = 360 /20
        local table = {x = boss.x, y = boss.y -20}
        Particulemanager.add_particule_effect(particule_manager, "aoe", table, boss)

      if distance <  boss.radius_aoe_delta then
      Boss.wound(boss, hero)
      end



      boss.timer_aoe = 0
    else
      boss.timer_aoe = boss.timer_aoe +delta
    end


end

function Boss.wound(boss, hero, level)
  Entity.wound(boss, hero)
  Particulemanager.add_particule_effect(particule_manager, "blood", hero)
  camera.isShaking = true
  if hero.health <= 0 then
      Level.game_over(level)
  end
end


function Boss.phase(boss, delta)
  if boss.health >= Boss.HEALTH *0.75 and boss.phase ~= 1 then
    return
  elseif boss.health >= Boss.HEALTH *0.50 and boss.health <= Boss.HEALTH *0.75 and boss.phase <= 1 then
    boss.phase = 2
    Boss.TIMER_CASTING_AOE = 1.5
    boss.velocity_x = boss.velocity_x * 1.25
    boss.velocity_y = boss.velocity_y * 1.25
  elseif boss.health <=  Boss.HEALTH* 0.50 and boss.phase <= 2 then

    boss.phase = 3
    Boss.TIMER_CASTING_AOE = 1.25
    boss.velocity_x = boss.velocity_x * 1.25
    boss.velocity_y = boss.velocity_y * 1.25
  end


end




function Boss.update(boss, hero, delta)
  local factor = hero.bullet_time and Boss.BULLET_TIME_VELOCITY_FACTOR or 1
  local delta = delta *factor
  Entity.update_stagger_timer(boss, delta)
  update_recovering_timer(boss, delta)
  boss.module.think(boss, hero)
  Boss.phase(boss, delta)


  if boss.state == Boss.states.STAGGERED then
    --Entity.staggered(boss)

  elseif boss.state == Boss.states.RECOVERING then
    Boss.recover(boss)

  elseif boss.state == Boss.states.HUNTING then
    Boss.move(boss, hero, delta)

  elseif boss.state == Boss.states.ATTACKING then
    Boss.attack(boss, hero, delta)

  elseif boss.state == Boss.states.CASTING then
    Boss.casting(boss, hero, delta)
  elseif boss.state == Boss.states.AEOING then
    Boss.aoe(boss, hero, delta)

  elseif boss.state == Boss.states.IDLE then
    Animation.replace(boss, "idle")
  end
end


return Boss