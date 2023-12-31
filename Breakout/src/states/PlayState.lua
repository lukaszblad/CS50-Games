--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = {
        [1] = params.ball
    }
    self.level = params.level
    self.recoverPoints = params.recoverPoints
    self.paddlePoints = params.paddlePoints

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- multiple balls powerup variables
    self.multiBallsTimer = 0
    self.multiBallsInGame = false

    -- key powerup timer
    self.keyBrickTimer = 0
    self.keyBrickInGame = false
    self.keypower = false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- spawn more balls powerup at a random time during gameplay
    self.multiBallsTimer = self.multiBallsTimer + dt
    if self.multiBallsTimer > math.random(60, 20) and self.multiBallsInGame == false and #self.balls == 1 then
        self.multiballs = PowerUp(9)
        self.multiBallsInGame = true
    end

    -- spawn key brick powerup at a random time during gameplay
    self.keyBrickTimer = self.keyBrickTimer + dt
    if self.keyBrickTimer > math.random(30, 60) and self.keyBrickInGame == false and self.keypower == false then
        self.keybrick = PowerUp(10)
        self.keyBrickInGame = true
    end
 
    -- update the powerup if in game
    if self.multiBallsInGame then
        self.multiballs:update(dt)
        if self.multiballs.y > VIRTUAL_HEIGHT then
            self.multiBallsInGame = false
            self.multiBallsTimer = 0
        end
    end

    -- update key brick powerup
    if self.keyBrickInGame then
        self.keybrick:update(dt)
        if self.keybrick.y > VIRTUAL_HEIGHT then
            self.keyBrickInGame = false
            self.keyBrickTimer = 0
        end
    end

    -- if the multiball powerup collides with the paddle
    if self.multiBallsInGame and self.multiballs:collides(self.paddle) then
        self.multiBallsInGame = false
        self.multiBallsTimer = 0

        table.insert(self.balls, Ball(math.random(7)))
        table.insert(self.balls, Ball(math.random(7)))
        for index, ball in pairs(table.slice(self.balls, 2)) do
            ball.x = self.balls[1].x
            ball.y = self.balls[1].y

            ball.dx = math.random(self.balls[1].dx - 5, self.balls[1].dx + 5)
            ball.dy = math.random(self.balls[1].dy - 5, self.balls[1].dy + 5)
        end
    end

    -- if the keybrick powerup collides with the paddle
    if self.keyBrickInGame and self.keybrick:collides(self.paddle) then
        self.keyBrickInGame = false
        self.keypower = true
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for index, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for index, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for index, ball in pairs(self.balls) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                if brick.color == 6 and self.keypower == false then
                    -- nothing happens
                else
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = self.recoverPoints + math.min(10000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- increase paddle size if scored 3000 points
                    if self.score > self.paddlePoints and gFrames['paddles'][self.paddle.paddleIndex]['size'] < 128 then
                        self.paddle = Paddle(self.paddle.paddleIndex + 1, self.paddle.x + self.paddle.width / 2)
                        self.paddlePoints = self.paddlePoints + 500
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = self.balls[1],
                            recoverPoints = self.recoverPoints,
                            paddlePoints = self.paddlePoints
                        })
                    end
                end
                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for index, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            self.health = self.health - 1
            gSounds['hurt']:play()

            -- reducing paddle size if hearth lost
            if gFrames['paddles'][self.paddle.paddleIndex]['size'] > 32 then
                self.paddle = Paddle(self.paddle.paddleIndex - 1, self.paddle.x + self.paddle.width / 2)
            end

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints,
                    paddlePoints = self.paddlePoints
                })
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    -- render poweup if in game
    if self.multiBallsInGame then
        self.multiballs:render()
    end

    -- render key brick powerup
    if self.keyBrickInGame then
        self.keybrick:render()
    end

    self.paddle:render()
    for index, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- render powerups miniatures
    if #self.balls > 1 then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][9], VIRTUAL_WIDTH - 50, VIRTUAL_HEIGHT - 20)
    end
    if self.keypower == true then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][10], VIRTUAL_WIDTH - 25, VIRTUAL_HEIGHT - 20)
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end