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
	
	self.t			= 0
	self.lt			= 0
	self.tick		= 1/40
	
	self.split		= "$$"
end

--[[
	Start Server
]]--
function Server:start(port)
	self.connection = lube.tcpServer()
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
	self.recvcommands.DISCONNECT(self, nil, clientId)
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
					
					d = json.encode(params)
					self.recvcommands[cmd](self, d, clientId)
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
	
	self.t = self.t + dt
	if self.t - self.lt >= self.tick then
		
		self.lt = self.t
	end
end

--[[
	Server Commands
]]--
Server.recvcommands = {
	-- Initialize Player
	CONNECT = function(self, params, clientId)
		local id		= tostring(clientId)
		local client	= json.decode(params)
		
		self.recvcommands.WHO_AM_I(self, nil, clientId)
		self.recvcommands.SEND_PLAYERS(self, nil, clientId)
		
		local player	= json.encode({
			id		= id,
			name	= client.name,
		})
		
		self.recvcommands.CREATE_PLAYER(self, player, clientId)
		
		local chat	= json.encode({
			scope	= "GLOBAL",
			msg		= "has connected.",
		})
		
		self.recvcommands.CHAT(self, chat, clientId)
	end,
	
	-- Destroy Player
	DISCONNECT = function(self, params, clientId)
		local data	= json.encode({
			scope	= "GLOBAL",
			msg		= "has disconnected.",
		})
		
		self.recvcommands.CHAT(self, data, clientId)
		self.recvcommands.REMOVE_PLAYER(self, nil, clientId)
	end,
	
	-- Send Chat Message
	CHAT = function(self, params, clientId)
		local cmd	= "CHAT"
		local id	= tostring(clientId)
		local chat	= json.decode(params)
		
		local data	= json.encode({
			cmd		= cmd,
			scope	= chat.scope,
			msg		= self.players[id].name .. ": " .. chat.msg,
		})
		
		self.connection:send(data .. self.split)
	end,
	
	-- Confirm Ready to Play
	READY = function(self, params, clientId)
		local cmd	= "READY"
		local id	= tostring(clientId)
		local ready	= json.decode(params)
		
		local data	= json.encode({
			cmd		= cmd,
			id		= id,
			ready	= ready.ready,
		})
		
		self.connection:send(data .. self.split)
	end,
	
	SEND_PLAYERS = function(self, params, clientId)
		local cmd		= "SEND_PLAYERS"
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
		
		self.connection:send(data .. self.split, clientId)
	end,
	
	CREATE_PLAYER = function(self, params, clientId)
		local cmd		= "CREATE_PLAYER"
		local id		= tostring(clientId)
		local player	= json.decode(params)
		
		-- If first player, player becomes host
		local count = 0
		for k, _ in pairs(self.players) do
			count = count + 1
		end
		
		if count == 0 then
			player.host		= true
			player.ready	= true
		else
			player.host		= false
			player.ready	= false
		end
		
		player.team		= 1
		
		-- debug
		player.x		= 128
		player.y		= 128
		player.r		= 30
		player.tr		= 45
		player.hp		= 100
		player.cd		= 0
		
		self.players[id] = {}
		for k,v in pairs(player) do
			self.players[id][k] = v
		end
		
		player.cmd	= cmd
		local data	= json.encode(player)
		self.connection:send(data .. self.split)
	end,
	
	-- Send Updated Player Data to Clients
	UPDATE_PLAYER = function(self, params, clientId)
		local cmd		= "UPDATE_PLAYER"
		local id		= tostring(clientId)
		local player	= json.decode(params)
		
		for k,v in pairs(player) do
			self.players[id][k] = v
		end
		
		player.cmd	= cmd
		local data	= json.encode(player)
		
		self.connection:send(data .. self.split)
	end,
	
	REMOVE_PLAYER = function(self, params, clientId)
		local cmd	= "REMOVE_PLAYER"
		local id	= tostring(clientId)
		
		self.players[id] = nil
		
		local data	= json.encode({
			cmd	= cmd,
			id	= id,
		})
		
		self.connection:send(data .. self.split)
		
	end,
	
	-- Send Data to Clients					THIS IS DEPRACATED GET RID OF IT ASAP
	SET_DATA = function(self, params, clientId)
		local data	= json.encode({
			options	= self.options,
			map		= self.map,
		})
	end,
	
	-- Send Client ID to Client
	WHO_AM_I = function(self, params, clientId)
		local cmd	= "WHO_AM_I"
		local id	= tostring(clientId)
		
		local data	= json.encode({
			cmd		= cmd,
			id		= id,
		})
		
		self.connection:send(data .. self.split, clientId)
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
	
	for sub, j in string.gfind(s, match) do
		i = i + 1
		t[i] = sub
		f = j
	end
	
	if i ~= 0 then
		t[i+1] = string.sub(s, f)
	end
	
	return t
end
