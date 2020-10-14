local component = require("component")
local modem = component.modem

print("Sent remote boot ping!")
modem.broadcast(28820,"remote_microprocessor:remote_boot")