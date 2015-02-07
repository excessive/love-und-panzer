local cdata   = require "libs.cdata"
local packets = {}

-- all structs get a type field so we don't lose our minds.
function add_struct(name, fields, map)
	local struct = string.format("typedef struct { uint8_t type; %s } %s;", fields, name)
	cdata:new_struct(name, struct)

	-- the packet_type struct isn't a real packet, so don't index it.
	if map then
		map.name = name
		table.insert(packets, map)
		packets[name] = #packets
	end
end

-- Slightly special, I guess.
add_struct("packet_type", "")

add_struct(
	"player_whois", [[
		uint16_t id;
	]], {
		"id",
	}
)

add_struct(
	"player_name", [[
		uint16_t id;
		unsigned char name[64];
	]], {
		"id",
		"name",
	}
)

add_struct(
	"player_create", [[
		uint16_t id;
		uint8_t flags;
		int32_t model;
		int32_t decals;
		int32_t accessories;
		int32_t costumes;
		uint16_t hp;
		float turret;
		float turret_velocity;
		float cannon_x,       cannon_y;
		float position_x,     position_y,     position_z;
		float orientation_x,  orientation_y,  orientation_z;
		float velocity_x,     velocity_y,     velocity_z;
		float rot_velocity_x, rot_velocity_y, rot_velocity_z;
		float scale_x,        scale_y,        scale_z;
		float acceleration;
		unsigned char name[64];
	]], {
		"id",
		"flags",
		"model",
		"decals",
		"accessories",
		"costumes",
		"hp",
		"turret",
		"turret_velocity",
		"cannon_x",       "cannon_y",
		"position_x",     "position_y",     "position_z",
		"orientation_x",  "orientation_y",  "orientation_z",
		"velocity_x",     "velocity_y",     "velocity_z",
		"rot_velocity_x", "rot_velocity_y", "rot_velocity_z",
		"scale_x",        "scale_y",        "scale_z",
		"acceleration",
		"name",
	}
)

add_struct(
	"player_action", [[
		uint16_t id;
		uint16_t action;
	]], {
		"id",
		"action",
	}
)

add_struct(
	"player_update_c", [[
		uint16_t id;
		uint16_t hp;
		float cannon_x, cannon_y;
	]], {
		"id",
		"hp",
		"cannon_x", "cannon_y",
	}
)

add_struct(
	"player_update_f", [[
		uint16_t id;
		float turret;
		float turret_velocity;
		float position_x,     position_y,     position_z;
		float orientation_x,  orientation_y,  orientation_z;
		float velocity_x,     velocity_y,     velocity_z;
		float rot_velocity_x, rot_velocity_y, rot_velocity_z;
		float acceleration;
	]], {
		"id",
		"turret",
		"turret_velocity",
		"position_x",     "position_y",     "position_z",
		"orientation_x",  "orientation_y",  "orientation_z",
		"velocity_x",     "velocity_y",     "velocity_z",
		"rot_velocity_x", "rot_velocity_y", "rot_velocity_z",
		"acceleration",
	}
)

return { cdata=cdata, packets=packets }
