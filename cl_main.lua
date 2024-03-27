local isInTrunk = false

CreateThread(function()
    while true do
        Wait(0)
        if isInTrunk then
            local vehicle = GetEntityAttachedTo(PlayerPedId())
            if DoesEntityExist(vehicle) or not IsPedDeadOrDying(PlayerPedId()) or not IsPedFatallyInjured(PlayerPedId()) then
                local coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot'))
                SetEntityCollision(PlayerPedId(), false, false)
                DrawText3D(coords, '[E] sortir du coffre.')

                if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                    SetEntityVisible(PlayerPedId(), false, false)
                else
                    if not IsEntityPlayingAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 3) then
                        while not HasAnimDictLoaded("timetable@floyd@cryingonbed@base") do
                            Wait(0)
                        end

                        TaskPlayAnim(PlayerPedId(), "timetable@floyd@cryingonbed@base", "base", 8.0, 8.0, -1, 1, 0, false, false, false)

                        SetEntityVisible(PlayerPedId(), true, false)
                    end
                end
                if IsControlJustReleased(0, 38) and isInTrunk then
                    SetCarBootOpen(vehicle)
                    SetEntityCollision(PlayerPedId(), true, true)
                    Wait(750)
                    isInTrunk = false
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    ClearPedTasks(PlayerPedId())
                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))
                    Wait(250)
                    SetVehicleDoorShut(vehicle, 5)

                    Entity(vehicle).state.someoneInTrunk = false
                    local netVeh = VehToNet(vehicle)
                    TriggerServerEvent("trunk:server:toggleTrunk", netVeh, false)
                end
            else
                SetEntityCollision(PlayerPedId(), true, true)
                DetachEntity(PlayerPedId(), true, true)
                SetEntityVisible(PlayerPedId(), true, false)
                ClearPedTasks(PlayerPedId())
                SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))


            end
        end
    end
end)   

CreateThread(function()

    while not NetworkIsSessionStarted() do
        Wait(500)
    end

    while true do
        Wait(0)
        local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 70)
        local locked = GetVehicleDoorLockStatus(vehicle)

        if DoesEntityExist(vehicle) and GetEntitySpeed(vehicle) < 1.0 then
            local trunk = GetEntityBoneIndexByName(vehicle, "boot")
            if trunk ~= -1 then
                local trunkPos = GetWorldPositionOfEntityBone(vehicle, trunk)
                local playerPos = GetEntityCoords(PlayerPedId())
                local dist = #(playerPos - trunkPos)

                if dist < 1.5 then
                    if not isInTrunk then
                        DrawText3D(trunkPos, "[~g~E~s~] pour entrer dans le coffre.")
                        if IsControlJustPressed(0, 38) then
                            if not locked == 1 then
                                TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "The trunk is locked.")
                            else

                                if Entity(vehicle).state.someoneInTrunk then
                                    TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "Someone is already in the trunk.")
                                    return
                                end

                                Entity(vehicle).state.someoneInTrunk = true
                                local netVeh = VehToNet(vehicle)
                                TriggerServerEvent("trunk:server:toggleTrunk", netVeh, true)

                                SetCarBootOpen(vehicle)
                                
                                Wait(250)
                                AttachEntityToEntity(PlayerPedId(), vehicle, -1, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                                RequestAnimDict("timetable@floyd@cryingonbed@base")

                                while not HasAnimDictLoaded("timetable@floyd@cryingonbed@base") do
                                    Wait(0)
                                end

                                TaskPlayAnim(PlayerPedId(), "timetable@floyd@cryingonbed@base", "base", 8.0, 8.0, -1, 1, 0, false, false, false)

                                isInTrunk = true
                                Wait(1500)

                                SetVehicleDoorShut(vehicle, 5, false)
                                

                            end
                        end
                    end
                end
            end
        end

    end
end)

RegisterCommand("toggleNearestTrunk", function(source, args)
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 70)
    local locked = GetVehicleDoorLockStatus(vehicle)

    if DoesEntityExist(vehicle) and GetEntitySpeed(vehicle) < 1.0 then
        local toggle = args[1]
        if toggle == "open" then
            SetCarBootOpen(vehicle)
        elseif toggle == "close" then
            SetVehicleDoorShut(vehicle, 5, false)
        end
    end
end, false)

function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
  
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
  
    AddTextComponentString(text)
    DrawText(_x, _y)
end


--[[ DO NOT REMOVE ]]
print("^1======================================================================^0")
print("^1[^0Author^1] ^0:^1 ^57empest15")
print("^1======================================================================^0")
--[[ DO NOT REMOVE ]]