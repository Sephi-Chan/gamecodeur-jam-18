local UUID = { id = 0 }

function UUID.uuid(prefix)
  UUID.id = UUID.id + 1
  return (prefix and prefix .. "_" or "") .. UUID.id
end


return UUID