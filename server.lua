local ffi          = require "ffi"
local cpml         = require "libs.cpml"
local lube         = require "libs.lube"
local packet_types = require "packet_types"
local cdata        = packet_types.cdata
local packets      = packet_types.packets
local Server       = {}

-- Start Server
function Server:start(port)
	port = port or 2808
	self.connection = lube.enetServer()
	self.connection.handshake = "loveTanks"
	self.connection:setPing(true, 6, "lePing\n")

	self.connection:listen(tonumber(port))
	console.i("Server started on port: " .. port)

	function self.connection.callbacks.recv(d, id) self:recv(d, id) end
	function self.connection.callbacks.connect(id) self:connect(id) end
	function self.connection.callbacks.disconnect(id) self:disconnect(id) end
end

-- Client Connects to Server
function Server:connect(client_id)
	console.i("Client connected: " .. tostring(client_id))
	Signal.emit("player-connect", tonumber(client_id), client_id)
end

-- Client Disconnects from Server
function Server:disconnect(client_id)
	console.i("Client disconnected: " .. tostring(client_id))
	Signal.emit("player-disconnect", tonumber(client_id))
end

-- Receive Data from Server
function Server:recv(data, client_id)
	if data then
		local header = cdata:decode("packet_type", data)

		local map = packets[header.type]
		if not map then
			console.e("Invalid packet type (%s) from client %d!", header.type, client_id)
			return
		end

		self.recvcommands[map.name](self, cdata:decode(map.name, data), client_id)
	end
end

-- Update Server
function Server:update(dt)
	self.connection:update(dt)
end

-- Send Data to Client
function Server:send(data, client_id)
	self.connection:send(data, client_id)
end

-- Server Commands
Server.recvcommands = {}

function Server.recvcommands:player_name(data, client_id)
	Signal.emit("player-name", data.id, ffi.string(data.name))
end

function Server.recvcommands:player_action(data, client_id)
	Signal.emit("player-action", data.id, data.action)
end

function Server.recvcommands:player_update_c(data, client_id)
	local update = {
		hp     = data.hp,
		cannon = cpml.vec2(data.cannon_x, data.cannon_y),
	}

	Signal.emit("player-update_c", data.id, update)
end

function Server.recvcommands:player_update_f(data, client_id)
	local update = {
		turret          = data.turret,
		position        = cpml.vec3(data.position_x,     data.position_y,     data.position_z),
		orientation     = cpml.vec3(data.orientation_x,  data.orientation_y,  data.orientation_z),
		velocity        = cpml.vec3(data.velocity_x,     data.velocity_y,     data.velocity_z),
		rot_velocity    = cpml.vec3(data.rot_velocity_x, data.rot_velocity_y, data.rot_velocity_z),
		turret_velocity = data.turret_velocity,
		acceleration    = data.acceleration,
	}

	Signal.emit("player-update_f", data.id, update)
end

return Server
