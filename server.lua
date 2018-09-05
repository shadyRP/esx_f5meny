ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('f5-menu:bunt', function(source, cb) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem('bunt').count
    if item>0 then
        cb(true) 
    else
        cb(false)
    end
end)