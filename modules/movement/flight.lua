local Module = {}

Module.Name = "Fly"
Module.Tab = "Movement"
Module.Description = "Fly freely using WASD."

Module.Settings = {
    Enabled = false,
    Speed = 50
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local BodyVelocity = nil
local BodyGyro = nil

local UpdateConnection = nil
local CharacterConnection = nil

local Keys = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local Character = getCharacter()
    return Character and Character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local Character = getCharacter()

    if not Character then
        return nil
    end

    return Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("Torso")
end

local function resetKeys()
    for Key in pairs(Keys) do
        Keys[Key] = false
    end
end

local function cleanupForces()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
end

local function stopFlight()
    cleanupForces()
    resetKeys()

    local Humanoid = getHumanoid()

    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

local function startFlight()
    local Root = getRoot()
    local Humanoid = getHumanoid()

    if not Root or not Humanoid then
        return false
    end

    cleanupForces()

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 90000
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.Parent = Root

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = Root

    Humanoid.PlatformStand = true

    return true
end

local function updateFlight()
    if not Module.Settings.Enabled then
        return
    end

    local Root = getRoot()
    local Humanoid = getHumanoid()
    local Camera = workspace.CurrentCamera

    if not Root or not Humanoid or not Camera then
        return
    end

    if not BodyVelocity or not BodyGyro then
        if not startFlight() then
            return
        end
    end

    Humanoid.PlatformStand = true

    local Forward = Camera.CFrame.LookVector
    local Right = Camera.CFrame.RightVector

    local MoveDirection = Vector3.zero

    if Keys.Forward then
        MoveDirection += Forward
    end

    if Keys.Backward then
        MoveDirection -= Forward
    end

    if Keys.Right then
        MoveDirection += Right
    end

    if Keys.Left then
        MoveDirection -= Right
    end

    if MoveDirection.Magnitude > 0 then
        MoveDirection = MoveDirection.Unit
    end

    local Vertical = 0

    if Keys.Up then
        Vertical += 1
    end

    if Keys.Down then
        Vertical -= 1
    end

    local HorizontalVelocity = MoveDirection * Module.Settings.Speed
    local VerticalVelocity = Vector3.new(
        0,
        Vertical * Module.Settings.Speed,
        0
    )

    BodyVelocity.Velocity = HorizontalVelocity + VerticalVelocity

    BodyGyro.CFrame = CFrame.lookAt(
        Root.Position,
        Root.Position + Camera.CFrame.LookVector
    )
end

------------------------------------------------------------
-- FIXED FLY CONTROLS
------------------------------------------------------------

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then
        return
    end

    if Input.KeyCode == Enum.KeyCode.W then
        Keys.Forward = true

    elseif Input.KeyCode == Enum.KeyCode.S then
        Keys.Backward = true

    elseif Input.KeyCode == Enum.KeyCode.A then
        Keys.Left = true

    elseif Input.KeyCode == Enum.KeyCode.D then
        Keys.Right = true

    elseif Input.KeyCode == Enum.KeyCode.Space then
        Keys.Up = true

    elseif Input.KeyCode == Enum.KeyCode.LeftControl then
        Keys.Down = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.W then
        Keys.Forward = false

    elseif Input.KeyCode == Enum.KeyCode.S then
        Keys.Backward = false

    elseif Input.KeyCode == Enum.KeyCode.A then
        Keys.Left = false

    elseif Input.KeyCode == Enum.KeyCode.D then
        Keys.Right = false

    elseif Input.KeyCode == Enum.KeyCode.Space then
        Keys.Up = false

    elseif Input.KeyCode == Enum.KeyCode.LeftControl then
        Keys.Down = false
    end
end)

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

UpdateConnection = RunService.RenderStepped:Connect(updateFlight)

CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
    if Module.Settings.Enabled then
        task.wait(0.5)

        stopFlight()
        startFlight()
    end
end)

------------------------------------------------------------
-- MODULE API
------------------------------------------------------------

function Module:Enable()
    if self.Settings.Enabled then
        return
    end

    self.Settings.Enabled = true

    startFlight()
end

function Module:Disable()
    self.Settings.Enabled = false

    stopFlight()
end

function Module:SetSetting(Name, Value)
    if self.Settings[Name] == nil then
        return false
    end

    if Name == "Enabled" then
        if Value then
            self:Enable()
        else
            self:Disable()
        end

        return true
    end

    self.Settings[Name] = Value

    return true
end

function Module:GetSetting(Name)
    return self.Settings[Name]
end

function Module:GetSettings()
    return self.Settings
end

function Module:Destroy()
    self:Disable()

    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
    end

    if CharacterConnection then
        CharacterConnection:Disconnect()
        CharacterConnection = nil
    end
end

return Module
