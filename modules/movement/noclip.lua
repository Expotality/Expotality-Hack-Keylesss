local Module = {}

Module.Name = "NoClip"
Module.Tab = "Movement"
Module.Description = "Walk through solid objects."

Module.Settings = {
    Enabled = false,
    Interval = 0.21
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Connection = nil

local function setCollision(enabled)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("BasePart") then
            Object.CanCollide = enabled
        end
    end
end

local function applyNoClip()
    local Character = LocalPlayer.Character
    if not Character then
        return
    end

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("BasePart") then
            Object.CanCollide = false
        end
    end
end

function Module:Enable()
    if Connection then
        return
    end

    self.Settings.Enabled = true

    Connection = RunService.Stepped:Connect(function()
        if self.Settings.Enabled then
            applyNoClip()
        end
    end)
end

function Module:Disable()
    self.Settings.Enabled = false

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    setCollision(true)
end

function Module:SetSetting(Name, Value)
    if self.Settings[Name] == nil then
        return false
    end

    self.Settings[Name] = Value

    if Name == "Enabled" then
        if Value then
            self:Enable()
        else
            self:Disable()
        end
    end

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
end

return Module
