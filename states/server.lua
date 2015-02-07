local bit          = require "bit"
local cpml         = require "libs.cpml"
local packet_types = require "packet_types"
local actions      = require "action_enum"
local cdata        = packet_types.cdata
local packets      = packet_types.packets
local Server       = {}

function Server:enter(state)
	local w, h                   = love.graphics.getDimensions()
	lurker_no_lurking            = true
	console.visible              = true
	console.height_divisor       = 1
	console.colors["background"] = { r = 23, g = 55, b = 86,  a = 190 }
	console.colors["input"]      = { r = 40, g = 70, b = 100, a = 255 }
	console.resize(w, h)
	console.clearCommand("list")
	console.clearCommand("load")

	local bg = console.colors.background
	love.graphics.setBackgroundColor(bg.r, bg.g, bg.b, 255)

	self.server = require "server"
	self.server:start(2808)

	Signal.register("player-connect",    function(...) self:player_connect(...)    end)
	Signal.register("player-disconnect", function(...) self:player_disconnect(...) end)
	Signal.register("player-name",       function(...) self:player_name(...)       end)
	Signal.register("player-action",     function(...) self:player_action(...)     end)
	Signal.register("player-update_c",   function(...) self:player_update_c(...)   end)
	Signal.register("player-update_f",   function(...) self:player_update_f(...)   end)

	self.players      = {}
	self.move_speed   = 420/6/6
	self.turn_speed   = 35
	self.turret_speed = 44
end

function Server:update(dt)
	console.visible = true
	self.server:update(dt)
end

function Server:leave()
	Signal.clear_pattern("player%-.*")

	self.players = nil
end

function Server:player_connect(id, client_id)
	local function player_create(player, client)
		local data = {
			type            = packets["player_create"],
			id              = player.id,
			name            = player.name,
			flags           = player.flags,
			model           = player.model,
			decals          = player.decals,
			accessories     = player.accessories,
			costumes        = player.costumes,
			hp              = player.hp,
			turret          = player.turret,
			cannon_x        = player.cannon.x,
			cannon_y        = player.cannon.y,
			position_x      = player.position.x,
			position_y      = player.position.y,
			position_z      = player.position.z,
			orientation_x   = player.orientation.x,
			orientation_y   = player.orientation.y,
			orientation_z   = player.orientation.z,
			velocity_x      = player.velocity.x,
			velocity_y      = player.velocity.y,
			velocity_z      = player.velocity.z,
			rot_velocity_x  = player.rot_velocity.x,
			rot_velocity_y  = player.rot_velocity.y,
			rot_velocity_z  = player.rot_velocity.z,
			turret_velocity = player.turret_velocity,
			scale_x         = player.scale.x,
			scale_y         = player.scale.y,
			scale_z         = player.scale.z,
			acceleration    = player.acceleration,
		}
		local struct  = cdata:set_struct("player_create", data)
		local encoded = cdata:encode(struct)
		self.server:send(encoded, client)
	end

	local function set_byte(integer, segment)
		return bit.lshift(integer, 8*(segment-1))
	end

	local data = {
		type = packets["player_whois"],
		id   = id,
	}
	local struct  = cdata:set_struct("player_whois", data)
	local encoded = cdata:encode(struct)
	self.server:send(encoded, client_id)

	for _, player in pairs(self.players) do
		player_create(player, client_id)
	end

	local tank = set_byte(1,   4)
	local r    = set_byte(255, 3)
	local g    = set_byte(255, 2)
	local b    = set_byte(255, 1)

	local player = {
		id              = id,
		flags           = 0,
		model           = bit.bor(tank, r, g, b), -- Model       (1 byte) & RGB (3 bytes)
		decals          = 0,                      -- Decals      (1 byte each)
		accessories     = 0,                      -- Accessories (1 byte each)
		costumes        = 0,                      -- Costume     (Turret, Hull, Cannon, Tracks)
		hp              = 100,
		turret          = 0,
		cannon          = cpml.vec2(0, 0),
		position        = cpml.vec3(10, 10, 10),
		orientation     = cpml.vec3(0, 0, 0),
		velocity        = cpml.vec3(0, 0, 0),
		rot_velocity    = cpml.vec3(0, 0, 0),
		turret_velocity = 0,
		scale           = cpml.vec3(1, 1, 1),
		acceleration    = 0,
	}

	local name
	if self.players[id] then
		name = self.players[id].name
	end

	self.players[id]      = player
	self.players[id].name = name or "Panzer"

	player_create(player)
