require "libs.screen"

-- Send Chat Message
function sendChat()
	if gui.chat.input:GetText() ~= "" then
		local str = json.encode({
			scope = string.upper(gui.chat.scope),
			msg = gui.chat.input:GetText(),
		})
		local data = string.format("%s %s", "CHAT", str)
		
		client:send(data)
		gui.chat.input:SetText("")
	end
end

local function load(self)
	---------------------------------
	for _, obj in pairs(gui.title) do
		obj:SetVisible(false)
	end
	---------------------------------
	
	--[[ Chat UI Elements ]]--
	gui.chat = {scope="global"}
	
	-- Chat Group
	gui.chat.group = loveframes.Create("panel")
	gui.chat.group:SetSize(400, 200)
	gui.chat.group:SetPos(0, windowHeight - 200)
	
	-- Chat Text
	gui.chat.global = loveframes.Create("list")
	gui.chat.global:SetSize(400, 160)
	gui.chat.global:SetAutoScroll(true)
	
	gui.chat.team = loveframes.Create("list")
	gui.chat.team:SetSize(400, 160)
	gui.chat.team:SetAutoScroll(true)
	
	-- Chat Tabs
	gui.chat.tabs = loveframes.Create("tabs", gui.chat.group)
	gui.chat.tabs:SetSize(400, 180)
	gui.chat.tabs:SetPos(0, 0)
	gui.chat.tabs:AddTab("Global", gui.chat.global, nil, nil, function() gui.chat.scope="global" end)
	gui.chat.tabs:AddTab("Team", gui.chat.team, nil, nil, function() gui.chat.scope="team" end)
	
	-- Chat Input
	gui.chat.input = loveframes.Create("textinput", gui.chat.group)
	gui.chat.input:SetSize(350, 20)
	gui.chat.input:SetPos(0, 180)
	
	-- Chat Button
	gui.chat.send = loveframes.Create("button", gui.chat.group)
	gui.chat.send:SetSize(50, 20)
	gui.chat.send:SetPos(350, 180)
	gui.chat.send:SetText("Send")
	
	-- Send Button Properties
	gui.chat.send.OnClick = function(this)
		sendChat()
	end


	
	--[[ Lobby UI Elements ]]--
	gui.lobby = {
		players = {slots = {}},
		options = {},
		ready = {},
	}
	
	gui.lobby.players.group = loveframes.Create("panel")
	gui.lobby.players.group:SetSize(300, 400)
	gui.lobby.players.group:SetPos(0, 0)
	
	gui.lobby.ready.button = loveframes.Create("button")
	gui.lobby.ready.button:SetSize(100, 40)
	gui.lobby.ready.button:SetPos(500, 500)
	gui.lobby.ready.button:SetText("Ready")
	gui.lobby.ready.button.OnClick = function()
		local str = nil
		
		if client.state.players[client.id].ready then
			str = json.encode({ready = false})
		else
			str = json.encode({ready = true})
		end
		
		local data = string.format("%s %s", "READY", str)
		client.connection:send(data)
	end
	
end

local function update(self, dt)
	client:update(dt)
	
	
	
	
	
	
	
	
	
	local count = 1
	for id, property in pairs(client.state.players) do
		gui.lobby.players.slots[id] = {}
		gui.lobby.players.slots[id].group = loveframes.Create("panel", gui.lobby.players.group)
		gui.lobby.players.slots[id].group:SetSize(300, 40)
		gui.lobby.players.slots[id].group:SetPos(0, 40*count)
		
		gui.lobby.players.slots[id].ready = loveframes.Create("image", gui.lobby.players.slots[id].group)
		gui.lobby.players.slots[id].ready:SetPos(0, 0)
		
		if property.host then
			gui.lobby.players.slots[id].ready:SetImage("assets/images/host.png")
		elseif property.ready then
			if property.team == 1 then
				gui.lobby.players.slots[id].ready:SetImage("assets/images/check-pink.png")
			else
				gui.lobby.players.slots[id].ready:SetImage("assets/images/check-blue.png")
			end
		else
			gui.lobby.players.slots[id].ready:SetImage("assets/images/block-blue.png")
		end
		
		gui.lobby.players.slots[id].name = loveframes.Create("text", gui.lobby.players.slots[id].group)
		gui.lobby.players.slots[id].name:SetSize(100, 20)
		gui.lobby.players.slots[id].name:SetPos(32, 0)
		gui.lobby.players.slots[id].name:SetText(property.name)
		
		gui.lobby.players.slots[id].team = loveframes.Create("text", gui.lobby.players.slots[id].group)
		gui.lobby.players.slots[id].team:SetSize(20, 20)
		gui.lobby.players.slots[id].team:SetPos(200, 0)
		gui.lobby.players.slots[id].team:SetText(property.team)
		
		count = count + 1
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	-- Update Global Chat
	if client.chat.global then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.global)
		gui.chat.global:AddItem(text)
		client.chat.global = nil
	end
	
	-- Update Team Chat
	if client.chat.team then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.team)
		gui.chat.team:AddItem(text)
		client.chat.team = nil
	end
	
	if client.updategame then
		for k,v in pairs(client.updategame) do
			print(k,v)
		end
		
		client.updategame = nil
	end
	
	if client.state.players[client.id].x then
		--self.next.screen = "gameplay"
	end
	
	loveframes.update(dt)
end

local function draw(self)
	loveframes.draw()
end

local function keypressed(self, k, unicode)
	loveframes.keypressed(k, unicode)
end

local function keyreleased(self, k)
	loveframes.keyreleased(k)
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
