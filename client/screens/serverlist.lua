require "libs.screen"
require "libs.panzer.client"

local function load(self)
	self.gui = gui()
	self.client = self.data.client
	self.id = self.data.id
	
	-- GUI Theme
	self.theme = {
		padding	= 8,
		tiny	= 16,
		small	= 32,
		medium	= 64,
		large	= 128,
		xlarge	= 256,
	}
	
	--[[ Create GUI Elements ]]--
	
	-- Chat Group
	self.groupChat = self.gui:group(nil, {
		x = 0,
		y = windowHeight - 200,
		w = 400,
		h = 200,
	})
	
	-- Chat Text
	self.textChat = self.gui:text("", {
		x = 0,
		y = 0,
		w = 400,
		h = 200 - self.theme.tiny,
	}, self.groupChat)
	
	-- Chat Input
	self.inputChat = self.gui:input(nil, {
		x = 0,
		y = self.groupChat.pos.h - self.theme.tiny,
		w = 350,
		h = self.theme.tiny,
	}, self.groupChat)
	
	-- Chat Button
	self.buttonChatGlobal = self.gui:button("Send", {
		x = 350,
		y = self.groupChat.pos.h - self.theme.tiny,
		w = 50,
		h = self.theme.tiny,
	}, self.groupChat)
	
	--[[ Chat Group Properties ]]--
	
	-- Chat Input Properties
	self.inputChat.keydelay = KEY_DELAY
	self.inputChat.keyrepeat = KEY_REPEAT
	
	-- Chat Button Properties
	self.buttonChatGlobal.click = function(this)
		if self.inputChat.value and self.inputChat.value ~= "" then
			local str = json.encode({
				scope = "GLOBAL",
				msg = self.inputChat.value,
			})
			local data = string.format("%s %s", "CHAT", str)
			
			self.client.connection:send(data)
			self.inputChat.value = ""
		end
	end
end

local function update(self, dt)
	self.client:update(dt)
	self.gui:update(dt)
	
	if self.client.chat.global then
		self.textChat.label = self.textChat.label .. "\n" .. self.client.chat.global
		self.client.chat.global = nil
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
