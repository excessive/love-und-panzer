require "libs.screen"
require "libs.networking"
gui = require "libs.Gspot"
font = love.graphics.newFont(12)

KEY_DELAY = 0.2
KEY_REPEAT = 0.02

local function load(self)
	love.graphics.setFont(font)

        self.network_group = gui:group("Networking", {x=10, y=10, w=128, h=gui.style.unit})
	
<<<<<<< HEAD
	-- Create GUI Elements
	self.groupConnect	= gui:group(nil, {x=100, y=100, w=244, h=gui.style.unit})
	self.inputHost		= gui:input(nil, {x=0, y=0, w=128, h=gui.style.unit}, self.groupConnect)
	self.inputPort		= gui:input(nil, {x=138, y=0, w=48, h=gui.style.unit}, self.groupConnect)
	self.buttonConnect	= gui:button("Connect", {x=196, y=0, w=48, h=gui.style.unit}, self.groupConnect)
=======
	self.input = gui:input("Host", {x=30, y=20, w=128, h=gui.style.unit}, self.network_group)
	self.input.keydelay = 0.2
	self.input.keyrepeat = 0.02
>>>>>>> 8d5c50c1d5b4234aedd051be39936725a1e9f15a
	
	-- Connect Group Properties
	self.groupConnect.style.bg = {0,0,0,0}
	
	-- Host Input Properties
	self.inputHost.keydelay = KEY_DELAY
	self.inputHost.keyrepeat = KEY_REPEAT
	self.inputHost.value = "Host"
	self.inputHost.next = self.inputPort
	
	self.inputHost.click = function(this)
		if this.value == "Host" then this.value = "" end
		this:focus()
	end

        self.portInput = gui:input("Port", {x=30, y=40, w=128, h=gui.style.unit}, self.network_group)
        self.portInput.keydelay = 0.2
        self.portInput.keyrepeat = 0.02
	
<<<<<<< HEAD
	-- Port Input Properties
	self.inputPort.keydelay = KEY_DELAY
	self.inputPort.keyrepeat = KEY_REPEAT
	self.inputPort.value = "Port"
	self.inputPort.next = self.buttonConnect
	
	self.inputPort.click = function(this)
		if this.value == "Port" then this.value = "" end
		this:focus()
	end
	
	-- Connect Button Properties
	self.buttonConnect.click = function(this)
		self.next.screen	= "gameplay"
		self.next.data		= {
			host = self.inputHost.value,
			port = self.inputPort.value,
		}
=======
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
>>>>>>> 8d5c50c1d5b4234aedd051be39936725a1e9f15a
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
