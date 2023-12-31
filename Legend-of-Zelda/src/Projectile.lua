--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Projectile = Class{}

function Projectile:init(def, x, y, direction)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame

    -- whether it acts as an obstacle or not
    self.solid = def.solid
    self.bumped = false

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- starting point
    self.startX = x
    self.startY = y

    self.direction = direction
    self.velocity = 100
end

function Projectile:update(dt)
    -- flying logic
    if self.direction == 'left' then
        self.x = self.x - self.velocity * dt
    elseif self.direction == 'right' then
        self.x = self.x + self.velocity * dt
    elseif self.direction == 'up' then
        self.y = self.y - self.velocity * dt
    elseif self.direction == 'down' then
        self.y = self.y + self.velocity * dt
    end

    -- impact with walls
    local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE
    if self.direction == 'left' and self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
        self.bumped = true
    elseif self.direction == 'right' and self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
        self.bumped = true
    elseif self.direction == 'up' and self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then
        self.bumped = true
    elseif self.direction == 'down' and self.y + self.height >= bottomEdge then
        self.bumped = true
    end

    -- over 4 tiles
    local distance = 4 * TILE_SIZE
    if self.x > self.startX + distance then
        self.bumped = true
    elseif self.x < self.startX - distance then
        self.bumped = true
    elseif self.y > self.startY + distance then
        self.bumped = true
    elseif self.y < self.startY - distance then
        self.bumped = true
    end
end

function Projectile:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end