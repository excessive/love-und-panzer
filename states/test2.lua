local Camera = require "libs.camera3d"
local iqe = require "libs.iqe"
local Entity = require "entity"
local cpml = require "libs.cpml"
local ffi = require "ffi"

local Test = {}

function Test:enter(from)
	self.camera = Camera()
	self.camera.position = cpml.vec3(0, -2.5, 0.75)

	self.pancakes = Entity(iqe.load("assets/models/pancakes2.iqe"))
	self.pancakes.model:load_shader("assets/shaders/shader.glsl")
	self.pancakes.model:load_texture("assets/textures/rough-aluminum.jpg")
	self.pancakes.position		= cpml.vec3(0, 0, 0)
	self.pancakes.orientation	= cpml.vec3(0, 0, 0)
	self.pancakes.scale			= cpml.vec3(1, 1, 1)

	self.pancakes:interpolate("keyframes", 1, 2, 10)
end

function Test:update(dt)
	self.camera:update(dt)
	self.pancakes:update(dt)

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

function Test:keypressed(k, r)
	if k == "escape" then
		Gamestate.switch(require "states.menu")
	end

	if k == "return" then
		self.camera.position = cpml.vec3(0, -16, 0)
	end
end

function Test:draw()
	gl.Clear(GL.DEPTH_BUFFER_BIT)
	gl.Enable(GL.DEPTH_TEST)
	gl.Disable(GL.BLEND)
	gl.CullFace(GL.BACK)
	gl.DepthFunc(GL.LESS)
	gl.DepthRange(0, 1)
	gl.ClearDepth(1.0)
	gl.FrontFace(GL.CW)

	local model = cpml.mat4()
		:translate(self.pancakes.position)
		:rotate(self.pancakes.orientation.x, { 1, 0, 0 })
		:rotate(self.pancakes.orientation.y, { 0, 1, 0 })
		:rotate(self.pancakes.orientation.z, { 0, 0, 1 })
		:scale(self.pancakes.scale)

	self.pancakes.model.shader:send("u_model", model:to_vec4s())
	self.camera:send(self.pancakes.model.shader)

	self.pancakes:draw(nil, model)

	love.graphics.setShader()

	gl.FrontFace(GL.CCW)
	gl.Disable(GL.CULL_FACE)
	gl.Disable(GL.DEPTH_TEST)
	gl.Enable(GL.BLEND)


	
	love.graphics.setColor(255, 255, 255, 255)
end

return Test
