return {
    Name = "Speed",

    Type = "Toggle",

    Description = "Changes the player's movement speed.",

    Settings = {
        Speed = {
            Type = "Number",
            Default = 500,
            Minimum = 0,
            Maximum = math.huge
        }
    },

    Enable = function(settings)

        task.spawn(function()
            while settings.Enabled do

                local player = game.Players.LocalPlayer
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    humanoid.WalkSpeed = settings.Speed
                end

                task.wait()
            end
        end)

    end,

    Disable = function()

        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = 16
        end

    end,
}
