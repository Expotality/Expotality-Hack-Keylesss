local UI = {}

function UI:Initialize(registry)

    self.Registry = registry

    print("================================")
    print("        MODULAR MENU")
    print("================================")

    for tabName, modules in pairs(registry:GetTabs()) do

        print("")
        print("TAB:", tabName)

        for _, module in ipairs(modules) do

            if module.Loaded then

                print("  ✓", module.Name)

            else

                print("  ✗", module.Name)

            end

        end
    end

    print("")
    print("================================")

end

return UI
