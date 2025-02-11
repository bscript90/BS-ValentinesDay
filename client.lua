local curItem = {}
local curName = false
local selectPlayer = false

RegisterNetEvent('BS-ValentinesDay:client:openWheel',function()
    SetNuiFocus(true,true)
    SendNUIMessage({
        action = "openWheel",
        tasks = Config.Tasks
    })
end)

RegisterNUICallback('close',function(data)
    SetNuiFocus(false,false)
end)

RegisterNUICallback('showTask',function(data)
    local task = data.task
    local players = GetActivePlayers()
    local dist = 999
    local playerFound = false
    local orjCoords = GetEntityCoords(PlayerPedId())
    for i = 1, #players do
        local id = players[i]
        local ped = GetPlayerPed(id)
        if ped ~= PlayerPedId() then
            local coords = GetEntityCoords(ped)
            local curDist = #(coords - orjCoords)
            if curDist < dist and curDist < 3.0 then
                playerFound = GetPlayerServerId(id)
                dist = curDist
            end
        end
    end
    if playerFound then
        TriggerServerEvent('BS-ValentinesDay:server:showTask',playerFound,task)
    end
end)


RegisterNetEvent('BS-ValentinesDay:client:showTask',function(task)
    SendNUIMessage({
        action = "showTask",
        task = task
    })
end)

RegisterNetEvent('BS-ValentinesDay:client:selectPlayer',function(item,name)
    selectPlayer = true
    SetNuiFocus(true,true)    
    curName = name
    curItem = item
    if Config.SelectPlayer then
        Citizen.CreateThread(function()
            SendNUIMessage({
                action = "openPlayerPositions",
            })
            while selectPlayer do
                local players = GetActivePlayers()
                local playersPositions = {}
                local orjCoords = GetEntityCoords(PlayerPedId())
                for i = 1, #players do
                    local id = players[i]
                    local ped = GetPlayerPed(id)
                    if ped ~= PlayerPedId() then
                        local coords = GetEntityCoords(ped)
                        if #(coords - orjCoords) < 15.0 then
                            local onscreen, x, y = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z) 
                            if onscreen then
                                x = x * 100
                                y = y * 100
                                playersPositions[#playersPositions+1] = {
                                    value = GetPlayerServerId(id),
                                    x = x,
                                    y = y
                                }
                            end
                        end
                    end
                end
             
                SendNUIMessage({
                    action = "setPlayersPositions",
                    players = playersPositions,
                })
                Wait(1000)
            end
            SendNUIMessage({
                action = "setPlayersPositions",
                players = {},
            })
        end)
    else
        TriggerServerEvent('BS-ValentinesDay:server:getPlayerName',curItem,curName,GetPlayerServerId(PlayerId()))
    end
end)

RegisterNUICallback('selectPlayer',function(data)
    selectPlayer = false
    local target = tonumber(data.target)
    TriggerServerEvent('BS-ValentinesDay:server:getPlayerName',curItem,curName,target)
end)

RegisterNUICallback('save',function(data)
    local message = data.message 
    local from = data.from
    local to = data.to
    SetNuiFocus(false,false)
    TriggerServerEvent('BS-ValentinesDay:server:save',curItem,message,from,to)
end)

RegisterNetEvent('BS-ValentinesDay:client:openEnvelope',function(item,from,to,disabled)
    SetNuiFocus(true,true)
    SendNUIMessage({
        action = "openEnvelope",
        from = from,
        to = to,
        disabled = disabled,
        message = item.metadata.valentines and item.metadata.valentines.message or ""
    })
end)

if Config.GiveAnimation then
    local function giveAnimation()
        -- p_cs_flowers01x
        ClearPedTasks(PlayerPedId())
        local modelHash = GetHashKey("p_cs_flowers01x")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(100)
        end
        local coords = GetEntityCoords(PlayerPedId())
        local rose = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, true)
        FreezeEntityPosition(rose, true)
        local boneIndex = GetEntityBoneIndexByName(PlayerPedId(), "SKEL_L_HAND") 
        AttachEntityToEntity(rose, PlayerPedId(), boneIndex, 0.08, 0.09, 0.0, 238.0, 0.0, 0, false, false, true, false, 0, true, false, false)
        RequestAnimDict("script_story@nts3@ig@ig19_arrow_give")
        while not HasAnimDictLoaded("script_story@nts3@ig@ig19_arrow_give") do
            Citizen.Wait(100)
        end
        local animDuration = GetAnimDuration("script_story@nts3@ig@ig19_arrow_give", "rhand_take_arrow_handover_charles")
        TaskPlayAnim(PlayerPedId(), "script_story@nts3@ig@ig19_arrow_give", "rhand_take_arrow_handover_charles", 1.0, -1.0, -1, 1, 0.0, false, false, false, '', false)
        RemoveAnimDict("script_story@nts3@ig@ig19_arrow_give")
        Wait(animDuration*500)
        ClearPedTasks(PlayerPedId())
        SetModelAsNoLongerNeeded(rose)
        DeleteEntity(rose)
    end
    local function takeAnimation()
        -- "script_common@other@unapproved", "take_obj"
        Wait(500)
        RequestAnimDict("script_common@other@unapproved")
        while not HasAnimDictLoaded("script_common@other@unapproved") do
            Citizen.Wait(100)
        end
        local animDuration = GetAnimDuration("script_common@other@unapproved", "take_obj")
        TaskPlayAnim(PlayerPedId(), "script_common@other@unapproved", "take_obj", 1.0, -1.0, -1, 1, 0.0, false, false, false, '', false)

        SetEntityAnimSpeed(PlayerPedId(), "script_common@other@unapproved", "take_obj", 0.1)
        RemoveAnimDict("script_common@other@unapproved")
        Wait(animDuration*700)
        ClearPedTasks(PlayerPedId())
    end
    
    if Config.Framework == "VORP" then
        RegisterNetEvent('vorpInventory:removeItem',function(itemname)
            if itemname == "loveenvelope" then
                giveAnimation()
            end
        end)
        RegisterNetEvent('vorpInventory:receiveItem',function(itemname)
            if itemname == "loveenvelope" then
                takeAnimation()
            end
        end)
    elseif Config.Framework == "RSG" then
        RegisterNetEvent('rsg-inventory:client:ItemBox',function(iteminfo,status)
            if status == "remove" then
                if iteminfo.name == "loveenvelope" then
                    giveAnimation()
                end
            elseif status == "add" then
                if iteminfo.name == "loveenvelope" then
                    takeAnimation()
                end
            end
        end)
    end
end

