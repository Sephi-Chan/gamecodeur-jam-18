local Shader_manager ={}




function Shader_manager.set(shader)
  love.graphics.setShader(shader)
end


function Shader_manager.unset(shader_manager)
  love.graphics.setShader()
end


function Shader_manager.set_active_shader(shader_manager, shader)
  shader_manager.active_shader = shader
end

function Shader_manager.update_bullet_time(shader_manager, hero,  delta)
  if hero.bullet_time then
    Shadermanager.set_active_shader(shader_manager, shader_manager.list_shaders.bullet_time)
    shader_manager.radius_bullet_time = shader_manager.radius_bullet_time + (shader_manager.speed_radius_acceleration*delta)
    shader_manager.is_first_time_bullet = true
  elseif shader_manager.is_first_time_bullet then
    shader_manager.radius_bullet_time = shader_manager.radius_bullet_time - (shader_manager.speed_radius_deceleration*delta)
    if shader_manager.radius_bullet_time <= 0 then 
      shader_manager.is_first_time_bullet = false 
    end
  else
    Shadermanager.set_active_shader(shader_manager, shader_manager.list_shaders.basic_shader)
    shader_manager.radius_bullet_time = 0
  end
end





function Shader_manager.send(shader_manager)
  if shader_manager.active_shader == shader_manager.list_shaders.bullet_time then
    shader_manager.active_shader:send ("heroPosition", {hero.x -(camera.x) , hero.y - (camera.y)})
    shader_manager.active_shader:send ("radius",  {shader_manager.radius_bullet_time, shader_manager.radius_bullet_time})
  end

end

function Shader_manager.initialize()
  local new_shader_manager = {}
  new_shader_manager.list_shaders = {}
  
  


  local basic_shader =love.graphics.newShader[[
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
      vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
  return pixel * color;
}
]]
  
  
  
  
  local bullet_time_shader = love.graphics.newShader[[
      extern vec2 heroPosition;
      extern vec2 radius;
      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        
        vec4 pixel = Texel(texture, texture_coords ); //This is the current pixel color
        number dist= pow(pow((screen_coords.x-heroPosition.x),2) + pow((screen_coords.y-heroPosition.y),2),0.5);
        if (dist < radius.x ){
            float av = (pixel.r + pixel.g + pixel.b)/3.0;
            return vec4(av,av,av,pixel.a );
        }else{
          return pixel *color ;
        }
      }
      ]]
  
      
      
      
      
  new_shader_manager.list_shaders.basic_shader = basic_shader
  new_shader_manager.list_shaders.bullet_time = bullet_time_shader
  
  new_shader_manager.is_first_time_bullet = false
  new_shader_manager.radius_bullet_time = 0.0 
  new_shader_manager.speed_radius_acceleration = 200
  new_shader_manager.speed_radius_deceleration = 800
  new_shader_manager.active_shader = basic_shader
  
  
  return new_shader_manager
end


return Shader_manager