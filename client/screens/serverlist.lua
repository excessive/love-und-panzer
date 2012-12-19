require "libs.screen"
require "libs.panzer.client"

local function load(self)
	gui.chat = Gspot()
	gui.serverlist = Gspot()
	self.client = self.data.client
	self.id = self.data.id
	
	--[[ Chat UI Elements ]]--
	
	self.chat = {
		scope = "global"
	}
	
	-- Chat Group
	self.chat.group = gui.chat:group(nil, {
		x = 0,
		y = windowHeight - 200,
		w = 400,
		h = 200,
	})
	
	-- Global Button
	self.chat.buttonGlobal = gui.chat:button("Global", {
		x = 0,
		y = 0,
		w = 50,
		h = gui.theme.tiny,
	}, self.chat.group)
	
	-- Local Button
	self.chat.buttonGame = gui.chat:button("Game", {
		x = 50,
		y = 0,
		w = 50,
		h = gui.theme.tiny,
	}, self.chat.group)
	
	-- Team Button
	self.chat.buttonTeam = gui.chat:button("Team", {
		x = 100,
		y = 0,
		w = 50,
		h = gui.theme.tiny,
	}, self.chat.group)
	
	-- Chat Text
	self.chat.global = gui.chat:scrollgroup(nil, {
		x = 0,
		y = gui.theme.tiny,
		w = 400 - gui.theme.tiny,
		h = 200 - gui.theme.small,
	}, self.chat.group, "vertical")
	
	self.chat.game = gui.chat:scrollgroup(nil, {
		x = 0,
		y = gui.theme.tiny,
		w = 400 - gui.theme.tiny,
		h = 200 - gui.theme.small,
	}, self.chat.group, "vertical")
	
	self.chat.team = gui.chat:scrollgroup(nil, {
		x = 0,
		y = gui.theme.tiny,
		w = 400 - gui.theme.tiny,
		h = 200 - gui.theme.small,
	}, self.chat.group, "vertical")
	
	-- Chat Input
	self.chat.input = gui.chat:input(nil, {
		x = 0,
		y = self.chat.group.pos.h - gui.theme.tiny,
		w = 350,
		h = gui.theme.tiny,
	}, self.chat.group)
	
	-- Chat Button
	self.chat.send = gui.chat:button("Send", {
		x = 350,
		y = self.chat.group.pos.h - gui.theme.tiny,
		w = 50,
		h = gui.theme.tiny,
	}, self.chat.group)

	--[[ Chat UI Properties ]]--
	self.chat.global:show()
	self.chat.game:hide()
	self.chat.team:hide()
	
	-- Chat Input Properties
	self.chat.input.keydelay = KEY_DELAY
	self.chat.input.keyrepeat = KEY_REPEAT
	
	-- Global Button Properties
	self.chat.buttonGlobal.click = function(this)
		self.chat.scope = "global"
		self.chat.global:show()
		self.chat.game:hide()
		self.chat.team:hide()
	end
	
	-- Game Button Properties
	self.chat.buttonGame.click = function(this)
		self.chat.scope = "game"
		self.chat.global:hide()
		self.chat.game:show()
		self.chat.team:hide()
	end
	
	-- Team Button Properties
	self.chat.buttonTeam.click = function(this)
		self.chat.scope = "team"
		self.chat.global:hide()
		self.chat.game:hide()
		self.chat.team:show()
	end
	
	-- Send Button Properties
	self.chat.send.click = function(this)
		sendChat()
	end

	-- Send Chat Message
	function sendChat()
		if self.chat.input.value and self.chat.input.value ~= "" then
			local str = json.encode({
				scope = string.upper(self.chat.scope),
				msg = self.chat.input.value,
			})
			local data = string.format("%s %s", "CHAT", str)
			
			self.client.connection:send(data)
			self.chat.input.value = ""
		end
	end
	
	--[[ Server List UI Elements ]]--
	
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
	
	--[[ Server List UI Properties ]]--
	
	-- Refresh Server List
	self.serverRefresh.click = function(this)
		local data = string.format("%s %s", "SERVERLIST", "")
		self.client.connection:send(data)
	end
	
	self.buttonNewGame.click = function(this)
		local str = json.encode({
			name = self.inputNewGameName.value,
			pass = self.inputNewGamePass.value,
		})
		
		local data = string.format("%s %s", "NEWGAME", str)
		self.client.connection:send(data)
		
		self.next.data = {}
		self.next.data.client = self.client
		self.next.data.chat = self.chat
		
		self.next.screen = "lobby"
	end
end

local function update(self, dt)
	self.client:update(dt)
	
	-- Update Global Chat
	if self.client.chat.global then
		self.chat.global:addchild(gui.chat:text(self.client.chat.global, {w = self.chat.group.pos.w - gui.theme.tiny}), "vertical")
		self.client.chat.global = nil
	end
	
	-- Update Game Chat
	if self.client.chat.game then
		self.chat.game:addchild(gui.chat:text(self.client.chat.game, {w = self.chat.group.pos.w, h = gui.theme.tiny}), "vertical")
		self.client.chat.game = nil
	end
	
	-- Update Team Chat
	if self.client.chat.team then
		self.chat.team:addchild(gui.chat:text(self.client.chat.team, {w = self.chat.group.pos.w, h = gui.theme.tiny}), "vertical")
		self.client.chat.team = nil
	end
	
	-- Update Server List
	if self.client.serverlist then
		for game, properties in pairs(self.client.serverlist) do
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
				self.client.connection:send(data)
				
				self.next.data = {}
				self.next.data.client = self.client
				self.next.data.chat = self.chat
				
				self.next.screen = "lobby"
			end
			
			self.serverlist:addchild(group, "vertical")
		end
		
		self.client.serverlist = nil
	end
	
	gui.chat:update(dt)
	gui.serverlist:update(dt)
end

local function draw(self)
	gui.chat:draw()
	gui.serverlist:draw()
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
	gui.serverlist:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	gui.chat:mouserelease(x, y, button)
	gui.serverlist:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "ServerList",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
