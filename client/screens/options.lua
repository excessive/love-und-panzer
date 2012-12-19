require "libs.screen"

local function load(self)
	gui.options = Gspot()
end

local function update(self, dt)
	gui.options:update(dt)
end

local function draw(self)
	gui.options:draw()
end

local function mousepressed(self, x, y, button)
	gui.options:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	gui.options:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "Options",
		load			= load,
		update			= update,
		draw			= draw,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
