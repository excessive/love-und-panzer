require "libs.AnAL"
require "bullet"
Class = require "libs.hump.class"

Tank = Class {}

--[[
	Tank object
	
	map			- A reference of the map
	collision	- Collision map
	image		- Spritemap
	w			- Width on map
	h			- Height on map
	x			- TileX on map
	y			- TileY on map
	r			- Radial direction
	tr			- Turret Radial direction
	speed		- Tiles per second
	turnSpeed	- Radians per second
	ammo		- Number of bullets
]]--
function Tank:init(id, map, collision, image, w, h, x, y, r, tr, speed, turnSpeed, reloadSpeed)
	self.colour = {
		pink = 0,
		blue = 1,
	}
	
	self.id				= id
	
	self.map			= map
	self.collision		= collision
	self.speed			= speed
	self.turnSpeed		= turnSpeed
	self.reloadSpeed	= reloadSpeed
	
	self.image			= love.graphics.newImage(image)
	self.w				= w
	self.h				= h
	
	self.x				= x
	self.y				= y
	self.r				= r
	self.tr				= tr
	self.hp				= 100
	self.cd				= 0
	
	self.sprites		= {}
	self:newSprite("idle",		self.image, self.w, self.h, 0, self.colour.pink, 1, self.colour.pink, 0.03)
	self:newSprite("forward",	self.image, self.w, self.h, 3, self.colour.pink, -1, self.colour.pink, 0.03)
	self:newSprite("backward",	self.image, self.w, self.h, 0, self.colour.pink, 4, self.colour.pink, 0.03)
	self:newSprite("turnLeft",	self.image, self.w, self.h, 4, self.colour.pink, 8, self.colour.pink, 0.03)
	self:newSprite("turnRight",	self.image, self.w, self.h, 7, self.colour.pink, 3, self.colour.pink, 0.03)
	self.facing			= "idle"
	
	self.turret			= love.graphics.newQuad(self.colour.pink * 32, 128, 32, 64, 512, 256)
	
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
	
	self.sprites[self.facing].image:update(dt)
	self.bullet:update(dt)
end

--[[
	Draw Tank
]]--
function Tank:draw()
	self.bullet:draw()
	self.sprites[self.facing].image:draw(math.floor(self.x), math.floor(self.y), math.rad(math.floor(self.r + 90)), 1, 1, self.w / 2, self.h / 2)
	love.graphics.draw(self.image, self.turret, math.floor(self.x), math.floor(self.y), math.rad(math.floor(self.tr + 90)), 1, 1, 16, 48)
end

--[[
	New Sprites
	
	name	- Name of sprite
	img		- Spritemap
	w		- Sprite width
	h		- Sprite height
	sx		- Staert Frame: X
	sy		- Start Frame: Y
	ex		- End Frame: X
	ey		- End Frame: Y
	ft		- Time to display each frame (in seconds)
]]--
function Tank:newSprite(name, img, w, h, sx, sy, ex, ey, ft)
	local a = newAnimation(img, w, h, ft, 1)
	a.frames = {}
	
	while sx ~= ex do
		a:addFrame(sx * w, sy * h, w, h, ft)
		
		if sx < ex then
			sx = sx + 1
		else
			sx = sx - 1
		end
	end
	
	self.sprites[name] = {}
	self.sprites[name].image	= a
	self.sprites[name].w		= w
	self.sprites[name].h		= h
end

--[[
	Shoot Cannon
]]--
function Tank:shoot()
	if self.ammo > 0 and self.reload <= 0 then
		self.bullet:load(self.x, self.y, self.tr)
		self.reload = self.reloadSpeed
		self.ammo = self.ammo - 1
	end
end
