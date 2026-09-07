local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Teleport = {
    Name = "Teleport",

    Type = "Teleport",

    Description = "Teleport to coordinates, players, and saved waypoints.",

    Settings = {
        X = {
            Type = "Number",
            Default = 0,
            Value = 0
        },

        Y = {
            Type = "Number",
            Default = 0,
            Value = 0
        },

        Z = {
            Type = "Number",
            Default = 0,
            Value = 0
        }
    },

    Waypoints = {}
}

function Teleport:GetRoot()
    local Character = LocalPlayer.Character

    return Character
        and Character:FindFirstChild("HumanoidRootPart")
end

function Teleport:GetCoordinates()
    local Root = self:GetRoot()

    if not Root then
        return nil
    end

    return Root.Position
end

function Teleport:TeleportToCoordinates(X, Y, Z)

    local Root = self:GetRoot()

    if not Root then
        return false
    end

    Root.CFrame = CFrame.new(X, Y, Z)

    return true
end

function Teleport:TeleportToPlayer(TargetPlayer)

    if not TargetPlayer then
        return false
    end

    local Root = self:GetRoot()

    local TargetCharacter = TargetPlayer.Character
    local TargetRoot = TargetCharacter
        and TargetCharacter:FindFirstChild("HumanoidRootPart")

    if not Root or not TargetRoot then
        return false
    end

    Root.CFrame =
        TargetRoot.CFrame
        + Vector3.new(0, 3, 0)

    return true
end

function Teleport:SaveWaypoint(Name)

    local Position = self:GetCoordinates()

    if not Position then
        return false
    end

    self.Waypoints[Name] = {
        X = Position.X,
        Y = Position.Y,
        Z = Position.Z
    }

    return true
end

function Teleport:TeleportToWaypoint(Name)

    local Waypoint = self.Waypoints[Name]

    if not Waypoint then
        return false
    end

    return self:TeleportToCoordinates(
        Waypoint.X,
        Waypoint.Y,
        Waypoint.Z
    )
end

function Teleport:DeleteWaypoint(Name)

    if not self.Waypoints[Name] then
        return false
    end

    self.Waypoints[Name] = nil

    return true
end

return Teleport
