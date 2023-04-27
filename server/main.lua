local QBCore = exports['qb-core']:GetCoreObject()
GlobalState.TreasureChest = Config.TreasureChest

Citizen.CreateThread(function()
    for _, v in pairs(Config.TreasureChest) do
        v.taken = false
    end
end)

function treasureCooldown(loc)
    CreateThread(function()
        Wait(180 * 1000)
        Config.TreasureChest[loc].taken = false
        GlobalState.TreasureChest = Config.TreasureChest
        Wait(1000)
        TriggerClientEvent('treasure:respawnCane', -1, loc)
    end)
end

RegisterNetEvent("treasure:pickupCane")
AddEventHandler("treasure:pickupCane", function(loc)
    if not Config.TreasureChest[loc].taken then
        Config.TreasureChest[loc].taken = true
        GlobalState.TreasureChest = Config.TreasureChest
        TriggerClientEvent("treasure:removeCane", -1, loc)
        treasureCooldown(loc)
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem("unopenedchest", 1)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["unopenedchest"], "add", 1)
    end
end)


QBCore.Functions.CreateUseableItem('unopenedchest', function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local randomchance = math.random(1,100)
	if Player.Functions.RemoveItem("unopenedchest", 1) then 
		if randomchance <= 2 then 
			Player.Functions.AddItem("goldbar", 1)
			TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['goldbar'], "add", 8)
		elseif randomchance >= 3 and randomchance <= 5 then
				Player.Functions.AddItem("goldbar", 5)
				TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['goldbar'], "add", 5)
		elseif randomchance >= 6 and randomchance <= 15 then
				Player.Functions.AddItem("oldgoldcoin", 20)
				TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['oldgoldcoin'], "add", 20)
		elseif randomchance >= 16 and randomchance <= 30 then
				Player.Functions.AddItem("oldsilvercoin", 15)
				TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['oldsilvercoin'], "add", 15)
		elseif randomchance >= 31 and randomchance <= 55 then
				Player.Functions.AddItem("oldgoldcoin", 3)
				TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['oldgoldcoin'], "add", 3)			
		elseif randomchance >= 56 and randomchance <= 70 then
				Player.Functions.AddItem("oldsilvercoin", 3)
				TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['oldsilvercoin'], "add", 3)
		else
				Player.Functions.AddItem("waterloggedbook", 1)
				TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['waterloggedbook'], "add", 1)
			
		end
	end
	
end)


RegisterNetEvent("md-treasure:server:getchestloc")
AddEventHandler("md-treasure:server:getchestloc", function()
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	
	if Player.Functions.RemoveItem(Config.itemone, Config.amountone) then
		TriggerClientEvent("md-treasure:client:getlocationone", src)
	elseif Player.Functions.RemoveItem(Config.itemtwo, Config.amounttwo) then
		TriggerClientEvent("md-treasure:client:getlocationtwo", src)
    elseif Player.Functions.RemoveItem(Config.itemthree, Config.amountthree) then
		TriggerClientEvent("md-treasure:client:getlocationthree", src)
	elseif Player.Functions.RemoveItem(Config.itemfour, Config.amountfour) then
		TriggerClientEvent("md-treasure:client:getlocationfour", src)
    elseif Player.Functions.RemoveItem(Config.itemfive, Config.amountfive) then
		TriggerClientEvent("md-treasure:client:getlocationfive", src)	
	elseif Player.Functions.RemoveItem(Config.itemsix, Config.amountsix) then
		TriggerClientEvent("md-treasure:client:getlocationsix", src)
    elseif Player.Functions.RemoveItem(Config.itemseven, Config.amountseven) then
		TriggerClientEvent("md-treasure:client:getlocationseven", src)
	elseif Player.Functions.RemoveItem(Config.itemeight, Config.amounteight) then
		TriggerClientEvent("md-treasure:client:getlocationeight", src)
    elseif Player.Functions.RemoveItem(Config.itemnine, Config.amountnine) then
		TriggerClientEvent("md-treasure:client:getlocationnine", src)
	elseif Player.Functions.RemoveItem(Config.itemten, Config.amountten) then
		TriggerClientEvent("md-treasure:client:getlocationten", src)
	elseif Player.Functions.RemoveItem(Config.itemeleven, Config.amounteleven) then
		TriggerClientEvent("md-treasure:client:getlocationeleven", src)
    elseif Player.Functions.RemoveItem(Config.itemtwelve, Config.amounttwelve) then
		TriggerClientEvent("md-treasure:client:getlocationtwelve", src)
	elseif Player.Functions.RemoveItem(Config.itemthirteen, Config.amountthirteen) then
		TriggerClientEvent("md-treasure:client:getlocationethirteen", src)
    elseif Player.Functions.RemoveItem(Config.itemfourteen, Config.amountfourteen) then
		TriggerClientEvent("md-treasure:client:getlocationfourteen", src)	
	else
	TriggerClientEvent('QBCore:Notify', src, Config.langone, "error")
	end
end)


------------------------------------------------------ 

RegisterNetEvent('qb-diving:server:RemoveGear', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["diving_gear"], "remove")
end)

RegisterNetEvent('qb-diving:server:GiveBackGear', function(oxygen)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if oxygen > 0 then
        Player.Functions.AddItem("diving_gear", 1, false, {['oxygen']=oxygen})
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["diving_gear"], "add")
    end
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-diving:server:GetDivingConfig', function(_, cb)
    cb(Config.CoralLocations, currentDivingArea)
end)

QBCore.Functions.CreateCallback('qb-diving:server:RemoveGear', function(src, cb)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        cb(false)
        return
    end
    local divingGear = Player.Functions.GetItemByName("diving_gear")
    if divingGear.amount > 0 then
        local oxygen = 200
        if divingGear.info.oxygen ~= nil then
            oxygen = divingGear.info.oxygen
        end
        Player.Functions.RemoveItem("diving_gear", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["diving_gear"], "remove")
        cb(true, oxygen)
        return
    end
    cb(false, 0)
end)

-- Items

QBCore.Functions.CreateUseableItem("diving_gear", function(source)
    TriggerClientEvent("qb-diving:client:UseGear", source, true)
end)


