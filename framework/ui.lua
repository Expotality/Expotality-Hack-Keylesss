local UI = {}

UI.Name = "MainUI"
UI.Version = "1.1.0"

UI.Settings = {
    ToggleKey = Enum.KeyCode.Insert,

    AccentColor = Color3.fromRGB(90, 140, 255),

    Width = 760,
    Height = 500,

    Visible = true
}

UI.Registry = nil
UI.CurrentTab = nil

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------

local Existing = PlayerGui:FindFirstChild("RobloxHackMenu")

if Existing then
    Existing:Destroy()
end

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function Create(ClassName, Properties)
    local Object = Instance.new(ClassName)

    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end

    return Object
end

local function AddCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 6)
    Corner.Parent = Object

    return Corner
end

local function AddStroke(Object, Thickness, Transparency)
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = Thickness or 1
    Stroke.Transparency = Transparency or 0
    Stroke.Parent = Object

    return Stroke
end

------------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------------

local ScreenGui = Create("ScreenGui", {
    Name = "RobloxHackMenu",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

------------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------------

local Main = Create("Frame", {
    Name = "Main",
    Parent = ScreenGui,

    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),

    Size = UDim2.fromOffset(
        UI.Settings.Width,
        UI.Settings.Height
    ),

    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0
})

AddCorner(Main, 10)
AddStroke(Main, 1, 0.65)

------------------------------------------------------------
-- TOP BAR
------------------------------------------------------------

local TopBar = Create("Frame", {
    Name = "TopBar",
    Parent = Main,

    Size = UDim2.new(1, 0, 0, 55),

    BackgroundColor3 = Color3.fromRGB(23, 23, 28),
    BorderSizePixel = 0
})

AddCorner(TopBar, 10)

Create("Frame", {
    Parent = TopBar,

    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),

    BackgroundColor3 = Color3.fromRGB(23, 23, 28),
    BorderSizePixel = 0
})

Create("TextLabel", {
    Parent = TopBar,

    Position = UDim2.fromOffset(18, 0),
    Size = UDim2.new(0, 250, 1, 0),

    BackgroundTransparency = 1,

    Font = Enum.Font.GothamBold,
    Text = "◈  MENU",

    TextColor3 = Color3.fromRGB(240, 240, 245),
    TextSize = 17,

    TextXAlignment = Enum.TextXAlignment.Left
})

Create("TextLabel", {
    Parent = TopBar,

    Position = UDim2.fromOffset(110, 0),
    Size = UDim2.fromOffset(100, 55),

    BackgroundTransparency = 1,

    Font = Enum.Font.Gotham,
    Text = "v1.1",

    TextColor3 = Color3.fromRGB(120, 120, 130),
    TextSize = 12,

    TextXAlignment = Enum.TextXAlignment.Left
})

------------------------------------------------------------
-- CLOSE BUTTON
------------------------------------------------------------

local CloseButton = Create("TextButton", {
    Parent = TopBar,

    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),

    Size = UDim2.fromOffset(32, 32),

    BackgroundColor3 = Color3.fromRGB(35, 35, 42),
    BorderSizePixel = 0,

    AutoButtonColor = false,

    Font = Enum.Font.GothamBold,
    Text = "×",

    TextColor3 = Color3.fromRGB(210, 210, 215),
    TextSize = 20
})

AddCorner(CloseButton, 6)

CloseButton.MouseButton1Click:Connect(function()
    UI.Settings.Visible = false
    ScreenGui.Enabled = false
end)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------

local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Parent = Main,

    Position = UDim2.fromOffset(0, 55),
    Size = UDim2.new(0, 150, 1, -55),

    BackgroundColor3 = Color3.fromRGB(15, 15, 19),
    BorderSizePixel = 0
})

Create("UIListLayout", {
    Parent = Sidebar,

    Padding = UDim.new(0, 5),

    SortOrder = Enum.SortOrder.LayoutOrder
})

Create("UIPadding", {
    Parent = Sidebar,

    PaddingTop = UDim.new(0, 14),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
})

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------

local Content = Create("Frame", {
    Name = "Content",
    Parent = Main,

    Position = UDim2.fromOffset(150, 55),
    Size = UDim2.new(1, -150, 1, -55),

    BackgroundColor3 = Color3.fromRGB(20, 20, 24),
    BorderSizePixel = 0
})

Create("UIPadding", {
    Parent = Content,

    PaddingTop = UDim.new(0, 20),
    PaddingLeft = UDim.new(0, 22),
    PaddingRight = UDim.new(0, 22),
    PaddingBottom = UDim.new(0, 20)
})

------------------------------------------------------------
-- TABS
------------------------------------------------------------

local Tabs = {
    "Visuals",
    "Movement",
    "Events",
    "Customization",
    "Utilities"
}

local TabButtons = {}
local TabFrames = {}

