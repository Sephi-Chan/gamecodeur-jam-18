local Level = {}


function Level.one(camera, hero)
    local front_herbs           = Layer.new(love.graphics.newImage("images/layers/10-front-herbs.png"), 1)
    local road                  = Layer.new(love.graphics.newImage("images/layers/20-road.png"), 1)
    local front_trees           = Layer.new(love.graphics.newImage("images/layers/30-front-trees.png"), 1)
    local background_herbs      = Layer.new(love.graphics.newImage("images/layers/40-background-herbs.png"), 1)
    local background_trees      = Layer.new(love.graphics.newImage("images/layers/50-background-trees.png"), 1)
    local more_background_herbs = Layer.new(love.graphics.newImage("images/layers/60-more-background-herbs.png"), 1)
    local sky_background_top    = Layer.new(love.graphics.newImage("images/layers/70-sky-background-top.png"), 1)
    local more_background_trees = Layer.new(love.graphics.newImage("images/layers/80-more-background-trees.png"), 1)
    local sky_background        = Layer.new(love.graphics.newImage("images/layers/90-sky-background.png"), 1)
     
    local level = {
      width  = 8000,
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
    Camera.attach(camera, 2, road)
    Camera.attach(camera, 1.5, function() Entity.draw(Entity.sortByY(Entity.entities())) end)
    Camera.attach(camera, 1, front_herbs)

    return level
end


return Level
