local modemSide = "top"
local rsSide = "left"
local CHANNEL = 8008

if not peripheral.isPresent(modemSide) or peripheral.getType(modemSide) ~= "modem" then
    print("Error: No modem found on " .. modemSide)
    return
end

local modem = peripheral.wrap(modemSide)
modem.open(CHANNEL)

term.clear()
term.setCursorPos(1, 1)
print("=== Home Signal Receiver (Ext 4-6) ===")
print("Listening on channel " .. CHANNEL .. "...")

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if side == modemSide and channel == CHANNEL then
        local sides = {}
        if message == "trigger_home" then
            sides = {"left", "back", "right"}
        elseif message == "trigger_home_4" then
            sides = {"left"}
        elseif message == "trigger_home_5" then
            sides = {"back"}
        elseif message == "trigger_home_6" then
            sides = {"right"}
        end

        if #sides > 0 then
            print("Signal received! Activating redstone to the " .. table.concat(sides, ", "))
            for _, s in ipairs(sides) do rs.setOutput(s, true) end
            sleep(0.1)
            for _, s in ipairs(sides) do rs.setOutput(s, false) end
        end
    end
end
