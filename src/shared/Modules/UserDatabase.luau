local UserDatabase = {

    Gold = 0,
    ConveyorLevel = 1,
    
    HasVIP = false,
    Has2xSpeed = false,
    Hasx3Spawn = false,
    Hasx5Spawn = false,
    HasAutoBuy = false,
    HasAutoSpawn = false,
    Has2xLuck = false,
    Has2xMutationLuck = false,
    Has4xLuck = false,
    Has4xMutationLuck = false,

    OwnedMannequins = {},
    Items = {},

    UnlockedItems = {},

    PortalSettings = {
        AutoSpawn = false,
        AutoBuy = false,
        x2Speed = false,
        x3Spawn = false,
        AutoCommon = false,
        AutoUncommon = false
    },

    Statistics = {
        PlayTime = 0
    }

}

return UserDatabase