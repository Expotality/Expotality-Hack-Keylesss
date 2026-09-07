local VirtualUser = game:GetService("VirtualUser")

local AntiAFK = {

    Name = "Anti-AFK",

    Type = "Toggle",

    Description = "Prevents the player from being kicked for being idle.",

    Settings = {
        Enabled = false
    }
}

function AntiAFK:Enable()

    if self.Connection then
        self.Connection:Disconnect()
    end

    self.Connection =
        game.Players.LocalPlayer.Idled:Connect(function()

            VirtualUser:CaptureController()

            VirtualUser:ClickButton2(
                Vector2.new(0, 0)
            )

        end)

end

function AntiAFK:Disable()

    if self.Connection then

        self.Connection:Disconnect()

        self.Connection = nil

    end

end

function AntiAFK:Destroy()

    self:Disable()

end

return AntiAFK
