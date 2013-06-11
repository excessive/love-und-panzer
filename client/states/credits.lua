local credits = {}

function credits:enter(state)
	gui.credits = {}
end

function credits:update(dt)
	--client:update(dt)
	loveframes.update(dt)
end

function credits:draw()
	loveframes.draw()
end

function credits:keypressed(key, unicode)
	loveframes.keypressed(key, unicode)
end

function credits:keyreleased(key)
	loveframes.keyreleased(key)
end

function credits:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function credits:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

return credits
