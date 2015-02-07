Signal = Signal or require "libs.hump.signal"
local Class = require "libs.hump.class"
local socket = require "socket"

local IRC = Class {}
local utils = require "utils"

function IRC:init(settings)
	self.settings	= settings
	if self.settings.dummy then
		return
	end

	self.joined		= false
	self.names		= {}
	self.commands	= {}
	
	-- TOPIC in channel
	self.commands["332"] = function(receive)
		local nick, channel, topic = receive:match(":[%w%d%p]+ TOPIC ([%w%d%p]+) (#[%w%d%p]+) :(.+)")
		Signal.emit("process_topic", nick, channel, topic)
	end
	
	-- TOPICWHOTIME (Ignore)
	self.commands["333"] = function(receive) end
	
	-- NAMES list in channel
	self.commands["353"] = function(receive)
		local channel, names = receive:match(":[%w%d%p]+ 353 [%w%d%p]+ . (#[%w%d%p]+) :(.+)")
		print(channel, names, receive)
		
		-- accumulate names until we get a 366
		self.names[channel] = self.names[channel] or ""
		self.names[channel] = self.names[channel] .. " " .. names
		
		if self.settings.verbose then
			Signal.emit("message", self.settings.channel, names)
		end
	end
	
	-- End of NAMES list in channel
	self.commands["366"] = function(receive)
		local channel = receive:match(":[%w%d%p]+ 366 [%w%d%p]+ (#[%w%d%p]+) :.+")
		local names = self.names[channel]

		if names then
			Signal.emit("process_names", channel, names)

			-- clear out the accumulated names
			self.names[channel] = nil
		end
	end
	
	-- End of MOTD, safe to JOIN
	self.commands["376"] = function(receive)
		self.socket:send("JOIN " .. self.settings.channel .. "\r\n\r\n")
		self.joined = true
		return true
	end

	self.commands["433"] = function(receive)
		self.socket:send("NICK " .. self.settings.nick .. "_\r\n\r\n")
	end

	-- Client joins channel
	self.commands["JOIN"] = function(receive)
		local nick, channel = receive:match(":([%w%d%p]+)![%w%d%p]+ JOIN :(#[%w%d%p]+)")
		
		if nick and channel then
			Signal.emit("process_join", nick, channel)
		end
	end
	
	-- Ignore
	self.commands["MODE"] = function(receive) end
	
	-- Client changes nickname
	self.commands["NICK"] = function(receive)
		local old_nick, new_nick = receive:match(":([%w%d%p]+)![%w%d%p]+ NICK :(.+)")
		Signal.emit("process_nick", old_nick, new_nick)	
	end
	
	-- Client leaves channel
	self.commands["PART"] = function(receive)
		local nick, channel = receive:match(":([%w%d%p]+)![%w%d%p]+ PART (#[%w%d%p]+)")
		
		if nick and channel then
			Signal.emit("process_part", nick, channel)
		end
	end
	
	-- Message
	self.commands["PRIVMSG"] = function(receive)
		local line = nil
		local channel = channel

		-- :Xkeeper!xkeeper@netadmin.badnik.net PRIVMSG #fart :gas
		local nick, channel, line = receive:match(":([%w%d%p]+)![%w%d%p]+ PRIVMSG ([%w%d%p]+) :(.+)")

		print(":".. nick .. " PRIVMSG " .. channel .. " :" .. line)

		if line then
			if channel:find("#") then
				Signal.emit("process_message", nick, line, channel)
			else
				Signal.emit("process_query", nick, line, channel)
			end
		end
		
		if self.settings.verbose then
			Signal.emit('message', self.settings.channel, receive)
		end
	end
	
	-- Client quits
	self.commands["QUIT"] = function(receive)
		local nick, message = receive:match(":([%w%d%p]+)![%w%d%p]+ QUIT :(.+)")
		Signal.emit("process_quit", nick, message, time)
	end
	
	-- Unhandled responses
	self.commands["UNHANDLED"] = function(receive, command)
		local message = "unhandled response: " .. command .. ": " .. receive
		print(self.settings.channel, message)
		
		if self.settings.verbose then
			Signal.emit("message", self.settings.channel, message)
		end
	end
end

-- XXX: stupid
function IRC:quit()
	if self.settings.dummy then
		return
	end

	self.socket:send("QUIT :Goodbye, cruel world!\r\n\r\n")
	self.socket:close()
end

function IRC:join_channel(channel)
	self.socket:send("JOIN " .. channel .. "\r\n\r\n")
end

function IRC:change_nick(nick)
	self.socket:send("NICK " .. nick .. "\r\n\r\n")
end

function IRC:part_channel(channel)
	self.socket:send("PART " .. channel .. "\r\n\r\n")
end

function IRC:request_names(channel)
	self.socket:send("NAMES " .. channel .. "\r\n\r\n")
end

function IRC:request_topic(channel)
	self.socket:send("TOPIC " .. channel .. "\r\n\r\n")
end

function IRC:handle_receive(receive, time)
	-- Respond to PING
	if receive:find("PING :([%wx]+)") == 1 then
		self.socket:send("PONG :" .. receive:sub(receive:find("PING :") + 6) .. "\r\n\r\n")
		print("PONG")
		return true
	end
	
	local command = receive:match(":[%w%d%p]+ ([%u%d]+) .+")
	
	if self.commands[command] then
		return self.commands[command](receive)
	else
		return self.commands["UNHANDLED"](receive, command)
	end

	print(self.settings.channel, "response: " .. command .. ": " .. receive)

	return true
end

function IRC:connect()
	if self.settings.dummy then
		return
	end

	local function connect_socket(params)
		print("Connecting to " .. params.server .. ":" .. params.port .. "/" .. params.channel .. " as " .. params.nick)

		local s = socket.tcp()
		s:connect(socket.dns.toip(params.server), params.port)

		-- USER username hostname servername :realname
		s:send("USER " .. string.format("%s %s %s :%s\r\n\r\n", params.nick, params.nick, params.nick, params.fullname or "inhumanity"))
		s:send("NICK " .. params.nick .. "\r\n\r\n")

		return s
	end

	self.socket = connect_socket(self.settings)

	self.joined = false

	if self.socket == nil then
		return self:connect()
	end

	Signal.register('message', function(channel, content, response_code)
		if response_code then
			content = response_code .. ": " .. content
		end
		self.socket:send("PRIVMSG " .. channel .. " :" .. content ..  "\r\n\r\n")
		print("PRIVMSG " .. channel .. " :" .. content)
	end)

	self.start = socket.gettime()

	return true
end

function IRC:update(dt)
	if self.settings.dummy then
		return
	end

	local ready = socket.select({self.socket}, nil, 0.01)
	local time = socket.gettime() - self.start

	-- process incoming, reply as needed
	if ready[self.socket] then
		local receive = self.socket:receive('*l')

		if self.settings.verbose then print(receive) end
		
		if receive == nil then
			print("Timed out.. attempting to reconnect!")
			return self:connect()
		end

		self:handle_receive(receive, time)
	end

	return true
end

function IRC:run()
	if self.settings.dummy then
		return
	end

	self:connect()
	while true do
		if not self:update() then
			return
		end
	end
end

return IRC
