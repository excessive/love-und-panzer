local Camera = require "libs.camera3d"
local cpml = require "libs.cpml"
local ffi = require "ffi"
local lume = require "libs.lume"
local Load = require "libs.map_loader"

local CubeTest = {}

function CubeTest:enter(from)
	lurker.postswap = function(f)
		Gamestate.switch(require "states.cube_test")
	end

	self.camera = Camera()
	self.camera.position = cpml.vec3(0, -16, 0)

	self.map = Load.new("assets/maps/test_cube_map.lua")
	self.map:set_camera(self.camera)

	local s = love.filesystem.read("assets/shaders/shader.glsl")
	self.shader = love.graphics.newShader(s, s)
end

function CubeTest:update(dt)
	self.map:update(dt)

	local isDown = love.keyboard.isDown
	local holding = {
		left	= isDown "left"		or isDown "a",
		right	= isDown "right"	or isDown "d",
		up		= isDown "up"		or isDown "w",
		down	= isDown "down"		or isDown "s",
		jump	= isDown "kp0"		or isDown " ",
		crouch	= isDown "rshift"	or isDown "lshift",
	}

	local speed = 5
	if not console.visible then
		if holding.right then
			self.camera.position.x = self.camera.position.x + speed * dt
		end
		if holding.left then
			self.camera.position.x = self.camera.position.x - speed * dt
		end
		if holding.up then
			self.camera.position.y = self.camera.position.y + speed * dt
		end
		if holding.down then
			self.camera.position.y = self.camera.position.y - speed * dt
		end
		if holding.jump then
			self.camera.position.z = self.camera.position.z + speed * dt
		end
		if holding.crouch then
			self.camera.position.z = self.camera.position.z - speed * dt
		end
	end
end

function CubeTest:keypressed(k, r)
	if k == "escape" then
		Gamestate.switch(require "states.menu")
	end

	if k == "return" then
		self.camera.position = cpml.vec3(0, -16, 0)
	end
end

function CubeTest:draw()
	local w, h = love.graphics.getDimensions()

	gl.Clear(GL.DEPTH_BUFFER_BIT)
	gl.Enable(GL.DEPTH_TEST)
	gl.Disable(GL.BLEND)
	gl.CullFace(GL.BACK)
	gl.DepthFunc(GL.LESS)
	gl.DepthRange(0, 1)
	gl.ClearDepth(1.0)

	self.camera:send(self.shader)
	love.graphics.setShader(self.shader)
	local text_thingies = self.map:draw()
	love.graphics.setShader()

	gl.Disable(GL.CULL_FACE)
	gl.Disable(GL.DEPTH_TEST)
	gl.Enable(GL.BLEND)


	for i, v in ipairs(text_thingies) do
		if v.position.z < 0 then
			love.graphics.setColor(127, 127, 127, 127)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.print(v.text, v.position.x, h - v.position.y)
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function CubeTest:leave()
	Signal.clear_pattern("input%-.*")
end

return CubeTest
