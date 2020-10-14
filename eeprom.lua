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
            boot_invoke(modem, "setWakeMessage","remote_microprocessor:remote_wake")
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


--[[
    local a="v1.2"local b,c;local d=error;function error(...)computer.beep(1000,0.5)d(...)end;do local e=component.invoke;local function f(g,h,...)local i=table.pack(pcall(e,g,h,...))if not i[1]then return nil,i[2]else return table.unpack(i,2,i.n)end end;do local j=component.list("screen")()local k=component.list("gpu")()if k and j then f(k,"bind",j)end end;do local l=component.list("modem")()local m=28820;if l then if not select(1,f(l,"isWireless"))then error("The network card must be wireless")end;if not select(1,f(l,"setStrength",256))then error("The network card must be wireless")end;f(l,"open",m)else error("No network card found")end;if f(l,"broadcast",m,"remote_microprocessor:firmware_request",a)then while true do local n,n,n,o,p,q,r,s=computer.pullSignal("modem_message")if m==o then if q=="remote_microprocessor:firmware_response"then local t;b,t=load(r)c=s;if not b then error("Unable to compile recieved code: ",t)end;break end end end else error("Unable to request source from server")end end end;b(c)
]]