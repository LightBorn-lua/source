SharedData = {}

local Rep = game:GetService("ReplicatedStorage")
local Http = game:GetService("HttpService")
local module = {}

local Parts = script.Parent
local src = Parts.Parent
local Root = src.Parent
-----------------
local Models = src.Models
local Helpers = Root.Helpers
local Modules = Root.Modules

local Logger = require(Modules.Logger)

local System = require(Models.System)
local Controller = require(Models.Controller)
local TaskModule = require(Models.Task)
local Siren = require(Models.Siren)
local Helper = require(Helpers.Helper)
local LightoModule = require(Parts.Lighto)
local Types = require(Modules.Types)

local Shared = Rep:WaitForChild("LB_Shared", 3)
local Shared_Modules = Shared.Modules
local LightoHandler = require(Shared_Modules:FindFirstChild("LightoHandler") :: ModuleScript)

local RequiredValues = {
	["Alt"] = {
		["IsStatus"] = false,
		["IsNormal"] = true,
		["Type"] = "number"
	},
	["Dir"] = {
		["IsStatus"] = true,
		["IsNormal"] = true,
		["Type"] = "number"
	},
	["Stage"] = {
		["IsStatus"] = true,
		["IsNormal"] = true,
		["Type"] = "number"
	}
}

function TableConcat(t1: {}, t2: {})
	for n,v in t2 do
		t1[n] = v
	end
	return t1
end

System.Initializer = module

module.InitializeScript = function()
	print([[
	LightBorn  Copyright (C) 2025-2026  ErrorCezar
    This program comes with ABSOLUTELY NO WARRANTY; for details refer to the file "COPYING".
    This is free software, and you are welcome to redistribute it
    under certain conditions; for details refer to the file "COPYING".
    ]])
end

module.InitializeVehicle = function(Vehicle: Model, Connections: {[string]: () -> ()})
	local data = System.new()
	data.SurfaceElements = {}
	data.System = Vehicle
	
	data.InitConnections = Connections or {}
	
	local success, Settings: Helper.Config = pcall(function()
		return require(Vehicle:FindFirstChild("Settings") :: ModuleScript)
	end)
	
	if not success then
		Logger.warn("Error on settings loading ::", Settings)
		return
	end
	
	local CT = Settings.CustomTypes
	if typeof(CT) ~= "table" then
		CT = {}
	end
	
	data.DefaultLightProp = Settings.LightProperties or {
		["Brightness"] = 12,
		["Range"] = 50
	}

	Settings.DefaultPriority = Settings.DefaultPriority or 1

	Settings.Priority = Settings.Priority or {
		Stage = 0,
		Dir = -1
	}
	
	data.Settings = success and Settings or {}
	data.SpecialNames = {}
	Vehicle:SetAttribute("LB_ID", data.ID)
	
	local Values = Instance.new("Folder")
	Values.Name = "Values"
	
	for n,v in TableConcat(RequiredValues, CT) do
		local InsType = Types.Instances[v["Type"]]
		if not InsType then Logger.warn("Type is invalid for", n); continue end
		local Val = Instance.new(InsType)
		Val.Name = n
		Val.Parent = Values
		Val:SetAttribute("IsStatus", v["IsStatus"])
		if not v["IsNormal"] then
			data.SpecialNames:Insert(n)
		end
		Val.Parent = Values
	end
	
	Values.Parent = Vehicle
	
	for n,v in Controller do
		data[n] = v
	end
	
	for n,v in Siren do
		data[n] = v
	end
	
	for n,v in TaskModule do
		data[n] = v
	end
	
	data:Int_Lightos()
	data:InitializeModules(Vehicle:FindFirstChild("Modules"))
	
	data:InitializeSurfaceControl()
	
	Values.Stage.Value = Settings.DefaultStage or 0
	Values.Dir.Value = Settings.DefaultDir or 0
	
	data.CurrentStage = Values.Stage.Value
	data.CurrentDir = Values.Dir.Value
	
	data.MaxStage = Settings.MaxStage or 3
	data.MaxDir = Settings.MaxDir or 3
	
	local StatusRun = function(Name: string, Val: any)
		if Name == "Stage" or Name == "Dir" then
			data["Current"..Name] = Val
		end
		
		if data.SurfaceElements[Name] then
			local Turned = {}
			for StageID,content in data.SurfaceElements[Name]._getTable do
				for _,v: BasePart in content do
					if table.find(Turned, v) then continue end
					if StageID ~= Val then
						v.Transparency = 1
					else
						table.insert(Turned, v)
						v.Transparency = 0
					end
				end
			end
		end
			
		data:ChangeStatus(Name, Val)
	end
	
	-- General check case for all values marked as status
	for _,v in Values:GetChildren() do
		if not v:IsA("ValueBase") or not v:GetAttribute("IsStatus") then continue end
		
		v.Changed:Connect(function(val: any)
			StatusRun(v.Name, val)
		end)
	end
	
	
	-- Special check case for Alt
	Values.Alt.Changed:Connect(function(Val: number)
		data.CurrentAlt = Val
		for _,v in Values:GetChildren() do
			if not v:IsA("ValueBase") or not v:GetAttribute("IsStatus") then continue end
			StatusRun(v.Name, v.Value)
		end
	end)
	
	data.CurrentAlt = Values.Alt.Value
	
	-- Manual run for each values
	for _,v in Values:GetChildren() do
		if not v:IsA("ValueBase") or not v:GetAttribute("IsStatus") then continue end
		StatusRun(v.Name, v.Value)
	end

	data:IntializeSiren()
	
	data:InitializeController()
	
	return data
