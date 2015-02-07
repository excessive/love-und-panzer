local ffi = require "ffi"
local Class = require "libs.hump.class"

-- Just FXAA/Tonemap/CC for now
local PostProcess = Class {}

-- I have a hunch this stuff is gonna be memory-leaky
local function mk_canvas(fsaa, range)
	local w, h = love.graphics.getDimensions()
	local canvas = love.graphics.newCanvas(w, h, range, fsaa)
	assert(canvas)

	love.graphics.setCanvas(canvas)

	local depth = ffi.new("unsigned int[1]", 1)
	gl.GenRenderbuffers(1, depth);
	gl.BindRenderbuffer(GL.RENDERBUFFER, depth[0]);
	if canvas:getFSAA() > 1 then
		-- Note: Be sure to pass in the same number as specified when creating the canvas.
		-- If you use getFSAA() here, it could give you i.e. 4 when you specified 3...
		-- ...breaking everything.
		gl.RenderbufferStorageMultisample(GL.RENDERBUFFER, fsaa, GL.DEPTH_COMPONENT24, w, h)
	else
		gl.RenderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT24, w, h);
	end
	gl.FramebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depth[0]);

	gl.Clear(bit.bor(tonumber(GL.COLOR_BUFFER_BIT), tonumber(GL.DEPTH_BUFFER_BIT)))

	if fsaa > 1 then
		console.i(string.format("Created canvas with FSAA: %d", fsaa))
	else
		console.i("Created canvas without FSAA.")
	end

	local status = gl.CheckFramebufferStatus(GL.FRAMEBUFFER);
	if status ~= GL.FRAMEBUFFER_COMPLETE then
		console.e("Framebuffer is borked :(")
	end

	love.graphics.setCanvas()

	return canvas
end

function PostProcess:init()
	self.params = {
		tonemap_exposure = 1.0,
		-- gamma = 2.2, -- should materials do this or post?
		use_tonemapping = true,
		use_color_correction = true,
		use_fxaa = false,
		lut_primary = love.graphics.newImage("assets/lut-16_brighter.png"),
		lut_secondary = love.graphics.newImage("assets/lut-16.png"),
		lut_factor = 0,
		canvas_fsaa = 4,
		canvas_range = "hdr"
	}

	self.display_lut = false

	local fx = love.filesystem.read("assets/shaders/fxaa.glsl")
	self.shader = love.graphics.newShader(fx)
	self:rebuild()
end

function PostProcess:rebuild()
	self.canvas = mk_canvas(self.params.canvas_fsaa, self.params.canvas_range)
end

function PostProcess:bind()
	love.graphics.setCanvas(self.canvas)
	self.canvas:clear()
end

function PostProcess:unbind()
	love.graphics.setCanvas()
end

function PostProcess:draw()
	love.graphics.clear()
	love.graphics.setShader(self.shader)

	local params = self.params
	self.shader:sendInt("u_fxaa", params.use_fxaa and 1 or 0)
	self.shader:sendInt("u_tonemap", params.use_tonemapping and 1 or 0)
	self.shader:sendInt("u_color_correct", params.use_color_correction and 1 or 0)
	self.shader:send("u_exposure", params.tonemap_exposure)
	self.shader:send("u_lut_primary", params.lut_primary)
	self.shader:send("u_lut_secondary", params.lut_secondary)
	self.shader:send("u_factor", params.lut_factor)

	love.graphics.draw(self.canvas)
	love.graphics.setShader()
end

return PostProcess
