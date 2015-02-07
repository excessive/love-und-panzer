local actions = {}

local function define(name, id)
	-- reverse lookups for all the things!
	actions[name] = id
	actions[id] = name
end

define("shoot", 1)
define("disconnect", 7)

return actions
