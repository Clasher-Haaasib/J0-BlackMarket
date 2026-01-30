RegisterCommand("openBurnerPhone", function()
    print("Opening Burner Phone")
    FW.SendNuiMessage('openBurnerPhone', nil, true)
end)