local version = "v1.4"

local event = require("event")
local component = require("component")
local shell = require("shell")
local modem = component.modem

print("Now listening for firmware requests on port 28820...")
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
        print("Received firmware request.")
        local raw,err = io.open(file)
        if raw then
            data = raw:read("*a")
            if parameters then
                print("Preparing response for", from, "on port", port, "...")
                print("Please enter the coords of this slave:")
                modem.send(from, port, "remote_microprocessor:firmware_response", data, io.read())
            else
                print("Sending response to", from, "on port", port, "...")
                modem.send(from, port, "remote_microprocessor:firmware_response", data)
            end
            raw:close()
        else
            print("Failed to access file",file,". Skipping request.")
        end
    end
end