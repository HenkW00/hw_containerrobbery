ESX = exports["es_extended"]:getSharedObject()

local robberiesInProgress = {}
local searchedContainers = {}

local function debugPrint(message)
    if Config.Mode == 'debug' then
        print(message)
    end
end

local function sendLog(playerIdentifier, message)
    if Config.Webhook ~= "" and Config.Mode == 'debug' then
        local embeds = {
            {
                ["title"] = "🚨 Container Robbery Alert",
                ["description"] = message,
                ["type"] = "rich",
                ["color"] = 0xFF0000,
                ["fields"] = {
                    {
                        ["name"] = "Description:",
                        ["value"] = playerIdentifier,
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "HW Scripts | Container Robbery Logs",
                    ["icon_url"] = "https://youriconurlhere.png"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }

        PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "Robbery Log", embeds = embeds}), {['Content-Type'] = 'application/json'})
    end
end

RegisterServerEvent('hw_containerrobbery:searchContainer')
AddEventHandler('hw_containerrobbery:searchContainer', function(containerIndex)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if searchedContainers[containerIndex] then
        TriggerClientEvent('hw_containerrobbery:containerSearched', _source, false)
        xPlayer.showNotification("~r~You have already searched this container!")
        if Config.Mode == 'debug' then
        debugPrint(('^0[^1DEBUG^0] ^5Container ^3%s ^5already searched by ^3%s^0'):format(containerIndex, xPlayer.getIdentifier()))
        end
    else
        searchedContainers[containerIndex] = true
        xPlayer.showNotification("~y~Searching the container!")
        Citizen.Wait(5000)
        xPlayer.showNotification("~g~You received items from searching this container!")
        xPlayer.addInventoryItem('diamond', 10)
        xPlayer.addInventoryItem('black_money', 1500)
        xPlayer.addInventoryItem('goldbar', 1)
        TriggerClientEvent('hw_containerrobbery:containerSearched', _source, true)
        TriggerClientEvent('hw_containerrobbery:removeContainerBlip', _source, containerIndex)
        if Config.Mode == 'debug' then
        debugPrint(('^0[^1DEBUG^0] ^5Container ^3%s ^5searched by ^3%s^0'):format(containerIndex, xPlayer.getIdentifier()))
        end
        sendLog(('Container %s searched by %s, items awarded.'):format(containerIndex, xPlayer.getIdentifier()))
    end
end)

RegisterServerEvent('hw_containerrobbery:startRobbery')
AddEventHandler('hw_containerrobbery:startRobbery', function(coords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if robberiesInProgress[_source] then
        xPlayer.showNotification("~y~A robbery is ~r~already ~r~in progress.")
        return
    end

    robberiesInProgress[_source] = true
    if Config.Mode == 'debug' then
        print(('^0[^1DEBUG^0] ^5Robbery started by ^3%s ^5at ^3%s^0'):format(xPlayer.getIdentifier(), json.encode(coords)))
    end

    sendLog(('Robbery started by %s at %s'):format(xPlayer.getIdentifier(), json.encode(coords)))
    xPlayer.showNotification("~y~You ~g~unlocked ~y~some containers!")
    xPlayer.showNotification("~y~Go search them before time runs ~r~out!")

    Citizen.SetTimeout(Config.Time * 60000, function()
        if robberiesInProgress[_source] then
            xPlayer.showNotification("~g~You got a bonus payout!")
            xPlayer.addMoney(Config.Reward)
            robberiesInProgress[_source] = nil
        end
    end)

    sendLog(('Robbery notification sent to police by %s'):format(xPlayer.getIdentifier()))

    NotifyPolice(coords)
end)

function NotifyPolice(coords)
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.job and table.includes(Config.PoliceJobs, xPlayer.job.name) then
            Citizen.Wait(10000)
            TriggerClientEvent('esx:showNotification', playerId, '[10-90] ~r~Container robbery in progress!')
            TriggerClientEvent('hw_containerrobbery:createPoliceBlip', playerId, coords)
            if Config.Mode == 'debug' then
            debugPrint(('^0[^1DEBUG^0] ^5Police notified of robbery at ^3%s ^5by ^3%s^0'):format(json.encode(coords), xPlayer.getIdentifier()))
            end
        end
    end
end

function table.includes(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end