local ffi    = require "ffi"
local bit    = require "bit"
local Entity = require "entity"
local cpml   = require "libs.cpml"
local Class  = require "libs.hump.class"
local iqe    = require "libs.iqe"
local Player = Class {}
Player:include(Entity)

local tanks = {
	{
		model    = "assets/models/tank.iqe",
		shader   = "assets/shaders/shader.glsl",
		material = "assets/materials/tank.mtl",
	},
}

function Player:init(player)
	Entity.init(self, player)
	-- bitshift flags to determine access levels
	-- bitshift decals
	-- bitshift accessories
	-- bitshift costumes

	local function get_byte(integer, segment)
		local byte = bit.rshift(integer, 8*(segment-1))
		return bit.band(byte, 0x000000FF)
	end

	local tank = get_byte(player.model, 4)
	local r    = get_byte(player.model, 3)
	local g    = get_byte(player.model, 2)
	local b    = get_byte(player.model, 1)

	self.type            = "player"
	self.id              = player.id
	self.name            = ffi.string(player.name)
	self.hp              = player.hp
	self.turret          = player.turret
	self.cannon          = player.cannon
	self.velocity        = player.velocity
	self.rot_velocity    = player.rot_velocity
	self.turret_velocity = player.turret_velocity
	self.acceleration    = player.acceleration
	self.color           = cpml.vec3(r, g, b)
	self.model           = iqe.load(tanks[tank].model)
	self.decals          = {}
	self.accessories     = {}
	self.costumes        = {}
	self.flags           = {}
	self.radius          = 5.92 / 2
	self.model:load_shader(tanks[tank].shader)
	self.model:load_material(tanks[tank].material)
end

return Player
