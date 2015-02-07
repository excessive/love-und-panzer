local Class = require "libs.hump.class"
local IRC = require "libs.libirc"

local chat = Class {}

function chat:init(settings)
	self.settings = settings
	self.channels = {}
	self.users = {}

	self:join_channel(self.settings.channel)
	self.active_channel = self.settings.channel
	self:resize()

	Signal.register("chat_focus",		function() self:focus(true) end)
	Signal.register("chat_unfocus",		function() self:focus(false) end)
	Signal.register("chat_send",			function() self:send() end)

	Signal.register("process_message",	function(...) self:process_message(...) end)
	Signal.register("process_join",		function(...) self:process_join(...) end)
	Signal.register("process_part",		function(...) self:process_part(...) end)
	Signal.register("process_quit",		function(...) self:process_quit(...) end)
	Signal.register("process_names",	function(...) self:process_names(...) end)
	--Signal.register("process_nick",	function(...) self:process_nick(...) end)

	self.settings = {
		-- settings n shit
		dummy = true,
		channel = settings.channel or "#love",
		nick = settings.nick or "love_und_panzer",
		server = settings.server or "irc.oftc.net",
		port = settings.port or 6667
	}
	self.irc = IRC(self.settings)
	self.irc:connect()
	self.buffer = ""

	console.defineCommand(
		"say",
		"say stuff in chat",
		function(...)
			local line = table.concat({...}, " ")
			Signal.emit("message", self.settings.channel, line)
			console.i("%s <%s> %s", self.settings.channel, self.settings.nick, line)
		end
	)
end

function chat:update(dt)
	self.irc:update(dt)
end

function chat:draw()

end

function chat:resize()

end

function chat:disconnect()
	self.irc:quit()
end

function chat:send(text)
	Signal.emit("message", self.settings.channel, text or self.buffer)
	if not text then
		self.buffer = ""
	end
end

function chat:process_join(nick, channel)
	console.d("%s joined", nick)
end

function chat:process_part(nick, channel)
	console.d("%s left", nick)
end

function chat:process_quit(nick, message, time)
	console.d("%s quit (%s)", nick, message)
end

function chat:process_names(channel, names)

end

function chat:process_message(nick, message, channel)
	console.i("%s <%s> %s", channel, nick, message)
end

function chat:focus(focus)

end

function chat:join_channel(channel)

end

function chat:part_channel(channel)

end

return chat
