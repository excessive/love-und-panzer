local Camera      = require "libs.camera3d"
local cpml        = require "libs.cpml"
local lume        = require "libs.lume"
local geometry    = require "geometry"
local PostProcess = require "postprocess"
local map         = require "map_loader"
local Terrain     = require "terrain"
local Gameplay    = {}

--[[
1) terrain needs bounding boxes for each triangle (or just do a check on each tile's triangles)
2) implement gravity so tank falls and collides with terrain
3) use tank bounding box to grab terrain positions from each of the tank's corners
4) create new tile and adjust orientation to fix normals
5) adjust tank to this normal
--]]

function Gameplay:enter(from, name, resources, terrain, connection, chat, controls)
	lurker.postswap = function(f)
		if connection then
			connection:disconnect()
		end
		Gamestate.switch(require "states.loading", name, resources, connection.host, connection.port, controls, chat)
	end

	self.wireframe = false
	self.gamma     = 2.2
	self.post      = PostProcess()
	self.resources = resources

	self.players = {}
	self.map     = map.new()
	self.manager = require "client_manager"
	self.manager:init(connection, name, self.map, self.players)

	self.map:add_object(Terrain(
		"Terrain_01",
		terrain,
		"assets/shaders/shader.glsl",
		self.gamma,
		"assets/textures/Grass0130_2_S.dds"
	))

	self.chat     = chat or false
	self.controls = controls
	self.camera   = Camera(cpml.vec3(0,0,0))
	self.flat     = love.graphics.newShader("assets/shaders/flat.glsl")
	self.sniper   = false

	self.original_x, self.original_y = false, false
	self.prevx, self.prevy           = love.mouse.getPosition()

	self.grabbed     = false
	self.first_press = true
	self.focused     = love.window.hasFocus()

	self.camera:grab(self.grabbed)
	self.map:set_camera(self.camera)

	self.ui = require "ui.gameplay"
	self.ui:init()

	Signal.register("pressed-a",       function(...) self:pressed_a(...)       end)
	Signal.register("pressed-y",       function(...) self:pressed_y(...)       end)
	Signal.register("pressed-back",    function(...) self:pressed_back(...)    end)
	Signal.register("moved-axisleft",  function(...) self:moved_axisleft(...)  end)
	Signal.register("moved-axisright", function(...) self:moved_axisright(...) end)
end

