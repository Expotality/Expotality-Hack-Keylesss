local Aim = {}

local Players =
    game:GetService("Players")

local RunService =
    game:GetService("RunService")

local Workspace =
    game:GetService("Workspace")

local LocalPlayer =
    Players.LocalPlayer

local Camera =
    Workspace.CurrentCamera


Aim.Name = "Aim"
Aim.Tab = "Combat"

Aim.Description =
    "Targeting system for game testing."


Aim.Settings = {

    Enabled = false,

    AimPart = "Head",

    Smoothness = 1,

    FOV = 150,

    TeamCheck = true,

    VisibilityCheck = true,

    FOVCircle = true,

    TargetPriority = "Closest",

    DistanceLimit = 1000,

    AutoShoot = false
}


local Target = nil
local FOVGui = nil
local FOVCircle = nil


--------------------------------------------------
-- CHARACTER
--------------------------------------------------

local function getCharacter(Player)

    return Player
        and Player.Character

end


local function getHumanoid(Character)

    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass(
        "Humanoid"
    )

end


--------------------------------------------------
-- AIM PART
--------------------------------------------------

local function getAimPart(Character)

    if not Character then
        return nil
    end

    return Character:FindFirstChild(
        Aim.Settings.AimPart
    )
    or Character:FindFirstChild("Head")
    or Character:FindFirstChild("HumanoidRootPart")

end


--------------------------------------------------
-- TEAM CHECK
--------------------------------------------------

local function validTeam(Player)

    if not Aim.Settings.TeamCheck then
        return true
    end

    if not LocalPlayer.Team then
        return true
    end

    if not Player.Team then
        return true
    end

    return Player.Team ~= LocalPlayer.Team

end


--------------------------------------------------
-- VISIBILITY CHECK
--------------------------------------------------

local function isVisible(
    Character,
    Part
)

    if not Aim.Settings.VisibilityCheck then
        return true
    end

    if not Character or not Part then
        return false
    end


    Camera =
        Workspace.CurrentCamera

    if not Camera then
        return false
    end


    local Origin =
        Camera.CFrame.Position

    local Direction =
        Part.Position - Origin


    local Parameters =
        RaycastParams.new()

    Parameters.FilterType =
        Enum.RaycastFilterType.Exclude

    Parameters.FilterDescendantsInstances = {
        LocalPlayer.Character
    }


    local Result =
        Workspace:Raycast(
            Origin,
            Direction,
            Parameters
        )


    if not Result then
        return true
    end


    return Result.Instance:IsDescendantOf(
        Character
    )

end


--------------------------------------------------
-- VALID TARGET
--------------------------------------------------

local function validTarget(Player)

    if Player == LocalPlayer then
        return false
    end


    if not validTeam(Player) then
        return false
    end


    local Character =
        getCharacter(Player)

    if not Character then
        return false
    end


    local Humanoid =
        getHumanoid(Character)

    if not Humanoid then
        return false
    end


    if Humanoid.Health <= 0 then
        return false
    end


    return true

end


--------------------------------------------------
-- TARGET SELECTION
--------------------------------------------------

local function getTarget()

    Camera =
        Workspace.CurrentCamera

    if not Camera then
        return nil
    end


    local Best = nil

    local BestScore =
        math.huge


    local Viewport =
        Camera.ViewportSize


    local Center =
        Vector2.new(
            Viewport.X / 2,
            Viewport.Y / 2
        )


    for _, Player in
        ipairs(Players:GetPlayers()) do


        if validTarget(Player) then

            local Character =
                getCharacter(Player)

            local Humanoid =
                getHumanoid(Character)

            local Part =
                getAimPart(Character)


            if Part then

                local WorldDistance =
                    (
                        Camera.CFrame.Position
                        - Part.Position
                    ).Magnitude


                if WorldDistance <=
                    Aim.Settings.DistanceLimit then


                    local ScreenPosition,
                        OnScreen =
                        Camera:WorldToViewportPoint(
                            Part.Position
                        )


                    if OnScreen then

                        local ScreenPoint =
                            Vector2.new(
                                ScreenPosition.X,
                                ScreenPosition.Y
                            )


                        local FOVDistance =
                            (
                                ScreenPoint
                                - Center
                            ).Magnitude


                        if FOVDistance <=
                            Aim.Settings.FOV then


                            if isVisible(
                                Character,
                                Part
                            ) then


                                local Score


                                if Aim.Settings.TargetPriority
                                    == "Lowest Health" then

                                    Score =
                                        Humanoid.Health


                                elseif Aim.Settings.TargetPriority
                                    == "Highest Health" then

                                    Score =
                                        -Humanoid.Health


                                else

                                    Score =
                                        FOVDistance

                                end


                                if Score <
                                    BestScore then

                                    BestScore =
                                        Score

                                    Best =
                                        Part

                                end

                            end
                        end
                    end
                end
            end
        end
    end


    return Best

end


