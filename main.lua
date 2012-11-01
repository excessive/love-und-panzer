require "libs.input"
require "libs.TEsound"

function love.load()
	debug = {}
	
	-- Load screen types
	screens = {}
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
	
	-- Scale
	tileSize = 32
	numTiles = 18.75
end

function love.focus()
	layers:each("focus")
end

function love.update(dt)
	-----------------------------debug.fps = math.floor(1 / dt)
	
	-- Scale
	scale			= love.graphics.getHeight() / numTiles / tileSize
	windowWidth		= love.graphics.getWidth() / scale
	windowHeight	= love.graphics.getHeight() / scale
	
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
	
	-- Display Debug Info
	local i = 0
	for k, v in pairs(debug) do
		local r = type(v) == "table" and "" or v
		if type(v) == "table" then
			for _, v2 in ipairs(v) do
				r = r .. " " .. v2
			end
		end
		love.graphics.print(k..": "..r, 0, i * 15)
		i = i + 1
	end
end

function love.keypressed(k)
	layers:each("keypressed", k)
end

function love.keyreleased(k)
	layers:each("keyreleased", k)
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
