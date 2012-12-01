require "libs.screen"
require "libs.networking"
font = love.graphics.newFont(12)

KEY_DELAY = 0.2
KEY_REPEAT = 0.02

local function load(self)
	love.graphics.setFont(font)
	self.gui = gui()
	
	-- Create GUI Elements
	self.groupNetwork	= self.gui:group(nil, {x=100, y=100, w=244, h=self.gui.style.unit})
	self.inputHost		= self.gui:input(nil, {x=0, y=0, w=128, h=self.gui.style.unit}, self.groupNetwork)
	self.inputPort		= self.gui:input(nil, {x=138, y=0, w=48, h=self.gui.style.unit}, self.groupNetwork)
	self.buttonConnect	= self.gui:button("Connect", {x=196, y=0, w=48, h=self.gui.style.unit}, self.groupNetwork)
	self.buttonServer	= self.gui:button("Server", {x=196, y=24, w=48, h=self.gui.style.unit}, self.groupNetwork)
	
	-- Network Group Properties
	self.groupNetwork.style.bg = {0,0,0,0}
	
	-- Host Input Properties
	self.inputHost.keydelay = KEY_DELAY
	self.inputHost.keyrepeat = KEY_REPEAT
	self.inputHost.value = "localhost"
	self.inputHost.next = self.inputPort
	
	self.inputHost.click = function(this)
		if this.value == "Host" then this.value = "" end
		this:focus()
	end
	
	-- Port Input Properties
	self.inputPort.keydelay = KEY_DELAY
	self.inputPort.keyrepeat = KEY_REPEAT
	self.inputPort.value = "12345"
	self.inputPort.next = self.buttonConnect
	
	self.inputPort.click = function(this)
		if this.value == "Port" then this.value = "" end
		this:focus()
	end
	
	-- Connect Button Properties
	self.buttonConnect.click = function(this)
		if self.next.data == nil then
			self.next.data = {}
			self.next.data.conn = Networking:startClient(self.inputHost.value, self.inputPort.value)
			
			if self.next.data.conn.connected then
				self.next.screen = "gameplay"
			end
		end
	end
	
	-- Server Button Properties
	self.buttonServer.click = function(this)
		if self.next.data == nil then
			self.next.data = {}
			self.next.data.conn = Networking:startServer(self.inputPort.value)
		end
	end
end

local function update(self, dt)
	self.gui:update(dt)
	
	if self.next.data then
		self.next.data.conn:update(dt)
	end
end

local function draw(self)
	self.gui:draw()
end

local function keypressed(self, k, unicode)
	if self.gui.focus then
		self.gui:keypress(k, unicode)
	end
end

local function mousepressed(self, x, y, button)
	self.gui:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	self.gui:mouserelease(x, y, button)
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
