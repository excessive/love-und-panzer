local iqe = require "libs.iqe"
local ffi = require "ffi"
local cpml = require "libs.cpml"

local Test = {}

local l = {}
l.g = love.graphics
l.fs = love.filesystem
l.a = love.audio
l.s = love.sound
l.m = love.math
l.k = love.keyboard
l.sys = love.system
l.t = love.timer

-- I have a hunch this stuff is gonna be memory-leaky
local function mk_canvas(fsaa)
	local w, h = love.graphics.getDimensions()
	local canvas = love.graphics.newCanvas(w, h, "hdr", fsaa)
	assert(canvas)

	love.graphics.setCanvas(canvas)

	local depth = ffi.new("unsigned int[1]", 1)
	gl.GenRenderbuffers(1, depth);
	gl.BindRenderbuffer(GL.RENDERBUFFER, depth[0]);
	if fsaa > 1 then
		gl.RenderbufferStorageMultisample(GL.RENDERBUFFER, fsaa, GL.DEPTH_COMPONENT24, w, h)
	else
		gl.RenderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT24, w, h);
	end
	gl.FramebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, depth[0]);

	gl.Clear(bit.bor(tonumber(GL.COLOR_BUFFER_BIT), tonumber(GL.DEPTH_BUFFER_BIT)))

	if fsaa > 1 then
		console.i(string.format("Created canvas with FSAA: %d", fsaa))
	else
		console.i(string.format("Created canvas without FSAA.", fsaa))
	end

	local status = gl.CheckFramebufferStatus(GL.FRAMEBUFFER);
	if status ~= GL.FRAMEBUFFER_COMPLETE then
		console.e("Framebuffer is borked :(")
	end

	love.graphics.setCanvas()

	return canvas
end

local function mk_depth_canvas(w, h)
	-- The framebuffer, which regroups 0, 1, or more textures, and 0 or 1 depth buffer.
	local fbo = ffi.new("unsigned int[1]", 1);
	gl.GenFramebuffers(1, fbo);
	gl.BindFramebuffer(GL.FRAMEBUFFER, fbo[0]);

	-- Depth texture. Slower than a depth buffer, but you can sample it later in your shader
	local depth = ffi.new("unsigned int[1]", 1);
	gl.GenTextures(1, depth);
	gl.BindTexture(GL.TEXTURE_2D, depth[0]);
	gl.TexImage2D(GL.TEXTURE_2D, 0, GL.DEPTH_COMPONENT24, w, h, 0, GL.DEPTH_COMPONENT, GL.FLOAT, 0);
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);

	gl.FramebufferTexture(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, depth, 0);

	gl.DrawBuffer(GL.NONE); -- No color buffer is drawn to.

	-- Always check that our framebuffer is ok
	if gl.CheckFramebufferStatus(GL.FRAMEBUFFER) ~= GL.FRAMEBUFFER_COMPLETE then
		return false
	end

	return fbo
end

function Test:enter()
	self.outline = l.g.newShader("assets/shaders/shader-shell.glsl", "assets/shaders/shader-shell.glsl")
	self.post_shader = l.g.newShader("assets/shaders/shader-post.glsl")
	
	-- TODO: Switch to postprocess
	self.fxaa = l.g.newShader("assets/shaders/fxaa.glsl")

	self.model = iqe.load("assets/models/pancakes.iqe")
	self.model:load_material("assets/materials/pancakes.mtl")
	self.model:load_shader("assets/shaders/shader.glsl")
	self.reflection = "assets/textures/rough-aluminum.jpg"
	self.model:load_texture(self.reflection, 16)

	self.use_materials = 0

	self.font = l.g.newFont("assets/fonts/OpenSans-Regular.ttf", 18)

	self.blinker = 0
	self.rotation = 0

	-- helps to be able to *see* the error message.
	lurker.preswap = function(f)
		gl.FrontFace(GL.CCW)
		gl.Disable(GL.DEPTH_TEST)
		gl.Disable(GL.CULL_FACE)
		gl.Enable(GL.BLEND)
	end

	lurker.postswap = function(f)
		Gamestate.switch(require "states.test")
	end

	local w, h, mode = love.window.getMode()
	self.use_canvas = true
	self.use_fxaa = true
	self.use_tonemapping = true
	self.fsaa = 4
	self.canvas = mk_canvas(self.fsaa)
	self.gamma = 2.2
	self.exposure = 1.0
	self.light_power = 1.0
