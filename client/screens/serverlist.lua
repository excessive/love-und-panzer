require "libs.screen"

local function load(self)
	for _, obj in pairs(gui.title) do
		obj:SetVisible(false)
	end
	
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
	
	gui.chat.game = loveframes.Create("list")
	gui.chat.game:SetSize(400, 160)
	gui.chat.game:SetAutoScroll(true)
	
	gui.chat.team = loveframes.Create("list")
	gui.chat.team:SetSize(400, 160)
	gui.chat.team:SetAutoScroll(true)
	
	-- Chat Tabs
	gui.chat.tabs = loveframes.Create("tabs", gui.chat.group)
	gui.chat.tabs:SetSize(400, 180)
	gui.chat.tabs:SetPos(0, 0)
	gui.chat.tabs:AddTab("Global", gui.chat.global, nil, nil, function() gui.chat.scope="global" end)
	gui.chat.tabs:AddTab("Local", gui.chat.game, nil, nil, function() gui.chat.scope="game" end)
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
	
	--[[ Server List UI Elements ]]--
	gui.serverlist = {}
	
	-- Server Group
	gui.serverlist.group = loveframes.Create("panel")
	gui.serverlist.group:SetSize(400, 600)
	gui.serverlist.group:SetPos(400, 0)
	
	-- Refresh Button
	gui.serverlist.refresh = loveframes.Create("button", gui.serverlist.group)
	gui.serverlist.refresh:SetSize(400, 20)
	gui.serverlist.refresh:SetText("Refresh")
	gui.serverlist.refresh.OnClick = function(this)
		local data = string.format("%s %s", "SERVERLIST", "")
		client:send(data)
	end
	
	-- New Game Group
	gui.serverlist.newgame = {}
	gui.serverlist.newgame.group = loveframes.Create("panel", gui.serverlist.group)
	gui.serverlist.newgame.group:SetSize(400, 60)
	gui.serverlist.newgame.group:SetPos(0, 30)
	
	gui.serverlist.newgame.name = loveframes.Create("textinput", gui.serverlist.newgame.group)
	gui.serverlist.newgame.name:SetSize(400, 20)
	gui.serverlist.newgame.name:SetPos(0, 0)
	
	gui.serverlist.newgame.pass = loveframes.Create("textinput", gui.serverlist.newgame.group)
	gui.serverlist.newgame.pass:SetSize(340, 20)
	gui.serverlist.newgame.pass:SetPos(0, 30)
	
	gui.serverlist.newgame.create = loveframes.Create("button", gui.serverlist.newgame.group)
	gui.serverlist.newgame.create:SetSize(50, 20)
	gui.serverlist.newgame.create:SetPos(350, 30)
	gui.serverlist.newgame.create:SetText("Create")
	gui.serverlist.newgame.create.OnClick = function(this)
		local str = json.encode({
			name = gui.serverlist.newgame.name:GetText(),
			pass = gui.serverlist.newgame.pass:GetText(),
		})
		
		local data = string.format("%s %s", "NEWGAME", str)
		client:send(data)
		
		self.next.data = {}
		--self.next.screen = "lobby"
		self.next.screen = "gameplay"
	end
	
	-- Server List
	gui.serverlist.games = {}
	gui.serverlist.games.group = loveframes.Create("list", gui.serverlist.group)
	gui.serverlist.games.group:SetSize(400, 500)
	gui.serverlist.games.group:SetPos(0, 100)
end

local function update(self, dt)
	client:update(dt)
	
	-- Update Global Chat
	if client.chat.global then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.global)
		gui.chat.global:AddItem(text)
		client.chat.global = nil
	end
	
	-- Update Game Chat
	if client.chat.game then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.game)
		gui.chat.game:AddItem(text)
		client.chat.game = nil
	end
	
	-- Update Team Chat
	if client.chat.team then
		local text = loveframes.Create("text")
		text:SetMaxWidth(400)
		text:SetText(client.chat.team)
		gui.chat.team:AddItem(text)
		client.chat.team = nil
	end
	
	-- Update Server List
	if client.serverlist then
		for game, properties in pairs(client.serverlist) do
			local group = loveframes.Create("panel")
			group:SetSize(400, 80)
			
			local textName = loveframes.Create("text", group)
			textName:SetSize(400, 20)
			textName:SetText(properties.name)
			
			local textHost = loveframes.Create("text", group)
			textHost:SetSize(400, 20)
			textHost:SetPos(0, 20)
			textHost:SetText("Hosted by: " .. properties.host)
			
			local textState = loveframes.Create("text", group)
			textState:SetSize(200, 20)
			textState:SetPos(0, 40)
			textState:SetText(properties.state)
			
			local textPlayers = loveframes.Create("text", group)
			textPlayers:SetSize(200, 20)
			textPlayers:SetPos(200, 40)
			textPlayers:SetText(properties.players .. "/8")
			
			local buttonConnect = loveframes.Create("button", group)
			buttonConnect:SetSize(70, 20)
			buttonConnect:SetPos(330, 60)
			buttonConnect:SetText("Connect")
			buttonConnect.OnClick = function()
				local str = json.encode({id=tonumber(game)})
				local data = string.format("%s %s", "JOINGAME", str)
				client:send(data)
				
				self.next.data = {}
				--self.next.screen = "lobby"
				self.next.screen = "gameplay"
			end
			
			if properties.pass then
				local inputPass = loveframes.Create("textinput", group)
				inputPass:SetSize(320, 20)
				inputPass:SetPos(0, 60)
			end
			
			gui.serverlist.games.group:AddItem(group)
		end
		
		client.serverlist = nil
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
		name			= "ServerList",
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
