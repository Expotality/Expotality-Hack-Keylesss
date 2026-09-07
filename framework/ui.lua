local UI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Registry
local ScreenGui
local Main
local Content

local CurrentTab = "Visuals"
local MenuVisible = true

local Accent = Color3.fromRGB(90, 120, 255)
local Background = Color3.fromRGB(15, 16, 20)
local SidebarBackground = Color3.fromRGB(19, 20, 25)
local ElementBackground = Color3.fromRGB(24, 25, 31)
local ElementHover = Color3.fromRGB(31, 33, 41)
local TextColor = Color3.fromRGB(235, 235, 240)
local SubTextColor = Color3.fromRGB(145, 148, 158)

local TabButtons = {}

local TAB_ORDER = {
    "Visuals",
    "Movement",
    "Events",
    "Customization",
    "Utilities",
}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(45, 46, 54)
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function getSetting(module, name)
    if module.GetSetting then
        return module:GetSetting(name)
    end

    if module.Settings then
        return module.Settings[name]
    end
end

local function setSetting(module, name, value)
    if module.SetSetting then
        module:SetSetting(name, value)
    elseif module.Settings then
        module.Settings[name] = value
    end
end

local function enableModule(module)
    if module.Enable then
        module:Enable()
    else
        setSetting(module, "Enabled", true)
    end
end

local function disableModule(module)
    if module.Disable then
        module:Disable()
    else
        setSetting(module, "Enabled", false)
    end
end

local function toggleModule(module)
    if getSetting(module, "Enabled") then
        disableModule(module)
    else
        enableModule(module)
    end
end

local function prettyName(name)
    return tostring(name):gsub("(%l)(%u)", "%1 %2")
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local function createToggle(parent, module, settingName, title)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    addCorner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -75, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local button = create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(45, 46, 54),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(42, 22),
        Position = UDim2.new(1, -56, 0.5, -11),
        Parent = row,
    })

    addCorner(button, 12)

    local knob = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(180, 182, 190),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 3, 0.5, -8),
        Parent = button,
    })

    addCorner(knob, 10)

    local function refresh()
        local enabled = getSetting(module, settingName) == true

        if enabled then
            button.BackgroundColor3 = Accent
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Position = UDim2.new(1, -19, 0.5, -8)
        else
            button.BackgroundColor3 = Color3.fromRGB(45, 46, 54)
            knob.BackgroundColor3 = Color3.fromRGB(180, 182, 190)
            knob.Position = UDim2.new(0, 3, 0.5, -8)
        end
    end

    button.MouseButton1Click:Connect(function()
        if settingName == "Enabled" then
            toggleModule(module)
        else
            setSetting(
                module,
                settingName,
                not getSetting(module, settingName)
            )
        end

        refresh()
    end)

    refresh()

    return row
end

------------------------------------------------------------
-- NUMBER
------------------------------------------------------------

local function createNumber(parent, module, settingName, title)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44),
        Parent = parent,
    })

    addCorner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local input = create("TextBox", {
        BackgroundColor3 = Color3.fromRGB(18, 19, 24),
        BorderSizePixel = 0,
        Text = tostring(getSetting(module, settingName)),
        TextColor3 = TextColor,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromOffset(65, 28),
        Position = UDim2.new(1, -79, 0.5, -14),
        Parent = row,
    })

    addCorner(input, 5)

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)

        if value then
            setSetting(module, settingName, value)
            input.Text = tostring(value)
        else
            input.Text = tostring(getSetting(module, settingName))
        end
    end)

    return row
end

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

local function getDropdownOptions(settingName)
    if settingName == "BoxStyle" then
        return {
            "Corner",
            "Full",
        }
    end

    if settingName == "NameMode" then
        return {
            "DisplayName",
            "Username",
        }
    end

    return nil
end

local function createDropdown(parent, module, settingName, title)
    local container = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = container,
    })

    addCorner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local button = create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(18, 19, 24),
        BorderSizePixel = 0,
        Text = tostring(getSetting(module, settingName)) .. "  ▼",
        TextColor3 = TextColor,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(130, 28),
        Position = UDim2.new(1, -144, 0.5, -14),
        Parent = row,
    })

    addCorner(button, 5)

    local options = getDropdownOptions(settingName)

    if not options then
        return container
    end

    local dropdown = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 19, 24),
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 0, #options * 32),
        ZIndex = 20,
        Parent = container,
    })

    addCorner(dropdown, 6)
    addStroke(dropdown, Color3.fromRGB(55, 56, 65))

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = dropdown

    local open = false

    local function setOpen(value)
        open = value
        dropdown.Visible = value

        if value then
            container.Size = UDim2.new(
                1,
                0,
                0,
                46 + (#options * 32)
            )

            button.Text = tostring(getSetting(module, settingName)) .. "  ▲"
        else
            container.Size = UDim2.new(1, 0, 0, 42)
            button.Text = tostring(getSetting(module, settingName)) .. "  ▼"
        end
    end

    for index, option in ipairs(options) do
        local optionButton = create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(18, 19, 24),
            BorderSizePixel = 0,
            Text = option,
            TextColor3 = TextColor,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 32),
            LayoutOrder = index,
            ZIndex = 21,
            Parent = dropdown,
        })

        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = ElementHover
        end)

        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
        end)

        optionButton.MouseButton1Click:Connect(function()
            setSetting(module, settingName, option)
            setOpen(false)
        end)
    end

    button.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)

    return container
