require "libs.panzer.server"

function love.load()
	love.graphics.setFont(love.graphics.newFont(12))
	
	logo = love.graphics.newImage("assets/logo.png")
	
	server = Server()
	server:start(8088)
end

function love.update(dt)
	server:update(dt)
end

function love.draw()
	love.graphics.draw(logo, 0, 0)
end
