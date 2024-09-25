local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('client:playUnboxSound')
AddEventHandler('client:playUnboxSound', function()
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'unbox', 0.5)
end)

RegisterNetEvent('client:unboxingMessage')
AddEventHandler('client:unboxingMessage', function(lighterId)
    local lighterName = QBCore.Shared.Items["collectible_lighter_"..lighterId].label
    QBCore.Functions.Notify("You unboxed a " .. lighterName .. "!", "success")
end)

RegisterNetEvent('client:openLighterBox')
AddEventHandler('client:openLighterBox', function()
    TriggerServerEvent('player:useLighterBox')
end)

RegisterCommand('openuplighterbox', function()
    TriggerEvent('client:openLighterBox')
end, false)

RegisterNetEvent('client:showProgressBar')
AddEventHandler('client:showProgressBar', function()
    local playerPed = PlayerPedId()  -- Get the player's ped
    local animDict = "anim@heists@box_carry@"  -- The animation dictionary for holding a box
    local animName = "idle"  -- The animation name

    -- Load the animation
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)  -- Wait until the animation dictionary is loaded
    end

    -- Create the box prop and attach it to the player's hands
    local pos = GetEntityCoords(playerPed)  -- Get the current position of the player
    local boxProp = CreateObject(GetHashKey("prop_cardbordbox_02a"), pos.x, pos.y, pos.z, true, true, true)

    -- Attach the box to the player's hands with the corrected offsets and rotation
    AttachEntityToEntity(
        boxProp,                                  -- The box prop entity
        playerPed,                                -- The player entity
        GetPedBoneIndex(playerPed, 24816),        -- Spine bone
        -0.07,                                    -- X offset (adjust this if needed)
        0.55,                                     -- Y offset
        0.1,                                      -- Z offset (closer to hands)
        90.0,                                     -- Pitch (rotation around X-axis)
        0.0,                                      -- Roll (rotation around Y-axis)
        90.0,                                     -- Yaw (rotation around Z-axis)
        true,                                     -- Is attached
        true,                                     -- Is collision enabled
        false,                                    -- Physics disabled
        true,                                     -- Allow collision only with the player
        1,                                        -- Rotation fixed
        true                                      -- Allow soft pinning
    )

    -- Play the animation (holding the box)
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 50, 0, false, false, false)

    -- Start progress bar with movement enabled
    QBCore.Functions.Progressbar("unbox_lighter", "Unboxing...", 3000, false, true, {
        disableMovement = false,  -- Allow movement while unboxing
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        print("Unboxing complete!")  -- Debug
        ClearPedTasks(playerPed)  -- Stop the animation
        DeleteObject(boxProp)  -- Delete the box prop after the progress bar completes
        TriggerServerEvent('server:progressBarCompleted')  -- Notify server of completion
    end, function() -- Cancel
        ClearPedTasks(playerPed)  -- Stop the animation if canceled
        DeleteObject(boxProp)  -- Delete the box prop if canceled
        TriggerClientEvent('QBCore:Notify', source, "Unboxing canceled.")
    end)
end)


local collectedLighters = {}

-- Trigger loading of lighters when NUI is opened
RegisterCommand('openLighterNUI', function()
    TriggerServerEvent('lighter:loadLighters')
    SetNuiFocus(true, true)
end)



-- Update a single lighter (on collect or transfer)
RegisterNetEvent('lighter:updateLighter', function(lighterId, collected)
    if collected then
        table.insert(collectedLighters, lighterId)
    else
        for i, id in pairs(collectedLighters) do
            if id == lighterId then
                table.remove(collectedLighters, i)
                break
            end
        end
    end
    SendNUIMessage({
        action = 'updateLighter',
        lighterId = lighterId,
        collected = collected
    })
end)

-- Handle prize claim
RegisterNetEvent('lighter:prizeClaimed', function()
    SendNUIMessage({ action = 'prizeClaimed' })
end)

RegisterNetEvent('lighter:prizeFailed', function()
    SendNUIMessage({ action = 'prizeFailed' })
end)

-- Handle collecting a lighter
RegisterNUICallback('collectLighter', function(data)
    TriggerServerEvent('lighter:collectLighter', data.lighterId)
end)

-- Handle transferring a lighter
RegisterNUICallback('transferLighter', function(data)
    TriggerServerEvent('lighter:transferLighter', data.lighterId, data.targetPlayerId)
end)

-- Handle claiming prize
RegisterNUICallback('claimPrize', function()
    TriggerServerEvent('lighter:claimPrize')
end)

-- Listen for the '/lighters' command to open the NUI
RegisterCommand("lighters", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openLighters"
    })
end, false)



-- Listen for opening the NUI
RegisterNetEvent('lighter:openNUI', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openLighters"
    })
end)

-- Listen for ESC key to close the NUI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 322) then -- 322: ESC key
            print("ESC key pressed, closing NUI...") -- Debugging log
            SetNuiFocus(false, false) -- Disable focus from the NUI
            SendNUIMessage({
                action = "closeLighters" -- Notify NUI to hide itself
            })
        end
    end
end)










RegisterCommand("openLighters", function()
    -- This will trigger the NUI to open
    SetNuiFocus(true, true)
    SendNUIMessage({action = "openLighters"})
end)


-- Ensure you handle the NUI message for loading lighters
RegisterNUICallback("loadLighters", function(data, cb)
    SendNUIMessage({action = "loadLighters", lighters = data.lighters})
    cb("ok")
end)

-- Optionally handle any other commands or interactions




-- Closing the NUI when a close message is received from JavaScript
RegisterNUICallback('close', function(data, cb)
    print("Closing NUI...") -- Debugging log
    SetNuiFocus(false, false) -- Disable focus from the NUI
    SendNUIMessage({
        action = "closeLighters" -- Notify NUI to hide itself
    })
    cb('ok') -- Send response back to the NUI
end)

-- Listening for ESC key to close the NUI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 322) then -- 322: ESC key
            print("ESC key pressed, closing NUI...") -- Debugging log
            SetNuiFocus(false, false) -- Disable focus from the NUI
            SendNUIMessage({
                action = "closeLighters" -- Notify NUI to hide itself
            })
        end
    end
end)

-- Your other client-side logic for opening and managing the NUI goes here



-- Register a net event to receive collected lighters from the server
RegisterNetEvent('lighter:sendLighters', function(lighters)
    collectedLighters = lighters -- Update the global variable or declare it properly if not done before

    -- Update collected count
    updateCollectedCount()

    -- Update UI to reflect collected lighters
    for _, lighterId in ipairs(lighters) do
        -- Ensure the correct lighter icon gets marked as collected
        local lighterIcon = document.querySelector(`.lighter-icon[data-number="${lighterId}"]`)
        if lighterIcon then
            lighterIcon.classList.add('collected')
        end
    end
end)

