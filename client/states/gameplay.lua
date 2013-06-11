require "libs.panzer.tank"

local gameplay = {}

local function createCollisionMap(map, layer)
	local w, h = map.width-1, map.height-1
	local walk = {}

	for y=0, h do
		walk[y] = {}
		for x=0, w do
			walk[y][x] = 0
		end
	end

	for x, y, tile in map.layers[layer]:iterate() do
		walk[y][x] = 1
	end

	return walk
end

function gameplay:enter(state)
	---------------------------------
	gui.lobby.players.group:SetVisible(false)
	gui.lobby.ready.button:SetVisible(false)
	---------------------------------
	
	gui.gameplay = {}

	-- Tick
	self.t = 0
	self.lt = 0
	self.tick = 1/60

	-- Initialize Tiled Map
	local loader = require "libs.ATL.Loader"
	loader.path = "maps/"
	self.map = loader.load("test64")
	self.map.viewW = windowWidth
	self.map.viewH = windowHeight

	-- Custom Layer for Sprite Objects
	local spriteLayer = self.map:newCustomLayer("Sprites", 4)
	function spriteLayer:draw()
		self.player:draw()
		
		for id, state in pairs(self.players) do
			self.players[id]:draw()
		end
	end

	-- Create Collision Map
	self.collisionMap = createCollisionMap(self.map, "Collision")

	-- Initialize Players
	for id, state in pairs(client.state.players) do
		if id ~= client.id then
			self.players[id]	= Tank(self.map, self.collisionMap,"assets/sprites/tank.png", 64, 64, state.x, state.y, state.r, state.tr, 2, 30, 5, 10)
		else
			self.player			= Tank(self.map, self.collisionMap,"assets/sprites/tank.png", 64, 64, state.x, state.y, state.r, state.tr, 2, 30, 5, 10)
		end
	end
	
	-- Link Players to Sprites Layer
	self.map.layers.Sprites.player = self.player
	self.map.layers.Sprites.players = self.players
end

function gameplay:update(dt)
	local move		= 0
	local turn		= 0
	local turret	= 0
	local data		= ""
	
	-- Receive Data
	client:update(dt)
	
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
	
	-- Ticks
	self.t = self.t + dt
	if self.t - self.lt >= self.tick then
		-- lazy mode
		local function updateKeys(t)
			for _, k in ipairs(t) do
				self.keystate[k] = love.keyboard.isDown(k)
			end
		end
		
		if not gui.chat.input:GetFocus() then
			updateKeys { "up", "down", "left", "right", "lctrl", "lalt" }
		end

		if self.keystate.left then
			turn = turn - 1
		end
		
		if self.keystate.right then
			turn = turn + 1
		end
		
		if self.keystate.up then
			move = move + 1
		end
		
		if self.keystate.down then
			move = move - 1
		end
		
		if self.keystate.lctrl then
			turret = turret - 1
		end
		
		if self.keystate.lalt then
			turret = turret + 1
		end
		
		if turn ~= 0 or move ~= 0 then
			local str = json.encode({
				x	= self.player.x,
				y	= self.player.y,
				r	= self.player.r,
				tr	= self.player.tr,
			})
			local data = string.format("%s %s", "UPDATE_PLAYER", str)
			client:send(data)
		end
		
		-- Update Player
		self.player:update(dt)
		self.player:turn(turn * dt)
		self.player:move(move * dt)
		self.player:rotateTurret(turret * dt)
		
		self.lt = self.t
	end
	
	-- Update State
	if client.updatestate then
		local state = client.updatestate
		
		if not game[state.id] then
			game[state.id] = {}
		end
		
		game[state.id].x	= state.x
		game[state.id].y	= state.y
		game[state.id].r	= state.r
		game[state.id].tr	= state.tr
	end
	
	loveframes.update(dt)
end

function gameplay:draw()
	-- Draw World + Entities
	love.graphics.push()
	love.graphics.setColor(255, 255, 255, 255)
	local tx = math.floor(-self.player.x + windowWidth / 2 - self.map.tileWidth / 2)
	local ty = math.floor(-self.player.y + windowHeight / 2 - self.map.tileHeight / 2)
	love.graphics.translate(tx, ty)
	self.map:autoDrawRange(tx, ty, self.scale, self.map.tileWidth)
	self.map:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()
	
	loveframes.draw()
end

function gameplay:keypressed(key, unicode)
	if not gui.chat.input:GetFocus() then
		if k == " " then
			self.player:shoot()
		end
		
		if k == "return" then
			gui.chat.input:SetFocus(true)
		end
	else
		if k == "return" then
			sendChat()
			gui.chat.input:SetFocus(false)
		end
	end
	
	loveframes.keypressed(key, unicode)
end

function gameplay:keyreleased(key)
	loveframes.keyreleased(key)
end

function gameplay:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function gameplay:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

return gameplay
