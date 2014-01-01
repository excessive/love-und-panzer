require "libs.AnAL"
require "bullet"
require "entity"
local Class = require "libs.hump.class"

Tank = Class {}
Tank:include(Entity)

--[[
	Tank object
	
	id			- Network ID
	map			- A reference of the map
	collision	- Collision map
	image		- Sprite map
	w			- Width on map
	h			- Height on map
	x			- TileX on map
	y			- TileY on map
	r			- Radial direction
	tr			- Turret Radial direction
	speed		- Tiles per second
	turnSpeed	- Radians per second
]]--
function Tank:init(id, map, collision, image, w, h, x, y, r, tr, speed, turnSpeed, reloadSpeed)
	Entity.init(self, image, w, h, x, y, r)
	
	self.id				= id
	
	self.map			= map
	self.collision		= collision
	self.speed			= speed
	self.turnSpeed		= turnSpeed
	self.reloadSpeed	= reloadSpeed
	
	self.tr				= tr
	self.hp				= 100
	self.cd				= 0
	
	self:newSprite("idle",		self.image, self.w, self.h, 0, 0, 1, 0, 0.03)
	self:newSprite("forward",	self.image, self.w, self.h, 3, 0, -1, 0, 0.03)
	self:newSprite("backward",	self.image, self.w, self.h, 0, 0, 4, 0, 0.03)
	self:newSprite("turnLeft",	self.image, self.w, self.h, 4, 0, 8, 0, 0.03)
	self:newSprite("turnRight",	self.image, self.w, self.h, 7, 0, 3, 0, 0.03)
	
	self.turret			= love.graphics.newQuad(0 * 32, 128, 32, 64, 512, 256)
	
	self.bullet			= Bullet(map, collision, "assets/sprites/bullet.png", 4, 4, 5)
end

--[[
	Update Tank
]]--
function Tank:update(dt)
	self.x	= client.players[self.id].x
	self.y	= client.players[self.id].y
	self.r	= client.players[self.id].r
	self.tr	= client.players[self.id].tr
	self.hp	= client.players[self.id].hp
	self.cd	= client.players[self.id].cd
	
	self.bullet:update(dt)
	
	Entity.update(self, dt)
end

--[[
	Draw Tank
]]--
function Tank:draw()
	self.bullet:draw()
	
	local x		= math.floor(self.x)
	local y		= math.floor(self.y)
	local r		= math.rad(math.floor(self.r + 90))
	local tr	= math.rad(math.floor(self.tr + 90))
	
	self.sprites[self.facing].image:draw(x, y, r, 1, 1, self.w / 2, self.h / 2)
	love.graphics.draw(self.image, self.turret, x, y, tr, 1, 1, 16, 48)
end

--[[
	Shoot Cannon
]]--
function Tank:shoot()
	if self.cd <= 0 then
		self.bullet:load(self.x, self.y, self.tr)
		self.cd = self.reloadSpeed
	end
end
