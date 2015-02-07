function love.conf(t)
	t.identity              = nil
	t.version               = "0.9.1"
	t.console               = false

	t.window.title          = "LÖVE und PANZER: 3D!"
	t.window.icon           = nil
	t.window.width          = 1280
	t.window.height         = 720
	t.window.borderless     = false
	t.window.resizable      = true
	t.window.minwidth       = 960
	t.window.minheight      = 600
	t.window.fullscreen     = false
	t.window.fullscreentype = "desktop"
	t.window.vsync          = true
	t.window.fsaa           = 0
	t.window.display        = 1
	t.window.highdpi        = false
	t.window.srgb           = false

	t.modules.audio         = true
	t.modules.event         = true
	t.modules.graphics      = true
	t.modules.image         = true
	t.modules.joystick      = true
	t.modules.keyboard      = true
	t.modules.math          = true
	t.modules.mouse         = true
	t.modules.physics       = false
	t.modules.sound         = true
	t.modules.system        = true
	t.modules.timer         = true
	t.modules.window        = true

	io.stdout:setvbuf("no")
end
