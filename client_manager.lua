local Player       = require "player"
local actions      = require "action_enum"
local packet_types = require "packet_types"
local cpml         = require "libs.cpml"
local cdata        = packet_types.cdata
local packets      = packet_types.packets
local Manager      = {}

function Manager:init(connection, name, map, players)
	self.client  = connection
	self.name    = name
	self.map     = map
	self.players = players
	self.tick_c  = 1 / 5
	self.tick_f  = 1 / 20
	self.dt_c    = 0
	self.dt_f    = 0

	Signal.register("player-whois",    function(...) self:player_whois(...)    end)
	Signal.register("player-create",   function(...) self:player_create(...)   end)
	Signal.register("player-name",     function(...) self:player_name(...)     end)
	Signal.register("player-action",   function(...) self:player_action(...)   end)
	Signal.register("player-update_c", function(...) self:player_update_c(...) end)
	Signal.register("player-update_f", function(...) self:player_update_f(...) end)

	Signal.register("send-shoot", function(...) self:send_shoot(...) end)
end

function Manager:update(dt)
	self.client:update(dt)

	for _, player in pairs(self.players) do
		player.position      = player.position      + player.velocity * dt
		player.orientation.x = player.orientation.x + player.rot_velocity.x  * dt
		player.orientation.y = player.orientation.y + player.rot_velocity.y  * dt
		player.orientation.z = player.orientation.z + player.rot_velocity.z  * dt
		player.turret        = player.turret        + player.turret_velocity * dt

		if player.id ~= self.id then
			local adjust = 0.1
			player.position    = player.position:lerp(player.real_position, adjust)
			player.orientation = player.orientation:lerp(player.real_orientation, adjust)
			player.turret      = player.turret + adjust * (player.real_turret - player.turret)
		end

		player.direction = player.orientation:orientation_to_direction()
	end

	self.dt_c = self.dt_c + dt
	if self.dt_c >= self.tick_c and self.id then
		self.dt_c = self.dt_c - self.tick_c

		local player = self.players[self.id]
		local data   = {
			type     = packets["player_update_c"],
			id       = self.id,
			hp       = player.hp,
			cannon_x = player.cannon.x,
			cannon_y = player.cannon.y,
		}

		local struct  = cdata:set_struct("player_update_c", data)
		local encoded = cdata:encode(struct)
		self.client:send(encoded)
	end

	self.dt_f = self.dt_f + dt
	if self.dt_f >= self.tick_f and self.id then
		self.dt_f = self.dt_f - self.tick_f

		local player = self.players[self.id]
		local data   = {
			type            = packets["player_update_f"],
			id              = self.id,
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

		local struct = cdata:set_struct("player_update_f", data)
		local encoded = cdata:encode(struct)
		self.client:send(encoded)
	end

	if self.id then
		self.players[self.id].velocity        = cpml.vec3(0, 0, 0)
		self.players[self.id].rot_velocity    = cpml.vec3(0, 0, 0)
		self.players[self.id].turret_velocity = 0
	end
end

function Manager:destroy()
	self.id      = nil
	self.map     = nil
	self.players = nil
	self.tick_c  = nil
	self.tick_f  = nil
	self.dt_c    = nil
	self.dt_f    = nil

	self.client:disconnect()
	self.client  = nil

	Signal.clear_pattern("player%-.*")
end

function Manager:send_name(name)
	local data    = {
		type = packets["player_name"],
		id   = self.id,
		name = name,
	}

	local struct  = cdata:set_struct("player_name", data)
	local encoded = cdata:encode(struct)
	self.client:send(encoded .. name)
end

-- Networking Signals
function Manager:player_whois(id)
	self.id = id
	self:send_name(self.name)
end

function Manager:player_name(id, name)
	self.players[id]      = self.players[id] or {}
	self.players[id].name = name or "Panzerkampfwagen IV"
end

function Manager:player_create(id, player)
	local player     = Player(player)
	self.players[id] = player
	self.map:add_object(player)

	player.real_position    = player.position
	player.real_orientation = player.orientation
	player.real_turret      = player.turret
	player.direction        = player.orientation:orientation_to_direction()
	player.up               = cpml.vec3(0, 0, 1)

end

function Manager:player_action(id, action)
	if actions[action] then
		local state = Gamestate:current()
		state["action_"..actions[action]](state, id)
	else
		console.e("Invalid action: %d", action)
	end
end

function Manager:player_update_c(id, update)
	if id ~= self.id then
		self.players[id]        = self.players[id] or {}
		self.players[id].hp     = update.hp        or self.players[id].hp
		self.players[id].cannon = update.cannon    or self.players[id].cannon
	end
end

function Manager:player_update_f(id, update)
	if id ~= self.id then
		local peer   = self.client.connection.peer
		local ping   = peer:round_trip_time() / 1000 / 2

		update.position      = update.position      + update.velocity * ping
		update.orientation.x = update.orientation.x + math.rad(update.rot_velocity.x  * ping)
		update.orientation.y = update.orientation.y + math.rad(update.rot_velocity.y  * ping)
		update.orientation.z = update.orientation.z + math.rad(update.rot_velocity.z  * ping)
		update.turret        = update.turret        + math.rad(update.turret_velocity * ping)

		self.players[id]                  = self.players[id]       or {}
		self.players[id].real_turret      = update.turret          or self.players[id].real_turret
		self.players[id].real_position    = update.position        or self.players[id].real_position
		self.players[id].real_orientation = update.orientation     or self.players[id].real_orientation
		self.players[id].velocity         = update.velocity        or self.players[id].velocity
		self.players[id].rot_velocity     = update.rot_velocity    or self.players[id].rot_velocity
		self.players[id].turret_velocity  = update.turret_velocity or self.players[id].turret_velocity
		self.players[id].acceleration     = update.acceleration    or self.players[id].acceleration
	end
end

function Manager:send_shoot()
	local data   = {
		type     = packets["player_action"],
		id       = self.id,
		action   = actions.shoot,
	}

	local struct  = cdata:set_struct("player_action", data)
	local encoded = cdata:encode(struct)
	self.client:send(encoded)
end

return Manager
