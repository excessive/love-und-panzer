local cpml   = require "libs.cpml"
local Class  = require "libs.hump.class"
local iqe    = require "libs.iqe"
local Entity = Class {}

function Entity:init(object)
	self.type                 = "entity"
	self.position             = object.position    or cpml.vec3(0, 0, 0)
	self.orientation          = object.orientation or cpml.vec3(0, 0, 0)
	self.scale                = object.scale       or cpml.vec3(1, 1, 1)
	self.active_animation     = {}
	self.active_interpolation = {}
	self.id                   = 0
	self.dt                   = 0
	self.paused               = false

	if object.model and love.filesystem.isFile(object.model) then
		self.model = iqe.load(object.model)
		self.model:load_shader(object.shader)
		self.model:load_material(object.material)
	end
end

function Entity:update(dt)
	if self.paused then return end

	if self.active_animation.name then
		self.dt = self.dt + dt

		if self.dt >= 1 / self.active_animation.framerate then
			self.dt = self.dt - 1 / self.active_animation.framerate
			self:next_frame()
		end
	end

	if self.active_interpolation.name then
		self.dt = self.dt + dt

		if self.dt >= self.active_interpolation.length then
			self.dt = self.dt - self.active_interpolation.length
		end

		self:next_interpolated_frame()
	end
end

function Entity:draw(map_data, model)
	map_data = map_data or {}

	if self.model.shader then
		love.graphics.setShader(self.model.shader)
		for _, buffer in ipairs(self.model.vertex_buffer) do
			local mtl = self.model.materials[buffer.material]

			if mtl then
				self.model.shader:send("u_Ka", mtl.ka)
				self.model.shader:send("u_Kd", mtl.kd)
				self.model.shader:send("u_Ks", mtl.ks)
				self.model.shader:send("u_Ns", mtl.ns)
				self.model.shader:sendInt("u_shading", mtl.illum)
				self.model.shader:send("u_map_Kd", self.model:get_texture(mtl.map_kd))
			end

			self.model.shader:send("u_map_Kr", self.model:get_texture("assets/textures/rough-aluminum.jpg"))
			self.model.shader:send("u_Kr", { 0.1, 0.1, 0.1 })
			self.model.shader:send("u_Nf", 0.0)

			if self.active_animation.current_frame then
				self:send_frame()
			elseif self.active_interpolation.frame then
				self:send_interpolated_frame()
			else
				self.model.shader:sendInt("u_skinning", 0)
			end

			local name = buffer.name

			if map_data[name] then
				self.model.shader:send("u_model", (map_data[name] * model):to_vec4s())
				love.graphics.draw(buffer.mesh)
				self.model.shader:send("u_model", model:to_vec4s())
			else
				love.graphics.draw(buffer.mesh)
			end
		end

		love.graphics.setShader()
	end
end

function Entity:animate(animation)
	self.active_interpolation = {}

	if not self.model.rigged then
		self.active_animation.name          = nil
		self.active_animation.current_frame = false
		self.model.shader:sendInt("u_skinning", 0)
		return
	end

	local ani    = assert(self.model.data.animation[animation], string.format("No such animation: %s", animation))
	local buffer = self.model.animation_buffer[animation]

	self.active_animation               = {}
	self.active_animation.name          = animation
	self.active_animation.frame         = buffer
	self.active_animation.framerate     = ani.framerate
	self.active_animation.loop          = ani.loop
	self.active_animation.current_frame = 0
	self:next_frame()
end

function Entity:next_frame()
	if self.paused then return end

	local anim = self.active_animation
	if anim.current_frame then
		if anim.current_frame < #anim.frame then
			anim.current_frame = anim.current_frame + 1
			return
		elseif anim.current_frame == #anim.frame and anim.loop then
			anim.current_frame = 1
			return
		end
	end

	anim.current_frame = false
end

function Entity:send_frame()
	local f = self.active_animation.frame
	local cf = self.active_animation.current_frame
	self.model.shader:send("u_bone_matrices", unpack(f[cf]))
	self.model.shader:sendInt("u_skinning", 1)
end

function Entity:interpolate(animation, frame_start, frame_end, length)
--[[
	animation = "keyframes"
	frame_start = 1
	frame_end = 2
	length = 1.35 -- seconds
--]]
	self.active_animation = {}

	if not self.model.rigged then
		self.active_interpolation.name = nil
		self.active_interpolation.current_frame = false
		self.model.shader:sendInt("u_skinning", 0)
		return
	end

	local ani = assert(self.model.data.animation[animation], string.format("No such animation: %s", animation))

	self.active_interpolation             = {}
	self.active_interpolation.name        = animation
	self.active_interpolation.frame_start = frame_start
	self.active_interpolation.frame_end   = frame_end
	self.active_interpolation.length      = length
	self.active_interpolation.loop        = ani.loop
	self:next_interpolated_frame()
end

function Entity:next_interpolated_frame()
	local function calc_bone_matrix(pq1, pq2, s)
		local p1    = cpml.vec3(pq1[1], pq1[2], pq1[3])
		local r1    = cpml.quat(pq1[7], pq1[4], pq1[5], pq1[6])
		local s1    = cpml.vec3(pq1[8], pq1[9], pq1[10])
		local p2    = cpml.vec3(pq2[1], pq2[2], pq2[3])
		local r2    = cpml.quat(pq2[7], pq2[4], pq2[5], pq2[6])
		local s2    = cpml.vec3(pq2[8], pq2[9], pq2[10])
		local pos   = p1:lerp(p2, s)
		local rot   = r1:slerp(r2, s)
		local scale = s1:lerp(s2, s)
		local out   = cpml.mat4()
			:translate(pos)
			:rotate(rot)
			:scale(scale)
		return out
	end

	self.active_interpolation.frame = {}

	local transform = {}
	local animation = self.active_interpolation
	local ani       = self.model.data.animation[animation.name]
	local pq_start  = ani.frame[animation.frame_start].pq
	local pq_end    = ani.frame[animation.frame_end].pq

	for i, pq1 in ipairs(pq_start) do
		local joint    = self.model.data.joint[i]
		local pq2      = pq_end[i]
		local position = self.dt / animation.length -- 0..1
		local m        = calc_bone_matrix(pq1, pq2, position)
		local render   = cpml.mat4()

		if joint.parent > 0 then
			assert(joint.parent < i)
			transform[i] = m * transform[joint.parent]
			render       = self.model.inverse_base[i] * transform[i]
		else
			transform[i] = m
			render       = self.model.inverse_base[i] * m
		end

		table.insert(self.active_interpolation.frame, render:to_vec4s())
	end
end

function Entity:send_interpolated_frame()
	local f = self.active_interpolation.frame
	self.model.shader:send("u_bone_matrices", unpack(f))
	self.model.shader:sendInt("u_skinning", 1)
end

function Entity:play()
	self.paused = false
end

function Entity:pause()
	self.paused = true
end

function Entity:stop()
	self.active_animation     = {}
	self.active_interpolation = {}
end

return Entity
