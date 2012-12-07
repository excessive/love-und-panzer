Class = require "libs.hump.class"
require "libs.LUBE.LUBE"

Server = Class {
    function() end
}

function Server:start(port)
	server = lube.tcpServer()
	server.handshake = "loveTanks"
	server:setPing(true, 6, "lePing\n")
	
	server:listen(tonumber(port))
	print('Server started on port: ' .. port)
	
	server.callbacks.recv = function(d, id) self:recv(d, id) end
	server.callbacks.connect = function(id) self:connect(id) end
	server.callbacks.disconnect = function(id) self:disconnect(id) end
	
	return server
end

function Server:recv(data, clientId)
	print('Client data received from: ' .. tostring(clientId) .. ' containing: ' .. data)
end

function Server:connect(clientId)
	print('Client connected: ' .. tostring(clientId))
end

function Server:disconnect(clientId)
	print('Client disconnected: ' .. tostring(clientId))
end
