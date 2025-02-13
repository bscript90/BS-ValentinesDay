RegisterNetEvent('BS-ValentinesDay:server:showTask',function(id,task)
    if id == -1 then
        DropPlayer(source,"Cheater detected!")
        return
    end
    TriggerClientEvent('BS-ValentinesDay:client:showTask',id,task)
end)

BSRegisterUsableItem('loveenvelope',function(data)
    local src = data.source
    local item = data.item
    local name = BSGetName(src)
    if item.metadata.valentines then
        TriggerClientEvent('BS-ValentinesDay:client:openEnvelope',src,item,item.metadata.valentines.from,item.metadata.valentines.to,true)
    else
        TriggerClientEvent('BS-ValentinesDay:client:selectPlayer',src,item,name)
    end
end)
BSRegisterUsableItem('lovewheelspin',function(data)
    local src = data.source
    TriggerClientEvent('BS-ValentinesDay:client:openWheel',src)
end)

RegisterNetEvent('BS-ValentinesDay:server:getPlayerName',function(item,from,toid)
    local to = "A mysterious person"
    if Config.SelectPlayer then
        to = BSGetName(toid)
    end
    TriggerClientEvent('BS-ValentinesDay:client:openEnvelope',source,item,from,to,false)
end)

RegisterNetEvent('BS-ValentinesDay:server:save',function(item,message,from,to)
    local src = source
    if item and item.metadata then
        BSRemoveItem(src,"loveenvelope",1,item.metadata)
    
        item.metadata.valentines = {
            message = message,
            from = from,
            to = to
        }
       
        item.metadata.description = "An elaborate love letter from "..from.." to "..to.." <input type='hidden' name='' value='"..math.random(11111,999999)..    "'>"
        BSAddItem(src,"loveenvelope",1,item.metadata)
    end
end)