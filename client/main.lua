local QBCore = exports['qb-core']:GetCoreObject()
---------------------- target for diving 
local TreasureChest = {}

function LoadModel(hash)
    hash = GetHashKey(hash)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(3000)
    end
end 

RegisterNetEvent('treasure:respawnCane', function(loc)
    local v = GlobalState.TreasureChest[loc]
    local hash = GetHashKey(v.model)
    --if not HasModelLoaded(hash) then LoadModel(hash) end
    if not TreasureChest[loc] then
        TreasureChest[loc] = CreateObject(hash, v.location, false, true, true)
        SetEntityAsMissionEntity(TreasureChest[loc], true, true)
        FreezeEntityPosition(TreasureChest[loc], true)
        SetEntityHeading(TreasureChest[loc], v.heading)
        exports['qb-target']:AddTargetEntity(TreasureChest[loc], {
            options = { {
                    icon = "fas fa-hand",
                    label = "pick Cocaine",
                    action = function()
                        QBCore.Functions.Progressbar("pick_cane", "Grabbing Unopened Chest", 2000, false, true, {
                            disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true, },
                            { animDict = 'amb@prop_human_bum_bin@idle_a', anim = 'idle_a', flags = 47, },
                            {}, {}, function()
                            TriggerServerEvent("treasure:pickupCane", loc)
                            ClearPedTasks(PlayerPedId())
                        end, function() -- Cancel
                            ClearPedTasks(PlayerPedId())
                        end)
                    end
                }
            },
            distance = 3.0
        })
    end
end)



RegisterNetEvent('treasure:removeCane', function(loc)
    if DoesEntityExist(TreasureChest[loc]) then DeleteEntity(TreasureChest[loc]) end
    TreasureChest[loc] = nil
end)


RegisterNetEvent("treasure:init", function()
    for k, v in pairs (GlobalState.TreasureChest) do
        local hash = GetHashKey(v.model)
        if not HasModelLoaded(hash) then LoadModel(hash) end
        if not v.taken then
            TreasureChest[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z, false, true, true)
            SetEntityAsMissionEntity(TreasureChest[k], true, true)
            FreezeEntityPosition(TreasureChest[k], true)
            SetEntityHeading(TreasureChest[k], v.heading)
            exports['qb-target']:AddTargetEntity(TreasureChest[k], {
                options = { {
                        icon = "fas fa-hand",
                        label = "Open Chest",
                        action = function()
                            QBCore.Functions.Progressbar("pick_cane", "Opening Chest", 2000, false, true, {
                                disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true, },
                                { animDict = 'amb@prop_human_bum_bin@idle_a', anim = 'idle_a', flags = 47, },
                                {}, {}, function()
                                TriggerServerEvent("treasure:pickupCane", k)
                                ClearPedTasks(PlayerPedId())
                            end, function() -- Cancel
                                ClearPedTasks(PlayerPedId())
                            end)
                        end
                    }
                },
                distance = 3.0
            })
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        LoadModel('xm_prop_x17_chest_closed')
        TriggerEvent('treasure:init')
    end
 end)
 
 RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
     Wait(3000)
     LoadModel('xm_prop_x17_chest_closed')
     TriggerEvent('treasure:init')	
 end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetModelAsNoLongerNeeded(GetHashKey('xm_prop_x17_chest_closed'))
        for k, v in pairs(TreasureChest) do
            if DoesEntityExist(v) then
                DeleteEntity(v) SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)
--------------- fucky way to fix something because its late and idc to fix it properly
RegisterNetEvent("md-treasure:client:giveitem")
AddEventHandler("md-treasure:client:giveitem", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	    TriggerServerEvent("md-treasure:server:giveitem")
        ClearPedTasks(PlayerPedId())
	end)
end)

-- Functions
local currentGear = {
    mask = 0,
    tank = 0,
    oxygen = 0,
    enabled = false
}

local function deleteGear()
	if currentGear.mask ~= 0 then
        DetachEntity(currentGear.mask, 0, 1)
        DeleteEntity(currentGear.mask)
		currentGear.mask = 0
    end

	if currentGear.tank ~= 0 then
        DetachEntity(currentGear.tank, 0, 1)
        DeleteEntity(currentGear.tank)
		currentGear.tank = 0
	end

    currentGear.oxygen = 0
end

local function gearAnim()
    RequestAnimDict("clothingshirt")
    while not HasAnimDictLoaded("clothingshirt") do
        Wait(0)
    end
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end



