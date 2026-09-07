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
-- GET MODULE
------------------------------------------------------------

function Registry:Get(Name)
    return self.Modules[Name]
end

------------------------------------------------------------
-- GET ALL MODULES
------------------------------------------------------------

function Registry:GetAll()
    return self.Modules
end

------------------------------------------------------------
-- GET MODULES BY TAB
------------------------------------------------------------

function Registry:GetByTab(Tab)
    return self.ByTab[Tab] or {}
end

------------------------------------------------------------
-- ENABLE / DISABLE
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

    if not Module then
        return false
    end

    if not Module.Settings then
        return false
    end

    local Enabled = Module.Settings.Enabled

    if Enabled then
        return self:Disable(Name)
    else
        return self:Enable(Name)
    end
end

------------------------------------------------------------
-- SETTING MANAGEMENT
------------------------------------------------------------

function Registry:SetSetting(Name, Setting, Value)
    local Module = self:Get(Name)

    if not Module then
        return false
    end

    if Module.SetSetting then
        return Module:SetSetting(Setting, Value)
    end

    if Module.Settings then
        if Module.Settings[Setting] == nil then
            return false
        end

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
