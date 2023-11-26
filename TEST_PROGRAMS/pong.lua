local modem = peripheral.find("modem") or error("No modem attached", 0)
local channel = 2
modem.open(channel)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    print(("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
        side, channel, replyChannel, distance, tostring(message)
    ))
    modem.transmit(replyChannel, channel, "Pong!")
end
