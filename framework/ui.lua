local UI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Registry
local ScreenGui
local Main
local Content
local TabButtons = {}
local TabPages = {}

local CurrentTab = "Visuals"
local MenuVisible = true

local Accent = Color3.fromRGB(90, 120, 255)
local Background = Color3.fromRGB(15, 16, 20)
local SidebarBackground = Color3.fromRGB(19, 20, 25)
local ElementBackground = Color3.fromRGB(24, 25, 31)
local ElementHover = Color3.fromRGB(30, 32, 40)
local TextColor = Color3.fromRGB(235, 235, 240)
local SubTextColor = Color3.fromRGB(145, 148, 158)

local TAB_ORDER = {
    "Visuals",
    "Movement",
    "Events",
    "Customization",
    "Utilities",
}

local function create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent,
    })
end

local function stroke(parent, color, transparency)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(45, 46, 54),
        Transparency = transparency or 0,
        Thickness = 1,
        Parent = parent,
    })
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function getModuleName(module)
    return module.Name or "Unknown"
end

local function getModuleDescription(module)
    return module.Description or ""
end

local function getModuleSetting(module, name)
    if module.GetSetting then
        return module:GetSetting(name)
    end

    return module.Settings and module.Settings[name]
end

local function setModuleSetting(module, name, value)
    if module.SetSetting then
        module:SetSetting(name, value)
        return
    end

    if module.Settings then
        module.Settings[name] = value
    end
end

local function toggleModule(module)
    local enabled = getModuleSetting(module, "Enabled")

    if enabled then
        if module.Disable then
            module:Disable()
        else
            setModuleSetting(module, "Enabled", false)
        end
    else
        if module.Enable then
            module:Enable()
        else
            setModuleSetting(module, "Enabled", true)
        end
    end
end

local function makeLabel(parent, text, size, color)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or TextColor,
        TextSize = size or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = parent,
    })
end

local function makeButton(parent, text)
    local button = create("TextButton", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 38),
        Parent = parent,
    })

    corner(button, 6)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = ElementHover
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = ElementBackground
    end)

    return button
end

local function createToggle(parent, module, settingName, displayName)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    corner(row, 6)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local toggle = create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(45, 46, 54),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(42, 22),
        Position = UDim2.new(1, -56, 0.5, -11),
        Parent = row,
    })

    corner(toggle, 11)

    local indicator = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(180, 182, 190),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 3, 0.5, -8),
        Parent = toggle,
    })

    corner(indicator, 8)

    local function update()
        local enabled = getModuleSetting(module, settingName) == true

        if enabled then
            toggle.BackgroundColor3 = Accent
            indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            indicator.Position = UDim2.new(1, -19, 0.5, -8)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(45, 46, 54)
            indicator.BackgroundColor3 = Color3.fromRGB(180, 182, 190)
            indicator.Position = UDim2.new(0, 3, 0.5, -8)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        setModuleSetting(module, settingName, not getModuleSetting(module, settingName))
        update()
    end)

    update()

    return row
end

local function createNumber(parent, module, settingName, displayName)
    local value = getModuleSetting(module, settingName)

    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 54),
        Parent = parent,
    })

    corner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.55, 0, 0, 28),
        Position = UDim2.new(0, 14, 0, 4),
        Parent = row,
    })

    local input = create("TextBox", {
        BackgroundColor3 = Color3.fromRGB(18, 19, 24),
        BorderSizePixel = 0,
        Text = tostring(value),
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromOffset(70, 28),
        Position = UDim2.new(1, -84, 0, 8),
        Parent = row,
    })

    corner(input, 5)

    input.FocusLost:Connect(function()
        local number = tonumber(input.Text)

        if number then
            setModuleSetting(module, settingName, number)
            input.Text = tostring(number)
        else
            input.Text = tostring(getModuleSetting(module, settingName))
        end
    end)

    return row
end

local function createDropdown(parent, module, settingName, displayName)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    corner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local button = create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(18, 19, 24),
        BorderSizePixel = 0,
        Text = tostring(getModuleSetting(module, settingName)),
        TextColor3 = TextColor,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(130, 28),
        Position = UDim2.new(1, -144, 0.5, -14),
        Parent = row,
    })

    corner(button, 5)

    local options

    if settingName == "BoxStyle" then
        options = {"Corner", "Full"}
    elseif settingName == "NameMode" then
        options = {"DisplayName", "Username"}
    else
        options = {}
    end

    local index = 1

    for i, option in ipairs(options) do
        if option == getModuleSetting(module, settingName) then
            index = i
            break
        end
    end

    button.MouseButton1Click:Connect(function()
        if #options == 0 then
            return
        end

        index += 1

        if index > #options then
            index = 1
        end

        local selected = options[index]

        setModuleSetting(module, settingName, selected)
        button.Text = selected
    end)

    return row