local function CreateTabButton(TabName, Order)

    local Button = Create("TextButton", {
        Name = TabName .. "Tab",
        Parent = Sidebar,

        Size = UDim2.new(1, 0, 0, 38),

        BackgroundColor3 = Color3.fromRGB(15, 15, 19),
        BorderSizePixel = 0,

        AutoButtonColor = false,

        LayoutOrder = Order,

        Font = Enum.Font.GothamMedium,
        Text = TabName,

        TextColor3 = Color3.fromRGB(145, 145, 155),
        TextSize = 13,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    AddCorner(Button, 6)

    Create("UIPadding", {
        Parent = Button,
        PaddingLeft = UDim.new(0, 12)
    })

    TabButtons[TabName] = Button

    return Button
end

local function CreateTabFrame(TabName)

    local Frame = Create("ScrollingFrame", {
        Name = TabName .. "Frame",
        Parent = Content,

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        ScrollBarThickness = 3,

        CanvasSize = UDim2.new(0, 0, 0, 0),

        Visible = false
    })

    local Layout = Create("UIListLayout", {
        Parent = Frame,

        Padding = UDim.new(0, 10),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

        Frame.CanvasSize = UDim2.fromOffset(
            0,
            Layout.AbsoluteContentSize.Y + 10
        )

    end)

    TabFrames[TabName] = Frame

    return Frame
end

for Index, TabName in ipairs(Tabs) do

    local Button = CreateTabButton(TabName, Index)
    local Frame = CreateTabFrame(TabName)

    Button.MouseButton1Click:Connect(function()
        UI:SelectTab(TabName)
    end)

end

------------------------------------------------------------
-- MODULE CARD
------------------------------------------------------------

local function CreateModuleCard(Module)

    local Tab = Module.Tab or "Utilities"
    local Frame = TabFrames[Tab]

    if not Frame then
        return
    end

    local Card = Create("Frame", {
        Name = Module.Name .. "Card",
        Parent = Frame,

        Size = UDim2.new(1, -5, 0, 64),

        BackgroundColor3 = Color3.fromRGB(26, 26, 32),
        BorderSizePixel = 0
    })

    AddCorner(Card, 7)
    AddStroke(Card, 1, 0.8)

    --------------------------------------------------------
    -- MODULE NAME
    --------------------------------------------------------

    local Name = Create("TextLabel", {
        Parent = Card,

        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -120, 0, 22),

        BackgroundTransparency = 1,

        Font = Enum.Font.GothamSemibold,
        Text = Module.Name,

        TextColor3 = Color3.fromRGB(235, 235, 240),
        TextSize = 14,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    --------------------------------------------------------
    -- DESCRIPTION
    --------------------------------------------------------

    if Module.Description then

        Create("TextLabel", {
            Parent = Card,

            Position = UDim2.fromOffset(14, 31),
            Size = UDim2.new(1, -120, 0, 18),

            BackgroundTransparency = 1,

            Font = Enum.Font.Gotham,
            Text = Module.Description,

            TextColor3 = Color3.fromRGB(120, 120, 130),
            TextSize = 11,

            TextXAlignment = Enum.TextXAlignment.Left
        })

    end

    --------------------------------------------------------
    -- TOGGLE
    --------------------------------------------------------

    local Toggle = Create("TextButton", {
        Parent = Card,

        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),

        Size = UDim2.fromOffset(58, 28),

        BackgroundColor3 = Color3.fromRGB(42, 42, 49),
        BorderSizePixel = 0,

        AutoButtonColor = false,

        Font = Enum.Font.GothamBold,
        Text = "OFF",

        TextColor3 = Color3.fromRGB(150, 150, 160),
        TextSize = 11
    })

    AddCorner(Toggle, 6)

    local function UpdateToggle()

        local Enabled = false

        if Module.Settings then
            Enabled = Module.Settings.Enabled == true
        end

        if Enabled then

            Toggle.BackgroundColor3 = UI.Settings.AccentColor
            Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            Toggle.Text = "ON"

        else

            Toggle.BackgroundColor3 = Color3.fromRGB(42, 42, 49)
            Toggle.TextColor3 = Color3.fromRGB(150, 150, 160)
            Toggle.Text = "OFF"

        end

    end

    Toggle.MouseButton1Click:Connect(function()

        if UI.Registry then
            UI.Registry:Toggle(Module.Name)
        elseif Module.Enable and Module.Disable then

            if Module.Settings and Module.Settings.Enabled then
                Module:Disable()
            else
                Module:Enable()
            end

        end

        UpdateToggle()

    end)

    UpdateToggle()

    return Card
end

------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------

function UI:Initialize(Registry)

    self.Registry = Registry

    if not Registry then
        warn("[UI] Registry was not provided.")
        return false
    end

    --------------------------------------------------------
    -- CREATE MODULE CARDS
    --------------------------------------------------------

    for TabName, Frame in pairs(TabFrames) do

        for _, Child in ipairs(Frame:GetChildren()) do
            if Child:IsA("Frame") then
                Child:Destroy()
            end
        end

    end

    for TabName, Modules in pairs(Registry.ByTab) do

        for _, Module in ipairs(Modules) do
            CreateModuleCard(Module)
        end

    end

    self:SelectTab("Visuals")

    print("[UI] Initialized with registered modules.")

    return true
end

------------------------------------------------------------
-- TAB SELECTION
------------------------------------------------------------

function UI:SelectTab(TabName)

    if not TabFrames[TabName] then
        return
    end

    UI.CurrentTab = TabName

    for Name, Frame in pairs(TabFrames) do
        Frame.Visible = Name == TabName
    end

    for Name, Button in pairs(TabButtons) do

        if Name == TabName then

            Button.BackgroundColor3 = UI.Settings.AccentColor
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)

        else

            Button.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
            Button.TextColor3 = Color3.fromRGB(145, 145, 155)

        end

    end

end

------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------

local Dragging = false
local DragStart = nil
local StartPosition = nil

TopBar.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then

        Dragging = true

        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()

            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local Delta = Input.Position - DragStart

    Main.Position = UDim2.new(

        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,

        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y

    )

end)

------------------------------------------------------------
-- INSERT TOGGLE
------------------------------------------------------------

UserInputService.InputBegan:Connect(function(Input, GameProcessed)

    if GameProcessed then
        return
    end

    if Input.KeyCode == UI.Settings.ToggleKey then

        UI.Settings.Visible = not UI.Settings.Visible
        ScreenGui.Enabled = UI.Settings.Visible

    end

end)

------------------------------------------------------------
-- INITIAL STATE
------------------------------------------------------------

UI:SelectTab("Visuals")

return UI
