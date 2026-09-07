local Registry = {}

Registry.Modules = {}
Registry.ByTab = {}

------------------------------------------------------------
-- REGISTER
------------------------------------------------------------

function Registry:Register(Module)
    if not Module or not Module.Name then
        warn("[Registry] Invalid module.")
        return false
    end

    if self.Modules[Module.Name] then
        warn("[Registry] Module already registered: " .. Module.Name)
        return false
    end

    self.Modules[Module.Name] = Module

    local Tab = Module.Tab or "Utilities"

    if not self.ByTab[Tab] then
        self.ByTab[Tab] = {}
    end

    table.insert(self.ByTab[Tab], Module)

    print("[Registry] Registered: " .. Module.Name .. " [" .. Tab .. "]")

    return true
end

------------------------------------------------------------
-- LOAD MANIFEST
------------------------------------------------------------

function Registry:LoadManifest(Manifest, BaseURL)
    if type(Manifest) ~= "table" then
        warn("[Registry] Invalid manifest.")
        return false
    end

    for _, Entry in ipairs(Manifest) do
        if Entry.File then
            local URL = BaseURL .. Entry.File

            local Success, Source = pcall(function()
                return game:HttpGet(URL)
            end)

            if not Success then
                warn("[Registry] Failed to download: " .. Entry.File)
                warn(tostring(Source))
                continue
            end

            local LoadSuccess, Module = pcall(function()
                return loadstring(Source)()
            end)

            if not LoadSuccess then
                warn("[Registry] Failed to load: " .. Entry.File)
                warn(tostring(Module))
                continue
            end

            if not Module then
                warn("[Registry] Module returned nil: " .. Entry.File)
                continue
            end

            if Entry.Name then
                Module.Name = Entry.Name
            end

            if Entry.Tab then
                Module.Tab = Entry.Tab
            end

            self:Register(Module)
        end
    end

    return true
end

------------------------------------------------------------
-- UNREGISTER
------------------------------------------------------------

function Registry:Unregister(Name)
    local Module = self.Modules[Name]

    if not Module then
        return false
    end

    if Module.Destroy then
        Module:Destroy()
    end

    self.Modules[Name] = nil

    for Tab, Modules in pairs(self.ByTab) do
        for Index, RegisteredModule in ipairs(Modules) do
            if RegisteredModule == Module then
                table.remove(Modules, Index)
                break
            end
        end

        if #Modules == 0 then
            self.ByTab[Tab] = nil
        end
    end

    return true
end

------------------------------------------------------------
-- GET
------------------------------------------------------------

function Registry:Get(Name)
    return self.Modules[Name]
end

function Registry:GetAll()
    return self.Modules
end

function Registry:GetByTab(Tab)
    return self.ByTab[Tab] or {}
end

------------------------------------------------------------
-- ENABLE / DISABLE / TOGGLE
------------------------------------------------------------

function Registry:Enable(Name)
    local Module = self:Get(Name)

    if not Module then
        return false
    end

    if Module.Enable then
        Module:Enable()
        return true
    end

    return false
end

function Registry:Disable(Name)
    local Module = self:Get(Name)

    if not Module then
        return false
    end

    if Module.Disable then
        Module:Disable()
        return true
    end

    return false
end

function Registry:Toggle(Name)
    local Module = self:Get(Name)

    if not Module or not Module.Settings then
        return false
    end

    if Module.Settings.Enabled then
        return self:Disable(Name)
    else
        return self:Enable(Name)
    end
end

------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------

function Registry:SetSetting(Name, Setting, Value)
    local Module = self:Get(Name)

    if not Module then
        return false
    end

    if Module.SetSetting then
        return Module:SetSetting(Setting, Value)
    end

    if Module.Settings and Module.Settings[Setting] ~= nil then
        Module.Settings[Setting] = Value
        return true
    end

    return false
end

function Registry:GetSetting(Name, Setting)
    local Module = self:Get(Name)

    if not Module or not Module.Settings then
        return nil
    end

    return Module.Settings[Setting]
end

------------------------------------------------------------
-- DEBUG
------------------------------------------------------------

function Registry:PrintModules()
    print("========== MODULE REGISTRY ==========")

    for Tab, Modules in pairs(self.ByTab) do
        print("[" .. Tab .. "]")

        for _, Module in ipairs(Modules) do
            print("  • " .. Module.Name)
        end
    end

    print("=====================================")
end

return Registry
