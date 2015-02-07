local Class	= require"libs.hump.class"
local Item	= Class {}

function Item:init(item)
	assert(item.class ~= nil)
	assert(item.name ~= nil)

	self.class	= item.class
	self.name	= item.name
	self.lore	= item.lore or ""
	self.stats	= {}

	local stats = {
		"hp",
		"atk",
		"int",
		"def",
		"res",
		"spd"
	}

	for _, stat in ipairs(stats) do
		local s = {
			base = 0,
			apt = 0,
			value = 0
		}
		if item.stats and item.stats[stat] then
			s.base	= item.stats[stat].base or 0
			s.apt	= item.stats[stat].apt or 0
		end
		self.stats[stat] = s
	end
end	

return Item
