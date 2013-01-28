require "libs.screen"

local function load(self)
	gui.results = {}
end

local function update(self, dt)
	client:update(dt)
	loveframes.update(dt)
end

local function draw(self)
	loveframes.draw()
end

local function keypressed(self, k, unicode)
	loveframes.keypressed(k, unicode)
end

local function keyreleased(self, k)
	loveframes.keyreleased(k)
end

local function mousepressed(self, x, y, button)
	loveframes.mousepressed(x, y, button)
end

local function mousereleased(self, x, y, button)
	loveframes.mousereleased(x, y, button)
end

return function(data)
	return Screen {
		name			= "Results",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		keyreleased		= keyreleased,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
