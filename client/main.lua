-- vim: set noet ts=8 sw=8:

require "libs.input"
require "libs.TEsound"
require "libs.LUBE.LUBE"
local GameState = require "libs.hump.gamestate"
require "states.menu"
require "states.game"
PORT = 4356


function love.load()
	GameState.registerEvents()
	GameState.switch(menu)
end

-- Server

function serverRecv(data, clientId)

end

function serverConn(clientId)
end

function serverDisconn(clientId)
end

function startServer()
	conn = lube.tcpServer()
	conn.handshake = "loveTanks"
	conn:setPing(true, 16, "lePing\n")
	conn:listen(PORT)
	conn.callbacks.recv = serverRecv
	conn.callbacks.connect = serverConn
	conn.callbacks.disconnect = serverDisconn
end

-- Client

function clientRecv(data)
end

function startClient(host, port)
	conn = lube.tcpClient()
	conn.handshake = "loveTanks"
	conn:setPing(true, 2, "lePing\n")
	conn:connect(host, port, true)
	conn.callbacks.recv = clientRecv
end
