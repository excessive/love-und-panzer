require "libs.panzer.server"
--gui = require "libs.Gspot"

function love.load()
	love.graphics.setFont(love.graphics.newFont(12))
	
	logo = love.graphics.newImage("assets/logo.png")
	
	server = Server()
	server:start(8088)
end

function love.update(dt)
	server:update(dt)
	--gui:update(dt)
end

function love.draw()
	love.graphics.draw(logo, 0, 0)
	--gui:draw()
end

function love.keypressed(k, unicode)
	--[[if gui.focus then
		gui:keypress(k, unicode)
		return
	end]]--
end

function love.mousepressed(x, y, button)
	gui:mousepress(x, y, button)
end

function love.mousereleased(x, y, button)
	gui:mouserelease(x, y, button)
end