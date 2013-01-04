require "libs.screen"
require "libs.panzer.tank"

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

local function load(self)
	gui.gameplay = {}
	self.id = self.data.id

	-- Tick
	self.time = 0
	self.lastTime = 0
	self.lastTick = 0
	self.tickRate = 1/60

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
	end

	-- Create Collision Map
	self.collisionMap = createCollisionMap(self.map, "Collision")

	-- Initialize Player
	self.player = Tank(self.map, self.collisionMap,"assets/sprites/tank.png", 64, 64, 4, 4, 30, 2, 30, 5, 10)

	-- Link Player to Sprites Layer
	self.map.layers.Sprites.player = self.player
end

local function update(self, dt)
	local move = 0
	local turn = 0
	local data = ""
	
	-- Receive Data
	client:update(dt)
	
	-- Ticks
	self.time = self.time + dt
	if self.time - self.lastTime >= self.tickRate then
		-- lazy mode
		local function updateKeys(t)
			for _, k in ipairs(t) do
				self.keystate[k] = love.keyboard.isDown(k)
			end
		end

		updateKeys { "up", "down", "left", "right" }

		if self.keystate.left then
			turn = -1
			data = string.format("%s %f", 'turn', turn)
			client:send(data)
		end
		
		if self.keystate.right then
			turn = 1
			data = string.format("%s %f", 'turn', turn)
			client:send(data)
		end
		
		if self.keystate.up then
			move = 1
			data = string.format("%s %f", 'move', move)
			client:send(data)
		end
		if self.keystate.down then
			move = -1
			data = string.format("%s %f", 'move', move)
			client:send(data)
		end
	end

	-- Update Player
	self.player:update(dt)
	self.player:turn(turn * dt)
	self.player:move(move * dt)
	self.player.sprites[self.player.facing].image:update(dt)
	
	loveframes.update(dt)
end

local function draw(self)
	-- Draw World + Entities
	love.graphics.push()
	local tx = math.floor(-self.player.x + windowWidth / 2 - self.map.tileWidth / 2)
	local ty = math.floor(-self.player.y + windowHeight / 2 - self.map.tileHeight / 2)
	love.graphics.translate(tx, ty)
	self.map:autoDrawRange(tx, ty, self.scale, self.map.tileWidth)
	self.map:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.pop()
	
	loveframes.draw()
end

local function keypressed(self, k, unicode)
	if k == " " then
		self.player:shoot()
	end
	
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
		name			= "Gameplay",
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