RegisterNetEvent('qb-diving:client:UseGear', function(bool)
    local ped = PlayerPedId()
    if bool then
        if not IsPedSwimming(ped) and not IsPedInAnyVehicle(ped) then
            gearAnim()
            QBCore.Functions.TriggerCallback('qb-diving:server:RemoveGear', function(result, oxygen)
                if result then
                    QBCore.Functions.Progressbar("equip_gear","putting on suit", 5000, false, true, {}, {}, {}, {}, function() -- Done
                        deleteGear()
                        local maskModel = `p_d_scuba_mask_s`
                        local tankModel = `p_s_scuba_tank_s`
                        RequestModel(tankModel)
                        while not HasModelLoaded(tankModel) do
                            Wait(0)
                        end
                        currentGear.tank = CreateObject(tankModel, 1.0, 1.0, 1.0, 1, 1, 0)
                        local bone1 = GetPedBoneIndex(ped, 24818)
                        AttachEntityToEntity(currentGear.tank, ped, bone1, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)
                        currentGear.oxygen = oxygen
                        RequestModel(maskModel)
                        while not HasModelLoaded(maskModel) do
                            Wait(0)
                        end
                        currentGear.mask = CreateObject(maskModel, 1.0, 1.0, 1.0, 1, 1, 0)
                        local bone2 = GetPedBoneIndex(ped, 12844)
                        AttachEntityToEntity(currentGear.mask, ped, bone2, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)
                        SetEnableScuba(ped, true)
                        SetPedMaxTimeUnderwater(ped, 2000.00)
                        currentGear.enabled = true
                        ClearPedTasks(ped)
                        Citizen.CreateThread(function()
                            while currentGear.enabled do
                                if IsPedSwimmingUnderWater(PlayerPedId()) then
                                    currentGear.oxygen = currentGear.oxygen-1
                                    if currentGear.oxygen == 60 then
                                        QBCore.Functions.Notify("one minute left", 'error')
                                    elseif currentGear.oxygen == 0 then
                                        QBCore.Functions.Notify("its done", 'error')
                                        SetPedMaxTimeUnderwater(ped, 50.00)
                                    elseif currentGear.oxygen == -40 then
                                        deleteGear()
                                        SetEnableScuba(ped, false)
                                        SetPedMaxTimeUnderwater(ped, 1.00)
                                        currentGear.enabled = false
                                    end
                                end
                                Wait(1000)
                            end
                        end)
                    end)
                end
            end)
        else
            QBCore.Functions.Notify("not standing up", 'error')
        end
    else
        if currentGear.enabled then
            gearAnim()
            QBCore.Functions.Progressbar("remove_gear", "taking off suit", 5000, false, true, {}, {}, {}, {}, function() -- Done
                SetEnableScuba(ped, false)
                SetPedMaxTimeUnderwater(ped, 50.00)
                currentGear.enabled = false
                TriggerServerEvent('qb-diving:server:GiveBackGear', currentGear.oxygen)
                ClearPedTasks(ped)
                deleteGear()
                QBCore.Functions.Notify("took suit off")
            end)
        else
            QBCore.Functions.Notify("No Suit", 'error')
        end
    end
end)

-- Threads

CreateThread(function()
  local model = `ig_lestercrest`
  RequestModel(model)
  while not HasModelLoaded(model) do
    Wait(0)
  end
  local entity = CreatePed(0, model, Config.missionped, 180, true, false)
  FreezeEntityPosition(entity, true)
  SetEntityInvincible(entity, true)
  exports['qb-target']:AddTargetEntity(entity, { 
    options = { 
      { 
       
        type = "server", 
        event = "md-treasure:server:getchestloc", 
        icon = 'fas fa-example', 
        label = 'Get Info', 
      }
    },
    distance = 2.5, 
  })
end)


-------------------------- get locations

