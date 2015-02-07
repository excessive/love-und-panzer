return {
	-- note: +Z=up, +Y=forward
	cameras = {
		{
			position = { x = 0, y = 0, z = 0 },
			orientation = { x = 0, y = 0, z = 0 }, -- in radians
			fov = 45, -- in degrees
		}
	},
	lights = {},
	objects = {
		{
			position = { x = 0, y = 0, z = 0 },
			orientation = { x = 0, y = 0, z = 0 }, -- in radians
			scale = { x = 1, y = 1, z = 1 },
			model = "assets/models/tank.iqe",
			material = "assets/materials/tank.mtl",
			type = "animated",
			name = "Panzer", -- all names must be unique!
		},
		{
			name = "skydome",
			model = "assets/models/skydome.iqe",
			material = "assets/materials/skydome.mtl",
			position = { x = 0, y = 0, z = -1, },
			orientation = { x = 0, y = 0, z = 0 }, -- in radians
			scale = { x = 30, y = 30, z = 30 },
			type = "static"
		},
		{
			name = "grid",
			model = "assets/models/uv_grid.iqe",
			material = "assets/materials/uv_grid.mtl",
			position = { x = 0, y = 0, z = 0 },
			orientation = { x = 0, y = 0, z = 0 },
			scale = { x = 100, y = 100, z = 100 },
			type = "static"
		},
	}
}
