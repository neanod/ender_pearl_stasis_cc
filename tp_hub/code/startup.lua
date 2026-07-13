local modemSide = nil
local modems = {peripheral.find("modem")}
for _, m in ipairs(modems) do
    if m.isWireless() then
        modemSide = peripheral.getName(m)
        break
    end
end

if not modemSide then
    print("Error: No wireless modem found.")
    return
end

local modem = peripheral.wrap(modemSide)
local LISTEN_CHANNEL = 8000
modem.open(LISTEN_CHANNEL)

term.clear()
term.setCursorPos(1, 1)
print("=== Teleport Router Server ===")
print("Listening on channel " .. LISTEN_CHANNEL .. "...")



local ROUTES = {
    h = { channel = 8008, prefix = "trigger_home" },
    e = { channel = 8009, prefix = "trigger_embassy" },
    d1 = { channel = 8011, prefix = "trigger_d1" },
    g = { channel = 8012, prefix = "trigger_g" },
    f = { channel = 8013, prefix = "trigger_f" },
    o = { channel = 8014, prefix = "trigger_o" }
}

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if side == modemSide and channel == LISTEN_CHANNEL then
        local success, packet = pcall(textutils.unserializeJSON, message)
        if success and type(packet) == "table" and packet.type == "tp_request" then
            local route = ROUTES[packet.dest]
            if route then
                local outMsg = route.prefix
                if packet.id and packet.id ~= "" then
                    outMsg = outMsg .. "_" .. packet.id
                end

                print("Routing '" .. packet.dest .. "' (id: " .. (packet.id or "N/A") .. ") to channel " .. route.channel)
                modem.transmit(route.channel, route.channel, outMsg)
            else
                print("Unknown destination requested: " .. tostring(packet.dest))
            end
        end
    end
end
