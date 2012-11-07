Class = require "libs.hump.class"

Screen = Class {
	function (self, params)
		self.name				= params.name
		self.load				= params.load
		self.quit				= params.quit
		self.focus				= params.focus
		self.update				= params.update
		self.draw				= params.draw
		self.keypressed			= params.keypressed
		self.keyreleased		= params.keyreleased
		self.mousepressed		= params.mousepressed
		self.mousereleased		= params.mousereleased
		self.joystickpressed	= params.joystickpressed
		self.joystickreleased	= params.joystickreleased
		self.data				= params.data
		self.keystate = {}
		self.next = {
			screen	= false,
			data	= nil,
		}
		self.transition = false
	end
}
