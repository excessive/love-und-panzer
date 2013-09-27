-- NOTE: Special Thanks: http://tannerrogalsky.com/blog/2012/04/06/control-maps-in-love2d/

--[[
------------------------------------------------------------------------------
Input Manager is licensed under the MIT Open Source License.
(http://www.opensource.org/licenses/mit-license.html)
------------------------------------------------------------------------------

Copyright (c) 2012 Landon Manning - LManning17@gmail.com - LandonManning.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

Class = require "libs.hump.class"

Input = Class {
	--[[
		Input Manager
	]]--
	function(self)
		local numJoysticks = love.joystick.getNumJoysticks()
		
		self.keyboard	= {
			press		= {},
			release		= {},
			hold		= {},
		}
		
		self.mouse		= {
			press		= {},
			release		= {},
			hold		= {},
		}
		
		self.joystick = {}
		for i=1, numJoysticks do
			self.joystick[i]	= {
				press		= {},
				release		= {},
				hold		= {
					hats	= {},
					axes	= {},
				},
			}
			
			local numHats = love.joystick.getNumHats(i)
			for j=1, numHats do
				self.joystick[i].hold.hats[j]		= {}
			end
			
			local numAxes = love.joystick.getNumAxes(i)
			for j=1, numAxes do
				self.joystick[i].hold.axes[j]		= {}
			end
		end
	end
}

--[[
	Add Button Binding
	
	device		- Hardware device
	toggle		- Callback
	button		- Button code
	action		- Function to execute
	joystick	- [optional] joystick number
]]--
function Input:addButton(device, toggle, button, action, joystick)
	joystick = joystick or 0
	
	if joystick > 0 then
		self[device][joystick][toggle][button] = action
	else
		self[device][toggle][button] = action
	end
end

--[[
	Add Hat Binding
	
	joystick	- Joystick number
	hat			- Hat number
	button		- Button code
	action		- Function to execute
]]--
function Input:addHat(joystick, hat, button, action)
	self.joystick[joystick].hold.hats[hat][button] = action
end

--[[
	Add Axis Binding
	
	joystick	- Joystick number
	axis		- Axis number
	action		- Function to execute
]]--
function Input:addAxis(joystick, axis, action)
	self.joystick[joystick].hold.axes[axis] = action
end

--[[
	Remove Button Binding
	
	device		- Hardware device
	toggle		- Callback
	button		- Button code
	joystick	- [optional] joystick number
]]--
function Input:removeButton(device, toggle, button, joystick)
	joystick = joystick or 0
	
	if joystick > 0 then
		self[device][joystick][toggle][button] = nil
	else
		self[device][toggle][button] = nil
	end
end

--[[
	Remove Hat Binding
	
	joystick	- Joystick number
	hat			- Hat number
	button		- Button code
]]--
function Input:removeHat(joystick, hat, button)
	self.joystick[joystick].hold.hats[hat][button] = nil
end

--[[
	Add Axis Binding
	
	joystick	- Joystick number
	axis		- Axis number
]]--
function Input:removeAxis(joystick, axis)
	self.joystick[joystick].hold.axes[axis] = nil
end

--[[
	Key Pressed Callback
	
	key			- Key code
	unicode		- Key unicode
]]--
function Input:keypressed(key, unicode)
	local action = self.keyboard.press[key]
	if type(action) == "function" then action() end
end

--[[
	Key Released Callback
	
	key			- Key code
	unicode		- Key unicode
]]--
function Input:keyreleased(key, unicode)
	local action = self.keyboard.release[key]
	if type(action) == "function" then action() end
end

--[[
	Mouse Button Pressed Callback
	
	x			- X position of cursor
	y			- Y position of cursor
	button		- Button code
]]--
function Input:mousepressed(x, y, button)
	local action = self.mouse.press[button]
	if type(action) == "function" then action(x, y) end
end

--[[
	Mouse Button Released Callback
	
	x			- X position of cursor
	y			- Y position of cursor
	button		- Button code
]]--
function Input:mousereleased(x, y, button)
	local action = self.mouse.release[button]
	if type(action) == "function" then action(x, y) end
end

--[[
	Joystick Pressed Callback
	
	joystick	- Joystick number
	button		- Button code
]]--
function Input:joystickpressed(joystick, button)
	local action = self.joystick[joystick].press[button]
	if type(action) == "function" then action() end
end

--[[
	Joystick Released Callback
	
	joystick	- Joystick number
	button		- Button code
]]--
function Input:joystickreleased(joystick, button)
	local action = self.joystick[joystick].release[button]
	if type(action) == "function" then action() end
end

--[[
	Key Held Down
	
	dt			- Delta time
]]--
function Input:keyboardisdown(dt)
	-- Update keys
	for key, action in pairs(self.keyboard.hold) do
		if type(action) == "function" and love.keyboard.isDown(key) then
			action(dt)
		end
	end
end

--[[
	Mouse Button Held Down
	
	dt			- Delta time
]]--
function Input:mouseisdown(dt)
	local x, y = love.mouse.getPosition()
	
	-- Update buttons
	for button, action in pairs(self.mouse.hold) do
		if type(action) == "function" and love.mouse.isDown(button) then
			action(x, y, dt)
		end
	end
end

--[[
	Joystick Button/hat/Axis Held Down
	
	dt			- Delta time
]]--
function Input:joystickisdown(dt)
	for joystick in ipairs(self.joystick) do
		-- Update buttons
		for button, action in pairs(self.joystick[joystick].hold) do
			if type(action) == "function" and love.joystick.isDown(joystick, button) then
				action(dt)
			end
		end
		
		-- Update Hats
		for hat in ipairs(self.joystick[joystick].hold.hats) do
			for button, action in pairs(self.joystick[joystick].hold.hats[hat]) do
				if type(action) == "function" and love.joystick.getHat(joystick, hat) == button then
					action(dt)
				end
			end
		end
		
		-- Update Axes
		for axis, action in ipairs(self.joystick[joystick].hold.axes) do
			if type(action) == "function" then
				local v = love.joystick.getAxis(joystick, axis)
				action(v, dt)
			end
		end
	end
end

--[[
	Update All Devices
	
	dt			- Delta time
]]--
function Input:update(dt)
	self:keyboardisdown(dt)
	self:mouseisdown(dt)
	self:joystickisdown(dt)
end