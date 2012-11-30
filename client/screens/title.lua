require "libs.screen"
gui = require "libs.Gspot"
font = love.graphics.newFont(12)

local function load(self)
	love.graphics.setFont(font)
	
	self.input = gui:input("Host", {x=100, y=100, w=128, h=gui.style.unit})
	self.input.keydelay = 0.2
	self.input.keyrepeat = 0.02
	
	self.input.done = function(this)
		self.next.screen	= "gameplay"
		self.next.data		= {
			host = this.value
		}
	end
	
	self.button = gui:button("Connect", {x=138, y=0, w=48, h=gui.style.unit}, self.input)
	
	self.button.click = function(this)
		this.parent:done()
	end
end

local function update(self, dt)
	gui:update(dt)
end

local function draw(self)
	gui:draw()
end

local function keypressed(self, k, unicode)
	if gui.focus then
		gui:keypress(k, unicode)
	end
end

local function mousepressed(self, x, y, button)
	gui:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	gui:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "Title",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
