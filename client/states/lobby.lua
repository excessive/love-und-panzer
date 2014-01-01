local lobby = {}

function lobby:enter(state)
	self.ui = require "ui.lobby"
	self.chat = require "ui.chat"
	loveframes.SetState("lobby")
	
	self.ui:init()
	self.chat:init()
end

function lobby:update(dt)
	client:update(dt)
	
	self.ui:update()
	self.chat:update()
	
	if client.startGame then
		client.startGame = nil
		Gamestate.switch(states.gameplay, self.chat)
	end
	
	loveframes.update(dt)
end

function lobby:draw()
	loveframes.draw()
end

function lobby:keypressed(key, isrepeat)
	if key == "return" then
		Signal.emit("ChatFocus")
	end
	
	loveframes.keypressed(key, isrepeat)
end

function lobby:keyreleased(key)
	loveframes.keyreleased(key)
end

function lobby:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function lobby:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function lobby:textinput(text)
	loveframes.textinput(text)
end

return lobby
