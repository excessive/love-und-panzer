require "libs.screen"

local function load(self)
	gui.credits = Gspot()
end

local function update(self, dt)
	gui.credits:update(dt)
end

local function draw(self)
	gui.credits:draw()
end

local function mousepressed(self, x, y, button)
	gui.credits:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	gui.credits:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "Credits",
		load			= load,
		update			= update,
		draw			= draw,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
