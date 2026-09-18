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
    "Automatically aims at valid targets."

Aim.Settings = {
    Enabled = false,

    AimPart = "Head",
    Smoothness = 5,
    FOV = 100,

    TeamCheck = true,
    VisibilityCheck = true,

    FOVCircle = true,

    TargetPriority = "Closest",
    DistanceLimit = 1000,

    AutoShoot = false
}

local RenderConnection = nil
local FOVCircle = nil

local function getCharacter(Player)

    if not Player then
        return nil
    end

    return Player.Character
end

local function getHumanoid(Character)

    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass(
        "Humanoid"
    )
end

local function getAimPart(Character)

    if not Character then
        return nil
    end

    local Part =
        Character:FindFirstChild(
            Aim.Settings.AimPart
        )

    if Part then
        return Part
    end

    return Character:FindFirstChild("Head")
        or Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("Torso")
end

local function isAlive(Character)

    local Humanoid =
        getHumanoid(Character)

    return Humanoid
        and Humanoid.Health > 0
end

local function isTeammate(Player)

    if not Aim.Settings.TeamCheck then
        return false
    end

    if not LocalPlayer.Team then
        return false
    end

    return Player.Team == LocalPlayer.Team
end

local function isVisible(
    Part,
    Character
)

    if not Aim.Settings.VisibilityCheck then
        return true
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
        LocalPlayer.Character,
        Character
    }

    local Result =
        Workspace:Raycast(
            Origin,
            Direction,
            Parameters
        )

    return Result == nil
end

local function getScreenDistance(Part)

    local Position,
        OnScreen =
        Camera:WorldToViewportPoint(
            Part.Position
        )

    if not OnScreen then
        return nil
    end

    local Viewport =
        Camera.ViewportSize

    local Center =
        Vector2.new(
            Viewport.X / 2,
            Viewport.Y / 2
        )

    local ScreenPosition =
        Vector2.new(
            Position.X,
            Position.Y
        )

    return (
        ScreenPosition - Center
    ).Magnitude
end

local function getWorldDistance(Part)

    if not LocalPlayer.Character then
        return math.huge
    end

    local Root =
        LocalPlayer.Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not Root then
        return math.huge
    end

    return (
        Root.Position -
        Part.Position
    ).Magnitude
end

local function getTarget()

    local BestTarget = nil
    local BestValue = math.huge

    for _, Player in
        ipairs(Players:GetPlayers()) do

        if Player ~= LocalPlayer
            and not isTeammate(Player) then

            local Character =
                getCharacter(Player)

            if Character
                and isAlive(Character) then

                local Part =
                    getAimPart(Character)

                if Part then

                    local WorldDistance =
                        getWorldDistance(Part)

                    if WorldDistance <=
                        Aim.Settings.DistanceLimit then

                        local ScreenDistance =
                            getScreenDistance(Part)

                        if ScreenDistance
                            and ScreenDistance <=
                                Aim.Settings.FOV then

                            if isVisible(
                                Part,
                                Character
                            ) then

                                local Priority =
                                    Aim.Settings.TargetPriority

                                if Priority ==
                                    "Lowest Health" then

                                    local Humanoid =
                                        getHumanoid(
                                            Character
                                        )

                                    local Health =
                                        Humanoid.Health

                                    if Health <
                                        BestValue then

                                        BestValue =
                                            Health

                                        BestTarget =
                                            Part
                                    end

                                elseif Priority ==
                                    "Highest Health" then

                                    local Humanoid =
                                        getHumanoid(
                                            Character
                                        )

                                    local Health =
                                        Humanoid.Health

                                    if BestTarget == nil
                                        or Health >
                                            BestValue then

                                        BestValue =
                                            Health

                                        BestTarget =
                                            Part
                                    end

                                else

                                    if ScreenDistance <
                                        BestValue then

                                        BestValue =
                                            ScreenDistance

                                        BestTarget =
                                            Part
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return BestTarget
end

local function aimAt(Part)

    if not Part then
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

    local Alpha =
        math.clamp(
            1 / Smoothness,
            0.01,
            1
        )

    Camera.CFrame =
        CurrentCFrame:Lerp(
            TargetCFrame,
            Alpha
        )
end

local function createFOVCircle()

    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end

    if not Aim.Settings.FOVCircle then
        return
    end

    if not Drawing then
        return
    end

    FOVCircle =
        Drawing.new("Circle")

    FOVCircle.Visible = true

    FOVCircle.Radius =
        Aim.Settings.FOV

    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1

    FOVCircle.Color =
        Color3.fromRGB(
            255,
            255,
            255
        )
end

local function updateFOVCircle()

    if not FOVCircle then
        return
    end

    local Viewport =
        Camera.ViewportSize

    FOVCircle.Position =
        Vector2.new(
            Viewport.X / 2,
            Viewport.Y / 2
        )

    FOVCircle.Radius =
        Aim.Settings.FOV

    FOVCircle.Visible =
        Aim.Settings.Enabled
        and Aim.Settings.FOVCircle
end

function Aim:Enable()

    if self.Settings.Enabled then
        return
    end

    self.Settings.Enabled = true

    createFOVCircle()

    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end

    RenderConnection =
        RunService.RenderStepped:Connect(
            function()

                if not self.Settings.Enabled then
                    return
                end

                updateFOVCircle()

                local Target =
                    getTarget()

                if Target then
                    aimAt(Target)
                end
            end
        )
end

function Aim:Disable()

    self.Settings.Enabled = false

    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end

    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
end

function Aim:SetSetting(
    Setting,
    Value
)

    if self.Settings[Setting] == nil then
        return false
    end

    self.Settings[Setting] =
        Value

    if Setting == "FOVCircle" then
        createFOVCircle()
    end

    return true
end

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

function Aim:Destroy()

    self:Disable()

end

return Aim
