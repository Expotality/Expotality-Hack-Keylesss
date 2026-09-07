--[[
    ESP MODULE
    Designed for the central Roblox/Xeno menu framework.

    No standalone UI.
    No Fluent.
    No SaveManager.
    No InterfaceManager.

    Framework interface:
        Module.Name
        Module.Tab
        Module.Settings
        Module:Enable()
        Module:Disable()
        Module:SetSetting(name, value)
        Module:GetSetting(name)
        Module:GetSettings()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Module = {}

Module.Name = "ESP"
Module.Tab = "Visuals"
Module.Description = "Player ESP with boxes, tracers, health, names, chams and skeletons."

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------

Module.Settings = {
    Enabled = false,

    TeamCheck = false,
    ShowTeam = false,
    VisibilityCheck = true,

    BoxESP = false,
    BoxStyle = "Corner",
    BoxOutline = true,
    BoxFilled = false,
    BoxFillTransparency = 0.5,
    BoxThickness = 1,

    TracerESP = false,
    TracerOrigin = "Bottom",
    TracerStyle = "Line",
    TracerThickness = 1,

    HealthESP = false,
    HealthStyle = "Bar",
    HealthBarSide = "Left",
    HealthTextSuffix = "HP",
    HealthTextFormat = "Number",

    NameESP = false,
    NameMode = "DisplayName",

    ShowDistance = true,
    DistanceUnit = "studs",

    TextSize = 14,
    TextFont = 2,

    RainbowSpeed = 1,
    MaxDistance = 1000,
    RefreshRate = 144,

    Snaplines = false,
    SnaplineStyle = "Straight",

    RainbowEnabled = false,
    RainbowBoxes = false,
    RainbowTracers = false,
    RainbowText = false,

    ChamsEnabled = false,
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsFillColor = Color3.fromRGB(255, 0, 0),
    ChamsOccludedColor = Color3.fromRGB(150, 0, 0),
    ChamsTransparency = 0.5,
    ChamsOutlineTransparency = 0,
    ChamsOutlineThickness = 0.1,

    SkeletonESP = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1.5,
    SkeletonTransparency = 0,

    EnemyColor = Color3.fromRGB(255, 25, 25),
    AllyColor = Color3.fromRGB(25, 255, 25),
    NeutralColor = Color3.fromRGB(255, 255, 255),
    SelectedColor = Color3.fromRGB(255, 210, 0),
    HealthColor = Color3.fromRGB(0, 255, 0),
    DistanceColor = Color3.fromRGB(200, 200, 200),
}

----------------------------------------------------------------
-- RUNTIME
----------------------------------------------------------------

local Drawings = {
    ESP = {},
    Skeleton = {},
}

local Highlights = {}

local Connections = {}

local Running = false
local RainbowColor = Color3.fromRGB(255, 0, 0)
local LastUpdate = 0

----------------------------------------------------------------
-- UTILITY
----------------------------------------------------------------

local function safeRemove(object)
    if object then
        pcall(function()
            object:Remove()
        end)
    end
end

local function hideDrawingGroup(group)
    if not group then
        return
    end

    for _, object in pairs(group) do
        if typeof(object) == "table" then
            hideDrawingGroup(object)
        elseif object then
            pcall(function()
                object.Visible = false
            end)
        end
    end
end

local function getCamera()
    return workspace.CurrentCamera
end

local function getRainbowColor()
    return RainbowColor
end

----------------------------------------------------------------
-- PLAYER COLOR
----------------------------------------------------------------

local function GetPlayerColor(player)
    local settings = Module.Settings

    if settings.RainbowEnabled then
        if settings.RainbowBoxes and settings.BoxESP then
            return getRainbowColor()
        end

        if settings.RainbowTracers and settings.TracerESP then
            return getRainbowColor()
        end

        if settings.RainbowText and
            (settings.NameESP or settings.HealthESP) then
            return getRainbowColor()
        end
    end

    if player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            return settings.AllyColor
        end

        return settings.EnemyColor
    end

    return settings.NeutralColor
end

----------------------------------------------------------------
-- CREATE ESP
----------------------------------------------------------------

local function CreateESP(player)
    if player == LocalPlayer then
        return
    end

    if Drawings.ESP[player] then
        return
    end

    local settings = Module.Settings

    local box = {
        TopLeft = Drawing.new("Line"),
        TopRight = Drawing.new("Line"),
        BottomLeft = Drawing.new("Line"),
        BottomRight = Drawing.new("Line"),

        Left = Drawing.new("Line"),
        Right = Drawing.new("Line"),
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
    }

    for _, line in pairs(box) do
        line.Visible = false
        line.Color = settings.EnemyColor
        line.Thickness = settings.BoxThickness
    end

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = settings.EnemyColor
    tracer.Thickness = settings.TracerThickness

    local healthBar = {
        Outline = Drawing.new("Square"),
        Fill = Drawing.new("Square"),
        Text = Drawing.new("Text"),
    }

    healthBar.Outline.Visible = false
    healthBar.Outline.Filled = false
    healthBar.Outline.Color = Color3.new(0, 0, 0)

    healthBar.Fill.Visible = false
    healthBar.Fill.Filled = true
    healthBar.Fill.Color = settings.HealthColor

    healthBar.Text.Visible = false
    healthBar.Text.Center = true
    healthBar.Text.Size = settings.TextSize
    healthBar.Text.Color = settings.HealthColor
    healthBar.Text.Font = settings.TextFont
    healthBar.Text.Outline = true

    local info = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
    }

    for _, text in pairs(info) do
        text.Visible = false
        text.Center = true
        text.Size = settings.TextSize
        text.Font = settings.TextFont
        text.Outline = true
    end

    local snapline = Drawing.new("Line")
    snapline.Visible = false
    snapline.Color = settings.EnemyColor
    snapline.Thickness = 1

    local highlight = Instance.new("Highlight")

    highlight.FillColor = settings.ChamsFillColor
    highlight.OutlineColor = settings.ChamsOutlineColor
    highlight.FillTransparency = settings.ChamsTransparency
    highlight.OutlineTransparency = settings.ChamsOutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false

    Highlights[player] = highlight

    local skeleton = {
        Head = Drawing.new("Line"),
        Neck = Drawing.new("Line"),
        UpperSpine = Drawing.new("Line"),
        LowerSpine = Drawing.new("Line"),

        LeftShoulder = Drawing.new("Line"),
        LeftUpperArm = Drawing.new("Line"),
        LeftLowerArm = Drawing.new("Line"),
        LeftHand = Drawing.new("Line"),

        RightShoulder = Drawing.new("Line"),
        RightUpperArm = Drawing.new("Line"),
        RightLowerArm = Drawing.new("Line"),
        RightHand = Drawing.new("Line"),

        LeftHip = Drawing.new("Line"),
        LeftUpperLeg = Drawing.new("Line"),
        LeftLowerLeg = Drawing.new("Line"),
        LeftFoot = Drawing.new("Line"),

        RightHip = Drawing.new("Line"),
        RightUpperLeg = Drawing.new("Line"),
        RightLowerLeg = Drawing.new("Line"),
        RightFoot = Drawing.new("Line"),
    }

    for _, line in pairs(skeleton) do
        line.Visible = false
        line.Color = settings.SkeletonColor
        line.Thickness = settings.SkeletonThickness
        line.Transparency = settings.SkeletonTransparency
    end

    Drawings.Skeleton[player] = skeleton

    Drawings.ESP[player] = {
        Box = box,
        Tracer = tracer,
        HealthBar = healthBar,
        Info = info,
        Snapline = snapline,
    }
end

----------------------------------------------------------------
-- REMOVE ESP
----------------------------------------------------------------

local function RemoveESP(player)
    local esp = Drawings.ESP[player]

    if esp then
        for _, object in pairs(esp.Box) do
            safeRemove(object)
        end

        safeRemove(esp.Tracer)

        for _, object in pairs(esp.HealthBar) do
            safeRemove(object)
        end

        for _, object in pairs(esp.Info) do
            safeRemove(object)
        end

        safeRemove(esp.Snapline)

        Drawings.ESP[player] = nil
    end

    local highlight = Highlights[player]

    if highlight then
        pcall(function()
            highlight.Enabled = false
            highlight:Destroy()
        end)

        Highlights[player] = nil
    end

    local skeleton = Drawings.Skeleton[player]

    if skeleton then
        for _, line in pairs(skeleton) do
            safeRemove(line)
        end

        Drawings.Skeleton[player] = nil
    end
end

----------------------------------------------------------------
-- HIDE PLAYER
----------------------------------------------------------------

local function HideESP(player)
    local esp = Drawings.ESP[player]

    if esp then
        hideDrawingGroup(esp)
    end

    local skeleton = Drawings.Skeleton[player]

    if skeleton then
        hideDrawingGroup(skeleton)
    end

    local highlight = Highlights[player]

    if highlight then
        highlight.Enabled = false
    end
end

----------------------------------------------------------------
-- TRACER ORIGIN
----------------------------------------------------------------

local function GetTracerOrigin()
    local camera = getCamera()
    if not camera then
        return Vector2.new(0, 0)
    end

    local origin = Module.Settings.TracerOrigin

    if origin == "Bottom" then
        return Vector2.new(
            camera.ViewportSize.X / 2,
            camera.ViewportSize.Y
        )
    elseif origin == "Top" then
        return Vector2.new(
            camera.ViewportSize.X / 2,
            0
        )
    elseif origin == "Mouse" then
        return UserInputService:GetMouseLocation()
    end

    return Vector2.new(
        camera.ViewportSize.X / 2,
        camera.ViewportSize.Y / 2
    )
end

----------------------------------------------------------------
-- BONE HELPERS
----------------------------------------------------------------

local function GetBonePositions(character)
    if not character then
        return nil
    end

    local bones = {
        Head = character:FindFirstChild("Head"),

        UpperTorso =
            character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso"),

        LowerTorso =
            character:FindFirstChild("LowerTorso")
            or character:FindFirstChild("Torso"),

        LeftUpperArm =
            character:FindFirstChild("LeftUpperArm")
            or character:FindFirstChild("Left Arm"),

        LeftLowerArm =
            character:FindFirstChild("LeftLowerArm")
            or character:FindFirstChild("Left Arm"),

        LeftHand =
            character:FindFirstChild("LeftHand")
            or character:FindFirstChild("Left Arm"),

        RightUpperArm =
            character:FindFirstChild("RightUpperArm")
            or character:FindFirstChild("Right Arm"),

        RightLowerArm =
            character:FindFirstChild("RightLowerArm")
            or character:FindFirstChild("Right Arm"),

        RightHand =
            character:FindFirstChild("RightHand")
            or character:FindFirstChild("Right Arm"),

        LeftUpperLeg =
            character:FindFirstChild("LeftUpperLeg")
            or character:FindFirstChild("Left Leg"),

        LeftLowerLeg =
            character:FindFirstChild("LeftLowerLeg")
            or character:FindFirstChild("Left Leg"),

        LeftFoot =
            character:FindFirstChild("LeftFoot")
            or character:FindFirstChild("Left Leg"),

        RightUpperLeg =
            character:FindFirstChild("RightUpperLeg")
            or character:FindFirstChild("Right Leg"),

        RightLowerLeg =
            character:FindFirstChild("RightLowerLeg")
            or character:FindFirstChild("Right Leg"),

        RightFoot =
            character:FindFirstChild("RightFoot")
            or character:FindFirstChild("Right Leg"),
    }

    if not bones.Head or not bones.UpperTorso then
        return nil
    end

    return bones
end

local function DrawBone(from, to, line)
    local camera = getCamera()

    if not camera or not from or not to or not line then
        if line then
            line.Visible = false
        end
        return
    end

    local fromScreen, fromVisible =
        camera:WorldToViewportPoint(from.Position)

    local toScreen, toVisible =
        camera:WorldToViewportPoint(to.Position)

    if not fromVisible
        or not toVisible
        or fromScreen.Z <= 0
        or toScreen.Z <= 0 then

        line.Visible = false
        return
    end

    line.From = Vector2.new(fromScreen.X, fromScreen.Y)
    line.To = Vector2.new(toScreen.X, toScreen.Y)

    line.Color = Module.Settings.SkeletonColor
    line.Thickness = Module.Settings.SkeletonThickness
    line.Transparency = Module.Settings.SkeletonTransparency
    line.Visible = true
end

----------------------------------------------------------------
-- SKELETON
----------------------------------------------------------------

local function UpdateSkeleton(player, character)
    local skeleton = Drawings.Skeleton[player]

    if not skeleton or not Module.Settings.SkeletonESP then
        if skeleton then
            hideDrawingGroup(skeleton)
        end
        return
    end

    local bones = GetBonePositions(character)

    if not bones then
        hideDrawingGroup(skeleton)
        return
    end

    DrawBone(bones.Head, bones.UpperTorso, skeleton.Head)

    DrawBone(
        bones.UpperTorso,
        bones.LowerTorso,
        skeleton.UpperSpine
    )

    DrawBone(
        bones.UpperTorso,
        bones.LeftUpperArm,
        skeleton.LeftShoulder
    )

    DrawBone(
        bones.LeftUpperArm,
        bones.LeftLowerArm,
        skeleton.LeftUpperArm
    )

    DrawBone(
        bones.LeftLowerArm,
        bones.LeftHand,
        skeleton.LeftLowerArm
    )

    DrawBone(
        bones.UpperTorso,
        bones.RightUpperArm,
        skeleton.RightShoulder
    )

    DrawBone(
        bones.RightUpperArm,
        bones.RightLowerArm,
        skeleton.RightUpperArm
    )

    DrawBone(
        bones.RightLowerArm,
        bones.RightHand,
        skeleton.RightLowerArm
    )

    DrawBone(
        bones.LowerTorso,
        bones.LeftUpperLeg,
        skeleton.LeftHip
    )

    DrawBone(
        bones.LeftUpperLeg,
        bones.LeftLowerLeg,
        skeleton.LeftUpperLeg
    )

    DrawBone(
        bones.LeftLowerLeg,
        bones.LeftFoot,
        skeleton.LeftLowerLeg
    )

    DrawBone(
        bones.LowerTorso,
        bones.RightUpperLeg,
        skeleton.RightHip
    )

    DrawBone(
        bones.RightUpperLeg,
        bones.RightLowerLeg,
        skeleton.RightUpperLeg
    )

    DrawBone(
        bones.RightLowerLeg,
        bones.RightFoot,
        skeleton.RightLowerLeg
    )
end

----------------------------------------------------------------
-- UPDATE ESP
----------------------------------------------------------------

local function UpdateESP(player)
    if not Module.Settings.Enabled then
        HideESP(player)
        return
    end

    local esp = Drawings.ESP[player]

    if not esp then
        CreateESP(player)
        esp = Drawings.ESP[player]
    end

    if not esp then
        return
    end

    local character = player.Character

    if not character then
        HideESP(player)
        return
    end

    local rootPart =
        character:FindFirstChild("HumanoidRootPart")

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local camera = getCamera()

    if not rootPart or not humanoid or not camera then
        HideESP(player)
        return
    end

    if humanoid.Health <= 0 then
        HideESP(player)
        return
    end

    local distance =
        (rootPart.Position - camera.CFrame.Position).Magnitude

    if distance > Module.Settings.MaxDistance then
        HideESP(player)
        return
    end

    if Module.Settings.TeamCheck
        and player.Team == LocalPlayer.Team
        and not Module.Settings.ShowTeam then

        HideESP(player)
        return
    end

    local position, onScreen =
        camera:WorldToViewportPoint(rootPart.Position)

    if not onScreen or position.Z <= 0 then
        HideESP(player)
        return
    end

    local color = GetPlayerColor(player)

    ------------------------------------------------------------
    -- BOX
    ------------------------------------------------------------

    for _, object in pairs(esp.Box) do
        object.Visible = false
    end

    local size = character:GetExtentsSize()
    local cf = rootPart.CFrame

    local top = camera:WorldToViewportPoint(
        (cf * CFrame.new(0, size.Y / 2, 0)).Position
    )

    local bottom = camera:WorldToViewportPoint(
        (cf * CFrame.new(0, -size.Y / 2, 0)).Position
    )

    local screenHeight = math.abs(bottom.Y - top.Y)

    if screenHeight > 0 then
        local boxWidth = screenHeight * 0.65

        local boxPosition = Vector2.new(
            top.X - boxWidth / 2,
            math.min(top.Y, bottom.Y)
        )

        local boxSize = Vector2.new(
            boxWidth,
            screenHeight
        )

        if Module.Settings.BoxESP then

            if Module.Settings.BoxStyle == "Corner" then

                local cornerSize = boxWidth * 0.2

                esp.Box.TopLeft.From = boxPosition
                esp.Box.TopLeft.To =
                    boxPosition + Vector2.new(cornerSize, 0)

                esp.Box.TopRight.From =
                    boxPosition + Vector2.new(boxSize.X, 0)

                esp.Box.TopRight.To =
                    boxPosition + Vector2.new(
                        boxSize.X - cornerSize,
                        0
                    )

                esp.Box.BottomLeft.From =
                    boxPosition + Vector2.new(0, boxSize.Y)

                esp.Box.BottomLeft.To =
                    boxPosition + Vector2.new(
                        cornerSize,
                        boxSize.Y
                    )

                esp.Box.BottomRight.From =
                    boxPosition + boxSize

                esp.Box.BottomRight.To =
                    boxPosition + Vector2.new(
                        boxSize.X - cornerSize,
                        boxSize.Y
                    )

                esp.Box.Left.From = boxPosition
                esp.Box.Left.To =
                    boxPosition + Vector2.new(0, cornerSize)

                esp.Box.Right.From =
                    boxPosition + Vector2.new(boxSize.X, 0)

                esp.Box.Right.To =
                    boxPosition + Vector2.new(
                        boxSize.X,
                        cornerSize
                    )

                esp.Box.Top.From =
                    boxPosition + Vector2.new(0, boxSize.Y)

                esp.Box.Top.To =
                    boxPosition + Vector2.new(
                        0,
                        boxSize.Y - cornerSize
                    )

                esp.Box.Bottom.From = boxPosition + boxSize

                esp.Box.Bottom.To =
                    boxPosition + Vector2.new(
                        boxSize.X,
                        boxSize.Y - cornerSize
                    )

                esp.Box.TopLeft.Visible = true
                esp.Box.TopRight.Visible = true
                esp.Box.BottomLeft.Visible = true
                esp.Box.BottomRight.Visible = true
                esp.Box.Left.Visible = true
                esp.Box.Right.Visible = true
                esp.Box.Top.Visible = true
                esp.Box.Bottom.Visible = true

            elseif Module.Settings.BoxStyle == "ThreeD" then

                local points = {
                    Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
                    Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
                    Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
                    Vector3.new(-size.X/2, size.Y/2, size.Z/2),
                    Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
                    Vector3.new(size.X/2, -size.Y/2, size.Z/2),
                    Vector3.new(size.X/2, size.Y/2, -size.Z/2),
                    Vector3.new(size.X/2, size.Y/2, size.Z/2),
                }

                local projected = {}

                for i, point in ipairs(points) do
                    local screen =
                        camera:WorldToViewportPoint(
                            cf:PointToWorldSpace(point)
                        )

                    if screen.Z <= 0 then
                        HideESP(player)
                        return
                    end

                    projected[i] =
                        Vector2.new(screen.X, screen.Y)
                end

                local edges = {
                    {1, 2},
                    {1, 3},
                    {2, 4},
                    {3, 4},
                    {5, 6},
                    {5, 7},
                    {6, 8},
                    {7, 8},
                }

                local boxLines = {
                    esp.Box.TopLeft,
                    esp.Box.Left,
                    esp.Box.BottomLeft,
                    esp.Box.Top,
                    esp.Box.TopRight,
                    esp.Box.Right,
                    esp.Box.BottomRight,
                    esp.Box.Bottom,
                }

                for i, edge in ipairs(edges) do
                    local line = boxLines[i]

                    line.From = projected[edge[1]]
                    line.To = projected[edge[2]]
                    line.Visible = true
                    line.Color = color
                    line.Thickness =
                        Module.Settings.BoxThickness
                end

            else
                esp.Box.Left.From = boxPosition
                esp.Box.Left.To =
                    boxPosition + Vector2.new(0, boxSize.Y)

                esp.Box.Right.From =
                    boxPosition + Vector2.new(boxSize.X, 0)

                esp.Box.Right.To =
                    boxPosition + boxSize

                esp.Box.Top.From = boxPosition

                esp.Box.Top.To =
                    boxPosition + Vector2.new(boxSize.X, 0)

                esp.Box.Bottom.From =
                    boxPosition + Vector2.new(0, boxSize.Y)

                esp.Box.Bottom.To =
                    boxPosition + boxSize

                esp.Box.Left.Visible = true
                esp.Box.Right.Visible = true
                esp.Box.Top.Visible = true
                esp.Box.Bottom.Visible = true
            end

            for _, line in pairs(esp.Box) do
                if line.Visible then
                    line.Color = color
                    line.Thickness =
                        Module.Settings.BoxThickness
                end
            end
        end

        --------------------------------------------------------
        -- TRACER
        --------------------------------------------------------

        if Module.Settings.TracerESP then
            esp.Tracer.From = GetTracerOrigin()
            esp.Tracer.To =
                Vector2.new(position.X, position.Y)

            esp.Tracer.Color = color
            esp.Tracer.Thickness =
                Module.Settings.TracerThickness

            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end

        --------------------------------------------------------
        -- HEALTH
        --------------------------------------------------------

        if Module.Settings.HealthESP then
            local health = math.max(humanoid.Health, 0)
            local maxHealth =
                math.max(humanoid.MaxHealth, 1)

            local healthPercent =
                math.clamp(health / maxHealth, 0, 1)

            local barHeight = screenHeight * 0.8
            local barWidth = 4

            local barPosition =
                Vector2.new(
                    boxPosition.X - barWidth - 2,
                    boxPosition.Y +
                        (screenHeight - barHeight) / 2
                )

            esp.HealthBar.Outline.Size =
                Vector2.new(barWidth, barHeight)

            esp.HealthBar.Outline.Position =
                barPosition

            esp.HealthBar.Outline.Visible = true

            esp.HealthBar.Fill.Size =
                Vector2.new(
                    barWidth - 2,
                    barHeight * healthPercent
                )

            esp.HealthBar.Fill.Position =
                Vector2.new(
                    barPosition.X + 1,
                    barPosition.Y +
                        barHeight * (1 - healthPercent)
                )

            esp.HealthBar.Fill.Color =
                Color3.fromRGB(
                    255 - (255 * healthPercent),
                    255 * healthPercent,
                    0
                )

            esp.HealthBar.Fill.Visible = true

            if Module.Settings.HealthStyle == "Text"
                or Module.Settings.HealthStyle == "Both" then

                local text = ""

                if Module.Settings.HealthTextFormat == "Percentage" then
                    text =
                        tostring(math.floor(healthPercent * 100))
                        .. "%"

                elseif Module.Settings.HealthTextFormat == "Both" then
                    text =
                        tostring(math.floor(health))
                        .. " / "
                        .. tostring(math.floor(maxHealth))
                        .. " ("
                        .. tostring(math.floor(healthPercent * 100))
                        .. "%)"

                else
                    text =
                        tostring(math.floor(health))
                        .. Module.Settings.HealthTextSuffix
                end

                esp.HealthBar.Text.Text = text

                esp.HealthBar.Text.Position =
                    Vector2.new(
                        barPosition.X + barWidth + 4,
                        barPosition.Y + barHeight / 2
                    )

                esp.HealthBar.Text.Size =
                    Module.Settings.TextSize

                esp.HealthBar.Text.Visible = true

            else
                esp.HealthBar.Text.Visible = false
            end

        else
            for _, object in pairs(esp.HealthBar) do
                object.Visible = false
            end
        end

        --------------------------------------------------------
        -- NAME
        --------------------------------------------------------

        if Module.Settings.NameESP then

            local name

            if Module.Settings.NameMode == "Username" then
                name = player.Name
            else
                name = player.DisplayName
            end

            esp.Info.Name.Text = name

            esp.Info.Name.Position =
                Vector2.new(
                    boxPosition.X + boxWidth / 2,
                    boxPosition.Y - 20
                )

            esp.Info.Name.Size =
                Module.Settings.TextSize

            esp.Info.Name.Color = color
            esp.Info.Name.Visible = true

        else
            esp.Info.Name.Visible = false
        end

        --------------------------------------------------------
        -- DISTANCE
        --------------------------------------------------------

        if Module.Settings.ShowDistance then

            local distanceText

            if Module.Settings.DistanceUnit == "meters" then
                distanceText =
                    tostring(math.floor(distance * 0.28))
                    .. "m"
            else
                distanceText =
                    tostring(math.floor(distance))
                    .. " studs"
            end

            esp.Info.Distance.Text = distanceText

            esp.Info.Distance.Position =
                Vector2.new(
                    boxPosition.X + boxWidth / 2,
                    boxPosition.Y + boxSize.Y + 4
                )

            esp.Info.Distance.Size =
                Module.Settings.TextSize

            esp.Info.Distance.Color =
                Module.Settings.DistanceColor

            esp.Info.Distance.Visible = true

        else
            esp.Info.Distance.Visible = false
        end

        --------------------------------------------------------
        -- SNAPLINE
        --------------------------------------------------------

        if Module.Settings.Snaplines then

            esp.Snapline.From =
                Vector2.new(
                    camera.ViewportSize.X / 2,
                    camera.ViewportSize.Y
                )

            esp.Snapline.To =
                Vector2.new(
                    position.X,
                    position.Y
                )

            esp.Snapline.Color = color
            esp.Snapline.Visible = true

        else
            esp.Snapline.Visible = false
        end

        --------------------------------------------------------
        -- CHAMS
        --------------------------------------------------------

        local highlight = Highlights[player]

        if highlight then

            if Module.Settings.ChamsEnabled then
                highlight.Parent = character

                highlight.FillColor =
                    Module.Settings.ChamsFillColor

                highlight.OutlineColor =
                    Module.Settings.ChamsOutlineColor

                highlight.FillTransparency =
                    Module.Settings.ChamsTransparency

                highlight.OutlineTransparency =
                    Module.Settings.ChamsOutlineTransparency

                highlight.Enabled = true
            else
                highlight.Enabled = false
            end
        end

        --------------------------------------------------------
        -- SKELETON
        --------------------------------------------------------

        UpdateSkeleton(player, character)
    end
end

----------------------------------------------------------------
-- SETTING API
----------------------------------------------------------------

function Module:SetSetting(name, value)
    if self.Settings[name] == nil then
        return false
    end

    self.Settings[name] = value

    ------------------------------------------------------------
    -- Immediately propagate settings that affect drawings
    ------------------------------------------------------------

    if name == "SkeletonColor"
        or name == "SkeletonThickness"
        or name == "SkeletonTransparency" then

        for _, skeleton in pairs(Drawings.Skeleton) do
            for _, line in pairs(skeleton) do
                if name == "SkeletonColor" then
                    line.Color = value
                elseif name == "SkeletonThickness" then
                    line.Thickness = value
                elseif name == "SkeletonTransparency" then
                    line.Transparency = value
                end
            end
        end
    end

    if name == "TextSize" or name == "TextFont" then
        for _, esp in pairs(Drawings.ESP) do
            for _, text in pairs(esp.Info) do
                if name == "TextSize" then
                    text.Size = value
                else
                    text.Font = value
                end
            end

            esp.HealthBar.Text.Size =
                self.Settings.TextSize

            esp.HealthBar.Text.Font =
                self.Settings.TextFont
        end
    end

    return true
end

function Module:GetSetting(name)
    return self.Settings[name]
end

function Module:GetSettings()
    return self.Settings
end

----------------------------------------------------------------
-- ENABLE
----------------------------------------------------------------

function Module:Enable()
    if Running then
        self.Settings.Enabled = true
        return
    end

    Running = true
    self.Settings.Enabled = true

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    if not Connections.Render then
        Connections.Render =
            RunService.RenderStepped:Connect(function()

                if not Running or not Module.Settings.Enabled then
                    return
                end

                local now = os.clock()

                local refreshRate =
                    math.max(
                        tonumber(Module.Settings.RefreshRate) or 144,
                        1
                    )

                local interval = 1 / refreshRate

                if now - LastUpdate < interval then
                    return
                end

                LastUpdate = now

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        if not Drawings.ESP[player] then
                            CreateESP(player)
                        end

                        UpdateESP(player)
                    end
                end
            end)
    end

    if not Connections.PlayerAdded then
        Connections.PlayerAdded =
            Players.PlayerAdded:Connect(function(player)
                if Running then
                    CreateESP(player)
                end
            end)
    end

    if not Connections.PlayerRemoving then
        Connections.PlayerRemoving =
            Players.PlayerRemoving:Connect(function(player)
                RemoveESP(player)
            end)
    end
end

----------------------------------------------------------------
-- DISABLE
----------------------------------------------------------------

function Module:Disable()
    self.Settings.Enabled = false

    for _, player in ipairs(Players:GetPlayers()) do
        HideESP(player)
    end

    if Connections.Render then
        Connections.Render:Disconnect()
        Connections.Render = nil
    end

    Running = false
end

----------------------------------------------------------------
-- DESTROY
----------------------------------------------------------------

function Module:Destroy()
    self:Disable()

    if Connections.PlayerAdded then
        Connections.PlayerAdded:Disconnect()
        Connections.PlayerAdded = nil
    end

    if Connections.PlayerRemoving then
        Connections.PlayerRemoving:Disconnect()
        Connections.PlayerRemoving = nil
    end

    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESP(player)
    end

    Drawings.ESP = {}
    Drawings.Skeleton = {}
    Highlights = {}
end

----------------------------------------------------------------
-- RETURN MODULE
----------------------------------------------------------------

return Module
