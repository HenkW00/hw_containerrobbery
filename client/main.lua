lib.locale()
ESX = exports["es_extended"]:getSharedObject()

---------------
-----UTILS-----
---------------
local isRobbing = false
local startTime = 0
local robberyDuration = Config.Time * 60000
local containerBlips = {}

---------------------
----NOTIFY HELPER----
---------------------
RegisterNetEvent('hw_containerrobbery:displayNotification')
AddEventHandler('hw_containerrobbery:displayNotification', function(message, type, position)
    lib.notify({
        title = 'Container Robbery',
        description = message,
        duration = 3500,
        type = type or 'inform',
        position = position or 'top-center'
    })
end)

---------------
--Translation--
---------------
function _U(key, ...)
    local locale = Config.Locale or 'en'
    local text = Locales[locale] and Locales[locale][key] or 'Translation error: key %s not found'
    return string.format(text, ...)
end

--------------
-----TEXT-----
--------------
function DrawScreenText(text, x, y)
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

----------------------
-----POLICE CHECK-----
----------------------
RegisterNetEvent('hw_containerrobbery:startRobberyResult')
AddEventHandler('hw_containerrobbery:startRobberyResult', function(success)
    if not success then
        isRobbing = false
        for _, blip in pairs(containerBlips) do
            RemoveBlip(blip)
        end
        containerBlips = {}
        lib.notify({
            title = 'Container Robbery',
            description = locale('not_enough_police'),
            type = 'error',
            position = 'top-center',
        })
    else
        isRobbing = true
        startTime = GetGameTimer()
    end
end)

-----------------------
-----START ROBBERY-----
-----------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local dist = Vdist(coords.x, coords.y, coords.z, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z)

        if dist < 100 and not isRobbing then
            lib.hideTextUI()
            DrawMarker(1, Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
            if dist < 1.5 then
                lib.showTextUI(locale('start_robbery'))
                if IsControlJustReleased(0, 38) and not isRobbing then
                    lib.hideTextUI()
                    local currentWeapon = GetSelectedPedWeapon(playerPed)
                    local hasRequiredWeapon = false
                    for _, weapon in pairs(Config.Weapons) do
                        if GetHashKey(weapon) == currentWeapon then
                            hasRequiredWeapon = true
                            break
                        end
                    end
                    if hasRequiredWeapon then
                        isRobbing = true
                        startTime = GetGameTimer()

                        for _, blip in pairs(containerBlips) do
                            RemoveBlip(blip)
                        end
                        containerBlips = {}

                        for i, container in ipairs(Config.Containers) do
                            local blip = AddBlipForCoord(container.x, container.y, container.z)
                            SetBlipSprite(blip, 143)
                            SetBlipColour(blip, 1) 
                            SetBlipScale(blip, 0.5)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Container")
                            EndTextCommandSetBlipName(blip)
                            containerBlips[i] = blip
                        end

                        TriggerServerEvent('hw_containerrobbery:startRobbery', coords)
                    else
                        lib.notify({
                            title = 'Contianer Robbery',
                            description = locale('no_weapon'),
                            type = 'error'
                        })
                    end
                end
            end
        end

        if isRobbing then
            local currentTime = GetGameTimer()
            local elapsedTime = currentTime - startTime
            if elapsedTime < robberyDuration then
                local remainingTime = math.floor((robberyDuration - elapsedTime) / 1000)
                local mins = math.floor(remainingTime / 60)
                local secs = remainingTime % 60
                DrawScreenText(string.format("%02d:%02d", mins, secs), 0.5, 0.01)
            else
                isRobbing = false
                lib.notify({
                    title = 'Container Robbery',
                    description = locale('robbery_completed'),
                    type = 'success',
                    position = 'top-center',
                })
            end
        end
    end
end)

--------------------------
-----SEARCH CONTAINER-----
--------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isRobbing then
            local playerPos = GetEntityCoords(PlayerPedId())
            for i, container in ipairs(Config.Containers) do
                local dist = #(playerPos - vector3(container.x, container.y, container.z))
                if dist < 2.0 then
                    lib.showTextUI(locale('search_container'))
                    if IsControlJustReleased(0, 38) then
                        lib.progressCircle({
                            duration = 1000,
                            position = 'bottom',
                            label = 'Opening container...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                            },
                        })
                        TriggerServerEvent('hw_containerrobbery:searchContainer', i)
                    end
                end
            end
        end
    end
end)

---------------------
-----REMOVE BLIP-----
---------------------
RegisterNetEvent('hw_containerrobbery:removeContainerBlip')
AddEventHandler('hw_containerrobbery:removeContainerBlip', function(containerIndex)
    if containerBlips[containerIndex] then
        RemoveBlip(containerBlips[containerIndex])
        containerBlips[containerIndex] = nil
    end
end)

---------------------
-----POLICE BLIP-----
---------------------
RegisterNetEvent('hw_containerrobbery:createPoliceBlip')
AddEventHandler('hw_containerrobbery:createPoliceBlip', function(location)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, Config.PoliceBlipSprite)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, Config.PoliceBlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.PoliceBlipName)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, false)
    Citizen.SetTimeout(90000, function() 
        RemoveBlip(blip)
    end)
end)