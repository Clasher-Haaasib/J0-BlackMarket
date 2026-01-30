Config = {
    Locale = "en", -- Locale: "en" | "fr" | "es" | "bn"
    ServerCallbacks = {},
    FrameworkSettings = {
        CoreName = "qb-core", -- qb-core, es_extended, qbx_core, custom
        EmailResource = "qb-phone", -- lb-phone, 17mov_Phone, qb-phone, npwd, CUSTOM  (fw-sv file check please)
        TargetSettings = {
            resource = 'qb-target', --- ox_target | qb-target | interact |
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

}