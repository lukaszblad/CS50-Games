Medal = Class{}

function Medal:init(score)
    self.x = VIRTUAL_WIDTH / 2 - 25
    self.y = 200
    if score >= 20 then
        self.image = love.graphics.newImage('gold.png')
    elseif score >= 10 then
        self.image = love.graphics.newImage('silver.png')
    elseif score >= 5 then
        self.image = love.graphics.newImage('bronze.png')
    else
        self.image = love.graphics.newImage('no_medal.png')
    end
end

function Medal:render()
    love.graphics.draw(self.image, self.x, self.y)
end
