local title = {}

function title:init()
	-- UI Element Properties
	self.panelMenu = loveframes.Create("panel")
	self.panelMenu:SetState("title")
	self.panelMenu:SetSize(256, 320)
	self.panelMenu:CenterX()
	self.panelMenu:SetY(203)
	
	self.textName = loveframes.Create("text", self.panelMenu)
	self.textName:SetSize(216, 14)
	self.textName:CenterX()
	self.textName:SetY(20)
	self.textName:SetText("Name:")
	
	self.inputName = loveframes.Create("textinput", self.panelMenu)
	self.inputName:SetSize(216, 20)
	self.inputName:CenterX()
	self.inputName:SetY(34)
	
	self.textHost = loveframes.Create("text", self.panelMenu)
	self.textHost:SetSize(216, 14)
	self.textHost:CenterX()
	self.textHost:SetY(64)
	self.textHost:SetText("Host:")
	
	self.inputHost = loveframes.Create("textinput", self.panelMenu)
	self.inputHost:SetSize(216, 20)
	self.inputHost:CenterX()
	self.inputHost:SetY(78)
	
	self.textPort = loveframes.Create("text", self.panelMenu)
	self.textPort:SetSize(216, 14)
	self.textPort:CenterX()
	self.textPort:SetY(108)
	self.textPort:SetText("Port:")
	
	self.inputPort = loveframes.Create("textinput", self.panelMenu)
	self.inputPort:SetSize(216, 20)
	self.inputPort:CenterX()
	self.inputPort:SetY(122)
	
	self.buttonConnect = loveframes.Create("button", self.panelMenu)
	self.buttonConnect:SetSize(216, 20)
	self.buttonConnect:CenterX()
	self.buttonConnect:SetY(152)
	self.buttonConnect:SetText("Connect")
	self.buttonConnect.OnClick = function(this)
		client = Client()
		client:connect(self.inputHost:GetText(), self.inputPort:GetText())
		
		if client.connection.connected then
			settings.name = self.inputName:GetText()
			
			local data = json.encode({
				cmd		= "CONNECT",
				name	= settings.name,
			})
			
			client:send(data .. client.split)
		end
	end
	
	self.buttonOptions = loveframes.Create("button", self.panelMenu)
	self.buttonOptions:SetSize(216, 20)
	self.buttonOptions:CenterX()
	self.buttonOptions:SetY(182)
	self.buttonOptions:SetText("Options")
	self.buttonOptions.OnClick = function(this)
		Gamestate.switch(states.options)
	end
	
	self.buttonCredits = loveframes.Create("button", self.panelMenu)
	self.buttonCredits:SetSize(216, 20)
	self.buttonCredits:CenterX()
	self.buttonCredits:SetY(212)
	self.buttonCredits:SetText("Credits")
	self.buttonCredits.OnClick = function(this)
		Gamestate.switch(states.credits)
	end
	
	self.buttonExit = loveframes.Create("button", self.panelMenu)
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
	self.textCopyright:SetText({{255,255,255,255}, "(c) 2013 HEUHAEUAEHUE Productions"})
end

return title