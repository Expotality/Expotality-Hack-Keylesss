local Registry = {}

Registry.Modules = {}
Registry.Tabs = {}

function Registry:LoadManifest(manifest, baseURL)

    self.Modules = {}
    self.Tabs = {}

    for _, info in ipairs(manifest) do

        local module = {
            Name = info.Name,
            File = info.File,
            Tab = info.Tab,
            Loaded = false,
            Error = nil,
            Data = nil,
        }

        local success, result = pcall(function()

            local source = game:HttpGet(baseURL .. info.File)

            local compiled = loadstring(source)

            if not compiled then
                error("loadstring failed")
            end

            return compiled()

        end)

        if success and type(result) == "table" then

            module.Data = result
            module.Loaded = true

            print("[Menu] Loaded:", info.Name)

        else

            module.Error = result

            warn(
                "[Menu] Failed:",
                info.Name,
                tostring(result)
            )

        end

        table.insert(self.Modules, module)

        if not self.Tabs[info.Tab] then
            self.Tabs[info.Tab] = {}
        end

        table.insert(self.Tabs[info.Tab], module)
    end

    return self
end

function Registry:GetTab(tabName)
    return self.Tabs[tabName]
end

function Registry:GetTabs()
    return self.Tabs
end

function Registry:GetModules()
    return self.Modules
end

return Registry
