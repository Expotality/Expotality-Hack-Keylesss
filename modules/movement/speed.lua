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

    Speed = 16
}


local Connection =
    nil

local OriginalWalkSpeed =
    nil


--------------------------------------------------
-- CHARACTER
--------------------------------------------------

local function getCharacter()

    return LocalPlayer.Character

end


local function getHumanoid()

    local Character =
        getCharacter()

    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass(
        "Humanoid"
    )

end


--------------------------------------------------
-- ENABLE
--------------------------------------------------

function Speed:Enable()

    if self.Settings.Enabled then
        return
    end

    self.Settings.Enabled =
        true


    local Humanoid =
        getHumanoid()


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
                    getCharacter()

                local Humanoid =
                    getHumanoid()


                if not Character
                    or not Humanoid then

                    return

                end


                if self.Settings.Mode
                    == "WalkSpeed" then


                    if OriginalWalkSpeed == nil then

                        OriginalWalkSpeed =
                            Humanoid.WalkSpeed

                    end


                    Humanoid.WalkSpeed =
                        tonumber(
                            self.Settings.Speed
                        ) or 16


                elseif self.Settings.Mode
                    == "TP Speed" then


                    local MoveDirection =
                        Humanoid.MoveDirection


                    if MoveDirection.Magnitude > 0 then

                        local SpeedAmount =
                            tonumber(
                                self.Settings.Speed
                            ) or 16


                        local Distance =
                            SpeedAmount
                            * DeltaTime


                        Character:PivotTo(
                            Character:GetPivot()
                            + (
                                MoveDirection
                                * Distance
                            )
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


    local Humanoid =
        getHumanoid()


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


    self.Settings[Setting] =
        Value


    if Setting == "Mode" then

        local Humanoid =
            getHumanoid()


        if Humanoid
            and Value == "WalkSpeed" then

            Humanoid.WalkSpeed =
                tonumber(
                    self.Settings.Speed
                ) or 16

        end

    end


    return true

end


--------------------------------------------------
-- DROPDOWNS
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
