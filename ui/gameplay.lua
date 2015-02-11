local boxer = require "libs.boxer"
local ui = {}

function ui:init(manager)
	self.manager  = manager
	self.nametags = {}
end

function ui:update(dt)

end

function ui:draw()
	local w, h = love.graphics.getDimensions()

	love.graphics.setShader()

	for _, nametag in ipairs(self.nametags) do
		if nametag.viewable then
			love.graphics.setColor(0, 0, 0, 100)
			love.graphics.printf(nametag.text, nametag.position.x, h - nametag.position.y + 1, 0, "center")
			love.graphics.setColor(255, 255, 255, 200)
			love.graphics.printf(nametag.text, nametag.position.x, h - nametag.position.y, 0, "center")
		end
	end
	love.graphics.setColor(255, 255, 255, 255)

	local boxes = {}
	--local font = self.resources.font.ui
	local font = love.graphics.newFont()
	local c = boxer.new_box(boxes, font)

	local bright = { 255, 255, 255, 255 }
	local dim = { 180, 180, 180, 255 }
	boxer.new_line(c, "Stats", bright)
	boxer.new_line(c, string.format("FPS: %4.2f", love.timer.getFPS()), dim)
	boxer.new_line(c, string.format("ms/f: %4.2f", (1 / love.timer.getFPS()) * 1000), dim)

	c = boxer.new_box(boxes, font)
	boxer.new_line(c, "Hotkeys", bright)
	boxer.new_line(c, "WASD: Move", dim)
	boxer.new_line(c, "Space: Sniper", dim)
	boxer.new_line(c, "G: (Un)grab mouse", dim)
	boxer.new_line(c, "Mouse: Aim", dim)

	boxer.draw(boxes)

	if self.display_lut then
		love.graphics.draw(self.use_color_correction and self.lut_primary or self.lut_secondary)
	end

	-- Minimap!
	local w, h = love.graphics.getDimensions()
	local x, y = w-210, 10
	local size = 200
	love.graphics.setColor(50, 50, 50, 200)
	love.graphics.rectangle("fill", x, y, size, size)

	for _, player in pairs(self.manager.players) do
		love.graphics.setColor(255, 127, 225, 255)
		local px = math.floor(player.position.x / 256 * size)
		local py = math.floor(player.position.y / 256 * size)

		if px <= size and py <= size and px >= 0 and py >= 0 then
			if self.manager.id then
				if player.id == self.manager.id then
					love.graphics.setColor(127, 225, 255, 255)
				end
			end
			love.graphics.circle("fill", x+px, y+py, 3)
			love.graphics.setColor(bright)
		end
	end
end

function ui:set_nametags(nametags)
	self.nametags = nametags
end

return ui
