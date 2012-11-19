-- Game running state

GameState = require "libs.hump.gamestate"
require "libs.TEsound"
--require "states.menu"

game = GameState.new()

function game:init()
	debug = {}

	-- Load screen types
	screens = {}
	screens.gameplay = require "screens.gameplay"

	layers = {}

	-- Scale
	tileSize = 64
	numTiles = 18.75
end

function game:enter()
	screens.gameplay = require "screens.gameplay"

	-- Initialize layers
	layers = {
		each = function(self, fn, ...)
			for k, v in ipairs(self) do
				if v[fn] then
					v[fn](v, unpack {...})
				end
			end
		end,
		screens.gameplay(nil)
	}

	layers:each("load")
end

function game:leave()
	-- Unload all the game state
	layers:each("quit")
end

function game:focus()
	layers:each("focus")
end

function game:update(dt)
	scale = love.graphics.getHeight() / numTiles / tileSize
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()

	for k, v in ipairs(layers) do
		if v.next.screen then
			local n = #layers
			table.remove(layers, n)
			layers[n] = screens[v.next.screen](v.next.data)
			layers[n]:load()
		end
	end

	layers:each("update", dt)

	TEsound.cleanup()
end

function game:draw()
	love.graphics.push()
	love.graphics.scale(scale)
	layers:each("draw")
	love.graphics.pop()

	-- Display debug info
	local i = 0
	for k, v in pairs(debug) do
		local r = type(v) == "table" and "" or v
		if type(v) == "table" then
			for _, v2 in ipairs(v) do
				r = r .. " " .. v2
			end
		end
		love.graphics.print(k .. ": " .. r, 0, i * 15)
		i = i + 1
	end
end

function game:keypressed(k)
	layers:each("keypressed", k)
end

function game:keyreleased(k)
	if k == "escape" then
		GameState.switch(menu)
	end
	layers:each("keyreleased", k)
end

function game:mousepressed(x, y, button)
	layers:each("mousepressed", x, y, button)
end

function game:mousereleased(x, y, button)
	layers:each("mousereleased", x, y, button)
end

function game:joystickpressed(joystick, button)
	layers:each("joystickpressed", joystick, button)
end

function game:joystickreleased(joystick, button)
	layers:each("joystickreleased", joystick, button)
end

function game:quit()
	layers:each("quit")
end
