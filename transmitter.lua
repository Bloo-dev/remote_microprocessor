local version = "v1.5"

local modem = component.proxy(component.list("modem")())
local radiation_sensor = component.proxy(component.list("nc_geiger_counter")())
local drive = component.proxy(component.list("drive")())
local RAD_SEN_PORT = 24487
local arg = ...

if arg == nil 
then
    cx, cz = drive.readByte(1), drive.readByte(2)
else
    cx, cz = load("return " .. arg)()
    drive.writeByte(1,cx)
    drive.writeByte(2,cz)
end

-- open ports
modem.open(RAD_SEN_PORT)

while true do
    _,_,from,port,dist,msg = computer.pullSignal("modem_message")
    if port == RAD_SEN_PORT then
        if msg == "radiation_sensor:query" then 
        local level = radiation_sensor.getChunkRadiationLevel()

        modem.send(
            from,
            port, 
            "radiation_sensor:response", cx, cz, level
        )
        end
        if msg == "radiation_sensor:shutdown" then
            computer.shutdown()
        end
    end
    
end