end

local function createColor(parent, module, settingName, displayName)
    local row = create("Frame", {
        BackgroundColor3 = ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = parent,
    })

    corner(row, 6)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = TextColor,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = row,
    })

    local colorButton = create("TextButton", {
        BackgroundColor3 = getModuleSetting(module, settingName),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(32, 24),
        Position = UDim2.new(1, -46, 0.5, -12),
        Parent = row,
    })

    corner(colorButton, 5)
    stroke(colorButton, Color3.fromRGB(80, 81, 90))

    local colors = {
        Color3.fromRGB(255, 25, 25),
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(255, 170, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 100),
        Color3.fromRGB(0, 200, 255),
        Color3.fromRGB(90, 120, 255),
        Color3.fromRGB(180, 80, 255),
        Color3.fromRGB(255, 80, 180),
        Color3.fromRGB(255, 255, 255),
    }

    local index = 1

    for i, color in ipairs(colors) do
        local current = getModuleSetting(module, settingName)

        if current and color == current then
            index = i
            break
        end
    end

    colorButton.MouseButton1Click:Connect(function()
        index += 1

        if index > #colors then
            index = 1
        end

        local color = colors[index]

        setModuleSetting(module, settingName, color)
        colorButton.BackgroundColor3 = color
    end)

    return row
end

local function createModuleHeader(parent, module)
    local header = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 58),
        Parent = parent,
    })

    makeLabel(
        header,
        getModuleName(module),
        17,
        TextColor
    ).Size = UDim2.new(1, 0, 0, 25)

    local description = getModuleDescription(module)

    if description ~= "" then
        local desc = makeLabel(
            header,
            description,
            12,
            SubTextColor
        )

        desc.Position = UDim2.new(0, 0, 0, 26)
        desc.Size = UDim2.new(1, 0, 0, 22)
    end

    return header
end

local function createModule(parent, module)
    local container = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })

    createModuleHeader(container, module)

    createToggle(
        container,
        module,
        "Enabled",
        "Enabled"
    )

    local settings = module.Settings or {}

    for name, value in pairs(settings) do
        if name ~= "Enabled" then
            local displayName = name:gsub("(%l)(%u)", "%1 %2")

            if typeof(value) == "boolean" then
                createToggle(
                    container,
                    module,
                    name,
                    displayName
                )

            elseif typeof(value) == "number" then
                createNumber(
                    container,
                    module,
                    name,
                    displayName
                )

            elseif typeof(value) == "Color3" then
                createColor(
                    container,
                    module,
                    name,
                    displayName
                )

            elseif typeof(value) == "string" then
                if name == "BoxStyle" or name == "NameMode" then
                    createDropdown(
                        container,
                        module,
                        name,
                        displayName
                    )
                end
            end

            create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 6),
                Parent = container,
            })
        end
    end

    return container
end

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
        local empty = makeLabel(
            Content,
            "No modules in this tab.",
            14,
            SubTextColor
        )

        empty.TextXAlignment = Enum.TextXAlignment.Center
        return
    end

    for _, module in ipairs(modules) do
        createModule(Content, module)

        create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Parent = Content,
        })
    end
end

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
        Size = UDim2.new(1, -30, 0, 50),
        Position = UDim2.new(0, 18, 0, 10),
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
        Position = UDim2.new(0, 19, 0, 39),
        Parent = sidebar,
    })

    local tabs = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 1, -90),
        Position = UDim2.new(0, 12, 0, 80),
        Parent = sidebar,
    })

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabs,
    })

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

        padding(button, 14, 10, 0, 0)
        corner(button, 6)

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

local function createTopBar()
    local topBar = create("Frame", {
        BackgroundColor3 = Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = Main,
    })

    local title = create("TextLabel", {
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
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.fromOffset(45, 48),
        Position = UDim2.new(1, -90, 0, 0),
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

    close.MouseEnter:Connect(function()
        close.TextColor3 = Color3.fromRGB(255, 80, 80)
    end)

    close.MouseLeave:Connect(function()
        close.TextColor3 = SubTextColor
    end)

    close.MouseButton1Click:Connect(function()
        MenuVisible = false
        Main.Visible = false
    end)

    local dragging = false
    local dragStart
    local startPosition

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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

    padding(Content, 22, 22, 20, 20)

    create("UIListLayout", {
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Content,
    })
end

function UI:SelectTab(tabName)
    if TabPages[tabName] ~= nil or TabButtons[tabName] then
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

    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)

    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    Main = create("Frame", {
        BackgroundColor3 = Background,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(760, 500),
        Position = UDim2.new(0.5, -380, 0.5, -250),
        Parent = ScreenGui,
    })

    corner(Main, 8)
    stroke(Main, Color3.fromRGB(45, 46, 54))

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
