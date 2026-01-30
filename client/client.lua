RegisterCommand("openBurnerPhone", function()
    FW.SendNuiMessage('openBurnerPhone', {
        data = Config.BlackMarketSettings,
        locale = L or {}
    }, true)
end)

RegisterNuiCallback('closeUi', function(data)
    SetNuiFocus(false, false)
end)

RegisterNuiCallback('getTime', function(_, cb)
    cb(FW.GetGtaTime())
end)