require "libs.AnAL"
local Class = require "libs.hump.class"

Entity = Class {}

--[[
	Initialize Object
	
	image		- Sprite map
	w			- Width
	h			- Height
	x			- X coord
	y			- Y coord
	r			- Radial direction
]]--
function Entity:init(image, w, h, x, y, r)
	self.image			= love.graphics.newImage(image)
	self.w				= w
	self.h				= h
	self.x				= x
	self.y				= y
	self.r				= r
	
	self.facing			= "idle"
	self.sprites		= {}
end

--[[
	Update Object
]]--
function Entity:update(dt)
	self.sprites[self.facing].image:update(dt)
end

--[[
	Draw Object
]]--
function Entity:draw()
	local x	= math.floor(self.x)
	local y	= math.floor(self.y)
	local r	= math.rad(math.floor(self.r))
	
	self.sprites[self.facing].image:draw(x, y, r)
end

--[[
	New Sprites
	
	name	- Name of sprite
	img		- Sprite map
	w		- Sprite width
	h		- Sprite height
	sx		- Start Frame: X
	sy		- Start Frame: Y
	ex		- End Frame: X
	ey		- End Frame: Y
	ft		- Time to display each frame (in seconds)
]]--
function Entity:newSprite(name, img, w, h, sx, sy, ex, ey, ft)
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
