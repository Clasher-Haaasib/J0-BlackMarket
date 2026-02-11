local currentOrder = {}

local function wipe()
    if currentOrder.zoneId then FW.RemoveTarget(currentOrder.zoneId, 'zone') end
    if currentOrder.blip then RemoveBlip(currentOrder.blip) end
    if currentOrder.pickupZoneId then FW.RemoveTarget(currentOrder.pickupZoneId, 'zone') end

    currentOrder.zoneId = nil
    currentOrder.blip = nil
    currentOrder.pickupZoneId = nil
    currentOrder.vehicle = nil
    currentOrder.driver = nil
    currentOrder.phase = nil
    currentOrder.contactName = nil
    currentOrder.itemName = nil
    ClearGpsPlayerWaypoint()
end

local function makeDriverLeave(veh, driver)
    if not veh or not DoesEntityExist(veh) then return end

    Citizen.CreateThread(function()
        FreezeEntityPosition(veh, false)

        local ped = driver
        if not ped or not DoesEntityExist(ped) then
            local model = `a_m_m_business_01`
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(50) end
            local pos = GetEntityCoords(veh)
            ped = CreatePed(4, model, pos.x, pos.y, pos.z, 0.0, false, false)
            SetModelAsNoLongerNeeded(model)
            SetPedIntoVehicle(ped, veh, -1)
        end

        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskVehicleDriveWander(ped, veh, 30.0, 786603)
        Wait(20000)
        DeleteEntity(veh)
        DeleteEntity(ped)
    end)
end

local function spawnCar(loc, modelName)
    local x, y, z, h = loc[1], loc[2], loc[3], loc[4] or 0.0
    local cfg = Config

    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, cfg.AreaBlipSprite or 162)
    SetBlipColour(blip, cfg.AreaBlipColor or 1)
    SetBlipScale(blip, cfg.AreaBlipScale or 0.8)
    SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Pickup Zone")
    EndTextCommandSetBlipName(blip)
    currentOrder.blip = blip

    local hash = GetHashKey(modelName)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(50) end

    local car = CreateVehicle(hash, x, y, z, h, true, false)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleOnGroundProperly(car)
    SetEntityAsMissionEntity(car, true, true)
    currentOrder.vehicle = car

    local driverModel = `a_m_m_business_01`
    RequestModel(driverModel)
    while not HasModelLoaded(driverModel) do Wait(50) end

    local driver = CreatePed(4, driverModel, x, y, z, 0.0, false, false)
    SetModelAsNoLongerNeeded(driverModel)
    SetPedIntoVehicle(driver, car, -1)
    SetBlockingOfNonTemporaryEvents(driver, true)
    currentOrder.driver = driver

    local zoneId = "blackmarket_pickup_" .. GetGameTimer()
    FW.AddBoxZone(zoneId, vector3(x, y, z + 0.5), vector3(4.0, 4.0, 2.0), h, {
        {
            label = L.target_collect,
            icon = "fas fa-box",
            onSelect = function()
                TriggerCallback('J0-BlackMarket:collectItem', function(gotItem)
                    if not gotItem then return end

                    local carRef = currentOrder.vehicle
                    local driverRef = currentOrder.driver
                    wipe()
                    FW.SendNotify("success", L.done_business)
                    SendNUIMessage({ action = "blackmarketReset" })
                    makeDriverLeave(carRef, driverRef)
                end)
            end
        }
    })
    currentOrder.pickupZoneId = zoneId
end

RegisterNetEvent('J0-J0-BlackMarket:client:openBurnerPhone', function()
    local payload = { data = Config.BlackMarketSettings, locale = L }

    if currentOrder.phase == 1 then
        payload.activeOrder = { phase = 1, message = L.order_drop_cash }
    elseif currentOrder.phase == 2 then
        payload.activeOrder = { phase = 2, message = L.order_collect_item }
    end

    FW.SendNuiMessage('openBurnerPhone', payload, true)
end)

RegisterNuiCallback('closeUi', function()
    SetNuiFocus(false, false)
end)

RegisterNuiCallback('getTime', function(_, cb)
    cb(FW.GetGtaTime())
end)

RegisterNuiCallback('confirmPurchase', function(data, cb)
    local contactId = data.contactId
    local itemName = data.itemName
    local itemDisplayName = data.itemDisplayName
    local price = data.price

    if not contactId or not itemName or not price then
        cb(false)
        return
    end

    TriggerCallback('J0-BlackMarket:confirmPurchase', function(success, result)
        if not success then
            FW.SendNotify("error", L.not_enough_cash)
            cb(false)
            return
        end

        local drop = result.cashDrop
        SetNewWaypoint(drop[1], drop[2])

        currentOrder.phase = 1
        currentOrder.contactName = itemDisplayName
        currentOrder.itemName = itemDisplayName

        local zoneId = "blackmarket_drop_" .. GetGameTimer()
        FW.AddBoxZone(zoneId, vector3(drop[1], drop[2], drop[3]), vector3(2.0, 2.0, 2.0), drop[4] or 0.0, {
            {
                label = L.target_drop_cash,
                icon = "fas fa-money-bill",
                onSelect = function()
                    TriggerCallback('J0-BlackMarket:dropCash', function(success, result)
                        if not success then return end

                        local dropZone = currentOrder.zoneId
                        currentOrder.zoneId = nil
                        currentOrder.phase = 2

                        Citizen.CreateThread(function()
                            Wait(100)
                            if dropZone then FW.RemoveTarget(dropZone, 'zone') end
                        end)

                        ClearGpsPlayerWaypoint()
                        FW.SendNotify("primary", L.phone_go_area)
                        spawnCar(result.carLoc, result.carModel)
                    end)
                end
            }
        })
        currentOrder.zoneId = zoneId
        cb(true)
    end, contactId, itemName, itemDisplayName, price)
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end

    if currentOrder.vehicle and DoesEntityExist(currentOrder.vehicle) then
        DeleteEntity(currentOrder.vehicle)
    end
    if currentOrder.driver and DoesEntityExist(currentOrder.driver) then
        DeleteEntity(currentOrder.driver)
    end
    wipe()
end)
