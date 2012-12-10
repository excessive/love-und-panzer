Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE.LUBE"

Client = Class {
    function(self) end
}

--[[
	Connect to Server
	
	host		= Server host
	port		= Server port
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
]]--
function Client:recv(data)
	print('Server data received: ' .. data)
	
	if data then
		cmd, params = data:match("^(%S*) (.*)")
		
		if cmd == "GAMELIST" then
			self:gameList(params)
		--[[
		elseif cmd == "MOVE" then
			local x, y = params:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y)
			x, y = tonumber(x), tonumber(y)

			local ent = world[entity] or {x=0, y=0}
			world[entity] = {x=ent.x+x, y=ent.y+y}
		elseif cmd == "AT" then
			local x, y = params:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y)
			x, y = tonumber(x), tonumber(y)

			world[entity] = {x=x, y=y}
		]]--
		else
			print("Unrecognized command: ", cmd)
		end
	end
end

function Client:update(dt)
	self.connection:update(dt)
end

function Client:gameList(params)
	local list = json.decode(params)
	
	for k,v in pairs(list) do
		print(k,v)
	end
end
