local options = {}

function options:enter(state)
	loveframes.SetState("options")
end

function options:update(dt)
	--client:update(dt)
	loveframes.update(dt)
end

function options:draw()
	loveframes.draw()
end

function options:keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end

function options:keyreleased(key)
	loveframes.keyreleased(key)
end

function options:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function options:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function options:textinput(text)
	loveframes.textinput(text)
end

return options
