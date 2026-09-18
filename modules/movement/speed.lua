local Speed = {}

local Players =
    game:GetService("Players")

local RunService =
    game:GetService("RunService")

local LocalPlayer =
    Players.LocalPlayer


Speed.Name =
    "Speed"

Speed.Tab =
    "Movement"

Speed.Description =
    "Changes movement speed."


Speed.Settings = {

    Enabled = false,

    Mode = "WalkSpeed",

    Speed = 100
}


local Connection =
    nil

local OriginalWalkSpeed =
    nil


--------------------------------------------------
-- ENABLE
--------------------------------------------------

function Speed:Enable()

    self.Settings.Enabled =
        true


    if Connection then

        Connection:Disconnect()

        Connection =
            nil

    end


    local Character =
        LocalPlayer.Character

    local Humanoid =
        Character
        and Character:FindFirstChildOfClass(
            "Humanoid"
        )


    if Humanoid then

        OriginalWalkSpeed =
            Humanoid.WalkSpeed

    end


    Connection =
        RunService.Heartbeat:Connect(
            function(DeltaTime)

                if not self.Settings.Enabled then
                    return
                end


                local Character =
                    LocalPlayer.Character


                if not Character then
                    return
                end


                local Humanoid =
                    Character:FindFirstChildOfClass(
                        "Humanoid"
                    )


                if not Humanoid then
                    return
                end


                local SpeedAmount =
                    tonumber(
                        self.Settings.Speed
                    )


                if not SpeedAmount then
                    SpeedAmount = 100
                end


                --------------------------------------------------
                -- WALK SPEED
                --------------------------------------------------

                if self.Settings.Mode
                    == "WalkSpeed" then

                    Humanoid.WalkSpeed =
                        SpeedAmount


                --------------------------------------------------
                -- TP SPEED
                --------------------------------------------------

                elseif self.Settings.Mode
                    == "TP Speed" then


                    local Root =
                        Character:FindFirstChild(
                            "HumanoidRootPart"
                        )


                    if not Root then
                        return
                    end


                    local Direction =
                        Humanoid.MoveDirection


                    if Direction.Magnitude > 0 then

                        local Offset =
                            Direction.Unit
                            * SpeedAmount
                            * DeltaTime


                        Character:PivotTo(
                            Character:GetPivot()
                            + Offset
                        )

                    end

                end

            end
        )

end


--------------------------------------------------
-- DISABLE
--------------------------------------------------

function Speed:Disable()

    self.Settings.Enabled =
        false


    if Connection then

        Connection:Disconnect()

        Connection =
            nil

    end


    local Character =
        LocalPlayer.Character

    local Humanoid =
        Character
        and Character:FindFirstChildOfClass(
            "Humanoid"
        )


    if Humanoid then

        Humanoid.WalkSpeed =
            OriginalWalkSpeed
            or 16

    end


    OriginalWalkSpeed =
        nil

end


--------------------------------------------------
-- SETTINGS
--------------------------------------------------

function Speed:SetSetting(
    Setting,
    Value
)

    if self.Settings[Setting] == nil then
        return false
    end


    if Setting == "Speed" then

        Value =
            tonumber(Value)

        if not Value then
            return false
        end

    end


    if Setting == "Mode" then

        if Value ~= "WalkSpeed"
            and Value ~= "TP Speed" then

            return false

        end

    end


    self.Settings[Setting] =
        Value


    return true

end


--------------------------------------------------
-- DROPDOWN
--------------------------------------------------

function Speed:GetDropdownOptions(
    Setting
)

    if Setting == "Mode" then

        return {
            "WalkSpeed",
            "TP Speed",
        }

    end


    return nil

end


--------------------------------------------------
-- DESTROY
--------------------------------------------------

function Speed:Destroy()

    self:Disable()

end


return Speed
