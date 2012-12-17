Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE.LUBE"

Server = Class {
    function(self)
		self.games		= {}
		self.players	= {}
		self.serverlist	= {}
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
	
	self:sendServerList(clientId)
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
		elseif cmd == "SERVERLIST" then
			self:sendServerList(clientId)
		elseif cmd == "NEWGAME" then
			self:newGame(params, clientId)
		elseif cmd == "JOINGAME" then
			self:joinGame(params, clientId)
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
		name = client.name
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

--[[
	Create New Game
	
	params			= Name, Password
	clientId		= Unique client ID
]]--
function Server:newGame(params, clientId)
	local id = tostring(clientId)
	local str = json.decode(params)
	local pass = false
	
	if str.pass == "" then
		str.pass = nil
	end
	
	if str.pass then
		pass = true
	end
	
	while true do
		local r = math.random(999999)
		
		if not self.games[r] then
			self.games[r] = {
				state		= "lobby",
				name		= str.name,
				pass		= str.pass,
				host		= self.players[id].name,
				players		= {},
			}
			
			self.serverlist[r] = {
				name	= str.name,
				host	= self.players[id].name,
				state	= "lobby",
				players	= 0,
				pass	= pass,
			}
			
			local data = json.encode({id=r})
			self:joinGame(data, clientId)
			
			break
		end
	end
end

--[[
	Join Game
	
	params			= Unique game ID
	clientId		= Unique client ID
]]--
function Server:joinGame(params, clientId)
	local id = tostring(clientId)
	local game = json.decode(params)
	
	self.players[id].game = game.id
	self.games[game.id].players[id] = self.players[id]
	self.serverlist[game.id].players = self.serverlist[game.id].players + 1
	
	local str = json.encode(self.games[game.id])
	local data = string.format("%s %s", "UPDATEGAME", str)
	self.connection:send(data, clientId)
end

--[[
	Send Server List
	clientId		= Unique client ID
]]--
function Server:sendServerList(clientId)
	local str = json.encode(self.serverlist)
	local data = string.format("%s %s", "SERVERLIST", str)
	
	self.connection:send(data, clientId)
end