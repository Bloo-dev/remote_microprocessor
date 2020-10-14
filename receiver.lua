-- v 1.2

local component = require("component")
local event = require("event")
local modem = component.modem
local gpu = component.gpu
local gridSize = 7 --amount of grid cells to display
local bcolor = 0x000000
gpu.setResolution(gridSize*2,gridSize)
local RAD_SEN_PORT = 24487
local timeout = {} -- keeps track of when the slave last responded
for i=1,gridSize do 
    timeout[i] = {}
    for j=1,gridSize do
        timeout[i][j]=0
    end
end

function colorF(value)
    return value / (1 + value)
end

function colorG(value)
    return colorF(math.log(value/3 + 1))
end

function getPercentage(value)
    return colorG(1000 * value) / colorG(8) * 3 / 4
end

function clamp(min, value, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function getColor(value)
    local percentage = math.floor(getPercentage(value) * 2 * 255 - 255 + .5)
    local red = clamp(0,255 + percentage,255)
    local green = clamp(0,255 - percentage,255)
    return red << 16 | green << 8
end

local function clearScreen()
    gpu.fill(1, 1, gridSize*2, gridSize, " ")
end

local function set(x,z,color)
    gpu.setBackground(color)
    gpu.set(2 * z + 1, x + 1, "  ")
    gpu.setBackground(bcolor)
end

gpu.setBackground(bcolor)
clearScreen()

-- open ports
modem.open(RAD_SEN_PORT)

event.listen("modem_message", function(ev, on, from, port, dist, msgId, cx, cz, level) 

    if RAD_SEN_PORT == port and msgId == "radiation_sensor:response" then
        set(cx,cz,getColor(level))
        timeout[cx+1][cz+1]=0
    end
end
)

event.listen("interrupted", function() os.exit() end)

while true do
    for i=1,gridSize do 
        for j=1,gridSize do
            timeout[i][j] = timeout[i][j]+1
            if timeout[i][j] > 3 then
                set(i-1,j-1,bcolor)
            end
        end
    end
    modem.broadcast(RAD_SEN_PORT, "radiation_sensor:query")
    os.sleep(2)
end