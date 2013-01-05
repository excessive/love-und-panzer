require "libs.screen"

local function load(self)
	gui.serverlist.group:SetVisible(false)
	gui.serverlist.refresh:SetVisible(false)
	
	for k, obj in pairs(gui.serverlist.newgame) do
		obj:SetVisible(false)
	end
	
	for k, obj in pairs(gui.serverlist.games) do
		obj:SetVisible(false)
	end
	
	gui.lobby = {}
end

local function update(self, dt)
	client:update(dt)
	
	if client.updategame then
		for k,v in pairs(client.updategame) do
			print(k,v)
		end
		
		client.updategame = nil
	end
	
	loveframes.update(dt)
end

local function draw(self)
	loveframes.draw()
end

local function keypressed(self, k, unicode)
	loveframes.keypressed(k, unicode)
end

local function keyreleased(self, k, unicode)
	loveframes.keyreleased(k, unicode)
end

local function mousepressed(self, x, y, button)
	loveframes.mousepressed(x, y, button)
end

local function mousereleased(self, x, y, button)
	loveframes.mousereleased(x, y, button)
end

return function(data)
	return Screen {
		name			= "Lobby",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		keyreleased		= keyreleased,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