end

function Server:player_disconnect(id)
	self.players[id] = nil

	local data = {
		type   = packets["player_action"],
		id     = id,
		action = actions.disconnect,
	}
	local struct  = cdata:set_struct("player_action", data)
	local encoded = cdata:encode(struct)
	self.server:send(encoded)
end

function Server:player_name(id, name)
	local player = self.players[id] or {}
	player.name  = name

	local data = {
		type = packets["player_name"],
		id   = id,
		name = player.name,
	}
	local struct  = cdata:set_struct("player_name", data)
	local encoded = cdata:encode(struct)
	self.server:send(encoded)
end

function Server:player_action(id, action)

end

function Server:player_update_c(id, update)
	-- console.i("%d: %s, %s, %s", id, update.hp, update.turret, update.cannon)

	local player  = self.players[id]
	player.hp     = update.hp     or player.hp
	player.cannon = update.cannon or player.cannon

	local data = {
		type     = packets["player_update_c"],
		id       = id,
		hp       = player.hp,
		cannon_x = player.cannon.x,
		cannon_y = player.cannon.y,
	}
	local struct  = cdata:set_struct("player_update_c", data)
	local encoded = cdata:encode(struct)
	self.server:send(encoded)
end

function Server:player_update_f(id, update)
	--console.i("%d: %s, %s, %s, %s", id, update.position, update.orientation, update.velocity, update.rot_velocity)

	local player           = self.players[id]
	player.turret          = update.turret          or player.turret
	player.position        = update.position        or player.position
	player.orientation     = update.orientation     or player.orientation
	player.velocity        = update.velocity        or player.velocity
	player.rot_velocity    = update.rot_velocity    or player.rot_velocity
	player.turret_velocity = update.turret_velocity or player.turret_velocity
	player.acceleration    = update.acceleration    or player.acceleration

	local server = self.server.connection.socket
	local peer   = server:get_peer(id)
	local ping   = peer:round_trip_time() / 1000 / 2

	player.position      = player.position      + player.velocity * ping
	player.orientation.x = player.orientation.x + math.rad(player.rot_velocity.x  * ping)
	player.orientation.y = player.orientation.y + math.rad(player.rot_velocity.y  * ping)
	player.orientation.z = player.orientation.z + math.rad(player.rot_velocity.z  * ping)
	player.turret        = player.turret        + math.rad(player.turret_velocity * ping)

	local data = {
		type            = packets["player_update_f"],
		id              = id,
		turret          = player.turret,
		turret_velocity = player.turret_velocity,
		position_x      = player.position.x,
		position_y      = player.position.y,
		position_z      = player.position.z,
		orientation_x   = player.orientation.x,
		orientation_y   = player.orientation.y,
		orientation_z   = player.orientation.z,
		velocity_x      = player.velocity.x,
		velocity_y      = player.velocity.y,
		velocity_z      = player.velocity.z,
		rot_velocity_x  = player.rot_velocity.x,
		rot_velocity_y  = player.rot_velocity.y,
		rot_velocity_z  = player.rot_velocity.z,
		acceleration    = player.acceleration,
	}
	local struct  = cdata:set_struct("player_update_f", data)
	local encoded = cdata:encode(struct)
	self.server:send(encoded)
end

return Server
