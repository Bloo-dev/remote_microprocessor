local version = "v1.3"
local sourceFunc, data

local _error = error

function error(...)
    computer.beep(1000, 0.5)
    _error(...)
end

do
    local component_invoke = component.invoke

    local function boot_invoke(address, method, ...)
        local result = table.pack(pcall(component_invoke, address, method, ...))
        
        if not result[1] then
            return nil, result[2]
        else
            return table.unpack(result, 2, result.n)
        end
    end

    do -- get screen
        local screen = component.list("screen")()
        local gpu = component.list("gpu")()
        
        if gpu and screen then
            boot_invoke(gpu, "bind", screen)
        end
    end

    do
        -- get modem
        local modem = component.list("modem")()
        local port = 28820 -- remote boot

        if modem then
            if not select(1, boot_invoke(modem, "isWireless")) then
                error("The network card must be wireless")
            end
            if not select(1, boot_invoke(modem, "setStrength", 256)) then
              error("The network card must be wireless")
          end
            boot_invoke(modem, "open", port)
            boot_invoke(modem, "setWakeMessage","remote_microprocessor:remote_boot")
        else
            error("No network card found")
        end

        if boot_invoke(modem, "broadcast", port, "remote_microprocessor:firmware_request",version) then
            while true do
                local _, _, _, incport, distance, answer, source, extraData = computer.pullSignal("modem_message")
                
                if port == incport then
                    if answer == "remote_microprocessor:firmware_response" then
                        local err

                        sourceFunc, err = load(source)
                        data = extraData
                        if not sourceFunc then
                            error("Unable to compile recieved code: ", err)
                        end
                        
                        break
                    end
                end
            end
        else
            error("Unable to request source from server")
        end
    end
end

sourceFunc(data)