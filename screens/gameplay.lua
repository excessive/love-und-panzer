require "libs.screen"
require "libs.tank"

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
	-- Input
	self.input = Input()
	
	-- Tick
	self.time = 0
	self.lastTime = 0
	self.lastTick = 0
	self.tickRate = 1/8
	
	-- Initialize Tiled Map
	local loader = require "libs.ATL.Loader"
	loader.path = "maps/"
	self.map = loader.load("test")
	self.map.viewW = math.huge--windowWidth
	self.map.viewH = math.huge--windowHeight
	
	-- Create Collision Map
	self.collisionMap = createCollisionMap(self.map, "Collision")
	
	-- Initialize Player
	self.player = Tank(self.map, self.collisionMap, "Player", 4, "assets/sprites/tank.png", 64, 64, 4, 4)
end

local function update(self, dt)
	self.time = self.time + dt
	
	local playerX = 0
	local playerY = 0
	
	-- lazy mode
	local function updateKeys(t)
		for _, k in ipairs(t) do
			self.keystate[k] = love.keyboard.isDown(k)
		end
	end
	
	updateKeys { "up", "down", "left", "right", "w", "s", "a", "d" }
	
	if self.time - self.lastTime >= self.tickRate then
		self.player:savePosition()
		
		if self.keystate.up		or self.keystate.w then
			playerY	= -1
		end
		
		if self.keystate.down	or self.keystate.s then
			playerY	= 1
		end
		
		if self.keystate.left	or self.keystate.a then
			playerX	= -1
		end
		
		if self.keystate.right	or self.keystate.d then
			playerX	= 1
		end
		
		self.lastTime = self.time
	end
	
	-- Update Player
	self.player:moveTile(playerX, playerY)
	self.player:update(dt, self.tickRate, self.time, self.lastTime)
	self.player.sprites[self.player.facing].image:update(dt)
end

local function draw(self)
	-- Draw World + Entities
	love.graphics.push()
	local tx = math.floor(-self.player.x + windowWidth / 2 - self.map.tileWidth / 2)
	local ty = math.floor(-self.player.y + windowHeight / 2 - self.map.tileHeight / 2)
	love.graphics.translate(tx, ty)
	--self.map:autoDrawRange(tx, ty, self.scale, self.map.tileWidth)
	self.map:draw()
	love.graphics.pop()
end

local function keyreleased(self, k)
	-- Still frames
	--[[
	if table.find({"up", "down", "left", "right"}, k) then
		self.player.facing = k
	end]]--
	
	-- Fix me?
	if k == "w" or k == "up"	then self.player.facing = "up"		end
	if k == "s" or k == "down"	then self.player.facing = "down"	end
	if k == "a" or k == "left"	then self.player.facing = "left"	end
	if k == "d" or k == "right"	then self.player.facing = "right"	end
end

return function(data)
	return Screen {
		name		= "Gameplay",
		load		= load,
		update		= update,
		draw		= draw,
		keyreleased	= keyreleased,
		data		= data
	}
end
