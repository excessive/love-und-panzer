Class = require "libs.hump.class"

Bullet = Class {}

--[[
	Bullet object
	
	map			- A reference of the map
	collision	- Collision map
	image		- Spritemap
	w			- Width on map
	h			- Height on map
	speed		- Tiles per second
]]--
function Bullet:init(map, collision, image, w, h, speed)
	self.map		= map
	self.collision	= collision
	self.speed		= speed
	
	self.image		= love.graphics.newImage(image)
	self.w			= self.image:getWidth()
	self.h			= self.image:getHeight()
end

function Bullet:load(x, y, r)
	self.x = x
	self.y = y
	self.r = r
end

function Bullet:update(dt)
	if self.x ~= nil and self.y ~= nil and self.r ~= nil then
		local newX	= self.x + self.speed * self.map.tileWidth * dt * math.cos(math.rad(self.r))
		local newY	= self.y + self.speed * self.map.tileHeight * dt * math.sin(math.rad(self.r))
		
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
		
		if getTile("Ground") == nil then
			self.x = nil
			self.y = nil
			self.r = nil
			return
		end
		
		if self.collision[tileY][tileX] == 1 then
			--[[ WEEEEE
			for k,v in pairs(LIST_OF_TANKS) do
				if bullet collides with tank then
					tank.hp = tank.hp - 20
				end
			end
			]]--
			
			self.x = nil
			self.y = nil
			self.r = nil
			return
		end
		
		self.x		= newX
		self.y		= newY
	end
end

function Bullet:draw()
	if self.x ~= nil and self.y ~= nil and self.r ~= nil then
		love.graphics.draw(self.image, self.x, self.y, math.rad(self.r), 1, 1, self.w / 2, self.h / 2)
	end
end