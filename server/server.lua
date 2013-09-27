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
	
	local data = json.encode({
		scope	= "GLOBAL",
		msg		= "has disconnected.",
	})
	self.recvcommands.CHAT(self, data, clientId)
	
	self.players[tostring(clientId)] = nil
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
					self.recvcommands[params.cmd](self, d, clientId)
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
		
		self.players[id] = {
			name	= client.name,
			team	= 1,
			host	= false,
			ready	= false,
			
			-- debug
			x		= 128,
			y		= 128,
			r		= 30,
			tr		= 45,
			hp		= 100,
			cd		= 0,
		}
		
		local data	= json.encode({
			scope	= "GLOBAL",
			msg		= "has connected.",
		})
		
		self.recvcommands.WHO_AM_I(self, nil, clientId)
		self.recvcommands.SET_DATA(self, nil, clientId)
		self.recvcommands.CHAT(self, data, clientId)
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
	
	-- Send Updated Player Data to Clients
	UPDATE_PLAYER = function(self, params, clientId)
		local cmd		= "UPDATE_PLAYER"
		local id		= tostring(clientId)
		local player	= json.decode(params)
		
		self.players[id].x	= player.x
		self.players[id].y	= player.y
		self.players[id].r	= player.r
		self.players[id].tr	= player.tr
		
		local data	= json.encode({
			cmd		= cmd,
			id		= id,
			x		= player.x,
			y		= player.y,
			r		= player.r,
			tr		= player.tr,
		})
		
		self.connection:send(data .. self.split)
	end,
	
	-- Send Data to Clients
	SET_DATA = function(self, params, clientId)
		local cmd	= "SET_DATA"
		
		local data	= json.encode({
			cmd		= cmd,
			players	= self.players,
			options	= self.options,
			map		= self.map,
		})
		
		self.connection:send(data .. self.split)
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
