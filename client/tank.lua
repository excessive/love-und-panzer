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
function Tank:init(map, collision, image, w, h, x, y, r, tr, speed, turnSpeed, reloadSpeed, ammo)
	self.colour = {
		pink = 0,
		blue = 1,
	}
	
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
	
	self.sprites		= {}
	self:newSprite("idle",		self.image, self.w, self.h, 0, self.colour.pink, 1, self.colour.pink, 0.03)
	self:newSprite("forward",	self.image, self.w, self.h, 3, self.colour.pink, -1, self.colour.pink, 0.03)
	self:newSprite("backward",	self.image, self.w, self.h, 0, self.colour.pink, 4, self.colour.pink, 0.03)
	self:newSprite("turnLeft",	self.image, self.w, self.h, 4, self.colour.pink, 8, self.colour.pink, 0.03)
	self:newSprite("turnRight",	self.image, self.w, self.h, 7, self.colour.pink, 3, self.colour.pink, 0.03)
	self.facing			= "idle"
	
	self.turret		= love.graphics.newQuad(self.colour.pink * 32, 128, 32, 64, 512, 256)
	
	self.bullet			= Bullet(map, collision, "assets/sprites/bullet.png", 4, 4, 5)
	self.ammo			= ammo
	self.reload			= 0
end

--[[
	Update Tank
]]--
function Tank:update(dt)
	if self.reload > 0 then
		self.reload = self.reload - dt
	end
	
	self.sprites[self.facing].image:update(dt)
	self.bullet:update(dt)
end

--[[
	Draw Tank
]]--
function Tank:draw()
	self.bullet:draw()
	self.sprites[self.facing].image:draw(math.floor(self.x), math.floor(self.y), math.rad(math.floor(self.r + 90)), 1, 1, self.w / 2, self.h / 2)
	love.graphics.drawq(self.image, self.turret, math.floor(self.x), math.floor(self.y), math.rad(math.floor(self.tr + 90)), 1, 1, 16, 48)
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
	Turn Tank
	
	turn	- Direction to turn
]]--
function Tank:turn(turn)
	if turn > 0 then
		self.facing = "turnLeft"
	elseif turn < 0 then
		self.facing = "turnRight"
	else
		self.facing = "idle"
	end
	
	self.r = self.r + self.turnSpeed * turn
	
	if self.r > 360 then self.r = self.r - 360 end
	if self.r < 0 then self.r = self.r + 360 end
end

--[[
	Move Tank
	
	move	- Direction to move
]]--
function Tank:move(move)
	if move > 0 then
		self.facing = "forward"
	elseif move < 0 then
		self.facing = "backward"
	else
		self.facing = "idle"
	end
	
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
	Rotate Turret
	
	turret		- Direction to rotate
]]--
function Tank:rotateTurret(turret)
	self.tr = self.tr + self.turnSpeed * turret
	
	if self.tr > 360 then self.tr = self.tr - 360 end
	if self.tr < 0 then self.tr = self.tr + 360 end
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
