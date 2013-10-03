local lobby = {}

function lobby:init()
	self.players		= {}
	self.players.slots	= {}
	self.options		= {}
	
	-- Panel containing all players
	self.players.panel = loveframes.Create("panel")
	self.players.panel:SetState("lobby")
	self.players.panel:SetSize(300, 400)
	self.players.panel:SetPos(0, 0)
	
	-- Panel containing all options
	self.options.panel = loveframes.Create("panel")
	self.options.panel:SetState("lobby")
	self.options.panel:SetSize(300, 400)
	self.options.panel:SetPos(500, 0)
	
	-- Ready to play
	self.options.buttonReady = loveframes.Create("button", self.options.panel)
	self.options.buttonReady:SetSize(100, 40)
	self.options.buttonReady:SetPos(100, 350)
	
	if client.players[client.id].host then
		self.options.buttonReady:SetClickable(false)
		self.options.buttonReady:SetText("Start Game")
		self.options.buttonReady.OnClick = function()
			local data = json.encode({
				cmd		= "START_GAME",
			})
			client.connection:send(data .. client.split)
		end
	else
		self.options.buttonReady:SetText("Ready")
		self.options.buttonReady.OnClick = function()
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

function lobby:update()
	-- Add new players
	for id, _ in pairs(client.createPlayers) do
		self:createPlayer(id, client.players[id])
		client.createPlayers[id] = nil
	end
	
	-- Update current players
	for id, _ in pairs(client.updatePlayers) do
		self:updatePlayer(id, client.players[id])
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
		self:updatePos(id, count)
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
			self.options.buttonReady:SetClickable(true)
		else
			self.options.buttonReady:SetClickable(false)
		end
	end
end

function lobby:createPlayer(id, player)
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

function lobby:updatePos(id, offset)
	self.players.slots[id].panel:SetPos(0, 40 * offset - 40)
end

return lobby