--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:canPick(target, offset)

    -- check if player facing target
    if self.x < target.x + target.width and self.direction == 'left' then
        return false
    elseif self.x > target.x and self.direction == 'right' then
        return false
    elseif self.y < target.y + target.height - self.height / 2 and self.direction == 'up' then
        return false
    elseif self.y  > target.y - self.height / 2 and self.direction == 'down' then
        return false
    end

    -- check if player near target
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    return not (self.x + self.width < target.x - offset or self.x > target.x + target.width + offset or
                selfY + selfHeight < target.y - offset or selfY > target.y + target.height + offset)
end

function Player:render()
    Entity.render(self)
    
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end