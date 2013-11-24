local chat = {}

function chat:init()
	self.scope = "global"
	
	-- Group containing all chat elements
	self.panel = loveframes.Create("panel")
	self.panel:SetState("lobby")
	self.panel:SetSize(400, 200)
	self.panel:SetPos(0, windowHeight - 200)
	
	-- List of chat messages
	self.listGlobal = loveframes.Create("list", self.panel)
	self.listGlobal:SetSize(400, 160)
	self.listGlobal:SetAutoScroll(true)
	
	self.listTeam = loveframes.Create("list", self.panel)
	self.listTeam:SetSize(400, 160)
	self.listTeam:SetAutoScroll(true)
	
	-- Toggle lists
	self.tabs = loveframes.Create("tabs", self.panel)
	self.tabs:SetSize(400, 180)
	self.tabs:SetPos(0, 0)
	self.tabs:AddTab("Global", self.listGlobal, nil, nil, function() self.scope="global" end)
	self.tabs:AddTab("Team", self.listTeam, nil, nil, function() self.scope="team" end)
	
	-- Input message
	self.input = loveframes.Create("textinput", self.panel)
	self.input:SetSize(350, 20)
	self.input:SetPos(0, 180)
	
	-- Send message
	self.buttonSend = loveframes.Create("button", self.panel)
	self.buttonSend:SetSize(50, 20)
	self.buttonSend:SetPos(350, 180)
	self.buttonSend:SetText("Send")
	self.buttonSend.OnClick = function(this)
		self:send()
	end
end

function chat:update()
	if client.chat.global then
		self:receive("global")
	end
	
	if client.chat.team then
		self:receive("team")
	end
end

-- Send Chat Message
function chat:send()
	if self.input:GetText() ~= "" then
		local data = json.encode({
			cmd		= "CHAT",
			scope	= string.upper(self.scope),
			msg		= self.input:GetText(),
		})
		client:send(data)
		
		self.input:Clear()
	end
end

function chat:receive(scope)
	local text = loveframes.Create("text")
	text:SetMaxWidth(400)
	text:SetText(client.chat[scope])
	client.chat[scope] = nil
	
	if scope == "team" then
		self.listTeam:AddItem(text)
	else
		self.listGlobal:AddItem(text)
	end
end

return chat