local ffi          = require "ffi"
local cpml         = require "libs.cpml"
local lube         = require "libs.lube"
local packet_types = require "packet_types"
local cdata        = packet_types.cdata
local packets      = packet_types.packets
local Client       = {}

-- Connect to Server
function Client:connect(host, port)
	self.connection = lube.enetClient()
	self.connection.handshake = "loveTanks"
	self.connection:setPing(true, 2, "Ping\n")
	self.host = host
	self.port = port

	local connected, err = self.connection:connect(host, tonumber(port), true)
	if connected then
		print("Connect to " .. host .. ":" .. port)
	end

	function self.connection.callbacks.recv(d) self:recv(d) end

	return connected, err
end

function Client:disconnect()
	self.connection:disconnect()
end

-- Receive Data from Server
function Client:recv(data)
	if data then
		local header = cdata:decode("packet_type", data)

		local map = packets[header.type]
		if not map then
			console.e("Invalid packet type (%s) from server!", header.type)
			return
		end

		self.recvcommands[map.name](self, cdata:decode(map.name, data))
	end
end

-- Update Client
function Client:update(dt)
	self.connection:update(dt)
end

-- Send Data to Server
function Client:send(data)
	self.connection:send(data)
end

-- Client Commands
Client.recvcommands = {}

function Client.recvcommands:player_whois(data)
	Signal.emit("player-whois", data.id)
end

function Client.recvcommands:player_name(data)
	Signal.emit("player-name", data.id, ffi.string(data.name))
end

function Client.recvcommands:player_create(data)
	local player = {
		id              = data.id,
		name            = ffi.string(data.name),
		flags           = data.flags,
		model           = data.model,
		decals          = data.decals,
		accessories     = data.accessories,
		costumes        = data.costumes,
		hp              = data.hp,
		turret          = data.turret,
		cannon          = cpml.vec2(data.cannon_x,       data.cannon_y),
		position        = cpml.vec3(data.position_x,     data.position_y,     data.position_z),
		orientation     = cpml.vec3(data.orientation_x,  data.orientation_y,  data.orientation_z),
		velocity        = cpml.vec3(data.velocity_x,     data.velocity_y,     data.velocity_z),
		rot_velocity    = cpml.vec3(data.rot_velocity_x, data.rot_velocity_y, data.rot_velocity_z),
		turret_velocity = data.turret_velocity,
		scale           = cpml.vec3(data.scale_x,        data.scale_y,        data.scale_z),
		acceleration    = data.acceleration,
	}

	Signal.emit("player-create", data.id, player)
end

function Client.recvcommands:player_action(data)
	Signal.emit("player-action", data.id, data.action)
end

function Client.recvcommands:player_update_c(data)
	local update = {
		hp     = data.hp,
		cannon = cpml.vec2(data.cannon_x, data.cannon_y),
	}

	Signal.emit("player-update_c", data.id, update)
end

function Client.recvcommands:player_update_f(data)
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

return Client
