local camera = {}
local Camera = {}


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

self.layers = {}
end

function Camera:newLayer(scale)
  self.layers[scale] = {}
  -- table.insert(self.layers
  --table.insert(self.layers, { draw = func, scale = scale })
  
  
  
  --table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end

function Camera:AddToLayers(pScale,pObject)
   local object = {scale = pScale, obj = pObject}
   --[[
  if self.layers[pScale] == nil then
    self:newLayer(pScale)
  end
  --]]
  table.insert(self.layers,object)
  table.sort(self.layers, function(a,b) return a.scale>b.scale end)
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
  self.x = x or self.x
  self.y = y or self.y
end

function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end


function Camera:update(delta)
  if math.abs(self.x-self.objectToFollow.x)>width/3 and math.abs(self.x-self.objectToFollow.x)<width*(2/3) then

  else
    if math.abs(self.x-self.objectToFollow.x)>width*(2/3) then
      self.x = math.floor(self.x + (delta*math.abs(self.x-self.objectToFollow.x)/2))
    elseif math.abs(self.x-self.objectToFollow.x)<width/3 then
      self.x = math.floor(self.x - (delta*math.abs(self.x-self.objectToFollow.x)/2))
    end
  end
  
  
end

function Camera:Draw()
  local bx, by = self.x, self.y

  for scale, v in pairs(self.layers) do
    --for _,k in ipairs(v)do
      self.posModifX = bx * 1/v.scale
      self.posModifY = by * 1/v.scale
      
      self:set()
      if v.obj[draw] == nil then
        v.obj:Draw()
      else
      v.obj.draw()
      end
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