Config = {
    Locale = "en", -- Locale: "en" | "fr" | "es" | "bn"
    ServerCallbacks = {},
    FrameworkSettings = {
        CoreName = "qb-core", -- qb-core, es_extended, qbx_core, custom
        EmailResource = "qb-phone", -- lb-phone, 17mov_Phone, qb-phone, npwd, CUSTOM  (fw-sv file check please)
        TargetSettings = {
            resource = 'interact', --- ox_target | qb-target | interact |
            debug = false,
        },
    },
    BlackMarketSettings = {
        Time = {
            Enabled = true, -- true or false
            OpenTime = 10, -- 24 hour format
            CloseTime = 18, -- 24 hour format
        },
        contacts = {
            {
                id = "snake",
                name = "SNAKE",
                items = {
                    { name = "PISTOL", itemName = 'weapon_pistol', price = 2500 },
                    { name = "SMG",       itemName = 'weapon_smg', price = 7500 },
                    { name = "PISTOL AMMO",  itemName = 'pistol_ammo', price = 400  }
                }
            },
            {
                id = "ghost",
                name = "GHOST",
                items = {
                    { name = "LOCKPICK", itemName = 'lockpick', price = 150  },
                    { name = "TROJAN USB",   itemName = 'trojan_usb', price = 5000 },
                    { name = "ELECTRONIC KIT",    itemName = 'electronickit', price = 1200 }
                }
            }
        }
    },
    CashDropOffLocation = {
        vector4(-150.3517, -1294.1593, 31.2575, 354.5128),
        vector4(-175.7084, -1284.3866, 31.2960, 258.0212),
        vector4(-327.0416, -1317.7979, 31.4004, 283.5445),
        vector4(-634.1200, -1225.4890, 12.0860, 207.3251),
    },
    BlackMarketCarLocation = {
        vector4(-653.4383, -606.5893, 33.2534, 6.4743),
        vector4(-529.2074, -325.9189, 35.0425, 31.8999),
        vector4(-851.9827, 117.4270, 55.8485, 268.7933),
    },
    BlackMarketCarModels = {
        'sultan',
        'rumpo',
    },
    AreaBlipSprite = 162,
    AreaBlipColor = 1,
    AreaBlipScale = 0.8,
    Dispatch = function()
        print('Dispatching')
    end
}