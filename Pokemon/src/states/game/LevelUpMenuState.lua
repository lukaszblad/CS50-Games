LevelUpMenuState = Class{__includes = BaseState}

function LevelUpMenuState:init(close, currentStats, increase)
    self.LevelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 150,
        y = 0,
        width = 150,
        height = 100,
        type = 'lvlup',
        items = {
            {
                text = 'HP: ' .. tostring(currentStats.HP - increase['hp']) .. ' + ' .. tostring(increase['hp']) .. ' = ' .. tostring(currentStats.HP),
                onSelect = close
            },
            {
                text = 'AT: ' .. tostring(currentStats.attack - increase['attack']) .. ' + ' .. tostring(increase['attack']) .. ' = ' .. tostring(currentStats.attack)
            },
            {
                text = 'DF: ' .. tostring(currentStats.defense - increase['defense']) .. ' + ' .. tostring(increase['defense']) .. ' = ' .. tostring(currentStats.defense)
            },
            {
                text = 'SP: ' .. tostring(currentStats.speed - increase['speed']) .. ' + ' .. tostring(increase['speed']) .. ' = ' .. tostring(currentStats.speed)
            }
        }
    }
end

function LevelUpMenuState:update(dt)
    self.LevelUpMenu:update(dt)
end

function LevelUpMenuState:render()
    self.LevelUpMenu:render()
end