function Gameplay:update(dt)
	collectgarbage("step")

	self.manager:update(dt)

	if self.chat then
		self.chat:update(dt)
	end

	local move, turn, turret = self:check_controls()
	Signal.emit("moved-axisleft", nil, turn, move)
	Signal.emit("moved-axisright", nil, turret)

	local w, h = love.graphics.getDimensions()
	local mx, my = love.mouse.getPosition()
	local dx, dy = self.prevx - mx, self.prevy - my
	self.prevx, self.prevy = mx, my

	if console.visible or not self.focused then
		if love.mouse.isDown("l") or self.grabbed then
			dx, dy = love.mouse.getPosition()
			dx, dy = w/2 - dx, h/2 - dy
			if self.first_press then
				self.original_x, self.original_y = love.mouse.getPosition()
			end
			love.mouse.setPosition(w/2, h/2)
		else
			if self.original_x and self.original_y then
				love.mouse.setPosition(self.original_x, self.original_y)
				self.original_x, self.original_y = false, false
			end
		end

		if love.mouse.isDown("l") or self.grabbed then
			if not self.first_press then
				self.camera:rotateXY(dx, dy)
			else
				self.first_press = false
			end
		end
	end

	for _, player in pairs(self.players) do
		self.map.draw_data[player.id]        = {}
		self.map.draw_data[player.id].Turret = cpml.mat4():rotate(player.turret, { 0, 0, 1 })

		local terrain = self.map:get("Terrain_01")
		local tiles = {}
		tiles.start			= terrain:get_tile(player.position)
		tiles.top_left		= terrain:get_tile(cpml.vec3(player.position.x-2, player.position.y+2, player.position.z))
		tiles.top_right		= terrain:get_tile(cpml.vec3(player.position.x+2, player.position.y+2, player.position.z))
		tiles.bottom_right	= terrain:get_tile(cpml.vec3(player.position.x+2, player.position.y-2, player.position.z))
		tiles.bottom_left	= terrain:get_tile(cpml.vec3(player.position.x-2, player.position.y-2, player.position.z))

		-- I TOLD YOU ABOUT STAIRS BRO
		-- STOP REMOVING THIS MOTHERFUCKING CHECK YOU ASSHOLE
		-- @u@
		if tiles.start and tiles.top_left and tiles.top_right and tiles.bottom_left and tiles.bottom_right then
			local function ananas(tile, player_offset)
				local hit = cpml.intersect.ray_triangle
				local triangles = {
					{ tile.positions[1], tile.positions[2], tile.positions[3] },
					{ tile.positions[1], tile.positions[3], tile.positions[4] }
				}
				local ray = {
					point = tile.center + cpml.vec3(player_offset.x, player_offset.y, 10),
					direction = cpml.vec3(0, 0, -1)
				}

				-- only one of these will probably hit so we'll just go with that
				local p = hit(ray, triangles[1]) or hit(ray, triangles[2])
				if p then p = p + tile.offset end
				return p
			end

			local offset = player.position - (tiles.start.center + tiles.start.offset)
			local new_tile = {}
			new_tile.vertices = {}
			table.insert(new_tile.vertices, ananas(tiles.bottom_left, offset))
			table.insert(new_tile.vertices, ananas(tiles.bottom_right, offset))
			table.insert(new_tile.vertices, ananas(tiles.top_right, offset))
			table.insert(new_tile.vertices, ananas(tiles.top_left, offset))
			new_tile.center = cpml.mesh.average(new_tile.vertices)

			local normals = {}
			table.insert(normals, cpml.mesh.compute_normal(new_tile.vertices[1], new_tile.vertices[2], new_tile.vertices[3]))
			table.insert(normals, cpml.mesh.compute_normal(new_tile.vertices[1], new_tile.vertices[3], new_tile.vertices[4]))
			new_tile.normal = -(normals[1] + normals[2]):normalize()
			player.up = new_tile.normal

			player.orientation.x = -math.atan2(new_tile.normal.y, math.sqrt((new_tile.normal.x * new_tile.normal.x) + (new_tile.normal.z * new_tile.normal.z)))
			player.orientation.y = math.atan2(new_tile.normal.x, new_tile.normal.z)
			player.direction = player.orientation:orientation_to_direction()
			player.position.z = new_tile.center.z

			if self.debug_geometry then
				local triangles = {
					new_tile.vertices[1], new_tile.vertices[2], new_tile.vertices[3],
					new_tile.vertices[1], new_tile.vertices[3], new_tile.vertices[4]
				}
				table.insert(self.debug_squares, (geometry.new_triangles(triangles, cpml.vec3(0, 0, 0.01))))
			end
		end

		local model = cpml.mat4()
			:rotate(-player.orientation.z, { 0, 0, 1 })
			:rotate(-player.orientation.y, { 0, 1, 0 })
			:rotate(-player.orientation.x, { 1, 0, 0 })
			:scale(player.scale)

		for k, buffer in ipairs(player.model.bounds) do
			local m = model
			local vb = player.model.vertex_buffer[k]
			local draw_data = self.map.draw_data[id]
			if draw_data[vb.name] then
				m = m * draw_data[vb.name]:scale(cpml.vec3(-1, 1, 1))
			end
			geometry.update_bounding_box(buffer[1], buffer[2], m, vb.bounds.min, vb.bounds.max)
		end
	end

	if self.manager.id then
		local player     = self.players[self.manager.id]
		player.direction = player.orientation:orientation_to_direction()


		if self.sniper then
			local forward = player.direction:rotate(player.turret, player.up)
			local side    = forward:cross(player.up)
			local offset  = cpml.vec3(0, -1.97, 1.37)

			self.camera.forced_transforms = true
			self.camera.position          = player.position + offset
			self.camera.direction         = forward
			self.camera.view              = cpml.mat4()
				:translate(offset)
				:look_at(player.position, player.position + forward, player.up)
		else
			self.camera.forced_transforms = false
			self.camera.position          = player.position - player.direction * 13
			self.camera.position.z        = self.camera.position.z + 5
			self.camera.direction         = (player.position + cpml.vec3(0, 0, 3.5) - self.camera.position):normalize()
		end
	end

	self.map:update(dt)
	self.ui:update(dt)
end

function Gameplay:draw()
	local color = cpml.vec3(0.7, 0.9, 1.0)
	gl.ClearColor(color.x, color.y, color.z, color:dot(cpml.vec3(0.299, 0.587, 0.114)))

	-- Disable blending because we use/abuse the alpha channel for other stuff.
	gl.Disable(GL.BLEND)

	self.post:bind()
	self.map:draw()
	self.post:unbind()
	self.post:draw()

	gl.Enable(GL.BLEND)

	self.ui:set_nametags(self.map:get_nametags())
	self.ui:draw()
end

function Gameplay:keypressed(key, isrepeat)
	if key == "escape" then
		Signal.emit("pressed-back")
	end

	if key == " " then
		Signal.emit("pressed-y")
	end

	if key == "g" then
		self.grabbed = not self.grabbed
		if not self.grabbed then
			self.first_press = true
			self.camera:grab(self.grabbed)
		elseif not love.mouse.isDown("l") then
			self.camera:grab(self.grabbed)
		end
	end

	local move, turn, turret = self:check_controls(key, isrepeat)
	Signal.emit("moved-axisleft", nil, turn, move)
	Signal.emit("moved-axisright", nil, turret)
end

function Gameplay:keyreleased(key)
	local move, turn, turret = self:check_controls(key)
	Signal.emit("moved-axisleft", nil, turn, move)
	Signal.emit("moved-axisright", nil, turret)
