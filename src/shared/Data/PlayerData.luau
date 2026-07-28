local PlayerData = {
    Gold = 100,

    PortalLevel = 1,
    PortalSpeed = 8,

    Gamepasses = {
        VIP = false,
        x2Speed = false,
        x3Spawn = false,
        x5Spawn = false,
        AutoBuy = false,
        AutoSpawn = false,
        x2Luck = false,
        x2MutationLuck = false,
        x4Luck = false,
        x4MutationLuck = false,
    },

    Assets = {},          -- Clothes, hats, accessories, etc.
    Inventory = {},       -- Potions, tickets, keys, consumables
    OwnedMannequins = {},
    PlacedMannequins = {},

    PortalSettings = {
        AutoSpawn = false,
        AutoBuy = false,
        x2Speed = false,
        x3Spawn = false,
        AutoCommon = false,
        AutoUncommon = false,
    },

    Statistics = {
        PlayTime = 0,
    }
}

return PlayerData