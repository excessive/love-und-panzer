local title = {}

function title:enter(state)
	self.ui = require "ui.title"
	loveframes.SetState("title")
	
	self.ui:init()
	
	-- Logo
	self.logo = love.graphics.newImage("assets/images/title.png")
	
	-- Debug
	self.ui.inputName:SetText(settings.name)
	self.ui.inputHost:SetText(settings.host)
	self.ui.inputPort:SetText(settings.port)
end

function title:update(dt)
	if client then
		client:update(dt)
		
		for k, _ in pairs(client.createPlayers) do
			Gamestate.switch(states.lobby)
			break
		end
	end
	
	loveframes.update(dt)
end

function title:draw()
	love.graphics.draw(self.logo, windowWidth/2 - 303/2, 32)
	loveframes.draw()
end

function title:keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end

function title:keyreleased(key)
	loveframes.keyreleased(key)
end

function title:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function title:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function title:textinput(text)
	loveframes.textinput(text)
end

return title
