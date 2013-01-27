require "libs.panzer.server"

if not love then
	love = {
		event = {
			quit = function()
				_G.quit = true
			end
		}
	}
	hate = true
end

function love.load()
	server = Server()
	server:start(8088)
end

function love.update(dt)
	server:update(dt)
end

if hate then
	love.load()
	t2 = os.clock()
	
	while true do
		t1 = os.clock()
		server:update(t1-t2)
		t2 = t1
		
		if _G.quit then return end
	end
end
