local results = {}

function results:enter(state)
	loveframes.SetState("results")
end

function results:update(dt)
	--client:update(dt)
	loveframes.update(dt)
end

function results:draw()
	loveframes.draw()
end

function results:keypressed(key, unicode)
	loveframes.keypressed(key, unicode)
end

function results:keyreleased(key)
	loveframes.keyreleased(key)
end

function results:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function results:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

return results
