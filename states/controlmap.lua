local json = require "libs.dkjson"
local Controls = require "controls"
local Map = {}

-- bump this if the format changes so incompatible mappings don't crash everything
function Map:enter(state)	
	lurker.postswap = function(f)
		Gamestate.switch(require "states.controlmap")
	end

	self.index = 1
	self.controls = Controls()
end

function Map:update(dt)
	if self.index > #self.controls.map then
		controls = self.controls
		controls:write()
		Gamestate.switch(require "states.menu")
	end
end

function Map:draw()
	local w, h = love.graphics.getDimensions()
	local c = self.controls
	love.graphics.setColor(220, 220, 220, 255)
	love.graphics.print("Device: " .. c.device, 20, 20)
	for i,v in ipairs(c.map) do
		local pos = 50 + i * 30
		local key = c.map[i]
		if self.index == i then
			love.graphics.setColor(220, 220, 220, 255)
			love.graphics.print(string.format("Select key for %s", key), 20, pos)
		elseif self.index < i then
			love.graphics.setColor(100, 100, 100, 255)
			love.graphics.print(string.format("%s: %s", key, c.controls[key]), 20, pos)
		else
			love.graphics.setColor(100, 100, 100, 255)			
			love.graphics.print(string.format("%s: %s", key, c.controls[key]), 20, pos)
		end
	end
	love.graphics.setColor(100, 100, 100, 255)
	love.graphics.print("Press delete to skip and use default.", 20, h - 40)
end

function Map:keypressed(key, isrepeat)
	-- we're gonna switch gamestates next frame anyways
	if self.index > #self.controls.map then
		return
	end
	if key ~= console._KEY_TOGGLE then
		if key == "delete" then
			self.controls:set(self.index, false)
		else
			self.controls:set(self.index, key)
		end
		self.index = self.index + 1
	end
end

-- TODO: Handle axes
function Map:gamepadpressed(joystick, button)
	if button == "start" then
		self.controls.device = "gamepad"
		self.controls = {}
		return
	end
	if button == "back" then
		self.controls.device = "keyboard"
		self.controls = {}
		return
	end
	self.controls:set(self.index, button)
	self.index = self.index + 1
end

function Map:leave()
	self.index = nil
	self.controls = nil
end

return Map
