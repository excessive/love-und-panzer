local lobby = {}

function lobby:enter(state)
	loveframes.SetState("lobby")
	
	--[[ Chat UI Elements ]]--
	self.scope = "global"
	
	-- Chat Group
	self.group = loveframes.Create("panel")
	self.group:SetState("lobby")
	self.group:SetSize(400, 200)
	self.group:SetPos(0, windowHeight - 200)
	
	-- Chat Text
	self.global = loveframes.Create("list")
	self.global:SetSize(400, 160)
	self.global:SetAutoScroll(true)
	
	self.team = loveframes.Create("list")
	self.team:SetSize(400, 160)
	self.team:SetAutoScroll(true)
	
	-- Chat Tabs
	self.tabs = loveframes.Create("tabs", self.group)
	self.tabs:SetSize(400, 180)
	self.tabs:SetPos(0, 0)
	self.tabs:AddTab("Global", self.global, nil, nil, function() self.scope="global" end)
	self.tabs:AddTab("Team", self.team, nil, nil, function() self.scope="team" end)
	
	-- Chat Input
	self.input = loveframes.Create("textinput", self.group)
	self.input:SetSize(350, 20)
	self.input:SetPos(0, 180)
	
	-- Chat Button
	self.send = loveframes.Create("button", self.group)
	self.send:SetSize(50, 20)
	self.send:SetPos(350, 180)
	self.send:SetText("Send")
	
	-- Send Button Properties
	self.send.OnClick = function(this)
		self:sendChat()
	end
	
	--[[ Lobby UI Elements ]]--
	self.lobby = {
		players = {slots = {}},
		options = {},
		ready = {},
	}
	
	self.lobby.players.group = loveframes.Create("panel")
	self.lobby.players.group:SetState("lobby")
	self.lobby.players.group:SetSize(300, 400)
	self.lobby.players.group:SetPos(0, 0)
	
	self.lobby.ready.button = loveframes.Create("button")
	self.lobby.ready.button:SetSize(100, 40)
	self.lobby.ready.button:SetPos(500, 500)
	self.lobby.ready.button:SetText("Ready")
	self.lobby.ready.button.OnClick = function()
		local str = nil
		
		if client.state.players[client.id].ready then
			data = json.encode({cmd = "READY", ready = false})
		else
			data = json.encode({cmd = "READY", ready = true})
		end
		
		client.connection:send(data .. client.split)
	end
	
end

function lobby:update(dt)
	client:update(dt)
	
	local count = 1
	for id, property in pairs(client.state.players) do
		self.lobby.players.slots[id] = {}
		self.lobby.players.slots[id].group = loveframes.Create("panel", self.lobby.players.group)
		self.lobby.players.slots[id].group:SetSize(300, 40)
		self.lobby.players.slots[id].group:SetPos(0, 40*count)
		
		self.lobby.players.slots[id].ready = loveframes.Create("image", self.lobby.players.slots[id].group)
		self.lobby.players.slots[id].ready:SetPos(0, 0)
		
		if property.host then
			self.lobby.players.slots[id].ready:SetImage("assets/images/host.png")
		elseif property.ready then
			if property.team == 1 then
				self.lobby.players.slots[id].ready:SetImage("assets/images/check-pink.png")
			else
				self.lobby.players.slots[id].ready:SetImage("assets/images/check-blue.png")
			end
		else
			self.lobby.players.slots[id].ready:SetImage("assets/images/block-blue.png")
		end
		
		self.lobby.players.slots[id].name = loveframes.Create("text", self.lobby.players.slots[id].group)
		self.lobby.players.slots[id].name:SetSize(100, 20)
		self.lobby.players.slots[id].name:SetPos(32, 0)
		self.lobby.players.slots[id].name:SetText(property.name)
		
		self.lobby.players.slots[id].team = loveframes.Create("text", self.lobby.players.slots[id].group)
		self.lobby.players.slots[id].team:SetSize(20, 20)
		self.lobby.players.slots[id].team:SetPos(200, 0)
		self.lobby.players.slots[id].team:SetText(property.team)
		
		count = count + 1
	end
	
	-- Update Global Chat
	if client.chat.global then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.global)
		self.global:AddItem(text)
		client.chat.global = nil
	end
	
	-- Update Team Chat
	if client.chat.team then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.team)
		self.team:AddItem(text)
		client.chat.team = nil
	end
	
	if client.updategame then
		for k,v in pairs(client.updategame) do
			print(k,v)
		end
		
		client.updategame = nil
	end
	
	if client.state.players[client.id].x then
		--Gamestate.switch(states.gameplay)
	end
	
	loveframes.update(dt)
end

-- Send Chat Message
function lobby:sendChat()
	if self.input:GetText() ~= "" then
		local data = json.encode({
			cmd		= "CHAT",
			scope	= string.upper(self.scope),
			msg		= self.input:GetText(),
		})
		
		client:send(data .. client.split)
		self.input:SetText("")
	end
end

function lobby:draw()
	loveframes.draw()
end

function lobby:keypressed(key, unicode)
	loveframes.keypressed(key, unicode)
end

function lobby:keyreleased(key)
	loveframes.keyreleased(key)
end

function lobby:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function lobby:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

return lobby
