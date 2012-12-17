require "libs.screen"
require "libs.panzer.client"

local function load(self)
	self.gui = gui()
	self.client = self.data.client
	self.id = self.data.id
	
	-- UI Theme
	self.theme = {
		padding	= 8,
		tiny	= 16,
		small	= 32,
		medium	= 64,
		large	= 128,
		xlarge	= 256,
	}
	
	--[[ Chat UI Elements ]]--
	
	self.chat = {
		scope = "global"
	}
	
	-- Chat Group
	self.chat.group = self.gui:group(nil, {
		x = 0,
		y = windowHeight - 200,
		w = 400,
		h = 200,
	})
	
	-- Global Button
	self.chat.buttonGlobal = self.gui:button("Global", {
		x = 0,
		y = 0,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Local Button
	self.chat.buttonGame = self.gui:button("Game", {
		x = 50,
		y = 0,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Team Button
	self.chat.buttonTeam = self.gui:button("Team", {
		x = 100,
		y = 0,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Chat Text
	self.chat.global = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.tiny,
		w = 400 - self.theme.tiny,
		h = 200 - self.theme.small,
	}, self.chat.group, "vertical")
	
	self.chat.game = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.tiny,
		w = 400 - self.theme.tiny,
		h = 200 - self.theme.small,
	}, self.chat.group, "vertical")
	
	self.chat.team = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.tiny,
		w = 400 - self.theme.tiny,
		h = 200 - self.theme.small,
	}, self.chat.group, "vertical")
	
	-- Chat Input
	self.chat.input = self.gui:input(nil, {
		x = 0,
		y = self.chat.group.pos.h - self.theme.tiny,
		w = 350,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Chat Button
	self.chat.send = self.gui:button("Send", {
		x = 350,
		y = self.chat.group.pos.h - self.theme.tiny,
		w = 50,
		h = self.theme.tiny,
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
	self.servergroup = self.gui:group(nil, {
		x = windowWidth - 400,
		y = 0,
		w = 400,
		h = windowHeight,
	})
	
	-- Refresh Button
	self.serverRefresh = self.gui:button("Refresh", {
		x = 0,
		y = 0,
		w = 400,
		h = self.theme.tiny,
	}, self.servergroup)
	
	-- New Game Group
	self.groupNewGame = self.gui:group(nil, {
		x = 0,
		y = self.theme.tiny + self.theme.padding,
		w = 400,
		h = self.theme.medium,
	}, self.servergroup)
	
	self.inputNewGameName = self.gui:input(nil, {
		x = 0,
		y = 0,
		w = 400,
		h = self.theme.tiny,
	}, self.groupNewGame)
	
	self.inputNewGamePass = self.gui:input(nil, {
		x = 0,
		y = self.theme.tiny + self.theme.padding,
		w = 400 - self.theme.medium - self.theme.padding,
		h = self.theme.tiny,
	}, self.groupNewGame)
	
	self.buttonNewGame = self.gui:button("New Game", {
		x = 400 - self.theme.medium,
		y = self.theme.tiny + self.theme.padding,
		w = self.theme.medium,
		h = self.theme.tiny,
	}, self.groupNewGame)
	
	
	-- Server List
	self.serverlist = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.medium + self.theme.padding,
		w = 400 - self.theme.tiny,
		h = windowHeight - self.theme.medium - self.theme.padding,
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
		self.chat.global:addchild(self.gui:text(self.client.chat.global, {w = self.chat.group.pos.w - self.theme.tiny}), "vertical")
		self.client.chat.global = nil
	end
	
	-- Update Game Chat
	if self.client.chat.game then
		self.chat.game:addchild(self.gui:text(self.client.chat.game, {w = self.chat.group.pos.w, h = self.theme.tiny}), "vertical")
		self.client.chat.game = nil
	end
	
	-- Update Team Chat
	if self.client.chat.team then
		self.chat.team:addchild(self.gui:text(self.client.chat.team, {w = self.chat.group.pos.w, h = self.theme.tiny}), "vertical")
		self.client.chat.team = nil
	end
	
	-- Update Server List
	if self.client.serverlist then
		for game, properties in pairs(self.client.serverlist) do
			local group = self.gui:group(nil, {w = self.serverlist.pos.w, h = self.theme.medium})
			local textName = self.gui:text(properties.name, {w=group.pos.w, h=self.theme.tiny}, group)
			local textHost = self.gui:text("Hosted by: "..properties.host, {y=self.theme.tiny, w=group.pos.w, h=self.theme.tiny}, group)
			local textState = self.gui:text(properties.state, {y=self.theme.small, w=group.pos.w/2, h=self.theme.tiny}, group)
			local textPlayers = self.gui:text(properties.players.."/8", {x=group.pos.w/2, y=self.theme.small, w=group.pos.w/2, h=self.theme.tiny}, group)
			local buttonConnect = self.gui:button("Connect", {x=group.pos.w-48, y=self.theme.small + self.theme.tiny, w=48, h=self.theme.tiny}, group)
			
			if properties.pass then
				local inputPass = self.gui:input("Password", {y=self.theme.small + self.theme.tiny, w=group.pos.w-self.theme.medium, h=self.theme.tiny}, group)
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
	
	self.gui:update(dt)
end

local function draw(self)
	self.gui:draw()
end

local function keypressed(self, k, unicode)
	if self.gui.focus then
		self.gui:keypress(k, unicode)

		if k == 'return' then
			sendChat()
		end
	end
end

local function mousepressed(self, x, y, button)
	self.gui:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	self.gui:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "Title",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