end

function Gameplay:mousepressed(x, y, button)
	if button == "l" then
		self.camera:grab(true)
		self.first_press = true

		Signal.emit("pressed-a")
	end
end

function Gameplay:mousereleased(x, y, button)
	if button == "l" and not self.grabbed then
		self.camera:grab(false)
	end
end

function Gameplay:resize(x, y)
	self.post:rebuild()
end

function Gameplay:focus(f)
	self.focused = f
	if not f then
		self.camera:grab(false)
	else
		if self.grabbed then
			self.camera:grab(true)
		end
	end
end

function Gameplay:leave()
	--self.wireframe = nil
	--self.gamma     = nil
	--self.post      = nil
	--self.resources = nil
	--self.controls  = nil
	--self.camera    = nil
	--self.flat      = nil
	--self.players   = nil
	--self.prevx     = nil
	--self.prevy     = nil

	self.manager:destroy()

	if self.chat then
		self.chat:disconnect()
	end

	Signal.clear_pattern("pressed%-.*")
	Signal.clear_pattern("released%-.*")
	Signal.clear_pattern("moved%-.*")
end

function Gameplay:check_controls(key, isrepeat)
	local move    = 0
	local turn    = 0
	local turret  = 0
	local holding = {
		forward      = self.controls:check("move_forward", key) and not isrepeat,
		back         = self.controls:check("move_back",    key) and not isrepeat,
		left         = self.controls:check("turn_left",    key) and not isrepeat,
		right        = self.controls:check("turn_right",   key) and not isrepeat,
		turret_left  = self.controls:check("turret_left",  key) and not isrepeat,
		turret_right = self.controls:check("turret_right", key) and not isrepeat,
	}

	if holding.forward      then move   = move   - 1 end
	if holding.back         then move   = move   + 1 end
	if holding.left         then turn   = turn   - 1 end
	if holding.right        then turn   = turn   + 1 end
	if holding.turret_left  then turret = turret - 1 end
	if holding.turret_right then turret = turret + 1 end

	return move, turn, turret
end

-- Gamepad Signals
function Gameplay:pressed_a(joystick)
	if not self.manager.id then return end
end

function Gameplay:pressed_y(joystick)
	if not self.manager.id then return end

	self.sniper = not self.sniper
end

function Gameplay:pressed_back(joystick)
	Gamestate.switch(require "states.menu")
end

function Gameplay:moved_axisleft(joystick, x, y)
	if not self.manager.id then return end

	local dt         = love.timer.getDelta()
	local turn       = x
	local move       = -y
	local move_speed = 420/6/6
	local turn_speed = 35
	local id         = self.manager.id
	local player     = self.players[id]
	local collision  = false

	if move >= 0 then
		turn = -turn
	end

	-- velocity is additive so that conflicting inputs (i.e. two controllers)
	-- will not cause jitter or double integration.
	local velocity = player.velocity + cpml.vec3(0, move * move_speed, 0):rotate(player.orientation.z, cpml.vec3(0, 0, 1))
	if velocity:len() > move_speed then
		velocity = velocity:normalize() * move_speed
	end
	local new_pos = player.position + velocity * dt

	for i, p in pairs(self.players) do
		if i ~= id then
			local c1 = { point=new_pos,    radius=player.radius }
			local c2 = { point=p.position, radius=p.radius }
			if cpml.intersect.circle_circle(c1, c2) then
				collision = true
				break
			end
		end
	end

	if not collision then
		player.velocity = velocity
	else
		player.velocity = cpml.vec3(0, 0, 0)
	end

	-- rotational velocity is additive so that conflicting inputs (i.e. two controllers)
	-- will not cause jitter or double integration.
	player.rot_velocity = player.rot_velocity + cpml.vec3(0, 0, turn * turn_speed)
	if player.rot_velocity:len() > turn_speed then
		player.rot_velocity = player.rot_velocity:normalize() * turn_speed
	end
end

function Gameplay:moved_axisright(joystick, x, y)
	if not self.manager.id then return end

	local dt           = love.timer.getDelta()
	local turret       = -x
	local turret_speed = 44
	local id           = self.manager.id
	local player       = self.players[id]

	-- turret velocity is additive so that conflicting inputs (i.e. two controllers)
	-- will not cause jitter or double integration.
	player.turret_velocity = player.turret_velocity + turret * turret_speed
	if player.turret_velocity > turret_speed then
		player.turret_velocity = turret_speed
	end

	local direction         = cpml.mat4():rotate(player.turret, { 0, 0, 1 }) * cpml.mat4():rotate(player.orientation.z, { 0, 0, 1 })
	player.turret_direction = cpml.vec3(direction * { 0, 1, 0, 1 })
end

function Gameplay:action_shoot(id)

end

function Gameplay:action_disconnect(id)
	local player = self.players[id]
	self.players[id] = nil

	local map_id = self.map:get_id(player.id)
	if map_id then
		self.map:remove_object(map_id)
	end
end

return Gameplay
