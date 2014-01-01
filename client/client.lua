local Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE"

Client = Class {}

function Client:init()
	self.chat			= {}
	self.players		= {}
	self.createPlayers	= {}
	self.updatePlayers	= {}
	self.removePlayers	= {}
	self.options		= {}
	self.map			= {}
	
	self.moveSpeed		= 64
	self.turnSpeed		= 72
	self.turretSpeed	= 54
	self.reloadSpeed	= 5
	
	self.split			= "۞"
end

--[[
	Connect to Server
	
	host			= Server host
	port			= Server port
]]--
function Client:connect(host, port)
	self.connection = lube.enetClient()
	self.connection.handshake = "loveTanks"
	self.connection:setPing(true, 2, "lePing\n")
	
	if self.connection:connect(host, tonumber(port), true) then
		print('Connect to ' .. host .. ':' .. port)
	end
	
	self.connection.callbacks.recv = function(d) self:recv(d) end
end

--[[
	Receive Data from Server
	
	data			= Data received
]]--
function Client:recv(data)
	print('Server data received: ' .. data)
	
	if data then
		local cmds = string.split(data, self.split)
		
		for _, d in pairs(cmds) do
			local params = json.decode(d)
			
			if params then
				if self.recvcommands[params.cmd] then
					local cmd	= params.cmd
					params.cmd	= nil
					
					self.recvcommands[cmd](self, params)
				else
					print("Unrecognised command: ", params.cmd)
				end
			end
		end
	end
end

--[[
	Update Client
]]--
function Client:update(dt)
	self.connection:update(dt)
	
	for id, player in pairs(self.players) do
		-- Move Forward
		if player.move == "f" then
			local newX = player.x + self.moveSpeed * dt * math.cos(math.rad(player.r))
			local newY = player.y + self.moveSpeed * dt * math.sin(math.rad(player.r))
			
			-- do collision detection here!
			
			player.x = newX -- if no collision
			player.y = newY -- if no collision
			
			self.players[id].x = player.x
			self.players[id].y = player.y
		end
		
		-- Move Backward
		if player.move == "b" then
			local newX = player.x - self.moveSpeed * dt * math.cos(math.rad(player.r))
			local newY = player.y - self.moveSpeed * dt * math.sin(math.rad(player.r))
			
			-- do collision detection here!
			
			player.x = newX -- if no collision
			player.y = newY -- if no collision
			
			self.players[id].x = player.x
			self.players[id].y = player.y
		end
		
		-- Turn Left
		if player.turn == "l" then
			player.r = player.r - self.turnSpeed * dt
			if player.r > 360 then player.r = player.r - 360 end
			
			self.players[id].r = player.r
		end
		
		-- Turn Right
		if player.turn == "r" then
			player.r = player.r + self.turnSpeed * dt
			if player.r < 0 then player.r = player.r + 360 end
			
			self.players[id].r = player.r
		end
		
		-- Turn Turret Left
		if player.turret == "l" then
			player.tr = player.tr - self.turretSpeed * dt
			if player.tr > 360 then player.tr = player.tr - 360 end
			
			self.players[id].tr = player.tr
		end
		
		-- Turn Turret Right
		if player.turret == "r" then
			player.tr = player.tr + self.turretSpeed * dt
			if player.tr < 0 then player.tr = player.tr + 360 end
			
			self.players[id].tr = player.tr
		end
		
		-- Reload Cooldown
		if player.cd > 0 then
			player.cd = player.cd - dt
			
			self.players[id].cd = player.cd
		end
	end
end

--[[
	Send Data to Server
]]--
function Client:send(data)
	self.connection:send(data .. self.split)
end

--[[
	Client Commands
]]--
Client.recvcommands = {
	
	-- Post Chat Message
	CHAT = function(self, chat)
		if chat.scope == "GLOBAL" then
			self.chat.global = chat.msg
		elseif chat.scope == "GAME" then
			self.chat.game = chat.msg
		elseif chat.scope == "TEAM" then
			self.chat.team = chat.msg
		end
	end,
	
	-- Retrieve Current Players
	SYNC_PLAYERS = function(self, players)
		for id, player in pairs(players) do
			if not self.players[id] then
				self.createPlayers[id] = true
			end
			
			self.players[id] = player
		end
	end,
	
	-- Player Connected
	CREATE_PLAYER = function(self, player)
		self.players[player.id] = player
		self.createPlayers[player.id] = true
	end,
	
	-- Update Player Data
	UPDATE_PLAYER = function(self, player)
		local id = player.id
		player.id = nil
		
		for k, v in pairs(player) do
			self.players[id][k] = v
		end
		
		self.updatePlayers[id] = true
	end,
	
	-- Player Disconnected
	REMOVE_PLAYER = function(self, player)
		self.players[player.id] = nil
		self.removePlayers[player.id] = true
	end,
	
	-- Set ID
	WHO_AM_I = function(self, me)
		self.id = me.id
	end,
	
	-- Start Game
	START_GAME = function(self, data)
		client.startGame = true
	end,
}

-- http://wiki.interfaceware.com/534.html
function string.split(s, d)
	local t = {}
	local i = 0
	local f
	local match = '(.-)' .. d .. '()'
	
	if string.find(s, d) == nil then
		return {s}
	end
	
	for sub, j in string.gmatch(s, match) do
		i = i + 1
		t[i] = sub
		f = j
	end
	
	if i ~= 0 then
		t[i+1] = string.sub(s, f)
	end
	
	return t
end
