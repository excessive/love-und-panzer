local cpml = require "libs.cpml"

local geometry = {}

function geometry.new_ray(ballin_ray, length, thickness)
	local ray = {}
	ray.start = cpml.vec3(ballin_ray.point.x, ballin_ray.point.y, ballin_ray.point.z)
	ray.finish = cpml.vec3(ballin_ray.point.x, ballin_ray.point.y, ballin_ray.point.z) + cpml.vec3(ballin_ray.direction) * (length or 1)

	local ray_width = thickness or 0.05

	local vb_data = {}

	for k, v in pairs(ray) do
		local current = {}
		table.insert(current, v.x - ray_width / 2)
		table.insert(current, v.y)
		table.insert(current, v.z)
		table.insert(vb_data, current)

		current = {}
		table.insert(current, v.x + ray_width / 2)
		table.insert(current, v.y)
		table.insert(current, v.z)
		table.insert(vb_data, current)
	end

	for k, v in pairs(ray) do
		local current = {}
		table.insert(current, v.x)
		table.insert(current, v.y - ray_width / 2)
		table.insert(current, v.z)
		table.insert(vb_data, current)

		current = {}
		table.insert(current, v.x)
		table.insert(current, v.y + ray_width / 2)
		table.insert(current, v.z)
		table.insert(vb_data, current)
	end

	local line = {
		1, 2, 3,
		1, 3, 4,

		5, 6, 7,
		5, 7, 8,
	}

	-- HACK: Use the built in vertex positions for UV coords.
	local m = love.graphics.newMesh(0, nil, "triangles")

	local layout = {
		"float", 3
	}
	local buffer = love.graphics.newVertexBuffer(layout, vb_data, "static")

	if not buffer then
		error("Something went terribly wrong creating the vertex buffer.")
	end

	m:setVertexAttribute("VertexPosition", buffer, 1)
	m:setVertexMap(line)

	return m
end

function geometry.new_triangles(t, offset)
	offset = offset or cpml.vec3(0, 0, 0)
	local vb_data = {}
	local indices = {}
	for k, v in ipairs(t) do
		local current = {}
		table.insert(current, v.x + offset.x)
		table.insert(current, v.y + offset.y)
		table.insert(current, v.z + offset.z)
		table.insert(vb_data, current)
		table.insert(indices, k)
	end

	-- HACK: Use the built in vertex positions for UV coords.
	local m = love.graphics.newMesh(0, nil, "triangles")

	local buffer = love.graphics.newVertexBuffer({ "float", 3 }, vb_data, "static")

	if not buffer then
		error("Something went terribly wrong creating the vertex buffer.")
	end

	m:setVertexAttribute("VertexPosition", buffer, 1)
	m:setVertexMap(indices)

	return m, buffer
end

function geometry.update_bounding_box(mesh, buffer, model, min, max)
	local t = geometry.calc_bounding_box(model, min, max)

	local vb_data = {}
	for k, v in ipairs(t) do
		local current = {}
		table.insert(current, v.x)
		table.insert(current, v.y)
		table.insert(current, v.z)
		table.insert(vb_data, current)
	end

	-- console.d("cocks")

	-- buffer:bind()
	for i, v in ipairs(vb_data) do
		buffer:setVertex(i, v[1], v[2], v[3])
	end
	-- buffer:unbind()

	-- mesh:setVertexAttribute("VertexPosition", buffer, 1)
end

function geometry.calc_bounding_box(model, min, max)
	local vertices = {
		cpml.vec3(max.x, max.y, min.z),
		cpml.vec3(max.x, min.y, min.z),
		cpml.vec3(max.x, min.y, max.z),
		cpml.vec3(min.x, min.y, max.z),
		cpml.vec3(min),
		cpml.vec3(max),
		cpml.vec3(min.x, max.y, min.z),
		cpml.vec3(min.x, max.y, max.z),
	}

	for i, v in ipairs(vertices) do
		vertices[i] = cpml.vec3(model * { v.x, v.y, v.z, 1 })
	end

	local tris = {
		vertices[1], vertices[2], vertices[3],
		vertices[2], vertices[4], vertices[3],
		vertices[1], vertices[5], vertices[2],
		vertices[2], vertices[5], vertices[4],
		vertices[6], vertices[3], vertices[4],
		vertices[1], vertices[3], vertices[6],
		vertices[1], vertices[7], vertices[5],
		vertices[6], vertices[7], vertices[1],
		vertices[6], vertices[4], vertices[8],
		vertices[6], vertices[8], vertices[7],
		vertices[5], vertices[8], vertices[4],
		vertices[5], vertices[7], vertices[8],
	}

	return tris
end

function geometry.new_bounding_box(model, min, max)
	local tris = geometry.calc_bounding_box(model, min, max)
	return geometry.new_triangles(tris)
end

return geometry
