PowerUp = Class{}

function PowerUp:init(type)
    self.x = math.random(0, VIRTUAL_WIDTH - 16)
    self.y = 0

    self.width = 16
    self.height = 16

    self.dy = 50

    self.type = type
    self.inGame = false
end

function PowerUp:update(dt)
    self.y = self.y + self.dy * dt
end

function PowerUp:collides(paddle)
    if self.x + self.width >= paddle.x and self.x <= paddle.x + paddle.width then
        if self.y + self.height >= paddle.y and self.y <= paddle.y + paddle.height then
            return true
        end
    end
end

function PowerUp:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
end