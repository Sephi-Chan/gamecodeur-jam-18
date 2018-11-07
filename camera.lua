local camera = {}
local Camera = {}
function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function Camera:Camera(...)

self.x = 0
self.y = 0
self.scaleX = 1
self.scaleY = 1

self.posModifX = self.x
self.posModifY = self.y


self.rotation = 0

self.w = 800
self.h = 600

self.objects = {}
self:setBounds(0, 0, 800, 600)
end

function Camera:newLayer(scale)
  self.layers[scale] = {}
  -- table.insert(self.layers
  --table.insert(self.layers, { draw = func, scale = scale })
  
  
  
  --table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end

function Camera:AddToObjects(pScale,pRefTable)
   local object = {scale = pScale, refTable = pRefTable}
  table.insert(self.objects,object)
  table.sort(self.objects, function(a,b) return a.scale>b.scale end)
end



function Camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.posModifX, -self.posModifY)
  
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:MustFollow(pObject)
  self.objectToFollow = pObject
end



function Camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end


function Camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function Camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end


function Camera:setPosition(x, y)
  if x then self:setX(x) end
  if y then self:setY(y) end
end

function Camera:setX(value)
  if self._bounds then
    self.x = math.clamp(value, self._bounds.x1, self._bounds.x2)
  else
    self.x = value
  end
end

function Camera:setY(value)
  if self._bounds then
    self.y = math.clamp(value, self._bounds.y1, self._bounds.y2)
  else
    self.y = value
  end
end



function Camera:setBounds(x1, y1, x2, y2)
  self._bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end




function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end


function Camera:update(delta)
  --[[
  if math.abs(self.x-self.objectToFollow.x)>width/3 and math.abs(self.x-self.objectToFollow.x)<width*(2/3) then

  else
    if math.abs(self.x-self.objectToFollow.x)<width/3 then
      self.x = self.x - (math.abs(self.x-self.objectToFollow.x) *delta)
    elseif math.abs(self.x-self.objectToFollow.x)>width/3 then
      self.x = self.x + (math.abs(self.x-self.objectToFollow.x)*delta)
    end
  end
  ]]--
  
  self:setPosition(self.objectToFollow.x - math.floor(width / 3), self.objectToFollow.y - math.floor(height / 3))
  
end

function Camera:Draw()
  local bx, by = self.x, self.y

  for _, object in pairs(self.objects) do
    --for _,k in ipairs(v)do
      self.posModifX = bx * 1/object.scale
      self.posModifY = by * 1/object.scale
      self:set()
      object.refTable.draw(object.refTable)
      self:unset()
    --end
  end
  
end




function camera.new(...)
   local self = {}
    for k, v in pairs(Camera) do
      self[k] = v
    end
    self:Camera(...)
   return self
end


return camera 