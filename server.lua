--server
local QBCore = exports['qb-core']:GetCoreObject()

-- Register the usable item for the lighter box
QBCore.Functions.CreateUseableItem("lighter_box", function(source)
    TriggerClientEvent('client:openLighterBox', source)
end)


local lighters = {
    [1] = {rarity = 5},    -- Rare
    [2] = {rarity = 50},   -- Common
    [3] = {rarity = 10},   -- Uncommon
    [4] = {rarity = 30},   -- Common
    [5] = {rarity = 15},   -- Uncommon
    [6] = {rarity = 50},   -- Common
    [7] = {rarity = 5},    -- Rare
    [8] = {rarity = 40},   -- Common
    [9] = {rarity = 20},   -- Uncommon
    [10] = {rarity = 50},  -- Common
    [11] = {rarity = 10},  -- Uncommon
    [12] = {rarity = 25},  -- Common
    [13] = {rarity = 5},   -- Rare
    [14] = {rarity = 35},  -- Common
    [15] = {rarity = 15},  -- Uncommon
    [16] = {rarity = 50},  -- Common
    [17] = {rarity = 7},   -- Rare
    [18] = {rarity = 50},  -- Common
    [19] = {rarity = 25},  -- Common
    [20] = {rarity = 10},  -- Uncommon
    [21] = {rarity = 50},  -- Common
    [22] = {rarity = 3},   -- Very Rare
    [23] = {rarity = 50},  -- Common
    [24] = {rarity = 30},  -- Common
    [25] = {rarity = 12},  -- Uncommon
    [26] = {rarity = 50},  -- Common
    [27] = {rarity = 8},   -- Rare
    [28] = {rarity = 50},  -- Common
    [29] = {rarity = 18},  -- Uncommon
    [30] = {rarity = 50},  -- Common
    [31] = {rarity = 10},  -- Uncommon
    [32] = {rarity = 35},  -- Common
    [33] = {rarity = 4},   -- Rare
    [34] = {rarity = 50},  -- Common
    [35] = {rarity = 20},  -- Uncommon
    [36] = {rarity = 50},  -- Common
    [37] = {rarity = 5},   -- Rare
    [38] = {rarity = 50},  -- Common
    [39] = {rarity = 28},  -- Common
    [40] = {rarity = 50},  -- Common
    [41] = {rarity = 15},  -- Uncommon
    [42] = {rarity = 6},   -- Rare
    [43] = {rarity = 50},  -- Common
    [44] = {rarity = 12},  -- Uncommon
    [45] = {rarity = 50},  -- Common
    [46] = {rarity = 3},   -- Very Rare
    [47] = {rarity = 50},  -- Common
    [48] = {rarity = 22},  -- Uncommon
    [49] = {rarity = 50},  -- Common
    [50] = {rarity = 8},   -- Rare
    [51] = {rarity = 50},  -- Common
    [52] = {rarity = 27},  -- Common
    [53] = {rarity = 10},  -- Uncommon
    [54] = {rarity = 50},  -- Common
    [55] = {rarity = 5},   -- Rare
    [56] = {rarity = 50},  -- Common
    [57] = {rarity = 15},  -- Uncommon
    [58] = {rarity = 50},  -- Common
    [59] = {rarity = 10},  -- Uncommon
    [60] = {rarity = 50},  -- Common
    [61] = {rarity = 7},   -- Rare
    [62] = {rarity = 50},  -- Common
    [63] = {rarity = 20},  -- Uncommon
    [64] = {rarity = 50},  -- Common
    [65] = {rarity = 3},   -- Very Rare
    [66] = {rarity = 50},  -- Common
    [67] = {rarity = 18},  -- Uncommon
    [68] = {rarity = 50},  -- Common
    [69] = {rarity = 5},   -- Rare
    [70] = {rarity = 50},  -- Common
    [71] = {rarity = 28},  -- Common
    [72] = {rarity = 50},  -- Common
    [73] = {rarity = 12},  -- Uncommon
    [74] = {rarity = 50},  -- Common
    [75] = {rarity = 4},   -- Rare
}


















