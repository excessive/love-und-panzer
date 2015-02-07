local generator = require "generator"
local lume = require "libs.lume"
local Chat = require "chat"

local connecting = {}

-- connection indicator
function connecting:enter(from, name, resources, host, port, controls, chat)
	self.angle = 0
	self.canvas = love.graphics.newCanvas()
	self.canvas:clear()
	self.name = name
	self.resources = resources
	self.host = host
	self.port = port
	self.chat = chat
	self.generator = generator(16, 16, 16)
	self.controls = controls

	local w, h, f = love.window.getMode()

	-- Workaround for SDL returning 0 on some setups (OS X)
	-- Also, this was added in 0.9.2, default to 60 if it's not present.
	local refresh = f.refreshrate or 60
	refresh = refresh > 0 and refresh or 60

	self.target = 1 / refresh
end

function connecting:resize()
	self.canvas = love.graphics.newCanvas()
	self.canvas:clear()
end

function connecting:update(dt)
	self.angle = self.angle + math.pi * 1.25 * dt

	-- prevent chat disconnections
	if self.chat then
		self.chat:update(dt)
	end

	local substeps = 4
	local i = 1
	local finished, progress
	repeat
		local time = love.timer.getTime()
		finished, progress = self.generator:step()
		self.progress = progress
		time = love.timer.getTime() - time

		-- Run as many substeps as will fit without dropping frames (hopefully)
		substeps = lume.clamp(self.target / time, 1, 10)
		i = i + 1
	until finished or i >= substeps

	if finished then
		local client = require "client"
		local connected, err = client:connect(self.host, self.port)

		local chat = self.chat or Chat { nick = self.name }

		if connected then
			Gamestate.switch(require "states.gameplay", self.name, self.resources, self.generator:get_data(), client, chat, self.controls)
		else
			console.e(string.format("Connection failed: %s", err))
			Gamestate.switch(require "states.menu")
		end
	end

	local w, h = love.graphics.getDimensions()
	love.graphics.setCanvas(self.canvas)
	love.graphics.setColor(0, 0, 0, 255 * dt)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setCanvas()
end

function connecting:draw()
	local g = love.graphics
	local w, h = g.getDimensions()

	g.setFont(self.resources.font.bold)
	g.setCanvas(self.canvas)

	g.setColor(0, 0, 0, 10)
	g.rectangle("fill", 0, 0, w, h)

	g.push()

	-- Spinner
	g.translate(w/2, h/2)
	g.rotate(self.angle)
	g.setColor(255, 255, 255, 255)
	g.rectangle("fill", 0, 0, 15, 2)

	g.setCanvas()


	g.pop()


	g.setColor(255, 255, 255, 255)
	g.draw(self.canvas)
	g.circle("line", w/2, h/2, 15, 32)

	-- Progress bar
	g.push()
	g.translate(w/2, h/2)
	g.rectangle("line", -100, 40, 200, 10)
	g.rectangle("fill", -100, 40, 200 * self.progress, 10)
	g.pop()

	g.printf("Generating...", w/2, h/2 - 50, 0, "center")
end

function connecting:keypressed(k, r)
	if k == "escape" then
		Gamestate.switch(require "states.menu")
	end
end

return connecting