end

------------------------------------------------------------
-- COLOR
------------------------------------------------------------

local COLOR_OPTIONS = {
    Color3.fromRGB(255, 25, 25),
    Color3.fromRGB(255, 100, 100),
    Color3.fromRGB(255, 170, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 100),
    Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(90, 120, 255),
    Color3.fromRGB(180, 80, 255),
    Color3.fromRGB(255, 80, 180),
    Color3.fromRGB(255, 255, 255),
}

local function createColor(parent, module, settingName, title)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    addCorner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local colorButton = create("TextButton", {
        BackgroundColor3 = getSetting(module, settingName),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(34, 24),
        Position = UDim2.new(1, -48, 0.5, -12),
        Parent = row,
    })

    addCorner(colorButton, 5)
    addStroke(colorButton, Color3.fromRGB(70, 71, 80))

    local index = 1

    colorButton.MouseButton1Click:Connect(function()
        index += 1

        if index > #COLOR_OPTIONS then
            index = 1
        end

        local color = COLOR_OPTIONS[index]

        setSetting(module, settingName, color)
        colorButton.BackgroundColor3 = color
    end)

    return row
end

------------------------------------------------------------
-- KEYBIND
------------------------------------------------------------

local function createKeybind(parent, module)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    addCorner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Keybind",
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local keyButton = create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(18, 19, 24),
        BorderSizePixel = 0,
        Text = "None",
        TextColor3 = SubTextColor,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(100, 28),
        Position = UDim2.new(1, -114, 0.5, -14),
        Parent = row,
    })

    addCorner(keyButton, 5)

    local listening = false

    keyButton.MouseButton1Click:Connect(function()
        if listening then
            return
        end

        listening = true
        keyButton.Text = "Press key..."
        keyButton.TextColor3 = Accent

        local connection

        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            if input.KeyCode == Enum.KeyCode.Escape then
                keyButton.Text = "None"
                keyButton.TextColor3 = SubTextColor
                listening = false
                connection:Disconnect()
                return
            end

            local key = input.KeyCode

            keyButton.Text = key.Name
            keyButton.TextColor3 = TextColor
            listening = false

            connection:Disconnect()

            UserInputService.InputBegan:Connect(function(keyInput, processedInput)
                if processedInput then
                    return
                end

                if keyInput.KeyCode == key then
                    toggleModule(module)
                end
            end)
        end)
    end)

    return row
end

------------------------------------------------------------
-- MODULE CARD
------------------------------------------------------------

local function createModule(parent, module)
    local card = create("Frame", {
        BackgroundColor3 = SidebarBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })

    addCorner(card, 8)
    addStroke(card, Color3.fromRGB(40, 41, 49))

    local header = create("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 52),
        Parent = card,
    })

    local name = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = module.Name or "Module",
        TextColor3 = TextColor,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -100, 0, 24),
        Position = UDim2.new(0, 16, 0, 7),
        Parent = header,
    })

    local description = module.Description or ""

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = SubTextColor,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, -110, 0, 16),
        Position = UDim2.new(0, 16, 0, 30),
        Parent = header,
    })

    local arrow = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = SubTextColor,
        TextSize = 24,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromOffset(35, 35),
        Position = UDim2.new(1, -45, 0, 8),
        Parent = header,
    })

    local settingsFrame = create("Frame", {
        BackgroundTransparency = 1,
        Visible = false,
        Size = UDim2.new(1, -24, 0, 0),
        Position = UDim2.new(0, 12, 0, 58),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
    })

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = settingsFrame

    local opened = false

    local function refreshSize()
        if opened then
            task.defer(function()
                local height = settingsFrame.AbsoluteSize.Y
                card.Size = UDim2.new(
                    1,
                    0,
                    0,
                    64 + height
                )
            end)
        else
            card.Size = UDim2.new(1, 0, 0, 52)
        end
    end

    header.MouseButton1Click:Connect(function()
        opened = not opened

        settingsFrame.Visible = opened
        arrow.Text = opened and "⌄" or "›"

        refreshSize()
    end)

    --------------------------------------------------------
    -- SETTINGS
    --------------------------------------------------------

    createToggle(
        settingsFrame,
        module,
        "Enabled",
        "Enabled"
    )

    -- Universal keybind
    createKeybind(settingsFrame, module)

    local settings = module.Settings or {}

    for settingName, value in pairs(settings) do
        if settingName ~= "Enabled" then

            local title = prettyName(settingName)

            if typeof(value) == "boolean" then

                createToggle(
                    settingsFrame,
                    module,
                    settingName,
                    title
                )

            elseif typeof(value) == "number" then

                createNumber(
                    settingsFrame,
                    module,
                    settingName,
                    title
                )

            elseif typeof(value) == "Color3" then

                createColor(
                    settingsFrame,
                    module,
                    settingName,
                    title
                )

            elseif typeof(value) == "string" then

                local options = getDropdownOptions(settingName)

                if options then
                    createDropdown(
                        settingsFrame,
                        module,
                        settingName,
                        title
                    )
                end
            end
        end
    end

    return card
