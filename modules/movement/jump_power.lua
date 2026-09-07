return {
    Name = "Jump Power",

    Type = "Toggle",

    Description = "Changes the player's jump power.",

    Settings = {
        Enabled = false,

        JumpPower = {
            Type = "Number",
            Default = 100,
            Value = 100,
            Minimum = 0,
            Maximum = math.huge
        }
    },

    Enable = function(self)

        local settings = self.Settings

        task.spawn(function()
            while settings.Enabled do

                local player = game.Players.LocalPlayer
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    humanoid.UseJumpPower = true
                    humanoid.JumpPower = settings.JumpPower.Value
                end

                task.wait()
            end
        end)

    end,

    Disable = function(self)

        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.JumpPower = 50
        end

    end,
}
