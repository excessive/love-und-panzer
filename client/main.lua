require "libs.input"
require "libs.TEsound"
gui = require "libs.Gspot"

function love.load()
	debug = {}

	-- Load screen types
	screens = {}
	screens.title		= require "screens.title"
	screens.gameplay	= require "screens.gameplay"

	-- Initialize layers
	layers = {
		each = function(self, fn, ...)
			for k, v in ipairs(self) do
				if v[fn] then
					v[fn](v, unpack {...})
				end
			end
		end,
		screens.title(nil)
	}

	layers:each("load")

	-- Scale
	tileSize = 32
	numTiles = 18.75
end

function love.update(dt)
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

function love.draw()
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

function love.keypressed(k, unicode)
	layers:each("keypressed", k, unicode)
end

function love.keyreleased(k, unicode)
	layers:each("keyreleased", k, unicode)
end

function love.mousepressed(x, y, button)
	layers:each("mousepressed", x, y, button)
end

function love.mousereleased(x, y, button)
	layers:each("mousereleased", x, y, button)
end

function love.joystickpressed(joystick, button)
	layers:each("joystickpressed", joystick, button)
end

function love.joystickreleased(joystick, button)
	layers:each("joystickreleased", joystick, button)
end

function love.quit()
	layers:each("quit")
end
