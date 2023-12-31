PlayerLiftingPotState = Class{__includes = BaseState}

function PlayerLiftingPotState:init(player)
    self.player = player
    self.player:changeAnimation('lifting-' .. self.player.direction)
end

function PlayerLiftingPotState:enter()
    self.player.currentAnimation:refresh()
end

function PlayerLiftingPotState:update(dt)
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle-lifting')
    end
end

function PlayerLiftingPotState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end