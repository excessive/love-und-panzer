require "settings"
require "client"
require "libs.TEsound"
require "libs.LoveFrames"
Gamestate = require "libs.hump.gamestate"
Signal = require "libs.hump.signal"

function love.load()
	game = {}
	
	Signal.register('resize', function()
		windowWidth		= love.graphics.getWidth()
		windowHeight	= love.graphics.getHeight()
	end)
	
	Signal.register('update', function()
		TEsound.cleanup()
	end)
	
	Signal.emit('resize')

	-- Load screen types
	states = {}
	states.title	= require "states.title"
	states.options	= require "states.options"
	states.credits	= require "states.credits"
	states.lobby	= require "states.lobby"
	states.gameplay	= require "states.gameplay"
	states.results	= require "states.results"

	Gamestate.switch(states.title)
end

local callbacks = {
	"errhand", "threaderror",
	"focus", "visible", "resize",
	"textinput", "keypressed", "keyreleased",
	"mousepressed", "mousereleased", "mousefocus",
	"joystickpressed", "joystickreleased",
	"joystickadded", "joystickremoved",
	"joystickaxis", "joystickhat",
	"gamepadpressed", "gamepadaxis",
	"update", "draw",
	"quit"
}

for i,v in ipairs(callbacks) do
	love[v] = function(...)
		Signal.emit(v, ...)
		Gamestate[v](...)
	end
end
