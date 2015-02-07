local boxer = {}

function boxer.new_box(boxes, font)
	local ret = {}
	table.insert(boxes, ret)
	ret.lines = {}
	ret.padding = 10
	ret.line_height = 20
	ret.width = 180
	ret.color = { 50, 50, 50, 200 }
	ret.font = font
	return ret
end

function boxer.new_line(box, text, color)
	table.insert(box.lines, { color = color or { 0, 0, 0, 255 }, text = text })
end

function boxer.draw(boxes)
	local function draw_box(box, position)
		love.graphics.setFont(box.font)
		love.graphics.setColor(box.color[1], box.color[2], box.color[3], box.color[4])
		love.graphics.rectangle("fill", position.x, position.y, box.width + box.padding * 2, #box.lines * box.line_height + box.padding * 2)
		local last_color
		for i, line in ipairs(box.lines) do
			if line.color ~= last_color then
				love.graphics.setColor(line.color[1], line.color[2], line.color[3], line.color[4])
			end
			love.graphics.print(line.text, position.x + box.padding, position.y + box.padding + (i-1) * box.line_height)
		end
		love.graphics.setColor(255, 255, 255, 255)
	end

	local offset = 0
	for i, box in ipairs(boxes) do
		local position = { x = box.padding, y = box.padding }
		if i > 1 then
			local prev_box = boxes[i-1]
			position.y = #prev_box.lines * prev_box.line_height + prev_box.padding * 4
			position.y = position.y + offset
			offset = position.y - box.padding
		end
		draw_box(box, position)
	end
end

return boxer
