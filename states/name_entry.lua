local NameEntry = {}

function NameEntry:enter(from, name, resources, host, port, controls)
	lurker.postswap = function(f)
		Gamestate.switch(require "states.name_entry", name, resources, host, port, controls)
	end

	self.resources = resources
	self.name = name or "Panzer #" .. love.math.random(1914, 2808)
	self.pass = { resources, host, port, controls }
	self.controls = controls

	Signal.register("pressed-a",				function(...) self:pressed_a(...) end)
	Signal.register("pressed-b",				function(...) self:pressed_b(...) end)
end

function NameEntry:draw()
	local w, h = love.graphics.getDimensions()
	local padding = 10
	love.graphics.setFont(self.resources.font.ui)
	love.graphics.setColor(255, 255, 255, 50)
	love.graphics.rectangle("fill", w/2 - 100 - padding, h/2 - padding, 200 + padding * 2, 20 + padding * 2)
	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.rectangle("line", w/2 - 100 - padding, h/2 - padding, 200 + padding * 2, 20 + padding * 2)
	love.graphics.setColor(220, 220, 220, 255)
	love.graphics.print(self.name, w/2 - 100, h/2 - 2)
	love.graphics.setFont(self.resources.font.bold)
	love.graphics.print("Come on, name yourself.", w/2 - 100 - padding, h/2 - 36)
end

function NameEntry:keypressed(k, r)
	if k == "backspace" then
		self.name = self.name:sub(1,-2)
		return
	end

	if self.controls:check("start", k) or
	   self.controls:check("turret_fire", k) or
	   self.controls:check("menu_start", k)
	then
		self:pressed_a()
		return
	end

	if self.controls:check("back", k) or
	   self.controls:check("menu_back", k)
	then
		self:pressed_b()
		return
	end
end

function NameEntry:textinput(c)
	self.name = self.name .. c
end

function NameEntry:leave()
	love.filesystem.write("name", self.name)
	Signal.clear_pattern("pressed%-.*")
	Signal.clear_pattern("released%-.*")
	Signal.clear_pattern("moved%-.*")
end

function NameEntry:pressed_a()
	Gamestate.switch(require "states.loading", self.name, unpack(self.pass))
end

function NameEntry:pressed_b()
	Gamestate.switch(require "states.menu")
end

return NameEntry
