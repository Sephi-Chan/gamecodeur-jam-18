local Level = {}


function Level.one(camera, hero)
    local dark_grass_layer  = Layer.new(love.graphics.newImage("images/layers/dark-grass.png"), 1)
    local road_layer        = Layer.new(love.graphics.newImage("images/layers/road.png"), 1)
    local front_trees_layer = Layer.new(love.graphics.newImage("images/layers/front-trees.png"), 1)
     
    local level = {
      width  = 8000,
      layers = { dark_grass_layer, road_layer, front_trees_layer }
    }

    Camera.follow(camera, hero)
    Camera.bind(camera, level)

    Camera.attach(camera, 6, front_trees_layer)
    Camera.attach(camera, 4, road_layer)
    Camera.attach(camera, 2, function() Entity.draw(Entity.sortByY(Entity.entities())) end)
    Camera.attach(camera, 1, dark_grass_layer)

    return level
end


return Level
