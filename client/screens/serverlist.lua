require "libs.screen"

local function load(self)
	gui.chat = {scope="global"}
	gui.serverlist = {}
	
	--[[ Chat UI Elements ]]--
	
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
	gui.chat.tabs:AddTab("Global", gui.chat.global)
	gui.chat.tabs:AddTab("Local", gui.chat.game)
	gui.chat.tabs:AddTab("Team", gui.chat.team)
	
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
	--[[
	-- Server Group
	self.servergroup = gui.serverlist:group(nil, {
		x = windowWidth - 400,
		y = 0,
		w = 400,
		h = windowHeight,
	})
	
	-- Refresh Button
	self.serverRefresh = gui.serverlist:button("Refresh", {
		x = 0,
		y = 0,
		w = 400,
		h = gui.theme.tiny,
	}, self.servergroup)
	
	-- New Game Group
	self.groupNewGame = gui.serverlist:group(nil, {
		x = 0,
		y = gui.theme.tiny + gui.theme.padding,
		w = 400,
		h = gui.theme.medium,
	}, self.servergroup)
	
	self.inputNewGameName = gui.serverlist:input(nil, {
		x = 0,
		y = 0,
		w = 400,
		h = gui.theme.tiny,
	}, self.groupNewGame)
	
	self.inputNewGamePass = gui.serverlist:input(nil, {
		x = 0,
		y = gui.theme.tiny + gui.theme.padding,
		w = 400 - gui.theme.medium - gui.theme.padding,
		h = gui.theme.tiny,
	}, self.groupNewGame)
	
	self.buttonNewGame = gui.serverlist:button("New Game", {
		x = 400 - gui.theme.medium,
		y = gui.theme.tiny + gui.theme.padding,
		w = gui.theme.medium,
		h = gui.theme.tiny,
	}, self.groupNewGame)
	
	-- Server List
	self.serverlist = gui.serverlist:scrollgroup(nil, {
		x = 0,
		y = gui.theme.medium + gui.theme.padding,
		w = 400 - gui.theme.tiny,
		h = windowHeight - gui.theme.medium - gui.theme.padding,
	}, self.servergroup, "vertical")
	]]--
	--[[ Server List UI Properties ]]--
	--[[
	-- Refresh Server List
	self.serverRefresh.click = function(this)
		local data = string.format("%s %s", "SERVERLIST", "")
		client:send(data)
	end
	
	self.buttonNewGame.click = function(this)
		local str = json.encode({
			name = self.inputNewGameName.value,
			pass = self.inputNewGamePass.value,
		})
		
		local data = string.format("%s %s", "NEWGAME", str)
		client:send(data)
		
		self.next.data = {}
		self.next.screen = "lobby"
	end]]--
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
	--[[
	-- Update Server List
	if client.serverlist then
		for game, properties in pairs(client.serverlist) do
			local group = gui.serverlist:group(nil, {w = self.serverlist.pos.w, h = gui.theme.medium})
			local textName = gui.serverlist:text(properties.name, {w=group.pos.w, h=gui.theme.tiny}, group)
			local textHost = gui.serverlist:text("Hosted by: "..properties.host, {y=gui.theme.tiny, w=group.pos.w, h=gui.theme.tiny}, group)
			local textState = gui.serverlist:text(properties.state, {y=gui.theme.small, w=group.pos.w/2, h=gui.theme.tiny}, group)
			local textPlayers = gui.serverlist:text(properties.players.."/8", {x=group.pos.w/2, y=gui.theme.small, w=group.pos.w/2, h=gui.theme.tiny}, group)
			local buttonConnect = gui.serverlist:button("Connect", {x=group.pos.w-48, y=gui.theme.small + gui.theme.tiny, w=48, h=gui.theme.tiny}, group)
			
			if properties.pass then
				local inputPass = gui.serverlist:input("Password", {y=gui.theme.small + gui.theme.tiny, w=group.pos.w-gui.theme.medium, h=gui.theme.tiny}, group)
			end
			
			buttonConnect.click = function()
				local str = json.encode({id=tonumber(game)})
				local data = string.format("%s %s", "JOINGAME", str)
				client:send(data)
				
				self.next.data = {}
				self.next.screen = "lobby"
			end
			
			self.serverlist:addchild(group, "vertical")
		end
		
		client.serverlist = nil
	end
	]]--
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
