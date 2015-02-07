-- Terrain generator.
local Class = require "libs.hump.class"
local cpml = require "libs.cpml"

local generator = Class {}

-- TODO: Sub-tasks
function generator:init(size, chunks_x, chunks_y)
	self.size = size or 16
	self.chunks_x = chunks_x or 1
	self.chunks_y = chunks_y or 1
	self.total_chunks = self.chunks_x * self.chunks_y
	self.x = 1
	self.y = 1
	self.count = 1
	self.current_task = 1

	self.states = {
		{ run = self.generate_vertices },
		{ run = self.generate_indices },
		{ run = self.generate_buffer },
		{ --[[ done! ]] }
	}

	self.grid = {}
	self.data = {}
	self.mesh = {}
	self.faces = {}

	local count = 1
	for y=1, self.chunks_y do
		self.grid[y] = {}
		for x=1, self.chunks_x do
			self.grid[y][x] = count
			self.data[count] = { v={}, f={}, t={}, n={}, x=x, y=y }
			self.mesh[count] = {}
			self.faces[count] = {}
			count = count + 1
		end
	end
end

function generator:get_data()
	return {
		grid = self.grid,
		data = self.data,
		mesh = self.mesh,
		size = self.size,
		faces = self.tris,
		chunks_x = self.chunks_x,
		chunks_y = self.chunks_y,
	}
end

function generator:step()
	local task = self.states[self.current_task]

	--self.current_task = 1

	if task.run then
		task.run(self)
		-- not done yet
		return false, self.count / self.total_chunks
	else
		-- we're done!
		if self.count == self.total_chunks then
			return true, self.count / self.total_chunks
		else
			self.current_task = 1
			self.count = self.count + 1

			if self.x == self.chunks_x then
				self.x = 1
				self.y = self.y + 1
			else
				self.x = self.x + 1
			end

			return false, self.count / self.total_chunks
		end
	end
end

function generator:finish_task()
	local task = self.states[self.current_task]
	self.current_task = self.current_task + 1
end

function generator:generate_vertices()
	local data = self.data[self.count]
	local size = self.size

	-- Generate vertices
	for j=0, size-1 do
		for i=0, size-1 do
			local v = cpml.vec3(i, j, 0)
			local gv = cpml.vec3((size-1)*data.x+i, (size-1)*data.y+j, 0)
			local influence_1 = cpml.simplex.Simplex2D((gv / 200):tuple())
			local influence_2 = cpml.simplex.Simplex2D((gv / 150):tuple()) * 1.1
			v.z = v.z + cpml.simplex.Simplex2D((gv / 300):tuple()) * 20
			v.z = v.z + cpml.simplex.Simplex2D((gv / 100):tuple()) * 4.0 * influence_1
			v.z = v.z + cpml.simplex.Simplex2D((gv / 20):tuple()) * 1.0 * influence_2
			local distance_to_center = math.sqrt(
				math.pow(gv.x - (size-1)*self.chunks_x / 2, 2) +
				math.pow(gv.y - (size-1)*self.chunks_y / 2, 2)
			)
			v.z = v.z * (distance_to_center * 0.015) + (distance_to_center * 0.2)
			v.z = v.z + cpml.simplex.Simplex2D((gv / 5):tuple()) * -0.25 * influence_1
			v.z = v.z + cpml.simplex.Simplex2D((gv / 15):tuple()) * -0.35 * influence_1
			v.z = v.z + cpml.simplex.Simplex2D((gv / 4):tuple()) * -0.1 * influence_2
			v.z = v.z / 2

			table.insert(data.v, v)
			table.insert(data.t, { i/5, j/5 })
		end
	end

	self:finish_task()
end

function generator:generate_indices()
	local data = self.data[self.count]
	local size = self.size
	-- Build index buffer and calculate vertex normals.
	for j=1, size-1 do
		for i=1, size-1 do
			local row = (j-1)*size
			local next = row+size
			local f1 = {
				{v=row+i},
				{v=next+i},
				{v=next+i+1},
			}
			local f2 = {
				{v=row+i},
				{v=next+i+1}, -- move this line down -> boom!
				{v=row+i+1},
			}
			table.insert(data.f, f1)
			table.insert(data.f, f2)

			data.n[f1[1].v] = cpml.mesh.compute_normal(
				data.v[f1[1].v],
				data.v[f1[2].v],
				data.v[f1[3].v]
			)
			data.n[f1[2].v] = data.n[f1[1].v]
			data.n[f1[3].v] = data.n[f1[1].v]

			data.n[f2[1].v] = data.n[f1[1].v]
			data.n[f2[2].v] = data.n[f1[1].v]
			data.n[f2[3].v] = data.n[f1[1].v]
		end
	end

	self:finish_task()
end

function generator:generate_buffer()
	local data = self.data[self.count]
	local vb_data = {}
	for k, v in ipairs(data.v) do
		local current = {}
		table.insert(current, v.x)
		table.insert(current, v.y)
		table.insert(current, v.z)

		table.insert(current, data.n[k].x or 0)
		table.insert(current, data.n[k].y or 0)
		table.insert(current, data.n[k].z or 0)

		table.insert(current, data.t[k][1] or 0)
		table.insert(current, data.t[k][2] or 0)

		table.insert(vb_data, current)
	end

	local tris = {}
	for _, v in ipairs(data.f) do
		table.insert(tris, v[1].v)
		table.insert(tris, v[2].v)
		table.insert(tris, v[3].v)
	end

	local m = love.graphics.newMesh(0, nil, "triangles")

	local layout = {
		"float", 3,
		"float", 3,
		"float", 2
	}
	local buffer = love.graphics.newVertexBuffer(layout, vb_data, "static")

	if not buffer then
		error("Something went terribly wrong creating the vertex buffer.")
	end

	-- Use VertexPosition for LOVE.
	m:setVertexAttribute("VertexPosition", buffer, 1)
	m:setVertexAttribute("v_normal", buffer, 2)
	m:setVertexAttribute("v_coord", buffer, 3)
	m:setVertexMap(tris)

	self.faces[self.count] = tris
	self.mesh[self.count] = m

	self:finish_task()
end

return generator
