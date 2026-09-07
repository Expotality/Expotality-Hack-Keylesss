local Module = {}

Module.Name = "Customization"
Module.Description = "Customize the appearance of the menu."

------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------

Module.Settings = {
    Enabled = true,
    Theme = "Ocean",
}

------------------------------------------------------------
-- DROPDOWN OPTIONS
------------------------------------------------------------

Module.DropdownOptions = {
    Theme = {
        "Ocean",
        "Purple",
        "Pink",
        "Crimson",
        "Monochrome",
    },
}

------------------------------------------------------------
-- THEMES
------------------------------------------------------------

Module.Themes = {

    --------------------------------------------------------
    -- OCEAN
    --------------------------------------------------------

    Ocean = {
        Accent = Color3.fromRGB(90, 120, 255),

        Background = Color3.fromRGB(15, 16, 20),
        SidebarBackground = Color3.fromRGB(19, 20, 25),

        ElementBackground = Color3.fromRGB(24, 25, 31),
        ElementHover = Color3.fromRGB(31, 33, 41),

        TextColor = Color3.fromRGB(235, 235, 240),
        SubTextColor = Color3.fromRGB(145, 148, 158),

        BorderColor = Color3.fromRGB(43, 44, 52),
    },

    --------------------------------------------------------
    -- PURPLE
    --------------------------------------------------------

    Purple = {
        Accent = Color3.fromRGB(160, 90, 255),

        Background = Color3.fromRGB(16, 14, 20),
        SidebarBackground = Color3.fromRGB(21, 18, 27),

        ElementBackground = Color3.fromRGB(27, 23, 34),
        ElementHover = Color3.fromRGB(37, 31, 46),

        TextColor = Color3.fromRGB(240, 235, 245),
        SubTextColor = Color3.fromRGB(160, 150, 175),

        BorderColor = Color3.fromRGB(50, 43, 60),
    },

    --------------------------------------------------------
    -- PINK
    --------------------------------------------------------

    Pink = {
        Accent = Color3.fromRGB(255, 80, 170),

        Background = Color3.fromRGB(20, 14, 18),
        SidebarBackground = Color3.fromRGB(27, 18, 24),

        ElementBackground = Color3.fromRGB(35, 23, 31),
        ElementHover = Color3.fromRGB(47, 30, 41),

        TextColor = Color3.fromRGB(245, 235, 242),
        SubTextColor = Color3.fromRGB(175, 150, 165),

        BorderColor = Color3.fromRGB(60, 42, 52),
    },

    --------------------------------------------------------
    -- CRIMSON
    --------------------------------------------------------

    Crimson = {
        Accent = Color3.fromRGB(255, 55, 65),

        Background = Color3.fromRGB(20, 13, 14),
        SidebarBackground = Color3.fromRGB(27, 17, 18),

        ElementBackground = Color3.fromRGB(35, 22, 23),
        ElementHover = Color3.fromRGB(48, 28, 30),

        TextColor = Color3.fromRGB(245, 235, 235),
        SubTextColor = Color3.fromRGB(175, 150, 152),

        BorderColor = Color3.fromRGB(62, 40, 42),
    },

    --------------------------------------------------------
    -- MONOCHROME
    --------------------------------------------------------

    Monochrome = {
        Accent = Color3.fromRGB(220, 220, 220),

        Background = Color3.fromRGB(12, 12, 12),
        SidebarBackground = Color3.fromRGB(18, 18, 18),

        ElementBackground = Color3.fromRGB(25, 25, 25),
        ElementHover = Color3.fromRGB(35, 35, 35),

        TextColor = Color3.fromRGB(240, 240, 240),
        SubTextColor = Color3.fromRGB(145, 145, 145),

        BorderColor = Color3.fromRGB(45, 45, 45),
    },
}

------------------------------------------------------------
-- SETTINGS API
------------------------------------------------------------

function Module:GetSetting(name)
    return self.Settings[name]
end

function Module:SetSetting(name, value)

    if self.Settings[name] == nil then
        return
    end

    self.Settings[name] = value

    if name == "Theme" then
        self:ApplyTheme()
    end
end

------------------------------------------------------------
-- DROPDOWN API
------------------------------------------------------------

function Module:GetDropdownOptions(name)

    return self.DropdownOptions[name]
end

------------------------------------------------------------
-- THEME API
------------------------------------------------------------

function Module:GetTheme()

    return self.Themes[self.Settings.Theme]
end

function Module:GetThemes()

    return self.Themes
end

function Module:ApplyTheme()

    local theme = self:GetTheme()

    if not theme then
        return
    end

    self.CurrentTheme = theme

    if self._UI then
        self._UI:ApplyTheme(theme)
    end
end

------------------------------------------------------------
-- MODULE API
------------------------------------------------------------

function Module:Enable()

    self.Settings.Enabled = true

    self:ApplyTheme()
end

function Module:Disable()

    self.Settings.Enabled = false
end

function Module:Initialize()

    self:ApplyTheme()
end

return Module
