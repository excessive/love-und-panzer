local cpml = require "libs.cpml"
local Light = {}

function Light:init()
	self.lights = {}
end

function Light:new_light(name, position, direction, intensity)
	local light = {}
	light.position = position or cpml.vec3(0, 0, 0)
	light.direction = direction or cpml.vec3(0, 0, 0)
	light.intensity = intensity or 1

	self.lights[name] = light

	return light
end

function Light:update(dt)

end

function Light:draw()

end

return Light
