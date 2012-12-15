require "libs.screen"
require "libs.panzer.client"

local function load(self)
	self.gui = gui()
	self.client = self.data.client
	self.chat = self.data.chat
	
	for k,v in pairs(self.chat) do
		if k ~= "scope" then
			self.gui:add(v)
		end
	end
end

local function update(self, dt)
	self.client:update(dt)
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