-- Fetches a random lighter based on rarity
-- Function to get a random lighter based on rarity
function getRandomLighter()
    local totalRarity = 0
    for _, lighter in pairs(lighters) do
        totalRarity = totalRarity + lighter.rarity
    end

    local randomChance = math.random(1, totalRarity)
    local cumulativeRarity = 0

    for id, lighter in pairs(lighters) do
        cumulativeRarity = cumulativeRarity + lighter.rarity
        if randomChance <= cumulativeRarity then
            return id
        end
    end
end

-- Function to check for completion of the lighter collection
function checkForCompletion(playerId)
    exports.oxmysql:scalar('SELECT COUNT(lighter_id) FROM player_lighters WHERE player_id = ?', { playerId }, function(lighterCount)
        if lighterCount >= 75 then
            -- Award $50,000 for completing the collection
            TriggerClientEvent('player:receiveAward', playerId, 50000)
            TriggerClientEvent('QBCore:Notify', playerId, "Congratulations! You have collected all 75 lighters and won $50,000!")
        end
    end)
end

-- Event handler when a player uses the lighter box
-- Event handler when a player uses the lighter box
RegisterNetEvent('player:useLighterBox')
AddEventHandler('player:useLighterBox', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerId = Player.PlayerData.citizenid

    -- Define the name of the item being added
    local lighterId = getRandomLighter()  -- Get random lighter ID
    local lighterItemName = "collectible_lighter_" .. lighterId  -- Build the item name

    -- Check inventory space for the specific item type
    local canAddItem = Player.Functions.GetItemByName(lighterItemName)

    -- If the item exists, check the count
    if canAddItem then
        if canAddItem.amount >= 5 then  -- Assuming max stack size is 5 for collectible lighters
            TriggerClientEvent('QBCore:Notify', src, "Your inventory is full for this item! You can't unbox the lighter.", "error")
            return
        end
    else
        -- Check if they have any space at all if item doesn't exist
        if Player.Functions.GetItemByName("lighter_box") == nil or Player.Functions.GetItemByName("lighter_box").amount < 1 then
            TriggerClientEvent('QBCore:Notify', src, "Your inventory is full! You can't unbox the lighter.", "error")
            return
        end
    end

    -- Remove the lighter box from the player's inventory
    if not Player.Functions.RemoveItem("lighter_box", 1) then
        print("Failed to remove lighter box from player " .. src .. ".")
        return
    end

    print("Player " .. src .. " has successfully used the lighter box and removed it from their inventory.")

    -- Show progress bar
    TriggerClientEvent('client:showProgressBar', src)

    -- Wait for the progress bar to complete
    Citizen.Wait(3000)  -- Adjust the time to match your progress bar duration

    -- Now that the box has been removed, let's handle the lighter logic
    exports.oxmysql:scalar('SELECT 1 FROM player_lighters WHERE player_id = ? AND lighter_id = ?', { playerId, lighterId }, function(hasLighter)
        if not hasLighter then
            -- Add lighter to player's collection
            exports.oxmysql:execute('INSERT INTO player_lighters (player_id, lighter_id) VALUES (?, ?)', { playerId, lighterId })
            Player.Functions.AddItem(lighterItemName, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[lighterItemName], 'add')
            TriggerClientEvent('QBCore:Notify', src, "You opened the box and received a lighter!")
        else
            -- Give the lighter even though it's a duplicate
            Player.Functions.AddItem(lighterItemName, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[lighterItemName], 'add')
            TriggerClientEvent('QBCore:Notify', src, "You received a duplicate lighter!")
        end

        -- Play unboxing sound/animation
        TriggerClientEvent('client:playUnboxSound', src)
        TriggerClientEvent('client:unboxingMessage', src, lighterId)

        -- Check for completion
        checkForCompletion(playerId)
    end)
end)



-- Event handler for trading lighters between players
RegisterNetEvent('server:tradeLighter')
AddEventHandler('server:tradeLighter', function(receiverId, lighterId)
    local giverPlayer = QBCore.Functions.GetPlayer(source)
    local receiverPlayer = QBCore.Functions.GetPlayer(receiverId)

    if giverPlayer and receiverPlayer then
        -- Remove lighter from giver
        exports.oxmysql:execute('DELETE FROM player_lighters WHERE player_id = ? AND lighter_id = ?', { giverPlayer.PlayerData.citizenid, lighterId })
        -- Add lighter to receiver
        exports.oxmysql:execute('INSERT INTO player_lighters (player_id, lighter_id) VALUES (?, ?)', { receiverPlayer.PlayerData.citizenid, lighterId })

        -- Update inventories
        giverPlayer.Functions.RemoveItem("collectible_lighter_" .. lighterId, 1)
        receiverPlayer.Functions.AddItem("collectible_lighter_" .. lighterId, 1)

        TriggerClientEvent('QBCore:Notify', giverPlayer.PlayerData.source, "You have successfully traded your lighter.")
        TriggerClientEvent('QBCore:Notify', receiverPlayer.PlayerData.source, "You have received a lighter from another player.")
        TriggerClientEvent('inventory:client:ItemBox', receiverPlayer.PlayerData.source, QBCore.Shared.Items["collectible_lighter_" .. lighterId], 'add')
    end
end)




