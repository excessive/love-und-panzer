local index = {}

function index:enter(from)
	Signal.register("pressed-a",				function(...) self:pressed_a(...) end)
	Signal.register("pressed-b",				function(...) self:pressed_b(...) end)
	Signal.register("pressed-x",				function(...) self:pressed_x(...) end)
	Signal.register("pressed-y",				function(...) self:pressed_y(...) end)
	Signal.register("pressed-back",				function(...) self:pressed_back(...) end)
	Signal.register("pressed-guide",			function(...) self:pressed_guide(...) end)
	Signal.register("pressed-start",			function(...) self:pressed_start(...) end)
	Signal.register("pressed-leftstick",		function(...) self:pressed_leftstick(...) end)
	Signal.register("pressed-rightstick",		function(...) self:pressed_rightstick(...) end)
	Signal.register("pressed-leftshoulder",		function(...) self:pressed_leftshoulder(...) end)
	Signal.register("pressed-rightshoulder",	function(...) self:pressed_rightshoulder(...) end)
	Signal.register("pressed-dpup",				function(...) self:pressed_dpup(...) end)
	Signal.register("pressed-dpdown",			function(...) self:pressed_dpdown(...) end)
	Signal.register("pressed-dpleft",			function(...) self:pressed_dpleft(...) end)
	Signal.register("pressed-dpright",			function(...) self:pressed_dpright(...) end)

	Signal.register("released-a",				function(...) self:released_a(...) end)
	Signal.register("released-b",				function(...) self:released_b(...) end)
	Signal.register("released-x",				function(...) self:released_x(...) end)
	Signal.register("released-y",				function(...) self:released_y(...) end)
	Signal.register("released-back",			function(...) self:released_back(...) end)
	Signal.register("released-guide",			function(...) self:released_guide(...) end)
	Signal.register("released-start",			function(...) self:released_start(...) end)
	Signal.register("released-leftstick",		function(...) self:released_leftstick(...) end)
	Signal.register("released-rightstick",		function(...) self:released_rightstick(...) end)
	Signal.register("released-leftshoulder",	function(...) self:released_leftshoulder(...) end)
	Signal.register("released-rightshoulder",	function(...) self:released_rightshoulder(...) end)
	Signal.register("released-dpup",			function(...) self:released_dpup(...) end)
	Signal.register("released-dpdown",			function(...) self:released_dpdown(...) end)
	Signal.register("released-dpleft",			function(...) self:released_dpleft(...) end)
	Signal.register("released-dpright",			function(...) self:released_dpright(...) end)

	Signal.register("moved-axisleft",			function(...) self:moved_axisleft(...) end)
	Signal.register("moved-axisright",			function(...) self:moved_axisright(...) end)
	Signal.register("moved-triggerleft",		function(...) self:moved_triggerleft(...) end)
	Signal.register("moved-triggerright",		function(...) self:moved_triggerright(...) end)
end

function index:leave()
	Signal.clear_pattern("pressed%-.*")
	Signal.clear_pattern("released%-.*")
	Signal.clear_pattern("moved%-.*")
end

function index:pressed_a(joystick)

end

function index:pressed_b(joystick)

end

function index:pressed_x(joystick)

end

function index:pressed_y(joystick)

end

function index:pressed_back(joystick)

end

function index:pressed_guide(joystick)

end

function index:pressed_start(joystick)

end

function index:pressed_leftstick(joystick)

end

function index:pressed_rightstick(joystick)

end

function index:pressed_leftshoulder(joystick)

end

function index:pressed_rightshoulder(joystick)

end

function index:pressed_dpup(joystick)

end

function index:pressed_dpdown(joystick)

end

function index:pressed_dpleft(joystick)

end

function index:pressed_dpright(joystick)

end

function index:released_a(joystick)

end

function index:released_b(joystick)

end

function index:released_x(joystick)

end

function index:released_y(joystick)

end

function index:released_back(joystick)

end

function index:released_guide(joystick)

end

function index:released_start(joystick)

end

function index:released_leftstick(joystick)

end

function index:released_rightstick(joystick)

end

function index:released_leftshoulder(joystick)

end

function index:released_rightshoulder(joystick)

end

function index:released_dpup(joystick)

end

function index:released_dpdown(joystick)

end

function index:released_dpleft(joystick)

end

function index:released_dpright(joystick)

end

function index:moved_axisleft(joystick, x, y)

end

function index:moved_axisright(joystick, x, y)

end

function index:moved_triggerleft(joystick, direction)

end

function index:moved_triggerright(joystick, direction)

end

return index
