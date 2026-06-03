local Parts = script.Parent
local src = Parts.Parent
local Root = src.Parent
-----------------
local Helpers = Root.Helpers
local Modules = Root.Modules
local Logger = require(Modules.Logger)
local Helper = require(Helpers.Helper)

local module = {}

local DefaultConfig: Helper.Config = {
    Colors = {
        ["Red"] = Color3.fromRGB(150, 0, 0),
        ["Blue"] = Color3.fromRGB(0, 30, 150),
        ["White"] = Color3.fromRGB(252, 252, 252),
        ["Amber"] = Color3.fromRGB(213, 115, 61)
    };
    LightProperties = {
		["Brightness"] = 12,
		["Range"] = 50
	};

    DefaultStage = 0;
    DefaultDir = 0;

    MaxStage = 3;
    MaxDir = 3;
    
    DefaultPriority = 1;
    Priority = {
		Stage = 0,
		Dir = -1
	};

} :: Helper.Config

function module.ValidateConfig(Configuration: {}?)
    local ConfigToCheck = Configuration or {}
    local ValidatedConfig = {}

    for key, value in DefaultConfig do
        local ConfigValue = ConfigToCheck[key]
        if ConfigValue == nil then
            ValidatedConfig[key] = value
            continue
        end

        if typeof(ConfigValue) ~= typeof(value) then
            Logger.warn(`Invalid type for config key {key} (expected {typeof(value)}, got {typeof(ConfigValue)})`)
            ValidatedConfig[key] = value
        else
            ValidatedConfig[key] = ConfigValue
        end
    end

    for key, value in ConfigToCheck do
        if not ValidatedConfig[key] then
            ValidatedConfig[key] = value
        end
    end
    
    return ValidatedConfig
end

return module