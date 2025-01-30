if Config.Framework == "VORP" then
    if IsDuplicityVersion() then
        -- serverside
        VorpCore = exports.vorp_core:GetCore()

        function BSRegisterUsableItem(itemname,callBack)
            exports.vorp_inventory:registerUsableItem(itemname, function(data)
                local array = {
                    source = data.source,
                    item = data.item
                }
                exports.vorp_inventory:closeInventory(data.source)
                callBack(array)
            end)
        end


        function BSAddItem(src,itemname,itemcount,metadata)
            exports.vorp_inventory:addItem(src, itemname, itemcount, metadata)
        end

        function BSRemoveItem(src,itemname,itemcount,metadata)
            exports.vorp_inventory:subItem(src, itemname, itemcount, metadata)
        end

        function BSGetName(src)
            local User = VorpCore.getUser(src)
            local Character = User.getUsedCharacter
            return Character.firstname.. ' '..Character.lastname
        end
    else
        -- clientside
        VorpCore = exports.vorp_core:GetCore()
    end
elseif Config.Framework == "RSG" then
    if IsDuplicityVersion() then
        -- serverside
        RSGCore = exports['rsg-core']:GetCoreObject()

        function BSRegisterUsableItem(itemname,callBack)
            RSGCore.Functions.CreateUseableItem(itemname, function(source,item)
                local array = {
                    source = source,
                    item = item
                }
                array.item.item = item.name
                array.item.metadata = item.info
                TriggerClientEvent("rsg-inventory:client:closeinv", source)
                callBack(array)
            end)
        end

        function BSAddItem(src,itemname,itemcount,metadata)
            local Player = RSGCore.Functions.GetPlayer(src)
            Player.Functions.AddItem(itemname, itemcount,false,metadata)
        end
        
        function BSRemoveItem(src,itemname,itemcount,metadata)
            local Player = RSGCore.Functions.GetPlayer(src)
            local foundslot = false
            for slot,item in pairs(Player.PlayerData.items) do
                if item.name:lower() == itemname:lower() then
                    Wait(100)
                    if metadata then
                        if item.info.description == metadata.description then
                            foundslot = slot
                            break
                        end
                    else
                        foundslot = slot
                        break
                    end
                end
            end
            if not foundslot then return false end
            Wait(100)
            Player.Functions.RemoveItem(itemname, itemcount,foundslot)
        end

        function BSGetName(src)
            local Player = RSGCore.Functions.GetPlayer(src)
            return Player.PlayerData.charinfo.firstname.. ' '..Player.PlayerData.charinfo.lastname
        end
        
    else
        -- clientside
        RSGCore = exports['rsg-core']:GetCoreObject()
    end
end
