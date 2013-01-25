require "libs.screen"

local function load(self)
	-- Title Image
	self.title = love.graphics.newImage("assets/images/title.png")
	gui.title = {}
	
	-- UI Element Properties
	gui.title.groupTitleMenu = loveframes.Create("panel")
	gui.title.groupTitleMenu:SetSize(256, 320)
	gui.title.groupTitleMenu:CenterX()
	gui.title.groupTitleMenu:SetY(203)
	
	gui.title.textName = loveframes.Create("text", gui.title.groupTitleMenu)
	gui.title.textName:SetSize(216, 14)
	gui.title.textName:CenterX()
	gui.title.textName:SetY(20)
	gui.title.textName:SetText("Name:")
	
	gui.title.inputName = loveframes.Create("textinput", gui.title.groupTitleMenu)
	gui.title.inputName:SetSize(216, 20)
	gui.title.inputName:CenterX()
	gui.title.inputName:SetY(34)
	
	gui.title.textHost = loveframes.Create("text", gui.title.groupTitleMenu)
	gui.title.textHost:SetSize(216, 14)
	gui.title.textHost:CenterX()
	gui.title.textHost:SetY(64)
	gui.title.textHost:SetText("Host:")
	
	gui.title.inputHost = loveframes.Create("textinput", gui.title.groupTitleMenu)
	gui.title.inputHost:SetSize(216, 20)
	gui.title.inputHost:CenterX()
	gui.title.inputHost:SetY(78)
	
	gui.title.textPort = loveframes.Create("text", gui.title.groupTitleMenu)
	gui.title.textPort:SetSize(216, 14)
	gui.title.textPort:CenterX()
	gui.title.textPort:SetY(108)
	gui.title.textPort:SetText("Port:")
	
	gui.title.inputPort = loveframes.Create("textinput", gui.title.groupTitleMenu)
	gui.title.inputPort:SetSize(216, 20)
	gui.title.inputPort:CenterX()
	gui.title.inputPort:SetY(122)
	
	gui.title.buttonConnect = loveframes.Create("button", gui.title.groupTitleMenu)
	gui.title.buttonConnect:SetSize(216, 20)
	gui.title.buttonConnect:CenterX()
	gui.title.buttonConnect:SetY(152)
	gui.title.buttonConnect:SetText("Connect")
	gui.title.buttonConnect.OnClick = function(this)
		client = Client()
		client:connect(gui.title.inputHost:GetText(), gui.title.inputPort:GetText())
		
		if client.connection.connected then
			self.next.screen = "lobby"
			_G.settings.name = gui.title.inputName:GetText()
			
			local data = string.format("%s %s", "CONNECT", json.encode({name = _G.settings.name}))
			client:send(data)
		end
	end
	
	gui.title.buttonOptions = loveframes.Create("button", gui.title.groupTitleMenu)
	gui.title.buttonOptions:SetSize(216, 20)
	gui.title.buttonOptions:CenterX()
	gui.title.buttonOptions:SetY(182)
	gui.title.buttonOptions:SetText("Options")
	gui.title.buttonOptions.OnClick = function(this)
		self.next.screen = "options"
	end
	
	gui.title.buttonCredits = loveframes.Create("button", gui.title.groupTitleMenu)
	gui.title.buttonCredits:SetSize(216, 20)
	gui.title.buttonCredits:CenterX()
	gui.title.buttonCredits:SetY(212)
	gui.title.buttonCredits:SetText("Credits")
	gui.title.buttonCredits.OnClick = function(this)
		self.next.screen = "credits"
	end
	
	gui.title.buttonExit = loveframes.Create("button", gui.title.groupTitleMenu)
	gui.title.buttonExit:SetSize(216, 20)
	gui.title.buttonExit:CenterX()
	gui.title.buttonExit:SetY(242)
	gui.title.buttonExit:SetText("Exit")
	gui.title.buttonExit.OnClick = function(this)
		love.event.quit()
	end
	
	gui.title.textCopyright = loveframes.Create("text")
	gui.title.textCopyright:SetSize(256, 14)
	gui.title.textCopyright:CenterX()
	gui.title.textCopyright:SetY(564)
	gui.title.textCopyright:SetText({{255,255,255,255}, "© 2012 HEUHAEUAEHUE Productions"})
	
	-- Debug
	gui.title.inputName:SetText("Karai")
	gui.title.inputHost:SetText("k17.me")
	gui.title.inputPort:SetText("8088")
end

local function update(self, dt)
	if client then client:update(dt) end
	loveframes.update(dt)
end

local function draw(self)
	love.graphics.draw(self.title, windowWidth/2 - 303/2, 32)
	loveframes.draw()
end

local function keypressed(self, k, unicode)
	loveframes.keypressed(k, unicode)
end

local function keyreleased(self, k, unicode)
	loveframes.keyreleased(k, unicode)
end

local function mousepressed(self, x, y, button)
	loveframes.mousepressed(x, y, button)
end

local function mousereleased(self, x, y, button)
	loveframes.mousereleased(x, y, button)
end

return function(data)
	return Screen {
		name			= "Title",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		keyreleased		= keyreleased,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
