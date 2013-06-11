require "libs.TEsound"
require "libs.panzer.settings"
require "libs.panzer.client"
require "libs.loveframes"
Gamestate = require "libs.hump.gamestate"

function love.load()
	gui = {}
	debug = {}
	game = {}
	
	-- Scale
	tileSize = 32
	numTiles = 18.75
	
	-- Screen
	scale = love.graphics.getHeight() / numTiles / tileSize
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()
	
	-- Load screen types
	states = {}
	states.title		= require "states.title"
	states.options	= require "states.options"
	states.credits	= require "states.credits"
	states.lobby		= require "states.lobby"
	states.gameplay	= require "states.gameplay"
	states.results	= require "states.results"
	
	Gamestate.switch(states.title)
end

function love.update(dt)
	scale = love.graphics.getHeight() / numTiles / tileSize
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()

	Gamestate.update(dt)

	TEsound.cleanup()
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(scale)
	
	Gamestate.draw()
	
	love.graphics.pop()
	

	-- Display debug info
	local i = 0
	for k, v in pairs(debug) do
		local r = type(v) == "table" and "" or v
		if type(v) == "table" then
			for _, v2 in ipairs(v) do
				r = r .. " " .. v2
			end
		end
		love.graphics.print(k .. ": " .. r, 0, i * 15)
		i = i + 1
	end
end

function love.keypressed(key, unicode)
	Gamestate.keypressed(key, unicode)
end

function love.keyreleased(key)
	Gamestate.keyreleased(key)
end

function love.mousepressed(x, y, button)
	Gamestate.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	Gamestate.mousereleased(x, y, button)
end

function love.joystickpressed(joystick, button)
	Gamestate.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	Gamestate.joystickreleased(joystick, button)
end

function love.quit()
	Gamestate.quit()
end
