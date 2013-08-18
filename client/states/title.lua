local title = {}

function title:enter(state)
	-- Title Image
	self.title = love.graphics.newImage("assets/images/title.png")
	loveframes.SetState("title")
	
	-- UI Element Properties
	self.groupTitleMenu = loveframes.Create("panel")
	self.groupTitleMenu:SetState("title")
	self.groupTitleMenu:SetSize(256, 320)
	self.groupTitleMenu:CenterX()
	self.groupTitleMenu:SetY(203)
	
	self.textName = loveframes.Create("text", self.groupTitleMenu)
	self.textName:SetState("title")
	self.textName:SetSize(216, 14)
	self.textName:CenterX()
	self.textName:SetY(20)
	self.textName:SetText("Name:")
	
	self.inputName = loveframes.Create("textinput", self.groupTitleMenu)
	self.inputName:SetState("title")
	self.inputName:SetSize(216, 20)
	self.inputName:CenterX()
	self.inputName:SetY(34)
	
	self.textHost = loveframes.Create("text", self.groupTitleMenu)
	self.textHost:SetState("title")
	self.textHost:SetSize(216, 14)
	self.textHost:CenterX()
	self.textHost:SetY(64)
	self.textHost:SetText("Host:")
	
	self.inputHost = loveframes.Create("textinput", self.groupTitleMenu)
	self.inputHost:SetState("title")
	self.inputHost:SetSize(216, 20)
	self.inputHost:CenterX()
	self.inputHost:SetY(78)
	
	self.textPort = loveframes.Create("text", self.groupTitleMenu)
	self.textPort:SetState("title")
	self.textPort:SetSize(216, 14)
	self.textPort:CenterX()
	self.textPort:SetY(108)
	self.textPort:SetText("Port:")
	
	self.inputPort = loveframes.Create("textinput", self.groupTitleMenu)
	self.inputPort:SetState("title")
	self.inputPort:SetSize(216, 20)
	self.inputPort:CenterX()
	self.inputPort:SetY(122)
	
	self.buttonConnect = loveframes.Create("button", self.groupTitleMenu)
	self.buttonConnect:SetState("title")
	self.buttonConnect:SetSize(216, 20)
	self.buttonConnect:CenterX()
	self.buttonConnect:SetY(152)
	self.buttonConnect:SetText("Connect")
	self.buttonConnect.OnClick = function(this)
		client = Client()
		client:connect(self.inputHost:GetText(), self.inputPort:GetText())
		
		if client.connection.connected then
			_G.settings.name = self.inputName:GetText()
			
			local data = string.format("%s %s", "CONNECT", json.encode({name = _G.settings.name}))
			client:send(data)
		end
	end
	
	self.buttonOptions = loveframes.Create("button", self.groupTitleMenu)
	self.buttonOptions:SetState("title")
	self.buttonOptions:SetSize(216, 20)
	self.buttonOptions:CenterX()
	self.buttonOptions:SetY(182)
	self.buttonOptions:SetText("Options")
	self.buttonOptions.OnClick = function(this)
		Gamestate.switch(states.options)
	end
	
	self.buttonCredits = loveframes.Create("button", self.groupTitleMenu)
	self.buttonCredits:SetState("title")
	self.buttonCredits:SetSize(216, 20)
	self.buttonCredits:CenterX()
	self.buttonCredits:SetY(212)
	self.buttonCredits:SetText("Credits")
	self.buttonCredits.OnClick = function(this)
		Gamestate.switch(states.credits)
	end
	
	self.buttonExit = loveframes.Create("button", self.groupTitleMenu)
	self.buttonExit:SetState("title")
	self.buttonExit:SetSize(216, 20)
	self.buttonExit:CenterX()
	self.buttonExit:SetY(242)
	self.buttonExit:SetText("Exit")
	self.buttonExit.OnClick = function(this)
		love.event.quit()
	end
	
	self.textCopyright = loveframes.Create("text")
	self.textCopyright:SetState("title")
	self.textCopyright:SetSize(256, 14)
	self.textCopyright:CenterX()
	self.textCopyright:SetY(564)
	self.textCopyright:SetText({{255,255,255,255}, "© 2012 HEUHAEUAEHUE Productions"})
	
	-- Debug
	self.inputName:SetText("Karai")
	self.inputHost:SetText("k17.me")
	self.inputPort:SetText("8088")
end

function title:update(dt)
	if client then
		client:update(dt)
		
		for k,v in pairs(client.state) do
			print(k,v)
		end
		
		if client.state.players then
			Gamestate.switch(states.lobby)
		end
	end
	
	loveframes.update(dt)
end

function title:draw()
	love.graphics.draw(self.title, windowWidth/2 - 303/2, 32)
	loveframes.draw()
end

function title:keypressed(key, unicode)
	loveframes.keypressed(key, unicode)
end

function title:keyreleased(key)
	loveframes.keyreleased(key)
end

function title:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function title:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

return title
