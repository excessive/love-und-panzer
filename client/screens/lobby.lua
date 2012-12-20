require "libs.screen"

local function load(self)
	gui.lobby = Gspot()
end

local function update(self, dt)
	client:update(dt)
	
	if client.updategame then
		for k,v in pairs(client.updategame) do
			print(k,v)
		end
		
		client.updategame = nil
	end
	
	gui.chat:update(dt)
	gui.lobby:update(dt)
end

local function draw(self)
	gui.chat:draw()
	gui.lobby:draw()
end

local function keypressed(self, k, unicode)
	if gui.chat.focus then
		gui.chat:keypress(k, unicode)

		if k == 'return' then
			sendChat()
		end
	end
end

local function mousepressed(self, x, y, button)
	gui.chat:mousepress(x, y, button)
	gui.lobby:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	gui.chat:mouserelease(x, y, button)
	gui.lobby:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "Lobby",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
