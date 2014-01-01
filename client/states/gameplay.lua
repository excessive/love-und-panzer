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
	client:update(dt)
	
	self.chat:update()
	
	-- Remove Disconnected Players
	for id, _ in pairs(client.removePlayers) do
		self.players[id] = nil
		client.removePlayers[id] = nil
	end
	
	-- Update Players
	for id, _ in pairs(self.players) do
		self.players[id]:update(dt)
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

function gameplay:keypressed(key, isrepeat)
	if key == "return" then
		Signal.emit("ChatFocus")
	end
	
	if not self.chat.input:GetFocus() then
		local move		= false
		local turn		= false
		local turret	= false
		
		if key == "up" then
			if love.keyboard.isDown("down") then
				move = "s"
			else
				move = "f"
			end
		end
		
		if key == "down" then
			if love.keyboard.isDown("up") then
				move = "s"
			else
				move = "b"
			end
		end
		
		if key == "left" then
			if love.keyboard.isDown("right") then
				turn = "s"
			else
				turn = "l"
			end
		end
		
		if key == "right" then
			if love.keyboard.isDown("left") then
				turn = "s"
			else
				turn = "r"
			end
		end
		
		if key == "lctrl" then
			if love.keyboard.isDown("lalt") then
				turret = "s"
			else
				turret = "l"
			end
		end
		
		if key == "lalt" then
			if love.keyboard.isDown("lctrl") then
				turret = "s"
			else
				turret = "r"
			end
		end
		
		if key == " " then
			self.players[client.id]:shoot()
		end
		
		if move or turn or turret then
			if not move		then move	= nil end
			if not turn		then turn	= nil end
			if not turret	then turret	= nil end
			
			local data = json.encode({
				cmd		= "UPDATE_PLAYER",
				id		= client.id,
				move	= move,
				turn	= turn,
				turret	= turret,
			})
			client:send(data)
		end
	end
	
	loveframes.keypressed(key, isrepeat)
end

function gameplay:keyreleased(key)
	if not self.chat.input:GetFocus() then
		local move		= false
		local turn		= false
		local turret	= false
		
		if key == "up" then
			if love.keyboard.isDown("down") then
				move = "b"
			else
				move = "s"
			end
		end
		
		if key == "down" then
			if love.keyboard.isDown("up") then
				move = "f"
			else
				move = "s"
			end
		end
		
		if key == "left" then
			if love.keyboard.isDown("right") then
				turn = "r"
			else
				turn = "s"
			end
		end
		
		if key == "right" then
			if love.keyboard.isDown("left") then
				turn = "l"
			else
				turn = "s"
			end
		end
		
		if key == "lctrl" then
			if love.keyboard.isDown("lalt") then
				turret = "r"
			else
				turret = "s"
			end
		end
		
		if key == "lalt" then
			if love.keyboard.isDown("lctrl") then
				turret = "l"
			else
				turret = "s"
			end
		end
		
		if move or turn or turret then
			if not move		then move	= nil end
			if not turn		then turn	= nil end
			if not turret	then turret	= nil end
		
			local data = json.encode({
				cmd		= "UPDATE_PLAYER",
				id		= client.id,
				move	= move,
				turn	= turn,
				turret	= turret,
			})
			client:send(data)
		end
	end
	
	loveframes.keyreleased(key)
end

function gameplay:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function gameplay:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function gameplay:textinput(text)
	loveframes.textinput(text)
end

return gameplay
