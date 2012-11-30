require "libs.screen"
require "libs.networking"
gui = require "libs.Gspot"
font = love.graphics.newFont(12)

local function load(self)
	love.graphics.setFont(font)

        self.network_group = gui:group("Networking", {x=10, y=10, w=128, h=gui.style.unit})
	
	self.input = gui:input("Host", {x=30, y=20, w=128, h=gui.style.unit}, self.network_group)
	self.input.keydelay = 0.2
	self.input.keyrepeat = 0.02
	
	self.input.done = function(this)
		self.next.screen	= "gameplay"
		self.next.data		= {
			host = this.value
		}
	end

        self.portInput = gui:input("Port", {x=30, y=40, w=128, h=gui.style.unit}, self.network_group)
        self.portInput.keydelay = 0.2
        self.portInput.keyrepeat = 0.02
	
	self.connect_button = gui:button("Connect", {x=30, y=60, w=48, h=gui.style.unit}, self.network_group)
        self.server_button = gui:button("Host", {x=84, y=60, w=48, h=gui.style.unit}, self.network_group)
        self.test_button = gui:button("Test", {x=144, y=60, w=48, h=gui.style.unit}, self.network_group)

        self.test_button.click = function(this)
                self.next.data.conn:send("Test")
        end
	
	self.connect_button.click = function(this)
                if self.next.data == nil then
                        self.next.data = {}
                end
                self.next.data.conn = Networking:startClient(self.input.value, self.portInput.value)
		--this.parent:done()
	end

        self.server_button.click = function(this)
                if self.next.data == nil then
                        self.next.data = {}
                end
                self.next.data.conn = Networking:startServer(self.portInput.value)
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