RegisterNetEvent("md-treasure:client:getlocationone")
AddEventHandler("md-treasure:client:getlocationone", function() 
local CurrentLocation =  vector3(1685.11, -2846.77, -12.45)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasureone = CircleZone:Create(CurrentLocation, 5,{ name = "chestone", debugPoly = false })
	treasureone:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langtwo,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message = Config.langtwo,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationtwo")
AddEventHandler("md-treasure:client:getlocationtwo", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(2776.53, -1794.77, -21.67)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasuretwo = CircleZone:Create(CurrentLocation, 5,{ name = "chesttwo", debugPoly = false })
	treasuretwo:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langthree,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message = Config.langthree,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationthree")
AddEventHandler("md-treasure:client:getlocationthree", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(2939.85, -750.71, -13.47)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasurethree = CircleZone:Create(CurrentLocation, 5,{ name = "chestthree", debugPoly = false })
	treasurethree:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message = Config.langfour,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langfour,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationfour")
AddEventHandler("md-treasure:client:getlocationfour", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(2939.85, -689.71, -13.47)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasurefour = CircleZone:Create(CurrentLocation, 5,{ name = "chestfour", debugPoly = false })
	treasurefour:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langfive,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langfive,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationfive")
AddEventHandler("md-treasure:client:getlocationfive", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(3497.63, 2310.95, -37.5)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasurefive = CircleZone:Create(CurrentLocation, 5,{ name = "chestfive", debugPoly = false })
	treasurefive:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message = Config.langsix,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langsix,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationsix")
AddEventHandler("md-treasure:client:getlocationsix", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(4033.17, 3660.24, -13.7)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasuresix = CircleZone:Create(CurrentLocation, 5,{ name = "chestsix", debugPoly = false })
	treasuresix:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langseven,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langseven,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationseven")
AddEventHandler("md-treasure:client:getlocationseven", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(3437.65, 5759.08, -16.82)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	treasureseven = CircleZone:Create(CurrentLocation, 5,{ name = "treasureseven", debugPoly = false })
	treasureseven:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langeight,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langeight,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationeight")
AddEventHandler("md-treasure:client:getlocationeight", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(1754.77, 6798.1, -14.31)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chesteight = CircleZone:Create(CurrentLocation, 5,{ name = "chesteight", debugPoly = false })
	chesteight:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langnine,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langnine,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationnine")
AddEventHandler("md-treasure:client:getlocationnine", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(-599.92, 6499.51, -7.04)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chestnine = CircleZone:Create(CurrentLocation, 5,{ name = "chestnine", debugPoly = false })
	chestnine:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langten,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langten,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationten")
AddEventHandler("md-treasure:client:getlocationten", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(-2346.45, 4569.88, -15.85)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chestten = CircleZone:Create(CurrentLocation, 5,{ name = "chestten", debugPoly = false })
	chestten:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langeleven,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langeleven,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationeleven")
AddEventHandler("md-treasure:client:getlocationeleven", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(-2931.21, 2517.17, -19.38)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chesteleven = CircleZone:Create(CurrentLocation, 5,{ name = "chesteleven", debugPoly = false })
	chesteleven:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langtwelve,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langtwelve,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationtwelve")
AddEventHandler("md-treasure:client:getlocationtwelve", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(-3246.47, 567.22, -13.2)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chesttwelve = CircleZone:Create(CurrentLocation, 5,{ name = "twelve", debugPoly = false })
	chesttwelve:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langthirteen,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langthirteen,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationthirteen")
AddEventHandler("md-treasure:client:getlocationthirteen", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(-1578.02, -1441.01, -5.3)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chestthirteen = CircleZone:Create(CurrentLocation, 5,{ name = "chestthirteen", debugPoly = false })
	chestthirteen:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  Config.langthirteen,
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  Config.langthirteen,
					button = {}
				})
		
        end)
		end
	end)
end)

RegisterNetEvent("md-treasure:client:getlocationfourteen")
AddEventHandler("md-treasure:client:getlocationfourteen", function() 
	QBCore.Functions.Progressbar("drink_something", "grabbing items", 4000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        disableInventory = true,
    }, {}, {}, {}, function()-- Done
	 local CurrentLocation = vector3(-1687.02, -2058.45, -27.90)
	deliveryBlip = AddBlipForCoord(CurrentLocation)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Treasure")
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
	chestfourteen = CircleZone:Create(CurrentLocation, 5,{ name = "chestfourteen", debugPoly = false })
	chestfourteen:onPlayerInOut(function(isPointInside) if isPointInside then  RemoveBlip(deliveryBlip) end end)
        ClearPedTasks(PlayerPedId())
		if Config.gks then
			TriggerServerEvent('gksphone:NewMail', {
				sender = 'Captain Kane',
				image = '/html/static/img/icons/mail.png',
				subject = "ARGH MATEY YOU WANT TREASURE",
			message =  'You found them all!',
			})
		else
		SetTimeout(math.random(15000, 20000), function()
				emailSend = false
				TriggerServerEvent('qb-phone:server:sendNewMail', {
					sender = 'Captain Kane',
					subject = 'ARGH MATEY YOU WANT TREASURE',
					message =  'You found them all!',
					button = {}
				})
		
        end)
		end
	end)
end)
