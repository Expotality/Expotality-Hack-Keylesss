local BASE_URL = "https://raw.githubusercontent.com/Expotality/Expotality-Hack-Keylesss/main/"

local function fetch(path)
    return game:HttpGet(BASE_URL .. path)
end

local function load(path)
    local source = fetch(path)
    local fn = loadstring(source)

    if not fn then
        error("Failed to compile: " .. path)
    end

    return fn()
end

------------------------------------------------------------
-- LOAD CORE
------------------------------------------------------------

local manifest = load("manifest.lua")
local registry = load("framework/registry.lua")

------------------------------------------------------------
-- LOAD MODULES
------------------------------------------------------------

for _, entry in ipairs(manifest) do

    local success, module = pcall(function()
        return load(entry.File)
    end)

    if success and module then

        -- Manifest controls the tab.
        module.Tab = entry.Tab

        registry:Register(module)

        if module.Initialize then
            pcall(function()
                module:Initialize()
            end)
        end

    else
        warn("[Menu] Failed to load: " .. tostring(entry.File))
        warn(module)
    end
end

------------------------------------------------------------
-- LOAD UI
------------------------------------------------------------

local success, ui = pcall(function()
    return load("framework/ui.lua")
end)

if not success then
    error("[Menu] UI failed to load: " .. tostring(ui))
end

------------------------------------------------------------
-- CONNECT CUSTOMIZATION
------------------------------------------------------------

local customization = registry:Get("Customization")

if customization then
    customization._UI = ui

    if customization.ApplyTheme then
        pcall(function()
            customization:ApplyTheme()
        end)
    end
end

print("[Menu] Loaded successfully")