--------------------------------------------------
-- CAMERA AIM
--------------------------------------------------

local function aimCameraAt(
    Part,
    DeltaTime
)

    if not Part then
        return
    end


    Camera =
        Workspace.CurrentCamera

    if not Camera then
        return
    end


    local CurrentCFrame =
        Camera.CFrame


    local TargetCFrame =
        CFrame.lookAt(
            CurrentCFrame.Position,
            Part.Position
        )


    local Smoothness =
        math.max(
            tonumber(
                Aim.Settings.Smoothness
            ) or 1,
            1
        )


    if Smoothness <= 1 then

        Camera.CFrame =
            TargetCFrame

        return

    end


    local Speed =
        math.clamp(
            1 - math.exp(
                -20
                * DeltaTime
                / Smoothness
            ),
            0,
            1
        )


    Camera.CFrame =
        CurrentCFrame:Lerp(
            TargetCFrame,
            Speed
        )

end


--------------------------------------------------
-- FOV CIRCLE
--------------------------------------------------

local function createFOVCircle()

    if FOVGui then
        FOVGui:Destroy()
    end


    FOVGui =
        Instance.new(
            "ScreenGui"
        )


    FOVGui.Name =
        "AimFOV"


    FOVGui.IgnoreGuiInset =
        true


    FOVGui.ResetOnSpawn =
        false


    FOVGui.DisplayOrder =
        999


    FOVGui.Parent =
        LocalPlayer:WaitForChild(
            "PlayerGui"
        )


    FOVCircle =
        Instance.new(
            "Frame"
        )


    FOVCircle.Name =
        "Circle"


    FOVCircle.BackgroundTransparency =
        1


    FOVCircle.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )


    FOVCircle.Position =
        UDim2.fromScale(
            0.5,
            0.5
        )


    FOVCircle.Size =
        UDim2.fromOffset(
            Aim.Settings.FOV * 2,
            Aim.Settings.FOV * 2
        )


    FOVCircle.Parent =
        FOVGui


    local Corner =
        Instance.new(
            "UICorner"
        )


    Corner.CornerRadius =
        UDim.new(
            1,
            0
        )


    Corner.Parent =
        FOVCircle


    local Stroke =
        Instance.new(
            "UIStroke"
        )


    Stroke.Thickness =
        1.5


    Stroke.Transparency =
        0


    Stroke.Color =
        Color3.fromRGB(
            255,
            255,
            255
        )


    Stroke.Parent =
        FOVCircle

end


local function updateFOVCircle()

    if not FOVCircle then
        return
    end


    FOVCircle.Size =
        UDim2.fromOffset(
            Aim.Settings.FOV * 2,
            Aim.Settings.FOV * 2
        )


    FOVCircle.Visible =
        Aim.Settings.Enabled
        and Aim.Settings.FOVCircle

end


local function destroyFOVCircle()

    if FOVGui then

        FOVGui:Destroy()

        FOVGui =
            nil

        FOVCircle =
            nil

    end

end


--------------------------------------------------
-- ENABLE
--------------------------------------------------

function Aim:Enable()

    if self.Settings.Enabled then
        return
    end


    self.Settings.Enabled =
        true


    createFOVCircle()

    updateFOVCircle()


    RunService:BindToRenderStep(
        "AimCamera",
        Enum.RenderPriority.Camera.Value + 1,
        function(DeltaTime)


            if not self.Settings.Enabled then
                return
            end


            Camera =
                Workspace.CurrentCamera

            if not Camera then
                return
            end


            Target =
                getTarget()


            updateFOVCircle()


            if Target then

                aimCameraAt(
                    Target,
                    DeltaTime
                )

            end

        end
    )

end


--------------------------------------------------
-- DISABLE
--------------------------------------------------

function Aim:Disable()

    self.Settings.Enabled =
        false


    Target =
        nil


    RunService:UnbindFromRenderStep(
        "AimCamera"
    )


    destroyFOVCircle()

end


--------------------------------------------------
-- SETTINGS
--------------------------------------------------

function Aim:SetSetting(
    Setting,
    Value
)

    if self.Settings[Setting] == nil then
        return false
    end


    self.Settings[Setting] =
        Value


    if Setting == "FOV"
        or Setting == "FOVCircle" then

        updateFOVCircle()

    end


    return true

end


--------------------------------------------------
-- GET TARGET
--------------------------------------------------

function Aim:GetTarget()

    return Target

end


--------------------------------------------------
-- DROPDOWNS
--------------------------------------------------

function Aim:GetDropdownOptions(
    Setting
)

    if Setting == "AimPart" then

        return {
            "Head",
            "HumanoidRootPart",
            "Torso",
        }

    end


    if Setting == "TargetPriority" then

        return {
            "Closest",
            "Lowest Health",
            "Highest Health",
        }

    end


    return nil

end


--------------------------------------------------
-- DESTROY
--------------------------------------------------

function Aim:Destroy()

    self:Disable()

end


return Aim
