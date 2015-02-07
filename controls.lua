local Class = require "libs.hump.class"
local json = require "libs.dkjson"

local Controls = Class {}
function Controls:init()
	self.version = 2
	self.defaults = {
		move_forward	= "w",
		move_back		= "s",

		turn_left		= "a",
		turn_right		= "d",

		turret_left		= "q",
		turret_right	= "e",
		turret_fire		= " ",

		start			= "return",
		back			= "escape",

		menu_up			= "up",
		menu_down		= "down",
		menu_left		= "left",
		menu_right		= "right",
		menu_next		= "tab",
		menu_start		= "return",
		menu_back		= "escape",
	}
	self.map = {
		"move_forward",
		"move_back",
		"turn_left",
		"turn_right",

		"turret_left",
		"turret_right",
		"turret_fire",

		"start",
		"back",

		"menu_up",
		"menu_down",
		"menu_left",
		"menu_right",
	}

	self.device = "keyboard"
	self.version = self.version

	if love.filesystem.exists("controls.json") then
		self.controls = json.decode(love.filesystem.read("controls.json"))
		if type(self.controls) ~= "table" or (type(self.controls) == "table" and self.controls.version ~= self.version) then
			self.controls = self.defaults
		end
	else
		self.controls = self.defaults
	end
end

function Controls:write()
	local path = "controls.json"
	local output = json.encode(controls)
	love.filesystem.write(path, output)
	console.i("Wrote controls to " .. love.filesystem.getSaveDirectory() .. "/" .. path)
end

function Controls:get(mapping)
	return self.controls[mapping] or ""
end

function Controls:set(index, input)
	assert(type(index) == "number")

	local key = self.map[index]
	self.controls[key] = input or self.defaults[key]
end

function Controls:check(mapping, value)
	if value then
		return value == self.controls[mapping]
	end
	if self.device == "keyboard" then
		return love.keyboard.isDown(self.controls[mapping])
	end
	return false
end

return Controls
