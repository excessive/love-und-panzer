require "libs.AnAL"
Class = require "libs.hump.class"

Tank = Class {
	--[[
		Tank object
		
		map			- A reference of the map
		collision	- Collision map
		image		- Spritemap
		w			- Width on map
		h			- Height on map
		x			- TileX on map
		y			- TileY on map
		speed		- Tiles per second
	]]--
	function(self, map, collision, image, w, h, x, y, r, speed, turnSpeed)
		self.map		= map
		self.collision	= collision
		self.speed		= speed
		self.turnSpeed	= turnSpeed
		
		self.image		= love.graphics.newImage(image)
		self.width		= self.image:getWidth()
		self.height		= self.image:getHeight()
		self.facing		= ""
		self.sprites	= {}
		
		self.tileX		= x
		self.tileY		= y
		self.r			= r
		self:tileToPixel()
		self:savePosition()
		
		self:newSprite("idle",		self.image, 32, 32, 0, 0, 1, 1)
		self:newSprite("forward",	self.image, 32, 32, 0, 0, 1, 1)
		self:newSprite("backward",	self.image, 32, 32, 0, 0, 1, 1)
		self:newSprite("turnLeft",	self.image, 32, 32, 0, 0, 1, 1)
		self:newSprite("turnRight",	self.image, 32, 32, 0, 0, 1, 1)
		self.facing		= "idle"
	end
}

--[[
	Convert tile location to a pixel location for drawing
]]--
function Tank:tileToPixel()
	self.x = self.tileX * self.map.tileWidth
	self.y = self.tileY * self.map.tileHeight
end

--[[
	New Sprites
	
	name	- Name of sprite
	img		- Spritemap
	w		- Sprite width
	h		- Spright height
	ox		- Frame Offset: X
	oy		- Frame Offset: Y
	f		- Number of frames
	ft		- Time to display each frame (in seconds)
]]--
function Tank:newSprite(name, img, w, h, ox, oy, f, ft)
	local a = newAnimation(img, w, h, ft, 1)
	a.frames = {}
	
	for i = 0, f - 1 do
		a:addFrame(i * w + ox * w, oy * h, w, h, ft)
	end
	
	self.sprites[name] = {}
	self.sprites[name].image	= a
	self.sprites[name].width	= w
	self.sprites[name].height	= h
end

--[[
	Draw entity
]]--
function Tank:draw()
	self.sprites[self.facing].image:draw(self.x, self.y, math.rad(self.r), 1, 1, self.width / 2, self.height / 2)
end

--[[
	Draw entity flipped on X axis
]]--
function Tank:drawReverseX()
	self.sprites[self.facing].image:draw(self.x, self.y, math.rad(self.r), -1, 1, self.width / 2, self.height / 2)
end

--[[
	Draw entity flipped on Y axis
]]--
function Tank:drawReverseY()
	self.sprites[self.facing].image:draw(self.x, self.y, math.rad(self.r), 1, -1, self.width / 2, self.height / 2)
end

--[[
	Save current position of player before moving
]]--
function Tank:savePosition()
		self.prevX = self.tileX
		self.prevY = self.tileY
end

--[[
	Move tank
	
	move		- Direction to move
]]--
function Tank:move(move)
	local newX	= self.x + self.speed * self.map.tileWidth * move * math.cos(math.rad(self.r))
	local newY	= self.y + self.speed * self.map.tileHeight * move * math.sin(math.rad(self.r))
	
	local tileX, tileY = 0, 0
	
	if newX < 0 then
		tileX = math.ceil(newX / self.map.tileWidth)
	else
		tileX = math.floor(newX / self.map.tileWidth)
	end
	
	if newY < 0 then
		tileY = math.ceil(newY / self.map.tileHeight)
	else
		tileY = math.floor(newY / self.map.tileHeight)
	end
	
	local function getTile(layer_name)
		return self.map.layers[layer_name](tileX, tileY)
	end
	
	if getTile("Ground") == nil then return end
	if self.collision[tileY][tileX] == 1 then return end
	
	self.x		= newX
	self.y		= newY
end

--[[
	Turn tank
	
	turn		- Direction to turn
]]--
function Tank:turn(turn)
	self.r = self.r + self.turnSpeed * turn
	
	if self.r > 360 then self.r = self.r - 360 end
	if self.r < 0 then self.r = self.r + 360 end
end
