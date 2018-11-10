local Soundbox = {
  _sources = {}
}


function Soundbox.register_sound(name, path)
  Soundbox._sources[name] = love.audio.newSource(path, "static")
end


function Soundbox.play_sound(name, volume)
  local clone = Soundbox._sources[name]:clone()
  clone:setVolume(volume or 1.0)
  love.audio.play(clone)
end


function Soundbox.play_music(name, volume)
  local clone = Soundbox._sources[name]:clone()
  clone:setVolume(volume or 1.0)
  clone:setLooping(true)
  love.audio.play(clone)
end


return Soundbox 