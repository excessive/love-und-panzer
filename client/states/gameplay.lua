require "tank"

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

function gameplay:enter(state, chat)
	loveframes.SetState("gameplay")
	
	self.chat = chat
	self.chat.panel:SetState("gameplay")
	
	self.keystate = {}

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
		for id, _ in pairs(self.players) do
			self.players[id]:draw()
		end
	end

	-- Create Collision Map
	self.collisionMap = createCollisionMap(self.map, "Collision")

	-- Initialize Players
	self.players = {}
	for id, player in pairs(client.players) do
		self.players[id] = Tank(id, self.map, self.collisionMap,"assets/sprites/tank.png", 64, 64, player.x, player.y, player.r, player.tr, 2, 30, 5)
	end
	
	-- Link Players to Sprites Layer
	self.map.layers.Sprites.players = self.players
end

function gameplay:update(dt)
	local move		= 0
	local turn		= 0
	local turret	= 0
	local data		= ""
	
	-- Receive Data
	client:update(dt)
	
	self.chat:update()
	
	-- Ticks
	self.t = self.t + dt
	if self.t - self.lt >= self.tick then
		-- lazy mode
		local function updateKeys(t)
			for _, k in ipairs(t) do
				self.keystate[k] = love.keyboard.isDown(k)
			end
		end
		
		if not self.chat.input:GetFocus() then
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
			local data = json.encode({
				cmd	= "UPDATE_PLAYER",
				id	= client.id,
				x	= self.players[client.id].x,
				y	= self.players[client.id].y,
				r	= self.players[client.id].r,
				tr	= self.players[client.id].tr,
			})
			client:send(data .. client.split)
		end
		
		-- Update Players
		for id, _ in pairs(self.players) do
			self.players[id]:update(dt)
		end
		
		-- Locally update self
		self.players[client.id]:turn(turn * dt)
		self.players[client.id]:move(move * dt)
		self.players[client.id]:rotateTurret(turret * dt)
		
		self.lt = self.t
	end
	
	loveframes.update(dt)
end

function gameplay:draw()
	-- Draw World + Entities
	love.graphics.push()
	love.graphics.setColor(255, 255, 255, 255)
	local tx = math.floor(-self.players[client.id].x + windowWidth / 2 - self.map.tileWidth / 2)
	local ty = math.floor(-self.players[client.id].y + windowHeight / 2 - self.map.tileHeight / 2)
	love.graphics.translate(tx, ty)
	self.map:autoDrawRange(tx, ty, 1, 64)
	self.map:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()
	
	loveframes.draw()
end

function gameplay:keypressed(key, unicode)
	if not self.chat.input:GetFocus() then
		if key == " " then
			self.players[client.id]:shoot()
		end
		
		if key == "return" then
			self.chat.input:SetFocus(true)
		end
	else
		if key == "return" then
			if self.chat.input:GetText() then
				self.chat:send()
			end
			
			self.chat.input:SetFocus(false)
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
