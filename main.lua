local ffi = require "ffi" -- gotta get SDL_GL_GetProcAddress
local lume = require "libs.lume"
console = require "libs.console"
Gamestate = require "libs.hump.gamestate"
Timer = require "libs.hump.timer"
Signal = require "libs.hump.signal"
lurker = require "libs.lurker"
require "ffi.imagedata" -- speed up mapPixel and friends by a lot

-- error on undeclared globals so we don't bite ourselves in the ass.
-- not compatible with hump.class though :(
-- require "libs.strict"

local sixense = false -- disable the lib for now

if sixense then
	sixense = require "ffi.sixense"
end

-- I DO WHAT I WANT SLIME
-- YOU'RE NOT MY REAL DAD
ffi.cdef([[void *SDL_GL_GetProcAddress(const char *proc);]])

-- :|
local sdl_on_windows_tho
if love.system.getOS() == "Windows" then
	sdl_on_windows_tho = require "ffi.sdl2"
end

local screenshot

lurker_no_lurking = false

local function rpad(str, length)
	local padding = length - str:len()
	return str .. (" "):rep(math.max(padding, 0))
end

function love.load()
	local opengl = require "ffi.opengl"
	opengl.loader = function(fn)
		local ptr
		if sdl_on_windows_tho then
			ptr = sdl_on_windows_tho.GL_GetProcAddress(fn)
		else
			ptr = ffi.C.SDL_GL_GetProcAddress(fn)
		end
		-- GURU MEDITATION
		-- console.i(string.format("Loaded GL function: %s (%s)", fn, tostring(ptr)))
		return ptr
	end
	opengl:import()

	if sixense then
		sixense.sixenseExit()
		if sixense.sixenseInit() ~= sixense.SIXENSE_SUCCESS then
			console.e("Failed to init Sixense.")
			sixense = false
		else
			if sixense.sixenseIsBaseConnected(0) then
				console.i("Sixense base 0 detected. Enabling Sixense.")
				sixense.sixenseSetActiveBase(0)
			else
				console.i("No Sixense base detected. Disabling Sixense.")
				sixense = false
			end
		end
	end

	-- if sixense then
	-- 	sixense.sixenseExit()
	-- end

	love.graphics.setBackgroundColor(30, 30, 30, 255)
	console.load(love.graphics.newFont("assets/fonts/Inconsolata.otf", 14), true)

	console.defineCommand(
		"load",
		"Load a gamestate.",
		function(state)
			if not state then
				error("Load what? Usage: load <gamestate>")
			end
			local file = "states/" .. state .. ".lua"
			if not love.filesystem.isFile(file) then
				error(string.format("%s is not a valid gamestate.", state))
			end
			console.i(string.format("Loading gamestate: %s", state))
			Gamestate.switch(require("states." .. state))
		end
	)

	console.defineCommand(
		"list",
		"List all gamestates",
		function()
			function recursiveEnumerate(root, folder, fileTree)
				folder = folder or root
				fileTree = fileTree or ""
				local len = root:len() + 2 -- +2 for \n and /
				local lfs = love.filesystem
				local filesTable = lfs.getDirectoryItems(folder)
				for i,v in ipairs(filesTable) do
					local file = folder.."/"..v
					if lfs.isFile(file) then
						if file:sub(-4) == ".lua" then
							fileTree = fileTree .. string.format("\n%s", file:sub(len, -5))
						end
					elseif lfs.isDirectory(file) then
						fileTree = recursiveEnumerate(root, file, fileTree)
					end
				end
				return fileTree
			end
			console.i("Available gamestates:")
			console.i(recursiveEnumerate("states"):sub(2))
		end
	)

	Gamestate.registerEvents {
		'focus', 'keyreleased', 'mousefocus', 'resize', 'update', 'errhand',
		'mousereleased', 'quit', 'threaderror', 'visible', 'gamepadaxis',
		'gamepadpressed', 'gamepadreleased', 'joystickadded', 'joystickaxis',
		'joystickhat', 'joystickpressed', 'joystickreleased', 'joystickremoved'
	}
	Gamestate.switch(require "states.menu")
	screenshot = {
		watermark = love.image.newImageData("assets/coobs.png")
	}
end

function love.update(dt)
	console.update(dt)
	if not lurker_no_lurking then
		lurker.update()
	end

	local function get_direction(joystick, axis1, axis2)
		local axis = axis1
		local dir1, dir2
		local deadzone = 0.3

		dir1 = joystick:getGamepadAxis(axis1)
		if dir1 < deadzone and dir1 > -deadzone then dir1 = 0 end

		if axis2 then
			axis = "axis"..axis:sub(1, -2)
			dir2 = joystick:getGamepadAxis(axis2)
			if dir2 < deadzone and dir2 > -deadzone then dir2 = 0 end
		end

		Signal.emit("moved-"..axis, joystick, dir1, dir2)
	end

	local joysticks = love.joystick.getJoysticks()

	for _, joystick in ipairs(joysticks) do
		if joystick:isGamepad() then
			get_direction(joystick, "leftx", "lefty")
			get_direction(joystick, "rightx", "righty")
			get_direction(joystick, "triggerleft")
			get_direction(joystick, "triggerright")
		end
	end
end

function love.draw()
	Gamestate.draw()
	console.draw()
end

function love.threaderror(thread, errorstr)
	console.e(string.format("%s: %s", thread, errorstr))
end

function love.keypressed(k, r)
	if not love.window.hasFocus() then return end

	local isDown = love.keyboard.isDown
	if k == "f11" or (k == "return" and (isDown "lalt" or isDown "ralt")) then
		love.window.setFullscreen(not (love.window.getFullscreen()), "desktop")
	end

	-- Considering how automatic love tends to be, this is really weird.
	-- Should poke slime about it.
	local holding = {
		shift = isDown "lshift" or isDown "rshift"
	}
	if k == "f1" and holding.shift then
		love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
	end
	if k == "printscreen" or (k == "f12" and holding.shift) then
		local t = love.timer.getTime()
		love.filesystem.createDirectory("Screenshots")

		local screen = love.graphics.newScreenshot()
		local path = "Screenshots/" .. "ss-" .. os.time() .. ".png"

		local function blit(screen, mark)
			local w, h = screen:getDimensions()
			local cw, ch = mark:getDimensions()
			local alpha = 0.5

			-- Copy mark into the corner of the screenshot, respecting alpha.
			screen:mapPixel(function(x, y, r, g, b, a)
				if x >= w - cw and y >= h - ch then
					local cx, cy = x - (w - cw), y - (h - ch)
					local cr, cg, cb, ca = mark:getPixel(cx, cy)
					return lume.lerp(r, cr, (ca / 255) * alpha),
					       lume.lerp(g, cg, (ca / 255) * alpha),
					       lume.lerp(b, cb, (ca / 255) * alpha),
					       a
				else
					return r, g, b, a
				end
			end)
		end

		blit(screen, screenshot.watermark)

		local f = love.filesystem.newFile(path)
		f:open("w")
		screen:encode(path)
		f:close()

		console.i(string.format(
			"Wrote screenshot to %s in %fs",
			love.filesystem.getSaveDirectory() .. "/" .. path,
			love.timer.getTime() - t
		))
	end

	-- block for console events
	if console.keypressed(k) then return end

	Gamestate.keypressed(k, r)
end

function love.mousepressed(x, y, b)
	if not love.window.hasMouseFocus() then return end

	-- block for console events
	if console.mousepressed(x, y, b) then
		return
	end
	Gamestate.mousepressed(x, y, b)
end

function love.gamepadpressed(joystick, button)
	if not love.window.hasFocus() then return end

	-- console.i("Pressed: %s, %s", joystick:getID(), button)
	Signal.emit("pressed-"..button, joystick)
end

function love.gamepadreleased(joystick, button)
	-- console.i("Release: %s, %s", joystick:getID(), button)
	Signal.emit("released-"..button, joystick)
end

function love.textinput(t)
	if not love.window.hasFocus() then return end

	if console.textinput(t) then
		return
	end
	Gamestate.textinput(t)
end

function love.resize(w, h)
	console.resize(w, h)
end
