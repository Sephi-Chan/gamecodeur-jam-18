local Boss = {
  AGGRO_RADIUS = 800,
  ATTACK_RANGE = 50
}


function Boss.new(x, y)
  local boss = Entity.new("boss", Entity.sprites.druid, {
    x          = x,
    y          = y,
    state      = Enemy.states.IDLE,
    group      = Enemy.GROUP,
    velocity_x = Enemy.VELOCITY,
    velocity_y = Enemy.VELOCITY * 0.6,
    module     = Boss,
    health     = 50
  })

  boss.aggro_radius = Boss.AGGRO_RADIUS
  boss.attack_range = Boss.ATTACK_RANGE

  for name, animation in pairs(Entity.animations.druid) do
    Animation.attach(boss, Animation.new(boss.sprite, name, Enemy.FRAME_DURATION, animation.frames))
  end

  return boss
end


function Boss.think(boss, hero)
end


function Boss.update(boss, hero, delta)

end


return Boss