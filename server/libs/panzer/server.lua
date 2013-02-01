Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE"

Server = Class {
    function(self)
		self.state = {
			screen = "lobby",
			players = {
				--[[
					id = {,		-- Client ID
						-- GENERAL INFO
						name,	-- Player Name
						team,	-- Player Team
						host,	-- Host?
						
						-- LOBBY INFO
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
			},
			options = {
				--[[
					tk,		-- Team Kill
					fow,	-- Fog of War
					type,	-- Game Type
					max,	-- Max Players
				]]--
			},
			map = {
				--[[
					name,	-- Map Name
					col,	-- Collision Map
				]]--
			},
		}
		
		self.t			= 0
		self.lt			= 0
		self.tick		= 1/40
	end
}

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
	
	local str = json.encode({
		scope = "GLOBAL",
		msg = "has disconnected.",
	})
	self.recvcommands.CHAT(self, str, clientId)
	
	self.state.players[tostring(clientId)] = nil
end

--[[
	Receive Data from Client
]]--
function Server:recv(data, clientId)
	print('Client data received from: ' .. tostring(clientId) .. ' containing: ' .. data)
	
	if data then
		cmd, params = data:match("^(%S*) (.*)")
		
		if self.recvcommands[cmd] then
			self.recvcommands[cmd](self, params, clientId)
		else
			print("Unrecognized command: ", cmd)
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
	CONNECT				= function(self, params, clientId)
		local id = tostring(clientId)
		local client = json.decode(params)
		
		self.state.players[id] = {
			name	= client.name,
			team	= 1,
			host	= false,
			ready	= false,
			
			-- debug
			x = 128,
			y = 128,
			r = 30,
			tr = 45,
		}
		
		local str = json.encode({
			scope = "GLOBAL",
			msg = "has connected.",
		})
		
		self.recvcommands.WHO_AM_I(self, nil, clientId)
		self.recvcommands.SET_STATE(self, nil, clientId)
		self.recvcommands.CHAT(self, str, clientId)
	end,
	
	-- Send Chat Message
	CHAT				= function(self, params, clientId)
		local id = tostring(clientId)
		local chat = json.decode(params)
		local str = json.encode({
			scope = chat.scope,
			msg = self.state.players[id].name .. ": " .. chat.msg,
		})
		local data = string.format("%s %s", "CHAT", str)
		
		self.connection:send(data)
	end,
	
	-- Confirm Ready to Play
	READY				= function(self, params, clientId)
		local id = tostring(clientId)
		local ready = json.decode(params)
		local str = json.encode({
			id = id,
			ready = ready.ready,
		})
		local data = string.format("%s %s", "READY", str)
		
		self.connection:send(data)
	end,
	
	-- Send Updated Player Data to Clients
	UPDATE_PLAYER		= function(self, params, clientId)
		local id = tostring(clientId)
		local state = json.decode(params)
		
		self.state.players[id].x = state.x
		self.state.players[id].y = state.y
		self.state.players[id].r = state.r
		self.state.players[id].tr = state.tr
		
		local str = json.encode({
			id		= id,
			x		= state.x,
			y		= state.y,
			r		= state.r,
			tr		= state.tr,
		})
		local data = string.format("%s %s", "UPDATE_PLAYER", str)
		
		self.connection:send(data)
	end,
	
	-- Send State to Clients
	SET_STATE			= function(self, params, clientId)
		local str = json.encode(self.state)
		local data = string.format("%s %s", "SET_STATE", str)
		
		self.connection:send(data)
	end,
	
	-- Send Client ID to Client
	WHO_AM_I			= function(self, params, clientId)
		local id = tostring(clientId)
		local str = json.encode({id=id})
		local data = string.format("%s %s", "WHO_AM_I", str)
		
		self.connection:send(data, clientId)
	end,
}
