Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE"

Client = Class {}

function Client:init()
	self.chat = {}
	self.state = {}
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
		print('Connect to ' .. host .. ': ' .. port)
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
		cmd, params = data:match("^(%S*) (.*)")
		
		if self.recvcommands[cmd] then
			self.recvcommands[cmd](self, params)
		else
			print("Unrecognized command: ", cmd)
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
	CHAT				= function(self, params)
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
	READY				= function(self, params)
		local state = json.decode(params)
		client.state.players[state.id].ready = state.ready
	end,
	
	-- Update Player Data
	UPDATE_PLAYER		= function(self, params)
		local state = json.decode(params)
		self.state.players[state.id].x = state.x
		self.state.players[state.id].y = state.y
		self.state.players[state.id].r = state.r
		self.state.players[state.id].tr = state.tr
	end,
	
	-- Set State
	SET_STATE			= function(self, params)
		self.state = json.decode(params)
	end,
	
	-- Set ID
	WHO_AM_I			= function(self, params)
		local str = json.decode(params)
		self.id = str.id
	end,
}
