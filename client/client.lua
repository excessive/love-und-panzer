Class = require "libs.hump.class"
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
	self.split			= "$$"
end

--[[
	Connect to Server
	
	host			= Server host
	port			= Server port
]]--
function Client:connect(host, port)
	self.connection = lube.tcpClient()
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
					
					self.recvcommands[cmd](self, d)
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
end

--[[
	Send Data to Server
]]--
function Client:send(data)
	self.connection:send(data)
end

--[[
	Client Commands
]]--
Client.recvcommands = {
	
	-- Post Chat Message
	CHAT = function(self, params)
		local chat = json.decode(params)
		
		if chat.scope == "GLOBAL" then
			self.chat.global = chat.msg
		elseif chat.scope == "GAME" then
			self.chat.game = chat.msg
		elseif chat.scope == "TEAM" then
			self.chat.team = chat.msg
		end
	end,
	
	-- Confirm Ready to Play
	READY = function(self, params)
		local player = json.decode(params)
		client.players[player.id].ready = player.ready
	end,
	
	-- Player Connected
	CREATE_PLAYER = function(self, params)
		local player = json.decode(params)
		self.createPlayers[player.id] = player
	end,
	
	-- Update Player Data
	UPDATE_PLAYER = function(self, params)
		local player = json.decode(params)
		self.updatePlayers[player.id] = player
	end,
	
	-- Player Disconnected
	REMOVE_PLAYER = function(self, params)
		local player = json.decode(params)
		self.removePlayers[player.id] = player
	end,
	
	-- Set Data					KILL ME
	SET_DATA = function(self, params)
		local data = json.decode(params)
		
		self.options	= data.options
		self.map		= data.map
	end,
	
	-- Set ID
	WHO_AM_I = function(self, params)
		local data = json.decode(params)
		self.id = data.id
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
