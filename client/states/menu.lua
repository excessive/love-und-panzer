-- Menu State

local GameState = require "libs.hump.gamestate"
require "states.game"

menu = GameState.new()

-- Run when state first created
function menu:init()
end

-- Run whenever this state is switched to
function menu:enter()
end

-- Draw code for state
function menu:draw()
    love.graphics.print("Menu", 10, 10)
end

-- Input handler for state
function menu:keyreleased(key, code)
    if key == "return" then
        GameState.switch(game)
    end
end

function menu:update(dt)
end

function menu:enter()
end
