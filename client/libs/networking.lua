Class = require "libs.hump.class"
require "libs.LUBE.LUBE"

-- Server

Networking = Class {
    function(self) end
}

function Networking:serverRecv(data, clientId)
	print('Client data received from: ' .. tostring(clientId) .. ' containing: ' .. data)
end

function Networking:serverConn(clientId)
	print('Client connected: ' .. tostring(clientId))
end

function Networking:serverDisconn(clientId)
	print('Client disconnected: ' .. tostring(clientId))
end

function Networking:startServer(port)
	conn = lube.tcpServer()
	conn.handshake = "loveTanks"
	conn:setPing(true, 6, "lePing\n")
	
	conn:listen(tonumber(port))
	print('Server started on port: ' .. port)
	
	conn.callbacks.recv = function(d, id) self:serverRecv(d, id) end
	conn.callbacks.connect = function(id) self:serverConn(id) end
	conn.callbacks.disconnect = function(id) self:serverDisconn(id) end
    
    return conn
end

-- Client

function Networking:clientRecv(data)
	print('Server data received: ' .. data)
end

function Networking:startClient(host, port)
	conn = lube.tcpClient()
	conn.handshake = "loveTanks"
	conn:setPing(true, 2, "lePing\n")
	
	if conn:connect(host, tonumber(port), true) then
		print('Connect to ' .. host .. ': ' .. port)
	end
	
	conn.callbacks.recv = function(d) self:clientRecv(d) end
	
    return conn
end
