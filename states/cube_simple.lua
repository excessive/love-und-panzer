local Camera = require "libs.camera3d"
local iqe = require "libs.iqe"
local Entity = require "entity"
local cpml = require "libs.cpml"
local ffi = require "ffi"

local CubeTest = {}

function CubeTest:enter(from)
	self.camera = Camera()
	self.camera.position = cpml.vec3(0, -16, 0)

	self.cube = Entity(iqe.load("assets/models/test_cube.iqe"))
	self.cube.model:load_shader("assets/shaders/shader.glsl")
	self.cube.model:load_texture("assets/textures/rough-aluminum.jpg")
	self.cube.position		= cpml.vec3(0, 0, 0)
	self.cube.orientation	= cpml.vec3(0, 0, 0)
	self.cube.scale			= cpml.vec3(1, 1, 1)
end

function CubeTest:update(dt)
	self.camera:update(dt)
	self.cube:update(dt)

	local isDown = love.keyboard.isDown
	local holding = {
		right	= isDown "right"	or isDown "d",
		left	= isDown "left"		or isDown "a",
		up		= isDown "up"		or isDown "w",
		down	= isDown "down"		or isDown "s",
		jump	= isDown "kp0"		or isDown " ",
		crouch	= isDown "rshift"	or isDown "lshift",
	}

	local speed = 5
	if holding.right	then self.camera.position.x = self.camera.position.x + speed * dt end
	if holding.left		then self.camera.position.x = self.camera.position.x - speed * dt end
	if holding.up		then self.camera.position.y = self.camera.position.y + speed * dt end
	if holding.down		then self.camera.position.y = self.camera.position.y - speed * dt end
	if holding.jump		then self.camera.position.z = self.camera.position.z + speed * dt end
	if holding.crouch	then self.camera.position.z = self.camera.position.z - speed * dt end
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
	gl.Clear(GL.DEPTH_BUFFER_BIT)
	gl.Enable(GL.DEPTH_TEST)
	gl.Disable(GL.BLEND)
	gl.CullFace(GL.BACK)
	gl.DepthFunc(GL.LESS)
	gl.DepthRange(0, 1)
	gl.ClearDepth(1.0)
	gl.FrontFace(GL.CW)

	local w, h = love.graphics.getDimensions()
	local viewport = { 0, 0, w, h }

	local model = cpml.mat4()
		:translate(self.cube.position)
		:rotate(self.cube.orientation.x, { 1, 0, 0 })
		:rotate(self.cube.orientation.y, { 0, 1, 0 })
		:rotate(self.cube.orientation.z, { 0, 0, 1 })
		:scale(self.cube.scale)

	self.cube.model.shader:send("u_model", model:to_vec4s())
	self.camera:send(self.cube.model.shader)

	self.cube:draw(nil, model)

	love.graphics.setShader()

	gl.FrontFace(GL.CCW)
	gl.Disable(GL.CULL_FACE)
	gl.Disable(GL.DEPTH_TEST)
	gl.Enable(GL.BLEND)


	
	love.graphics.setColor(255, 255, 255, 255)
end

return CubeTest
