local Soundbox = {
  _sources = {}
}


function Soundbox.register_sound(name, path)
  Soundbox._sources[name] = love.audio.newSource(path, "static")
end


function Soundbox.play_sound(name)
  local clone = Soundbox._sources[name]:clone()
  love.audio.play(clone)
end


return Soundbox 