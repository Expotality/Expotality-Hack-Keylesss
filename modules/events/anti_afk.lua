return {
    Name = "Anti-AFK",

    Type = "Toggle",

    Description = "Prevents AFK kicks.",

    Settings = {
        Enabled = false
    },

    Enable = function(self)
        print("Anti-AFK enabled")
    end,

    Disable = function(self)
        print("Anti-AFK disabled")
    end
}