end

function Test:resize(w, h)
	self.canvas = mk_canvas(self.fsaa)
end

function Test:update(dt)
	self.blinker = (self.blinker + dt) % 1
	local speed = math.pi / 16
	if l.k.isDown("tab") then
		speed = speed * 4
	else
		self.blinker = 0
	end
	self.rotation = self.rotation + speed * dt
end

function Test:mousepressed(x, y, b)
	if self.use_materials == 1 then
		if b == "wu" then
			self.light_power = self.light_power + 0.1
		end
		if b == "wd" then
			self.light_power = self.light_power - 0.1
		end
	end
end

function Test:keypressed(k, r)
	if k == "f" then
		self.use_fxaa = not self.use_fxaa
	end
	if self.use_canvas and (k == "1" or k == "2" or k == "3") then
		local level = tonumber(k)
		self.fsaa = level > 1 and level + 1 or level
		self.canvas = mk_canvas(self.fsaa)
	end
	if k == "t" then
		self.use_tonemapping = not self.use_tonemapping
	end
	if k == "c" then
		self.use_canvas = not self.use_canvas
	end
	if k == "m" then
		self.use_materials = (self.use_materials + 1) % 3
	end
	if self.use_fxaa then
		if k == "=" then
			self.exposure = math.min(self.exposure + 0.05, 3)
		end
		if k == "-" then
			self.exposure = math.max(self.exposure - 0.05, 0.1)
		end
	end
	if self.use_materials == 1 then
		if k == "]" then
			self.gamma = math.min(self.gamma + 0.1, 3.0)
		end
		if k == "[" then
			self.gamma = math.max(self.gamma - 0.1, 0.1)
		end
	end
	if k == "0" then
		self.exposure = 1.0
		self.gamma = 2.2
		self.light_power = 1.0
	end
	if k == "escape" then
		Gamestate.switch(require "states.menu")
	end
end

