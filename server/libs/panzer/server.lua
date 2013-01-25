Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE"

Server = Class {
    function(self)
		self.players	= {}
		
		self.t			= 0
		self.lt			= 0
		self.tick		= 1/40
	end
}

--[[
	Start Server
	
	port		= Port to listen on
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
	
	clientId		= Unique client ID
]]--
function Server:connect(clientId)
	print('Client connected: ' .. tostring(clientId))
end

--[[
	Client Disconnects from Server
	
	clientId		= Unique client ID
]]--
function Server:disconnect(clientId)
	print('Client disconnected: ' .. tostring(clientId))
	
	local str = json.encode({
		scope = "GLOBAL",
		msg = "has disconnected.",
	})
	self:sendChat(str, clientId)
	
	self.players[tostring(clientId)] = nil
end

--[[
	Receive Data from Client
	
	data			= Data received
	clientId		= Unique client ID
]]--
function Server:recv(data, clientId)
	print('Client data received from: ' .. tostring(clientId) .. ' containing: ' .. data)
	
	if data then
		cmd, params = data:match("^(%S*) (.*)")
		
		if cmd == "CONNECT" then
			self:clientConnect(params, clientId)
		elseif cmd == "CHAT" then
			self:sendChat(params, clientId)
		elseif cmd == "UPDATESTATE" then
			self:updateState(params, clientId)
		else
			print("Unrecognized command: ", cmd)
		end
	end
end

--[[
	Update Server
	
	dt				= Delta time
]]--
function Server:update(dt)
	self.connection:update(dt)
	
	self.t = self.t + dt
	if self.t - self.lt >= self.tick then
		
		self.lt = self.t
	end
end

--[[
	Client Connected to Server
	
	params			= Nickname
	clientId		= Unique client ID
]]--
function Server:clientConnect(params, clientId)
	local id = tostring(clientId)
	local client = json.decode(params)
	
	self.players[id] = {
		name	= client.name,
		team	= 0,
	}
	
	local str = json.encode({
		scope = "GLOBAL",
		msg = "has connected.",
	})
	
	self:sendChat(str, clientId)
end

--[[
	Send Chat Message
	
	params			= Scope, Message, Nickname
	clientId		= Unique client ID
]]--
function Server:sendChat(params, clientId)
	local id = tostring(clientId)
	local chat = json.decode(params)
	local str = json.encode({
		scope = chat.scope,
		msg = self.players[id].name .. ": " .. chat.msg,
	})
	local data = string.format("%s %s", "CHAT", str)
	
	self.connection:send(data)
end

function Server:updateState(params, clientId)
	local id = tostring(clientId)
	local state = json.decode(params)
	local str = json.encode({
		id		= id,
		x		= state.x,
		y		= state.y,
		r		= state.r,
		tr		= state.tr,
	})
	local data = string.format("%s %s", "UPDATESTATE", str)
	
	self.connection:send(data)
end
