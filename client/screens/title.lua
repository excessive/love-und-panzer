require "libs.screen"
require "libs.panzer.client"

local function load(self)
	love.graphics.setFont(FONT)
	self.gui = gui()
	
	-- GUI Theme
	self.theme = {
		padding	= 8,
		tiny	= 16,
		small	= 32,
		medium	= 64,
		large	= 128,
		xlarge	= 256,
	}
	
	-- Title
	self.title = love.graphics.newImage("assets/images/title.png")
	
	-- Create GUI Elements
	self.groupTitleMenu = self.gui:group(nil, {
		x = windowWidth / 2 - self.theme.xlarge / 2,
		y = 239,
		w = self.theme.xlarge,
		h = self.theme.xlarge,
	})

	self.textName = self.gui:text("Name:", {
		x = 0,
		y = 0,
		w = self.theme.small,
		h = self.theme.tiny,
	}, self.groupTitleMenu)
	
	self.inputName = self.gui:input(nil, {
		x = self.textName.pos.w + self.theme.padding,
		y = 0,
		w = self.theme.xlarge - self.theme.small - self.theme.padding,
		h = self.theme.tiny,
	}, self.groupTitleMenu)
	
	self.textHost = self.gui:text("Host:", {
		x = 0,
		y = self.inputName.pos.h + self.theme.padding,
		w = self.theme.small,
		h = self.theme.tiny,
	}, self.groupTitleMenu)

	self.inputHost = self.gui:input(nil, {
		x = self.textHost.pos.w + self.theme.padding,
		y = self.inputName.pos.h + self.theme.padding,
		w = self.theme.large + self.theme.small,
		h = self.theme.tiny,
	}, self.groupTitleMenu)
	
	self.inputPort = self.gui:input(nil, {
		x = self.textHost.pos.w + self.inputHost.pos.w + self.theme.tiny,
		y = self.inputName.pos.h + self.theme.padding,
		w = self.theme.small + self.theme.tiny,
		h = self.theme.tiny,
	}, self.groupTitleMenu)
	
	self.buttonConnect = self.gui:button("Connect", {
		x = 0,
		y = self.inputHost.pos.y + self.inputHost.pos.h + self.theme.padding,
		w = self.theme.xlarge,
		h = self.theme.tiny},
	self.groupTitleMenu)
	
	self.buttonOptions = self.gui:button("Options", {
		x = 0,
		y = self.buttonConnect.pos.y + self.buttonConnect.pos.h + self.theme.padding,
		w = self.theme.xlarge,
		h = self.theme.tiny},
	self.groupTitleMenu)
	
	self.buttonExit = self.gui:button("Exit", {
		x = 0,
		y = self.buttonOptions.pos.y + self.buttonOptions.pos.h + self.theme.padding,
		w = self.theme.xlarge,
		h = self.theme.tiny},
	self.groupTitleMenu)
	
	-- Network Group Properties
	--self.groupNetwork.style.bg = {0,0,0,0}
	
	-- Host Input Properties
	self.inputName.keydelay = KEY_DELAY
	self.inputName.keyrepeat = KEY_REPEAT
	self.inputName.value = _G.settings.name
	self.inputName.next = self.inputHost
	
	self.inputName.click = function(this)
		if this.value == "Username" then this.value = "" end
		this:focus()
	end
	
	-- Host Input Properties
	self.inputHost.keydelay = KEY_DELAY
	self.inputHost.keyrepeat = KEY_REPEAT
	self.inputHost.value = _G.settings.host
	self.inputHost.next = self.inputPort
	
	self.inputHost.click = function(this)
		if this.value == "Host" then this.value = "" end
		this:focus()
	end
	
	-- Port Input Properties
	self.inputPort.keydelay = KEY_DELAY
	self.inputPort.keyrepeat = KEY_REPEAT
	self.inputPort.value = _G.settings.port
	self.inputPort.next = self.buttonConnect
	
	self.inputPort.click = function(this)
		if this.value == "Port" then this.value = "" end
		this:focus()
	end
	
	-- Connect Button Properties
	self.buttonConnect.click = function(this)
		self.client = Client()
		self.client:connect(self.inputHost.value, self.inputPort.value)
		
		if self.client.connection.connected then
			self.next.screen = "serverlist"
			self.next.data = {
				client = self.client
			}
			_G.settings.name = self.inputName.value
			
			local data = string.format("%s %s", "CONNECT", json.encode({name = _G.settings.name}))
			self.client.connection:send(data)
		end
	end
	
	-- Options Button Properties
	self.buttonOptions.click = function(this)
		self.next.screen = "options"
	end
	
	-- Exit Button Properties
	self.buttonExit.click = function(this)
		love.event.quit()
	end
end

local function update(self, dt)
	self.gui:update(dt)
	
	if self.next.data then
		self.next.data.client:update(dt)
	end
end

local function draw(self)
	love.graphics.draw(self.title, windowWidth/2 - 303/2, 50)
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
