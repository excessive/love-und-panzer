Class = require "libs.hump.class"
require "libs.LUBE.LUBE"

Client = Class {
    function(self) end
}

function Client:start(host, port)
	client = lube.tcpClient()
	client.handshake = "loveTanks"
	client:setPing(true, 2, "lePing\n")
	
	if client:connect(host, tonumber(port), true) then
		print('Connect to ' .. host .. ': ' .. port)
	end
	
	client.callbacks.recv = function(d) self:recv(d) end
	
    return client
end

function Client:recv(data)
	print('Server data received: ' .. data)
end
