local activeOrders = {}

FW.RegisterUsableItem('burner_phone')

local function randPick(tbl)
    return tbl[math.random(#tbl)]
end

CreateCallback('J0-BlackMarket:confirmPurchase', function(src, cb, contactId, itemName, itemDisplayName, price)
    local cash = FW.GetPlayerMoney(src, 'cash')
    if cash < price then
        cb(false, nil)
        return
    end

    local drops = Config.CashDropOffLocation
    local carSpots = Config.BlackMarketCarLocation
    local models = Config.BlackMarketCarModels

    if #drops == 0 or #carSpots == 0 or #models == 0 then
        cb(false, nil)
        return
    end

    local dropSpot = randPick(drops)
    local carSpot = randPick(carSpots)

    activeOrders[src] = {
        contactId = contactId,
        itemName = itemName,
        itemDisplayName = itemDisplayName,
        price = price,
        cashDrop = { dropSpot.x, dropSpot.y, dropSpot.z, dropSpot.w },
        carLoc = { carSpot.x, carSpot.y, carSpot.z, carSpot.w },
        carModel = randPick(models)
    }

    cb(true, { cashDrop = activeOrders[src].cashDrop })
end)

CreateCallback('J0-BlackMarket:dropCash', function(src, cb)
    local order = activeOrders[src]
    if not order then
        cb(false, nil)
        return
    end

    if FW.GetPlayerMoney(src, 'cash') < order.price then
        cb(false, nil)
        return
    end

    FW.RemoveMoney(src, 'cash', order.price, 'blackmarket_drop')
    order.cashDropped = true
    cb(true, { carLoc = order.carLoc, carModel = order.carModel })
end)

CreateCallback('J0-BlackMarket:collectItem', function(src, cb)
    local order = activeOrders[src]
    if not order or not order.cashDropped then
        cb(false)
        return
    end

    local gaveItem = FW.AddItem(src, order.itemName, 1, nil)
    activeOrders[src] = nil
    cb(gaveItem)
end)

AddEventHandler('playerDropped', function()
    activeOrders[source] = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    activeOrders = {}
end)
