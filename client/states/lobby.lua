local lobby = {}

function lobby:enter(state)
	loveframes.SetState("lobby")
	
	self.chat			= {}
	self.players		= {}
	self.players.slots	= {}
	self.options		= {}
	self.scope			= "global"
	
	--[[ Chat UI Elements ]]--
	
	-- Group containing all chat elements
	self.chat.panel = loveframes.Create("panel")
	self.chat.panel:SetState("lobby")
	self.chat.panel:SetSize(400, 200)
	self.chat.panel:SetPos(0, windowHeight - 200)
	
	-- List of chat messages
	self.chat.globalList = loveframes.Create("list", self.chat.panel)
	self.chat.globalList:SetSize(400, 160)
	self.chat.globalList:SetAutoScroll(true)
	
	self.chat.teamList = loveframes.Create("list", self.chat.panel)
	self.chat.teamList:SetSize(400, 160)
	self.chat.teamList:SetAutoScroll(true)
	
	-- Toggle lists
	self.chat.tabs = loveframes.Create("tabs", self.chat.panel)
	self.chat.tabs:SetSize(400, 180)
	self.chat.tabs:SetPos(0, 0)
	self.chat.tabs:AddTab("Global", self.chat.globalList, nil, nil, function() self.scope="global" end)
	self.chat.tabs:AddTab("Team", self.chat.teamList, nil, nil, function() self.scope="team" end)
	
	-- Input message
	self.chat.input = loveframes.Create("textinput", self.chat.panel)
	self.chat.input:SetSize(350, 20)
	self.chat.input:SetPos(0, 180)
	
	-- Send message
	self.chat.sendButton = loveframes.Create("button", self.chat.panel)
	self.chat.sendButton:SetSize(50, 20)
	self.chat.sendButton:SetPos(350, 180)
	self.chat.sendButton:SetText("Send")
	self.chat.sendButton.OnClick = function(this)
		self:sendChat()
	end
	
	--[[ Player UI Elements ]]--
	
	-- Group containing all players
	self.players.panel = loveframes.Create("panel")
	self.players.panel:SetState("lobby")
	self.players.panel:SetSize(300, 400)
	self.players.panel:SetPos(0, 0)
	
	--[[ Option UI Elements ]]--
	
	-- Group containing all options
	self.options.panel = loveframes.Create("panel")
	self.options.panel:SetState("lobby")
	self.options.panel:SetSize(300, 400)
	self.options.panel:SetPos(500, 0)
	
	-- Ready to play
	self.options.readyButton = loveframes.Create("button", self.options.panel)
	self.options.readyButton:SetSize(100, 40)
	self.options.readyButton:SetPos(100, 350)
	
	if client.players[client.id].host then
		self.options.readyButton:SetClickable(false)
		self.options.readyButton:SetText("Start Game")
		self.options.readyButton.OnClick = function()
			local data = json.encode({
				cmd		= "START_GAME",
			})
			client.connection:send(data .. client.split)
		end
	else
		self.options.readyButton:SetText("Ready")
		self.options.readyButton.OnClick = function()
			local data = nil
			
			if client.players[client.id].ready then
				data = json.encode({cmd = "READY", ready = false})
			else
				data = json.encode({cmd = "READY", ready = true})
			end
			
			client.connection:send(data .. client.split)
		end
	end
end

function lobby:update(dt)
	client:update(dt)
	
	-- Add new players
	for id, player in pairs(client.createPlayers) do
		self:createPlayer(id, player)
		client.createPlayers[id] = nil
	end
	
	-- Update current players
	for id, player in pairs(client.updatePlayers) do
		self:updatePlayer(id, player)
		client.updatePlayers[id] = nil
	end
	
	-- Remove old players
	for id, _ in pairs(client.removePlayers) do
		self:removePlayer(id)
		client.removePlayers[id] = nil
	end
	
	-- Update list positions
	local count = 0
	for id, _ in pairs(client.players) do
		count = count + 1
		self:updateListPosition(id, count)
	end
	
	-- Update Global Chat
	if client.chat.global then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.global)
		self.chat.globalList:AddItem(text)
		client.chat.global = nil
	end
	
	-- Update Team Chat
	if client.chat.team then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.team)
		self.chat.teamList:AddItem(text)
		client.chat.team = nil
	end
	
	-- If you are the host, check if everyone is ready
	if client.players[client.id].host then
		local players = 0
		local ready = 0
		
		for id, player in pairs(client.players) do
			players = players + 1
			
			if player.ready then
				ready = ready + 1
			end
		end
		
		if players == ready and players > 1 then
			self.options.readyButton:SetClickable(true)
		else
			self.options.readyButton:SetClickable(false)
		end
	end
	
	if client.startGame then
		client.startGame = nil
		Gamestate.switch(states.gameplay)
	end
	
	loveframes.update(dt)
end

-- Send Chat Message
function lobby:sendChat()
	if self.chat.input:GetText() ~= "" then
		local data = json.encode({
			cmd		= "CHAT",
			scope	= string.upper(self.scope),
			msg		= self.chat.input:GetText(),
		})
		
		client:send(data .. client.split)
		self.chat.input:Clear()
	end
end

function lobby:draw()
	loveframes.draw()
end

function lobby:createPlayer(id, player, offset)
	self.players.slots[id] = {}
	
	-- Group containing individual player's elements
	self.players.slots[id].panel = loveframes.Create("panel", self.players.panel)
	self.players.slots[id].panel:SetSize(300, 40)
	self.players.slots[id].panel:SetPos(0, 0)
	
	-- Image displaying player's ready status
	self.players.slots[id].readyImage = loveframes.Create("image", self.players.slots[id].panel)
	self.players.slots[id].readyImage:SetPos(0, 0)
	
	-- Display player's name
	self.players.slots[id].name = loveframes.Create("text", self.players.slots[id].panel)
	self.players.slots[id].name:SetSize(100, 20)
	self.players.slots[id].name:SetPos(32, 0)
	
	-- Display player's team number
	self.players.slots[id].team = loveframes.Create("text", self.players.slots[id].panel)
	self.players.slots[id].team:SetSize(20, 20)
	self.players.slots[id].team:SetPos(200, 0)
	
	self:updatePlayer(id, player)
end

function lobby:updatePlayer(id, player)
	-- Display image
	if player.host then
		self.players.slots[id].readyImage:SetImage("assets/images/host.png")
	elseif player.ready then
		if player.team == 1 then
			self.players.slots[id].readyImage:SetImage("assets/images/check-pink.png")
		else
			self.players.slots[id].readyImage:SetImage("assets/images/check-blue.png")
		end
	else
		if player.team == 1 then
			self.players.slots[id].readyImage:SetImage("assets/images/block-pink.png")
		else
			self.players.slots[id].readyImage:SetImage("assets/images/block-blue.png")
		end
	end
	
	-- Display info
	self.players.slots[id].name:SetText(player.name)
	self.players.slots[id].team:SetText(player.team)

end

function lobby:removePlayer(id)
	self.players.slots[id].panel:Remove()
	self.players.slots[id] = nil
end

function lobby:updateListPosition(id, offset)
	self.players.slots[id].panel:SetPos(0, 40 * offset - 40)
end

function lobby:keypressed(key, unicode)
	if key == "return" then
		if self.chat.input:GetFocus() then
			if self.chat.input:GetText() then
				self:sendChat()
				self.chat.input:SetFocus(false)
			else
				self.chat.input:SetFocus(false)
			end
		else
			self.chat.input:SetFocus(true)
		end
	end
	
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