end

------------------------------------------------------------
-- RENDER TAB
------------------------------------------------------------

local function clearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if not child:IsA("UIListLayout")
            and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function renderTab(tabName)
    CurrentTab = tabName

    clearContent()

    for name, button in pairs(TabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Accent
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = SidebarBackground
            button.TextColor3 = SubTextColor
        end
    end

    local modules = Registry:GetByTab(tabName)

    if not modules or #modules == 0 then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Text = "No modules in this tab.",
            TextColor3 = SubTextColor,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.new(1, 0, 0, 40),
            Parent = Content,
        })

        return
    end

    for _, module in ipairs(modules) do
        createModule(Content, module)

        create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 10),
            Parent = Content,
        })
    end
end

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------

local function createSidebar()
    local sidebar = create("Frame", {
        BackgroundColor3 = SidebarBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 175, 1, 0),
        Parent = Main,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "◈ MENU",
        TextColor3 = TextColor,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 18, 0, 14),
        Parent = sidebar,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "EXPOTALITY",
        TextColor3 = SubTextColor,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -30, 0, 18),
        Position = UDim2.new(0, 19, 0, 38),
        Parent = sidebar,
    })

    local tabs = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 1, -85),
        Position = UDim2.new(0, 12, 0, 75),
        Parent = sidebar,
    })

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = tabs

    for index, tabName in ipairs(TAB_ORDER) do
        local button = create("TextButton", {
            BackgroundColor3 = SidebarBackground,
            BorderSizePixel = 0,
            Text = tabName,
            TextColor3 = SubTextColor,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 38),
            LayoutOrder = index,
            Parent = tabs,
        })

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 14)
        padding.Parent = button

        addCorner(button, 6)

        TabButtons[tabName] = button

        button.MouseEnter:Connect(function()
            if CurrentTab ~= tabName then
                button.BackgroundColor3 = ElementHover
            end
        end)

        button.MouseLeave:Connect(function()
            if CurrentTab ~= tabName then
                button.BackgroundColor3 = SidebarBackground
            end
        end)

        button.MouseButton1Click:Connect(function()
            renderTab(tabName)
        end)
    end
end

------------------------------------------------------------
-- TOP BAR / DRAGGING
------------------------------------------------------------

local function createTopBar()
    local topBar = create("Frame", {
        BackgroundColor3 = Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = Main,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "Roblox Hack Menu",
        TextColor3 = TextColor,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 195, 0, 0),
        Parent = topBar,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = "v1.0",
        TextColor3 = SubTextColor,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Size = UDim2.fromOffset(40, 48),
        Position = UDim2.new(1, -85, 0, 0),
        Parent = topBar,
    })

    local close = create("TextButton", {
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = SubTextColor,
        TextSize = 23,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(45, 48),
        Position = UDim2.new(1, -45, 0, 0),
        Parent = topBar,
    })

    close.MouseButton1Click:Connect(function()
        MenuVisible = false
        Main.Visible = false
    end)

    --------------------------------------------------------
    -- DRAGGING
    --------------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------

local function createContent()
    Content = create("ScrollingFrame", {
        BackgroundColor3 = Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 175, 0, 48),
        Size = UDim2.new(1, -175, 1, -48),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Accent,
        Parent = Main,
    })

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = Content
end

------------------------------------------------------------
-- PUBLIC
------------------------------------------------------------

function UI:SelectTab(tabName)
    if TabButtons[tabName] then
        renderTab(tabName)
    end
end

function UI:SetVisible(visible)
    MenuVisible = visible
    Main.Visible = visible
end

function UI:Toggle()
    self:SetVisible(not MenuVisible)
end

function UI:Initialize(registry)
    Registry = registry

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RobloxHackMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)

    if not success or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    Main = create("Frame", {
        BackgroundColor3 = Background,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(760, 500),
        Position = UDim2.new(0.5, -380, 0.5, -250),
        Parent = ScreenGui,
    })

    addCorner(Main, 8)
    addStroke(Main, Color3.fromRGB(45, 46, 54))

    createTopBar()
    createSidebar()
    createContent()

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.Insert then
            self:Toggle()
        end
    end)

    renderTab("Visuals")

    return self
end

return UI