function Test:draw()
	local function draw_mesh(model)
		gl.CullFace(GL.FRONT)
		gl.Disable(GL.DEPTH_TEST)
		local outline_color = { 0.15, 0.1, 0.05 }
		for _, buffer in ipairs(model.vertex_buffer) do
			l.g.setShader(self.outline)
			self.outline:send("u_outline_color", outline_color)
			self.outline:send("u_thickness", 0.005)
			l.g.draw(buffer.mesh)
		end

		gl.Enable(GL.DEPTH_TEST)
		for _, buffer in ipairs(model.vertex_buffer) do
			l.g.setShader(self.outline)
			self.outline:send("u_outline_color", outline_color)
			self.outline:send("u_thickness", 0.002)
			l.g.draw(buffer.mesh)
		end

		l.g.setShader(self.model.shader)
		-- gl.CullFace(GL.BACK)
		gl.Disable(GL.CULL_FACE)
		for _, buffer in ipairs(model.vertex_buffer) do
			local mtl = model.materials[buffer.material]
			if mtl and self.use_materials == 0 then
				self.model.shader:send("u_Kd", mtl.kd)
				self.model.shader:send("u_Ks", mtl.ks)
				self.model.shader:send("u_Ns", mtl.ns)
				self.model.shader:send("u_map_Kd", model:get_texture(mtl.map_kd))
				self.model.shader:sendInt("u_shading", mtl.illum)
			else
				self.model.shader:send("u_Kd", { 0.25, 0.25, 0.25 })
				self.model.shader:send("u_Ks", { 0.15, 0.15, 0.15 })
				self.model.shader:send("u_Ns", 150)
				self.model.shader:send("u_map_Kd", model:get_texture("blank"))
				self.model.shader:sendInt("u_shading", self.use_materials + 1)
			end
			self.model.shader:send("u_gamma", self.gamma)
			self.model.shader:send("u_light_power", self.light_power)
			self.model.shader:send("u_Kr", { 0.1, 0.1, 0.1 })
			self.model.shader:send("u_Nf", 0.2)
			self.model.shader:send("u_map_Kr", model:get_texture(self.reflection))
			l.g.draw(buffer.mesh)
		end
		l.g.setShader()
	end

	if self.use_canvas then
		love.graphics.setCanvas(self.canvas)
		self.canvas:clear()
	end

	local color = cpml.vec3(25 / 255, 25 / 255, 25 / 255)
	-- FXAA magic.
	gl.ClearColor(color.x, color.y, color.z, color:dot(cpml.vec3(0.299, 0.587, 0.114)))
	gl.Clear(bit.bor(tonumber(GL.DEPTH_BUFFER_BIT), tonumber(GL.COLOR_BUFFER_BIT)))

	local w, h = l.g.getDimensions()

	local model = cpml.mat4():rotate(self.rotation, { 0, 0, 1 })
	local view = cpml.mat4():look_at(
		cpml.vec3(3, 0, 1),
		cpml.vec3(0, 0, 0.9),
		cpml.vec3(0, 0, 1)
	)
	local projection = cpml.mat4():perspective(math.rad(40), w/h, 0.001, 100.0)

	self.outline:send("u_model", model:to_vec4s())
	self.outline:send("u_view", view:to_vec4s())
	self.outline:send("u_projection", projection:to_vec4s())

	self.model.shader:send("u_model", model:to_vec4s())
	self.model.shader:send("u_view", view:to_vec4s())
	self.model.shader:send("u_projection", projection:to_vec4s())

	-- FXAA hijacks the alpha channel!
	gl.Disable(GL.BLEND)
	gl.Enable(GL.CULL_FACE)
	gl.Enable(GL.DEPTH_TEST)
	gl.DepthFunc(GL.LESS)
	gl.DepthRange(0, 1)
	gl.ClearDepth(1.0)
	gl.FrontFace(GL.CW)

	draw_mesh(self.model)

	gl.FrontFace(GL.CCW)
	gl.Disable(GL.DEPTH_TEST)
	gl.Disable(GL.CULL_FACE)

	if self.use_canvas then
		love.graphics.setCanvas()
		l.g.clear()
		love.graphics.setShader(self.fxaa)
		if self.use_tonemapping then
			self.fxaa:send("u_exposure", self.exposure)
			self.fxaa:sendInt("u_tonemap", 1)
		else
			self.fxaa:sendInt("u_tonemap", 0)
		end
		if self.use_fxaa then
			self.fxaa:sendInt("u_fxaa", 1)
		else
			self.fxaa:sendInt("u_fxaa", 0)
		end
		love.graphics.draw(self.canvas)
		love.graphics.setShader()
	end

	gl.Enable(GL.BLEND)

	-- ui crap
	l.g.setFont(self.font)
	l.g.setBackgroundColor(25, 25, 25, 255)
	local line = 1
	local function printl(text, enabled)
		if enabled then
			l.g.setColor(255, 255, 255, 220)
		else
			l.g.setColor(255, 255, 255, 100)
		end
		l.g.print(text, 10, h - self.font:getHeight() * line - 8)
		line = line + 1
	end

	printl("FPS: " .. l.t.getFPS(), true)
	printl("Gamma: " .. self.gamma, self.use_materials == 1)
	printl("Light Power: " .. self.light_power, self.use_materials == 1)

	-- TODO: Calculate exposure in EV
	local tonemap_str = "Off"
	local tonemap_enabled = self.use_canvas and self.use_tonemapping
	if tonemap_enabled then
		local function ev(x, n, t)
			local function log2(x)
				local ln2 = 0.6931471805599453
				return math.log(x) / ln2
			end
			return math.floor(log2(n*n / t))
		end
		local stops = (self.exposure - 1) / 0.1
		-- local stops = ev(8, 60)
		tonemap_str = string.format("%+2.1f", stops)
		-- tonemap_str = tonemap_str .. " EV"
	end

	printl("Tonemapping: " .. tonemap_str, tonemap_enabled)

	local aa_str = "Off"
	local aa_enabled = self.use_canvas and (self.use_fxaa or self.fsaa > 1)
	if aa_enabled then
		local aa = {}
		if self.use_fxaa then
			table.insert(aa, "FXAA")
		end
		if self.fsaa > 1 then
			table.insert(aa, string.format("MSAA %dx", self.fsaa))
		end
		aa_str = table.concat(aa, " + ")
	end

	printl("AA: " .. aa_str, aa_enabled)
	if l.k.isDown("tab") then
		l.g.setColor(255, 50, 50, self.blinker > 0.5 and 100 or 220)
		printl(">>", 10, h - self.font:getHeight() * line - 8)
	end
	l.g.setColor(255, 255, 255, 255)
end

function Test:leave()
	Signal.clear_pattern("input%-.*")
end

return Test
