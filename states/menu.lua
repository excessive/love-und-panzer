local Controls = require "controls"

local menu = {}

-- main menu
function menu:enter()
	lurker.postswap = function(f)
		Gamestate.switch(require "states.menu")
	end

	self.resources = {
		font = {
			normal = love.graphics.newFont("assets/fonts/OpenSans-Regular.ttf",  14),
			bold   = love.graphics.newFont("assets/fonts/OpenSans-Semibold.ttf", 14),
			ui     = love.graphics.newFont("assets/fonts/OpenSans-Regular.ttf",  16),
			big    = love.graphics.newFont("assets/fonts/OpenSans-Semibold.ttf", 18)
		}
	}

	if love.filesystem.exists("name") then
		self.name = love.filesystem.read("name")
	end

	self.host = "50.132.59.168"
	self.port = 2808

	if love.filesystem.isFile("force_local") then
		self.host = "localhost"
	end

	self.logo         = love.graphics.newImage("assets/title.png")
	self.controls     = Controls()
	self.current_item = 1
	self.items        = {
		{
			label = "Connect",
			action = function(self)
				Gamestate.switch(require "states.name_entry", self.name or nil, self.resources, self.host, tonumber(self.port), self.controls)
			end
		}, {
			label = "Server",
			action = function(self)
				Gamestate.switch(require "states.server")
			end
		}, {
			label = "Settings",
			action = function(self)
				Gamestate.switch(require "states.controlmap")
			end
		}, {
			label = "Quit",
			action = function(self)
				love.event.quit()
			end
		}
	}

	Signal.register("pressed-a",      function(...) self:pressed_a(...)      end)
	Signal.register("pressed-back",   function(...) self:pressed_back(...)   end)
	Signal.register("pressed-dpup",   function(...) self:pressed_dpup(...)   end)
	Signal.register("pressed-dpdown", function(...) self:pressed_dpdown(...) end)
end

function menu:draw()
	local w, h = love.graphics.getDimensions()

	love.graphics.setBackgroundColor(25, 25, 25, 255)
	love.graphics.setFont(self.resources.font.big)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.logo, math.floor(w/2 - self.logo:getWidth() / 2), math.floor(h/2 - self.logo:getHeight() - 20))

	local spacing = 30
	for i, v in ipairs(self.items) do
		if i == self.current_item then
			love.graphics.setColor(255, 255, 255, 255)
		else
			love.graphics.setColor(150, 150, 150, 255)
		end
		love.graphics.printf(self.items[i].label, w/2, h/2 + i * spacing, 0, "center")
	end
end

function menu:keypressed(k, r)
	-- TODO: combined input checks
	if self.controls:check("start", k) or
	   self.controls:check("turret_fire", k) or
	   self.controls:check("menu_start", k)
	then
		Signal.emit("pressed-a")
		return
	end

	if self.controls:check("menu_down", k) or
	   self.controls:check("move_back", k) or
	   self.controls:check("menu_next", k)
	then
		Signal.emit("pressed-dpdown")
		return
	end

	if self.controls:check("menu_up", k) or
	   self.controls:check("move_forward", k)
	then
		Signal.emit("pressed-dpup")
		return
	end
end

function menu:leave()
	Signal.clear_pattern("pressed%-.*")
	Signal.clear_pattern("released%-.*")
	Signal.clear_pattern("moved%-.*")
end

function menu:pressed_a()
	self.items[self.current_item].action(self)
end

function menu:pressed_back()
	love.event.quit()
end

function menu:pressed_dpup()
	self.current_item = self.current_item - 1
	if self.current_item < 1 then
		self.current_item = #self.items
	end
end

function menu:pressed_dpdown()
	self.current_item = self.current_item + 1
	if self.current_item > #self.items then
		self.current_item = 1
	end
end

return menu