end

function EncodeColorTable(Table: {})
	local res = {}
	for n,v in Table do
		res[n] = {v.R, v.G, v.B}
	end
	return Http:JSONEncode(res)
end

module.InitializeLight = function(Vehicle: Helper.SystemData, Light: BasePart)
	local LType = Light:GetAttribute("Type")
	if not LType or typeof(LType) ~= "string" then LType = "N/A" end

	local LightoType = string.lower(LType)
	Light:SetAttribute("Type", LightoType)
	
	for _,v in Light:GetChildren() do
		if not v:GetAttribute("NoRemove") then
			v:Destroy()
		end
	end
	
	local CustomFace = Light:GetAttribute("Face") or (Vehicle.Settings.Face or nil)
	local LightoName = Light:GetAttribute("Lighto") or (Vehicle.Settings.Lighto or "Default")
	
	local ColorValue = Instance.new("StringValue")
	ColorValue.Name = "ColorValue"
	ColorValue.Parent = Light
	
	if LightoType == "effect" then
		local Effect: SurfaceGui = SharedData.Effects[LightoName] or SharedData.Effects.Default
		local EffectClone: SurfaceGui = Effect:Clone()
		
		local StatusValue = Instance.new("BoolValue")
		StatusValue.Name = "Status"
		StatusValue.Parent = Light

		local LightValue = Instance.new("NumberValue")
		LightValue.Name = "LightValue"
		LightValue.Parent = Light
		LightValue.Value = -1
		
		EffectClone.Parent = Light
		EffectClone.Name = "Lighto"
	elseif LightoType == "part" then
		local LightValue = Instance.new("NumberValue")
		LightValue.Name = "LightValue"
		LightValue.Parent = Light
		LightValue.Value = -1
		
		local BrightValue = Instance.new("NumberValue")
		BrightValue.Name = "BrightValue"
		BrightValue.Parent = Light
		BrightValue.Value = -1
	else
		local LightValue = Instance.new("NumberValue")
		LightValue.Name = "LightValue"
		LightValue.Parent = Light
		LightValue.Value = -1

		local BrightValue = Instance.new("NumberValue")
		BrightValue.Name = "BrightValue"
		BrightValue.Parent = Light
		BrightValue.Value = -1

		local Lighto: SurfaceGui = SharedData.Lightos[LightoName] or SharedData.Lightos.Default
		local LightoClone: SurfaceGui = Lighto:Clone()
		
		LightoClone.Face = CustomFace or LightoClone.Face
		CustomFace = LightoClone.Face
		
		LightoClone.Parent = Light
		LightoClone.Name = "Lighto"
	end

	LightoModule.new(Vehicle, Light, CustomFace or Enum.NormalId.Back)
	
	local Colors = Vehicle.Settings.Colors._getTable
	local Renderer = Vehicle.Settings.Renderer or SharedData.Settings.Renderer or "Server"
	if Renderer == "Server" then
		LightoHandler(Light, Colors)
	else
		Light:AddTag("LB_LIGHT_CLIENT")
		Light:SetAttribute("Colors", EncodeColorTable(Colors))
	end
	
	for _,v in SharedData.Extras.Lighto do
		v(Light, Vehicle)
	end
end

return function()
	return module
end
