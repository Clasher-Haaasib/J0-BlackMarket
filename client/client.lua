RegisterCommand("openBurnerPhone", function()
    FW.SendNuiMessage('openBurnerPhone', Config.BlackMarketSettings, true)
end)