local oxmysql = exports.oxmysql

-- Helper function to get player identifier
local function GetPlayerIdentifier(playerId)
    return GetPlayerIdentifiers(playerId)[1] -- Adjust this according to your identifier setup
end

-- Load player's lighters from the database
RegisterNetEvent('lighter:loadLighters', function()
    local src = source
    local playerId = GetPlayerIdentifier(src)

    oxmysql:query('SELECT lighter_id FROM player_lighters WHERE player_id = ?', {playerId}, function(lighters)
        local collectedLighters = {}
        if lighters then
            for _, lighter in pairs(lighters) do
                table.insert(collectedLighters, lighter.lighter_id)
            end
            TriggerClientEvent('lighter:sendLighters', src, collectedLighters)
        end
    end)
end)

-- Save collected lighter
RegisterNetEvent('lighter:collectLighter', function(lighterId)
    local src = source
    local playerId = GetPlayerIdentifier(src)

    oxmysql:insert('INSERT INTO player_lighters (player_id, lighter_id) VALUES (?, ?)', {playerId, lighterId}, function()
        TriggerClientEvent('lighter:updateLighter', src, lighterId, true)
    end)
end)

-- Transfer a lighter to another player
RegisterNetEvent('lighter:transferLighter', function(lighterId, targetPlayerId)
    local src = source
    local playerId = GetPlayerIdentifier(src)

    -- Remove lighter from the current player
    oxmysql:execute('DELETE FROM player_lighters WHERE player_id = ? AND lighter_id = ?', {playerId, lighterId}, function(rowsAffected)
        if rowsAffected > 0 then
            -- Give it to the target player
            oxmysql:insert('INSERT INTO player_lighters (player_id, lighter_id) VALUES (?, ?)', {targetPlayerId, lighterId}, function()
                -- Notify both players
                TriggerClientEvent('lighter:updateLighter', src, lighterId, false)
                TriggerClientEvent('lighter:updateLighter', GetPlayerFromIdentifier(targetPlayerId), lighterId, true)
            end)
        end
    end)
end)

-- Claim the prize (after all 75 lighters collected)
RegisterNetEvent('lighter:claimPrize', function()
    local src = source
    local playerId = GetPlayerIdentifier(src)

    oxmysql:query('SELECT COUNT(*) as lighter_count FROM player_lighters WHERE player_id = ?', {playerId}, function(result)
        if result[1].lighter_count == 75 then
            -- Prize handling (not included, just a placeholder)
            TriggerClientEvent('lighter:prizeClaimed', src)
        else
            TriggerClientEvent('lighter:prizeFailed', src)
        end
    end)
end)

-- Optional: To get player identifiers from a target player ID
function GetPlayerFromIdentifier(identifier)
    for _, playerId in ipairs(GetPlayers()) do
        if GetPlayerIdentifier(playerId) == identifier then
            return playerId
        end
    end
    return nil
end




local function getPlayerLighters(playerId)
    local lighters = {}
    local result = MySQL.Sync.fetchAll("SELECT lighter_id FROM player_lighters WHERE player_id = @playerId", {
        ['@playerId'] = playerId
    })

    for _, row in ipairs(result) do
        table.insert(lighters, row.lighter_id)
    end

    return lighters
end

-- Trigger loading of lighters when NUI is opened
RegisterCommand('openLighterNUI', function(source)
    local playerId = GetPlayerIdentifiers(source)[1] -- Assuming the first identifier is the player's ID
    local lighters = getPlayerLighters(playerId)
    TriggerClientEvent('lighter:sendLighters', source, lighters) -- Send lighters to client
    SetNuiFocus(true, true)
end)
