require "libs.screen"
require "libs.loveframes"

local function load(self)
	-- Title Image
	self.title = love.graphics.newImage("assets/images/title.png")
	
	-- UI Element Properties
	local groupTitleMenu = loveframes.Create("panel")
	groupTitleMenu:SetSize(256, 320)
	groupTitleMenu:CenterX()
	groupTitleMenu:SetY(203)
	
	local textName = loveframes.Create("text", groupTitleMenu)
	textName:SetSize(216, 14)
	textName:CenterX()
	textName:SetY(20)
	textName:SetText("Name:")
	
	local inputName = loveframes.Create("textinput", groupTitleMenu)
	inputName:SetSize(216, 20)
	inputName:CenterX()
	inputName:SetY(34)
	
	local textHost = loveframes.Create("text", groupTitleMenu)
	textHost:SetSize(216, 14)
	textHost:CenterX()
	textHost:SetY(64)
	textHost:SetText("Host:")
	
	local inputHost = loveframes.Create("textinput", groupTitleMenu)
	inputHost:SetSize(216, 20)
	inputHost:CenterX()
	inputHost:SetY(78)
	
	local textPort = loveframes.Create("text", groupTitleMenu)
	textPort:SetSize(216, 14)
	textPort:CenterX()
	textPort:SetY(108)
	textPort:SetText("Port:")
	
	local inputPort = loveframes.Create("textinput", groupTitleMenu)
	inputPort:SetSize(216, 20)
	inputPort:CenterX()
	inputPort:SetY(122)
	
	local buttonConnect = loveframes.Create("button", groupTitleMenu)
	buttonConnect:SetSize(216, 20)
	buttonConnect:CenterX()
	buttonConnect:SetY(152)
	buttonConnect:SetText("Connect")
	buttonConnect.OnClick = function(this)
		client = Client()
		client:connect(inputHost:GetText(), inputPort:GetText())
		
		if client.connection.connected then
			self.next.screen = "serverlist"
			_G.settings.name = inputName:GetText()
			
			local data = string.format("%s %s", "CONNECT", json.encode({name = _G.settings.name}))
			client:send(data)
		end
	end
	
	local buttonOptions = loveframes.Create("button", groupTitleMenu)
	buttonOptions:SetSize(216, 20)
	buttonOptions:CenterX()
	buttonOptions:SetY(182)
	buttonOptions:SetText("Options")
	buttonOptions.OnClick = function(this)
		self.next.screen = "options"
	end
	
	local buttonCredits = loveframes.Create("button", groupTitleMenu)
	buttonCredits:SetSize(216, 20)
	buttonCredits:CenterX()
	buttonCredits:SetY(212)
	buttonCredits:SetText("Credits")
	buttonCredits.OnClick = function(this)
		self.next.screen = "credits"
	end
	
	local buttonExit = loveframes.Create("button", groupTitleMenu)
	buttonExit:SetSize(216, 20)
	buttonExit:CenterX()
	buttonExit:SetY(242)
	buttonExit:SetText("Exit")
	buttonExit.OnClick = function(this)
		love.event.quit()
	end
	
	local textCopyright = loveframes.Create("text")
	textCopyright:SetSize(256, 14)
	textCopyright:CenterX()
	textCopyright:SetY(564)
	textCopyright:SetText({{255,255,255,255}, "© 2012 HEUHAEUAEHUE Productions"})
	
	-- Debug
	inputName:SetText("Karai")
	inputHost:SetText("k17.me")
	inputPort:SetText("8088")
end

local function update(self, dt)
	if client then client:update(dt) end
	loveframes.update(dt)
end

local function draw(self)
	love.graphics.draw(self.title, windowWidth/2 - 303/2, gui.theme.small)
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
