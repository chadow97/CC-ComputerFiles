local logger = require("UTIL.logger")

local modem = peripheral.find("modem") or error("No modem attached", 0)
local channel = 2
logger.init(term.current())
modem.transmit(channel, channel, "Ping!")
print("sent message on channel " .. channel)

modem.open(channel)
-- wait for replies
local waiting = true
while waiting do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    print("Message received:" .. message)
    waiting = false
end