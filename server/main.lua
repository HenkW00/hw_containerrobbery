lib.locale()
ESX = exports["es_extended"]:getSharedObject()

---------------
-----DEBUG-----
---------------
local function debugPrint(message)
    if Config.Mode == 'debug' then
        print(message)
    end
end

---------------------
----NOTIFY HELPER----
---------------------
local function sendNotification(playerId, message, type, position)
    TriggerClientEvent('hw_containerrobbery:displayNotification', playerId, message, type, position)
end

---------------------
-----DISCORD LOG-----
---------------------
local function sendLog(playerIdentifier, message)
    if Config.Webhook ~= "" and Config.Mode == 'debug' then
        local embeds = {
            {
                ["title"] = Config.DiscordBotTitle,
                ["description"] = message,
                ["type"] = "rich",
                ["color"] = Config.DiscordBotColor,
                ["fields"] = {
                    {
                        ["name"] = Config.DiscordBotDescription,
                        ["value"] = playerIdentifier,
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = Config.DiscordBotFooter,
                    ["icon_url"] = "https://youriconurlhere.png"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }

        PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.DiscordBotName, embeds = embeds}), {['Content-Type'] = 'application/json'})
    end
end

---------------
-----UTILS-----
---------------
local robberiesInProgress = {}
local searchedContainers = {}

-----------------------
-----START ROBBERY-----
-----------------------
RegisterServerEvent('hw_containerrobbery:startRobbery')
AddEventHandler('hw_containerrobbery:startRobbery', function(coords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    local copsOnline = 0
    local players = ESX.GetPlayers()

    for i=1, #players do
        local xPlayer = ESX.GetPlayerFromId(players[i])
        if xPlayer.job and table.includes(Config.PoliceJobs, xPlayer.job.name) then
            copsOnline = copsOnline + 1
        end
    end

    if copsOnline < Config.CopsRequired then
        TriggerClientEvent('hw_containerrobbery:startRobberyResult', _source, false)
        return
    else
        TriggerClientEvent('hw_containerrobbery:startRobberyResult', _source, true)
    end

    if robberiesInProgress[_source] then
        sendNotification(_source, locale('robbery_in_progress'), 'error', 'top-center')
        return
    end

    robberiesInProgress[_source] = true
    if Config.Mode == 'debug' then
        print(('^0[^1DEBUG^0] ^5Robbery started by ^3%s ^5at ^3%s^0'):format(xPlayer.getIdentifier(), json.encode(coords)))
    end

    sendLog(('Robbery started by %s at %s'):format(xPlayer.getIdentifier(), json.encode(coords)))
    sendNotification(_source, locale('unlocked_container'), 'success', 'top-center')
    sendNotification(_source, locale('search_time'), 'info', 'top-center')

    Citizen.SetTimeout(Config.Time * 60000, function()
        if robberiesInProgress[_source] then
            sendNotification(_source, locale('bonus_payout'), 'success', 'top-center')
            xPlayer.addMoney(Config.Reward)
            robberiesInProgress[_source] = nil
        end
    end)

    sendLog(('Robbery notification sent to police by %s'):format(xPlayer.getIdentifier()))

    NotifyPolice(coords)
end)

--------------------------
-----SEARCH CONTAINER-----
--------------------------
RegisterServerEvent('hw_containerrobbery:searchContainer')
AddEventHandler('hw_containerrobbery:searchContainer', function(containerIndex)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if searchedContainers[containerIndex] then
        TriggerClientEvent('hw_containerrobbery:containerSearched', _source, false)
        sendNotification(_source, locale('already_searched'), 'info', 'top-center')
        if Config.Mode == 'debug' then
            debugPrint(('^0[^1DEBUG^0] ^5Container ^3%s ^5already searched by ^3%s^0'):format(containerIndex, xPlayer.getIdentifier()))
        end
    else
        searchedContainers[containerIndex] = true
        sendNotification(_source, locale('searching_goods'), 'info', 'top-center')
        Citizen.Wait(5000)
        
        for i = 1, Config.itemAmount do
            local totalChance = 0
            for _, reward in ipairs(Config.RewardItems) do
                totalChance = totalChance + reward.chance
            end

            local randomPoint = math.random() * totalChance
            local cumulativeChance = 0
            
            for _, reward in ipairs(Config.RewardItems) do
                cumulativeChance = cumulativeChance + reward.chance
                if randomPoint <= cumulativeChance then
                    xPlayer.addInventoryItem(reward.item, reward.quantity)
                    sendNotification(_source, locale('found_goods'), 'success', 'top-center')
                    break
                end
            end
        end

        TriggerClientEvent('hw_containerrobbery:containerSearched', _source, true)
        TriggerClientEvent('hw_containerrobbery:removeContainerBlip', _source, containerIndex)
        if Config.Mode == 'debug' then
            debugPrint(('^0[^1DEBUG^0] ^5Container ^3%s ^5searched by ^3%s^0'):format(containerIndex, xPlayer.getIdentifier()))
        end
        sendLog(('Container %s searched by %s, items awarded.'):format(containerIndex, xPlayer.getIdentifier()))
    end
end)

-----------------------
-----POLICE NOTIFY-----
-----------------------
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

---------------
-----TABLE-----
---------------
function table.includes(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end