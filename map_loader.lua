local cpml   = require "libs.cpml"
local iqe    = require "libs.iqe"
local Class  = require "libs.hump.class"
local Entity = require "entity"
local Player = require "player"
local Load   = Class {}
local Map    = Class {}

local function add_stats(self, stats)
	self.stats.vertices  = self.stats.vertices  + stats.vertices
	self.stats.triangles = self.stats.triangles + stats.triangles
	self.stats.textures  = self.stats.textures  + (stats.textures or 0)
end

local function remove_stats(self, stats)
	self.stats.vertices  = self.stats.vertices  - stats.vertices
	self.stats.triangles = self.stats.triangles - stats.triangles
	self.stats.textures  = self.stats.textures  - (stats.textures or 0)
end

function Load.new(filename)
	local map
	if filename then
		if not love.filesystem.isFile(filename) then
			error(string.format("Invalid map. File %s not found.", filename))
			return
		end

		console.i(string.format("Loading map: %s...", filename))

		-- Load map
		map = love.filesystem.load(filename)

		setfenv(map, {})
		map = setmetatable(map(), {__index = Map})
		map.filename = filename
	else
		map = {}
		setmetatable(map, {__index = Map})
	end

	map:init()

	return map
end

function Map:set_camera(camera)
	self.camera = camera
end

function Map:init()
	local t = love.timer.getTime()

	self.text_offset      = cpml.vec3(0, 0, 3.25)
	self.loaded_objects   = {}
	self.static_objects   = {}
	self.animated_objects = {}
	self.draw_data        = {}
	self.stats            = {
		vertices  = 0,
		triangles = 0,
		textures  = 0
	}

	-- probably just created an empty map, skip this stuff.
	if #self.loaded_objects == 0 then
		return
	end

	for i, object in pairs(self.objects) do
		self:load_object(object)
	end

	t = love.timer.getTime() - t

	console.i(
		"Successfully loaded map: %s with %d objects (%d static, %d animated) in %fs",
		self.filename, #self.loaded_objects, #self.static_objects, #self.animated_objects, t
	)
end

function Map:load_object(object)
	if love.filesystem.isFile(object.model) then
		local entity

		if object.cannon then -- unique to player entities
			entity = Player(object)
		elseif object.gamma then -- unique to terrain
			entity = Terrain(object)
		else
			entity = Entity(object)
		end

		self:add_object(entity)
	else
		console.e("Invalid model %s. Ignored.", object.model)
	end
end

function Map:add_object(object)
	if object.model.data.animation then
		table.insert(self.animated_objects, object)
	else
		table.insert(self.static_objects, object)
	end

	table.insert(self.loaded_objects, object)
	add_stats(self, object.model.stats)
end

function Map:remove_object(id)
	for k, object in ipairs(self.loaded_objects) do
		if k == id then
			if object.model.data.animation then
				for j, o in ipairs(self.animated_objects) do
					if o.id == id then
						table.remove(self.animated_objects, j)
						break
					end
				end
			else
				for j, o in ipairs(self.static_objects) do
					if o.id == id then
						table.remove(self.static_objects, j)
						break
					end
				end
			end

			table.remove(self.loaded_objects, k)
			remove_stats(self, object.model.stats)
			break
		end
	end
end

-- Get map id from network id
function Map:get_id(id)
	for k, object in ipairs(self.loaded_objects) do
		if object.id == id then
			return k
		end
	end

	return false
end

function Map:get(name)
	for _, object in ipairs(self.loaded_objects) do
		if object.name == name then
			return object
		end
	end

	return false
end

function Map:update(dt)
	for _, object in ipairs(self.loaded_objects) do
		object:update(dt)
	end

	self.camera:update()
end

function Map:draw()
	gl.Clear(bit.bor(tonumber(GL.DEPTH_BUFFER_BIT), tonumber(GL.COLOR_BUFFER_BIT)))

	gl.Enable(GL.DEPTH_TEST)
	gl.DepthFunc(GL.LESS)
	gl.DepthRange(0, 1)
	gl.ClearDepth(1.0)

	gl.Enable(GL.CULL_FACE)
	gl.CullFace(GL.BACK)

	-- IQE/IQM models use CW winding. I'm not entirely sure why, but that's how it is.
	-- It's convenient for us to follow IQM's winding, so we do it too.
	gl.FrontFace(GL.CW)

	for _, object in ipairs(self.loaded_objects) do
		-- TODO: Cache transforms for models and only update them if needed.
		local model = cpml.mat4():translate(object.position)
		if not cpml.vec3.isvector(object.orientation) then
			model = model:rotate(object.orientation)
		else
			model = model:rotate(object.orientation.x, { 1, 0, 0 })
			             :rotate(object.orientation.y, { 0, 1, 0 })
			             :rotate(object.orientation.z, { 0, 0, 1 })
		end
		model = model:scale(object.scale)

		object.model.shader:send("u_model", model:to_vec4s())
		self.camera:send(object.model.shader)

		object:draw(self.draw_data[object.id], model)
	end

	gl.FrontFace(GL.CCW)
	gl.Disable(GL.CULL_FACE)
	gl.Disable(GL.DEPTH_TEST)
end

function Map:get_nametags()
	local w, h     = love.graphics.getDimensions()
	local viewport = { 0, 0, w, h }
	local nametags = {}

	for _, object in ipairs(self.loaded_objects) do
		if object.name and object.type == "player" then
			local side = object.direction:cross(object.up)
			local position = cpml.mat4.project(
				object.position +
					object.up * self.text_offset.z +
					object.direction * self.text_offset.y +
					side * self.text_offset.x,
				self.camera.view,
				self.camera.projection,
				viewport
			)

			table.insert(nametags, {
				text     = object.name,
				position = position,
				viewable = self.camera.direction:dot(object.position - self.camera.position) > 0
			})
		end
	end

	return nametags
end

return Load
