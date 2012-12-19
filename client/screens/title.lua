require "libs.screen"
require "libs.panzer.client"

local function load(self)
	love.graphics.setFont(FONT)
	gui.title = Gspot()
	
	-- Title
	self.title = love.graphics.newImage("assets/images/title.png")
	
	-- Create GUI Elements
	self.groupTitleMenu = gui.title:group(nil, {
		x = windowWidth / 2 - gui.theme.xlarge / 2,
		y = 203,
		w = gui.theme.xlarge,
		h = gui.theme.xlarge + gui.theme.medium,
	})

	self.textName = gui.title:text("Name", {
		x = (gui.theme.xlarge - gui.theme.large - gui.theme.medium - gui.theme.small) / 2,
		y = (gui.theme.xlarge - gui.theme.large - gui.theme.medium - gui.theme.small) / 2,
		w = gui.theme.large + gui.theme.medium + gui.theme.small,
		h = gui.theme.tiny,
	}, self.groupTitleMenu)
	
	self.inputName = gui.title:input(nil, {
		x = self.textName.pos.x,
		y = self.textName.pos.h + self.textName.pos.y,
		w = self.textName.pos.w,
		h = gui.theme.tiny,
	}, self.groupTitleMenu)
	
	self.textHost = gui.title:text("Host", {
		x = self.textName.pos.x,
		y = self.inputName.pos.h + self.inputName.pos.y + gui.theme.padding,
		w = self.textName.pos.w,
		h = gui.theme.tiny,
	}, self.groupTitleMenu)

	self.inputHost = gui.title:input(nil, {
		x = self.textName.pos.x,
		y = self.textHost.pos.h + self.textHost.pos.y,
		w = self.textName.pos.w,
		h = gui.theme.tiny,
	}, self.groupTitleMenu)
	
	self.textPort = gui.title:text("Port", {
		x = self.textName.pos.x,
		y = self.inputHost.pos.h + self.inputHost.pos.y + gui.theme.padding,
		w = self.textName.pos.w,
		h = gui.theme.tiny,
	}, self.groupTitleMenu)
	
	self.inputPort = gui.title:input(nil, {
		x = self.textName.pos.x,
		y = self.textPort.pos.h + self.textPort.pos.y,
		w = self.textName.pos.w,
		h = gui.theme.tiny,
	}, self.groupTitleMenu)
	
	self.buttonConnect = gui.title:button("Connect", {
		x = self.textName.pos.x,
		y = self.inputPort.pos.h + self.inputPort.pos.y + gui.theme.padding,
		w = self.textName.pos.w,
		h = gui.theme.small,
	}, self.groupTitleMenu)
	
	self.buttonOptions = gui.title:button("Options", {
		x = self.textName.pos.x,
		y = self.buttonConnect.pos.h + self.buttonConnect.pos.y + gui.theme.padding,
		w = self.textName.pos.w,
		h = gui.theme.small,
	}, self.groupTitleMenu)
	
	self.buttonCredits = gui.title:button("Credits", {
		x = self.textName.pos.x,
		y = self.buttonOptions.pos.h + self.buttonOptions.pos.y + gui.theme.padding,
		w = self.textName.pos.w,
		h = gui.theme.small,
	}, self.groupTitleMenu)
	
	self.buttonExit = gui.title:button("Exit", {
		x = self.textName.pos.x,
		y = self.buttonCredits.pos.h + self.buttonCredits.pos.y + gui.theme.padding,
		w = self.textName.pos.w,
		h = gui.theme.small,
	}, self.groupTitleMenu)
	
	self.textCopyright = gui.title:text("© 2012 HEUHAEUAEHAUEHAUHUE Productions", {
		x = (windowWidth - gui.theme.xlarge) / 2,
		y = windowHeight - gui.theme.small,
		w = gui.theme.xlarge,
		h = gui.theme.tiny,
	})
	
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
	
	-- Credits Button Properties
	self.buttonCredits.click = function(this)
		self.next.screen = "credits"
	end
	
	-- Exit Button Properties
	self.buttonExit.click = function(this)
		love.event.quit()
	end
end

local function update(self, dt)
	gui.title:update(dt)
	
	if self.client then
		self.client:update(dt)
	end
end

local function draw(self)
	love.graphics.draw(self.title, windowWidth/2 - 303/2, gui.theme.small)
	gui.title:draw()
end

local function keypressed(self, k, unicode)
	if gui.title.focus then
		gui.title:keypress(k, unicode)
	end
end

local function mousepressed(self, x, y, button)
	gui.title:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	gui.title:mouserelease(x, y, button)
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
