local version = "v1.3"

local event = require("event")
local component = require("component")
local shell = require("shell")
local modem = component.modem

modem.open(28820)

local args, ops = shell.parse(...)

local file = args[1]
local parameters = ops.param


while true do
    ev, on, from, port, distance, msg = event.pull()
    if ev == "interrupted" then
        break
    end
    if port == 28820 and msg == "remote_microprocessor:firmware_request" then
        print("Received firmware request. Please enter coords:")
        local data = io.open(file):read("*a")
        if parameters then
            print("Sending response to", from, "on port", port, "...")
            modem.send(from, port, "remote_microprocessor:firmware_response", data, io.read())
        else
            print("Sending response to", from, "on port", port, "...")
            modem.send(from, port, "remote_microprocessor:firmware_response", data)
        end
    end
end