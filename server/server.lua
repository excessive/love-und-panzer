Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE"

Server = Class {}

function Server:init()
	self.state = "lobby"
	self.players = {
		--[[
			id = {,		-- Client ID
				-- GENERAL INFO
				name,	-- Player Name
				team,	-- Player Team
				
				-- LOBBY INFO
				host,	-- Host?
				ready,	-- Ready?
				
				-- GAME INFO
				x,		-- X Position
				y,		-- Y Position
				r,		-- Hull Rotation
				tr,		-- Turret Rotation
				hp,		-- Hit Points
				cd,		-- Cool Down
				move,	-- Move Direction (forward, back, or still)
				turn,	-- Turn Direction (left, right, or still)
				turret,	-- Turret Turn Direction (left, right, or still)
			},
		]]--
	}
	self.options = {
		--[[
			tk,		-- Team Kill
			fow,	-- Fog of War
			type,	-- Game Type
			max,	-- Max Players
		]]--
	}
	self.map = {
		--[[
			name,	-- Map Name
			col,	-- Collision Map
		]]--
	}
	
	-- Tick
	self.t = 0
	self.lt = 0
	self.tick = 1
	
	self.moveSpeed		= 64
	self.turnSpeed		= 72
	self.turretSpeed	= 54
	self.reloadSpeed	= 5
	
	self.split		= "۞"
end

--[[
	Start Server
]]--
function Server:start(port)
	self.connection = lube.enetServer()
	self.connection.handshake = "loveTanks"
	self.connection:setPing(true, 6, "lePing\n")
	
	self.connection:listen(tonumber(port))
	print('Server started on port: ' .. port)
	
	self.connection.callbacks.recv = function(d, id) self:recv(d, id) end
	self.connection.callbacks.connect = function(id) self:connect(id) end
	self.connection.callbacks.disconnect = function(id) self:disconnect(id) end
end

--[[
	Client Connects to Server
]]--
function Server:connect(clientId)
	print('Client connected: ' .. tostring(clientId))
end

--[[
	Client Disconnects from Server
]]--
function Server:disconnect(clientId)
	print('Client disconnected: ' .. tostring(clientId))
	self.recvcommands.DISCONNECT(self, cmd, nil, clientId, tostring(clientId))
end

--[[
	Receive Data from Client
]]--
function Server:recv(data, clientId)
	print('Client data received from: ' .. tostring(clientId) .. ' containing: ' .. data)
	
	if data then
		local cmds = string.split(data, self.split)
		
		for _, d in pairs(cmds) do
			local params = json.decode(d)
			
			if params then
				if self.recvcommands[params.cmd] then
					local cmd	= params.cmd
					params.cmd	= nil
					
					self.recvcommands[cmd](self, cmd, params, clientId, tostring(clientId))
				else
					print("Unrecognised command: ", params.cmd)
				end
			end
		end
	end
end

--[[
	Update Server
]]--
function Server:update(dt)
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
	
	-- Sync all players every second
	self.t = self.t + dt
	if self.t - self.lt >= self.tick then
		self.recvcommands.SYNC_PLAYERS(self, "SYNC_PLAYERS", nil, clientId, id)
		self.lt = self.t
	end
end

--[[
	Send Data to Client
]]--
function Server:send(data, clientId)
	if clientId then
		self.connection:send(data .. self.split, clientId)
	else
		self.connection:send(data .. self.split)
	end
end

--[[
	Server Commands
]]--
Server.recvcommands = {
	-- Initialize Player
	CONNECT = function(self, cmd, client, clientId, id)
		self.recvcommands.WHO_AM_I(self, "WHO_AM_I", nil, clientId, id)
		self.recvcommands.SYNC_PLAYERS(self, "SYNC_PLAYERS", nil, clientId, id)
		
		local player	= {
			id		= id,
			name	= client.name,
		}
		
		self.recvcommands.CREATE_PLAYER(self, "CREATE_PLAYER", player, clientId, id)
		
		local chat	= {
			scope	= "GLOBAL",
			msg		= "has connected.",
		}
		
		self.recvcommands.CHAT(self, "CHAT", chat, clientId, id)
	end,
	
	-- Destroy Player
	DISCONNECT = function(self, cmd, params, clientId, id)
		local chat	= {
			scope	= "GLOBAL",
			msg		= "has disconnected.",
		}
		
		self.recvcommands.CHAT(self, "CHAT", chat, clientId, id)
		self.recvcommands.REMOVE_PLAYER(self, "REMOVE_PLAYER", nil, clientId, id)
	end,
	
	-- Send Chat Message
	CHAT = function(self, cmd, chat, clientId, id)
		local data	= json.encode({
			cmd		= cmd,
			scope	= chat.scope,
			msg		= self.players[id].name .. ": " .. chat.msg,
		})
		self:send(data)
	end,
	
	SYNC_PLAYERS = function(self, cmd, params, clientId, id)
		local players	= {}
		local empty		= true
		
		for k, v in pairs(self.players) do
			players[k] = v
		end
		
		for id, _ in pairs(players) do
			empty = false
			break
		end
		
		if empty then return end
		
		players.cmd = cmd
		local data	= json.encode(players)
		self:send(data)
	end,
	
	CREATE_PLAYER = function(self, cmd, player, clientId, id)
		-- If first player, player becomes host
		local count = 0
		local host = false
		
		for id, player in pairs(self.players) do
			for k, v in pairs(player) do
				print(k,v)
				if k == "host" and v == true then
					host = true
					break
				end
			end
		end
		
		if host then
			player.host		= false
			player.ready	= false
		else
			player.host		= true
			player.ready	= true
		end
		
		player.team		= 1
		
		-- debug
		player.x		= 128
		player.y		= 128
		player.r		= 30
		player.tr		= 45
		player.hp		= 100
		player.cd		= 0
		player.move		= "s"
		player.turn		= "s"
		player.turret	= "s"
		
		self.players[id] = {}
		for k,v in pairs(player) do
			self.players[id][k] = v
		end
		
		player.cmd	= cmd
		local data	= json.encode(player)
		self:send(data)
	end,
	
	-- Send Updated Player Data to Clients
	UPDATE_PLAYER = function(self, cmd, player, clientId, id)
		for k,v in pairs(player) do
			self.players[id][k] = v
		end
		
		player.cmd	= cmd
		local data	= json.encode(player)
		self:send(data)
	end,
	
	REMOVE_PLAYER = function(self, cmd, params, clientId, id)
		self.players[id] = nil
		
		local data	= json.encode({
			cmd	= cmd,
			id	= id,
		})
		self:send(data)
	end,
	
	-- Send Client ID to Client
	WHO_AM_I = function(self, cmd, params, clientId, id)
		local data	= json.encode({
			cmd	= cmd,
			id	= id,
		})
		self:send(data, clientId)
	end,
	
	START_GAME = function(self, cmd, params, clientId, id)
		self.state = "gameplay"
		
		local data	= json.encode({
			cmd	= cmd,
		})
		self:send(data)
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
