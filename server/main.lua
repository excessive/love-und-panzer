require "libs.panzer.server"
gui = require "libs.Gspot"

function love.load()
	love.graphics.setFont(love.graphics.newFont(12))
	
	server = Server:start(12345)
	
	-- Create GUI Elements
	buttonTest = gui:button("Test", {x=0, y=0, w=48, h=gui.style.unit})
	
	-- Test Button Properties
	buttonTest.click = function(this)
		server:send("Test")
	end
end

function love.update(dt)
	gui:update(dt)
	server:update(dt)
end

function love.draw()
	gui:draw()
end

function love.keypressed(k, unicode)
	if gui.focus then
		gui:keypress(k, unicode)
		return
	end
end

function love.mousepressed(x, y, button)
	gui:mousepress(x, y, button)
end

function love.mousereleased(x, y, button)
	gui:mouserelease(x, y, button)
end