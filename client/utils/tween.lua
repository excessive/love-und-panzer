tween = {
	-- delay
	sleep = function(change, time, elapsed)
		if elapsed >= 1 then
			return 1
		end

		return 0
	end,
	linear = function(change, time, elapsed)
		return change * elapsed
	end,
	-- quadratic stuff
	ease_in = function(change, time, elapsed)
		return change * elapsed * time
	end,
	ease_out = function(change, time, elapsed)
		return change * ((1-elapsed)+1) * time
	end,
	smooth = function(change, time, elapsed)
		if elapsed/2 < 0.5 then
			return change * math.pow(elapsed, 2)
		end

		return change * (math.pow(elapsed-2, 2) + 2)
	end,
	-- cubic stuff
	ease_in_cubic = function(change, time, elapsed)
		return change * math.pow(elapsed, 3)
	end,
	ease_out_cubic = function(change, time, elapsed)
		return change * (math.pow(elapsed-1, 3)+1)
	end,
	smooth_cubic = function(change, time, elapsed)
		if elapsed/2 < 0.5 then
			return change * math.pow(elapsed, 3)
		end

		return change * (math.pow(elapsed-1, 3) + 1)
	end
}

--[[
	Interpolate Tween
	
	tween		- Tween function
	old			- Old position
	new			- New position
	duration	- Length of tween (in seconds)
	time		- Time since tween start.
]]--
function interpolate(tween, old, new, duration, time)
	-- don't divide by zero!
	if duration == 0 or tween == 0 then
		return new
	end
	
	return old - tween(old - new, time, time / duration)
end
