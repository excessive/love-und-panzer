Class = require "libs.hump.class"
require "libs.LUBE.LUBE"

-- Server

Networking = Class {
    function(self)
    end
}

function Networking:serverRecv(data, clientId)
        print('Client data received from: ' .. clientId .. ' containing: ' .. data)
end

function Networking:serverConn(clientId)
        print('Client connected: ' .. clientId)
end

function Networking:serverDisconn(clientId)
        print('Client disconnected: ' .. clientId)
end

function Networking:startServer(port)
	conn = lube.tcpServer()
	conn.handshake = "loveTanks"
	conn:setPing(true, 16, "lePing\n")
	conn:listen(tonumber(port))
	conn.callbacks.recv = function(d,id) Networking:serverRecv(d,id) end
	conn.callbacks.connect = function(id) print('CONNECT') end
	--conn.callbacks.connect = Networking:serverConn
	--conn.callbacks.disconnect = Networking:serverDisconn
        print('Server Started on port: ' .. port)
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
	assert(conn:connect(host, tonumber(port), true))
	--conn.callbacks.recv = Networking:clientRecv
        print('Connect to ' .. host .. ':' .. port)
        return conn
end
