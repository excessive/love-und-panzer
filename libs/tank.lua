require "libs.AnAL"
require "utils.tween"
Class = require "libs.hump.class"

Tank = Class {
	--[[
		Tank object
		
		map			- A reference of the map
		collision	- Collision map
		name		- Player's name
		image		- Spritemap
		stats		- Statistics
		w			- Width on map
		h			- Height on map
		x			- TileX on map
		y			- TileY on map
	]]--
	function(self, map, collision, image, w, h, x, y, speed)
		self.map		= map
		self.collision	= collision
		self.speed		= speed
		
		self.image		= love.graphics.newImage(image)
		self.width		= self.image:getWidth()
		self.height		= self.image:getHeight()
		self.facing		= ""
		self.sprites	= {}
		
		self.tileX		= x
		self.tileY		= y
		self:tileToPixel()
		self:savePosition()
		
		self:newSprite("up",		self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("down",		self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("left",		self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("right",		self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("upWalk",	self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("downWalk",	self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("leftWalk",	self.image, 64, 64, 0, 0, 1, 1)
		self:newSprite("rightWalk",	self.image, 64, 64, 0, 0, 1, 1)
		self.facing		= "down"
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
	self.sprites[self.facing].image:draw(self.x, self.y)
end

--[[
	Draw entity flipped on X axis
]]--
function Tank:drawReverseX()
	self.sprites[self.facing].image:draw(self.x, self.y, 0, -1, 1, self.sprites[self.facing].width, 0)
end

--[[
	Draw entity flipped on Y axis
]]--
function Tank:drawReverseY()
	self.sprites[self.facing].image:draw(self.x, self.y, 0, 1, -1, 0, self.sprites[self.facing].height)
end

--[[
	Save current position of player before moving
]]--
function Tank:savePosition()
		self.prevX = self.tileX
		self.prevY = self.tileY
end

--[[
	Move to next tile
	
	x		- Add to current x position
	y		- Add to current y position
]]--
function Tank:moveTile(x, y)
	local newX = self.tileX + x
	local newY = self.tileY + y
	
	local function getTile(layer_name)
		return self.map.layers[layer_name](newX, newY)
	end
	
	if y < 0 then
		self.facing = "upWalk"
	elseif y > 0 then
		self.facing = "downWalk"
	elseif x < 0 then
		self.facing = "leftWalk"
	elseif x > 0 then
		self.facing = "rightWalk"
	end
	
	if getTile("Ground") == nil then return end
	if self.collision[newY][newX] == 1 then return end
	
	self.tileX = newX
	self.tileY = newY
end

--[[
	Update Player
	
	dt			- Delta time
	tickRate	- Ticks per second
	time		- Time elapsed
	lastTime	- Time during last tick
]]--
function Tank:update(dt, tickRate, time, lastTime)
	self.x = interpolate(tween.linear,
		math.floor(self.prevX * self.map.tileWidth),
		math.floor(self.tileX * self.map.tileWidth),
		tickRate, time - lastTime
	)
	
	self.y = interpolate(tween.linear,
		math.floor(self.prevY * self.map.tileHeight),
		math.floor(self.tileY * self.map.tileHeight),
		tickRate, time - lastTime
	)
end
