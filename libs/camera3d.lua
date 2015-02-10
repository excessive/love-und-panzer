local Class = require "libs.hump.class"
local cpml = require "libs.cpml"

local Camera = Class {}

-- Camera assumes Y-forward, Z-up
function Camera:init(position, direction)
	self.fov  = 45
	self.near = 0.0001
	self.far  = 10.0

	self.view       = cpml.mat4()
	self.projection = cpml.mat4()

	self.position   = position  or cpml.vec3(0, 0, 0)
	self.direction  = direction or cpml.vec3(0, 1, 0)
	self.pre_offset = cpml.vec3(0, 0, 0)
	self.offset     = cpml.vec3(0, 0, 0)
	self.up         = cpml.vec3(0, 0, 1)

	-- up/down limit (radians)
	self.pitch_limit       = math.pi / 2.1
	self.current_pitch     = 0
	self.mouse_sensitivity = 15 -- higher = slower

	self:update()
end

function Camera:grab(grabbing)
	local w, h = love.graphics.getDimensions()
	love.mouse.setGrabbed(grabbing)
	love.mouse.setVisible(not grabbing)
end

function Camera:move(vector, speed)
	local side    = self.direction:cross(self.up)
	self.position = self.position + vector.x * side:normalize() * speed
	self.position = self.position + vector.y * self.direction:normalize() * speed
	self.position = self.position + vector.z * self.up:normalize() * speed
end

function Camera:move_to(vector)
	self.position.x = vector.x
	self.position.y = vector.y
	self.position.z = vector.z
end

function Camera:rotateXY(mx, my)
	local function rotate_camera(view, angle, axis)
		local temp = cpml.quat(
			axis.x * math.sin(angle/2),
			axis.y * math.sin(angle/2),
			axis.z * math.sin(angle/2),
			math.cos(angle/2)
		)

		local quat_view = cpml.quat(
			view.x,
			view.y,
			view.z,
			0
		)

		local result = (temp * quat_view) * temp:conjugate()
		view.x = result.x
		view.y = result.y
		view.z = result.z
	end

	local w, h = love.graphics.getDimensions()

	local mouse_direction = {
		x = math.rad(mx / self.mouse_sensitivity),
		y = math.rad(my / self.mouse_sensitivity)
	}

	self.current_pitch = self.current_pitch + mouse_direction.y

	-- don't rotate up/down more than self.pitch_limit
	if self.current_pitch > self.pitch_limit then
		self.current_pitch = self.pitch_limit
		mouse_direction.y  = 0
	elseif self.current_pitch < -self.pitch_limit then
		self.current_pitch = -self.pitch_limit
		mouse_direction.y  = 0
	end

	-- get the axis to rotate around the x-axis.
	local axis = self.direction:cross(self.up)
	axis = axis:normalize()

	-- important: y, then x
	rotate_camera(self.direction, mouse_direction.y, axis)
	rotate_camera(self.direction, mouse_direction.x, cpml.vec3(0, 0, 1))
end

-- Figure out the view matrix
function Camera:update()
	local w, h = love.graphics.getDimensions()

	if not self.forced_transforms then
		self.view = cpml.mat4()
			:translate(self.pre_offset)
			:look_at(self.position, self.position + self.direction, self.up)
			:translate(self.offset)
	end

	self.projection = self.projection:identity()
	self.projection = self.projection:perspective(math.rad(self.fov), w/h, self.near, self.far)
end

function Camera:send(shader, view_name, proj_name)
	shader:send(view_name or "u_view", self.view:to_vec4s())
	shader:send(proj_name or "u_projection", self.projection:to_vec4s())
end

function Camera:to_view_matrix()
	return self.view
end

function Camera:to_projection_matrix()
	return self.projection
end

function Camera:set_range(near, far)
	self.near = near
	self.far  = far
end

function Camera:add_fov(fov)
	self.fov = self.fov + fov
end

function Camera:set_fov(fov)
	self.fov = fov
end

-- We don't need this for anything yet
-- function Camera:to_quat()
-- 	return cpml.quat(self.x, self.y, self.z, 1)
-- end

return Camera
