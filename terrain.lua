local lume = require "libs.lume"
local cpml = require "libs.cpml"
local Class = require "libs.hump.class"
local Entity = require "entity"

local terrain = Class {}
terrain:include(Entity)

function terrain:init(name, data, shader, gamma, texture)
	Entity.init(self, {})
	self.model   = {
		data   = data,
		shader = love.graphics.newShader(shader, shader),

		-- dummy data so the map loader doesn't blow up.
		stats  = {
			vertices  = 0,
			triangles = 0,
			textures  = 0
		}
	}
	self.type    = "terrain"
	self.name    = name
	self.gamma   = gamma
	self.texture = love.graphics.newImage(texture)
	self.texture:setMipmapFilter("linear")
	self.texture:setFilter("linear", "linear", 16)
	self.texture:setWrap("repeat", "repeat")
end

function terrain:draw()
	local data   = self.model.data
	local shader = self.model.shader

	love.graphics.setShader(shader)
	shader:send("u_map_Kd", self.texture)
	shader:send("u_gamma", self.gamma)

	local count = 1
	for y=0, data.chunks_y-1 do
		for x=0, data.chunks_x-1 do
			if self.debug_geometry then
				if (y % 2 == 0 and x % 2 == 0) or (y % 2 == 1 and x % 2 == 1) then
					shader:send("u_Ka", { 0.05, 0.0, 0.05 })
				else
					shader:send("u_Ka", { 0, 0, 0 })
				end
			else
				shader:send("u_Ka", { 0, 0, 0 })
			end
			shader:send("u_model", cpml.mat4()
				:translate(cpml.vec3((data.size-1)*x, (data.size-1)*y, 0))
				:to_vec4s()
			)
			love.graphics.draw(data.mesh[count])
			count = count + 1
		end
	end

	love.graphics.setShader()
end

-- The chunk size is *15*, not 16, when calculating which tile you're on.
-- 16 is the *vertex* count, which means *15* faces each.
-- This happens to be a really fucking annoying thing when calculating all this bullshit.
function terrain:get_tile(position)
	local data     = self.model.data
	local size     = data.size
	local chunks_x = data.chunks_x
	local chunks_y = data.chunks_y
	local chunk_x  = math.floor(position.x / (size-1)) + 1
	local chunk_y  = math.floor(position.y / (size-1)) + 1
	local tile_x   = math.floor(position.x % (size-1)) + 1
	local tile_y   = math.floor(position.y % (size-1)) + 1

	if chunk_x <= 0 or chunk_x > data.chunks_x or
	   chunk_y <= 0 or chunk_y > data.chunks_y then
		return false
	end

	local chunk	 = data.grid[chunk_y][chunk_x]
	local n      = data.data[chunk].n
	local v      = data.data[chunk].v
	local vertex = (tile_y - 1) * size + tile_x

	if tile_x <= 0 or tile_y <= 0 or tile_x >= size or tile_y >= size then
		return false
	end

	return self:set_tile(vertex, chunk, chunk_x, chunk_y, size, n, v)
end

-- World Space
function terrain:get_offset(chunk_x, chunk_y, size)
	return cpml.vec3(
		(size-1)*chunk_x-(size-1),
		(size-1)*chunk_y-(size-1),
		0
	)
end

-- Our map is currently always square.
function terrain:get_bounding_box()
	local data = self.model.data
	return {
		min = cpml.vec2(0, 0),
		max = cpml.vec2(data.chunks_x*(data.size-1), data.chunks_y*(data.size-1))
	}
end

function terrain:set_tile(vertex, chunk, chunk_x, chunk_y, size, n, v)
	local tile = {}
	tile.vertices = {}

	table.insert(tile.vertices, vertex)
	table.insert(tile.vertices, vertex + 1)
	table.insert(tile.vertices, vertex + size + 1)
	table.insert(tile.vertices, vertex + size)

	assert(tile.vertices[3] <= size*size)
	assert(tile.vertices[4] <= size*size)

	tile.positions = {
		v[tile.vertices[1]],
		v[tile.vertices[2]],
		v[tile.vertices[3]],
		v[tile.vertices[4]],
	}

	tile.normal = (
		n[tile.vertices[1]] +
		n[tile.vertices[2]] +
		n[tile.vertices[3]] +
		n[tile.vertices[4]]
	):normalize()

	tile.center  = cpml.mesh.average(tile.positions)
	tile.chunk   = chunk
	tile.chunk_x = chunk_x
	tile.chunk_y = chunk_y
	tile.offset  = self:get_offset(chunk_x, chunk_y, size)

	return tile
end

return terrain
