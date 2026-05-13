--[[

	-- LightBorn --
	
	- LightBorn, a fully fleshed and centralized Emergency Lighting System controller.
	
	- DISCLAIMER:
		- This project has been built from the ground up, all the code written (external modules excluded) is licensed to the author of LightBorn.
		- LightBorn is its own entity, and is not related to any other product or company.
	
	--------------------------------------------------------------------------------
	
	LightBorn - a fully fleshed and centralized Emergency Lighting System controller.
    Copyright (C) 2025-2026  ErrorCezar

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
	--------------------------------------------------------------------------------
	
]]--

-- // SERVICES \\ --
local Players = game:GetService("Players")
local SS      = game:GetService("ServerStorage")
local RS      = game:GetService("ReplicatedStorage")
local CS      = game:GetService("CollectionService")
local SP      = game:GetService("StarterPlayer")

-- // DEPENDANCES \\ --
local Modules = script.Modules
local Helpers = script.Helpers

local Assets = Instance.new("Folder")
Assets.Name = "Assets"
Assets.Parent = script

local src = script.src
local Game_Assets = script.Game_Assets
local Parts = src.Parts

local Logger = require(Modules.Logger)
local MT = require(Modules.MetaTable)
local Helper = require(Helpers.Helper)

-- // SETTINGS CHECK  \\ --
local LB_Settings = SS:FindFirstChild("LB_Settings")

if not LB_Settings then
	LB_Settings = Game_Assets["default-settings"]
	LB_Settings.Name = "LB_Settings"
	LB_Settings.Parent = SS
	Logger.warn("LB_Settings not found in ServerStorage, using default settings")
end

local SettingModule = LB_Settings:FindFirstChild("Settings") :: ModuleScript?

if not SettingModule then
	Logger.error("Settings module not found in LB_Settings")
	return
end

local Settings = require(SettingModule)

local Shared = Game_Assets.Shared
Shared.Parent = RS
Shared.Name = "LB_Shared"

-- // CLIENT INITIATION \\ --
local LB_CLIENT = Game_Assets.LB_CLIENT
LB_CLIENT:Clone().Parent = SP.StarterPlayerScripts

for _,v in Players:GetPlayers() do
	local PlayerGui = v:WaitForChild("PlayerGui", 3)
	if not PlayerGui then continue end

	local UI = Instance.new("ScreenGui")
	UI.Name = "LB_CLIENT_FALLBACK"

	LB_CLIENT:Clone().Parent = UI
	UI.Parent = v:WaitForChild("PlayerGui", 3)
end

-- // SYSTEM VALUES \\ --
local AllowedLocations = Settings.AllowedLocations or {workspace}

local SystemData: MT.MetaTable<{[string]: Helper.SystemData}> = MT.new({})
local DecendantsConnection: MT.MetaTable<{[Instance]: RBXScriptConnection}> = MT.new({})

-- // DEFAULT INSTANCES + CUSTOMS \\ --
local Lightos = {}
local CustomLighto = LB_Settings.Types:FindFirstChild("Lighto")

for _,v in CustomLighto and CustomLighto:GetChildren() or {} do
	Lightos[v.Name] = v
end

local Effects = {}
local CustomEffect = LB_Settings.Types:FindFirstChild("Effect")

for _,v in CustomEffect and CustomEffect:GetChildren() or {} do
	Effects[v.Name] = v
end

-- // EXTRAS \\ --
local Extras = { 
	["Lighto"] = {},
	["Stage"] = {},
	["Dir"] = {},
	["Siren"] = {},
	["Special"] = {}
	
}
local ExtraList = LB_Settings:FindFirstChild("Extra")

for _,Module in ExtraList and ExtraList:GetChildren() or {} do
	local status, result = pcall(require, Module)
	if not status then
		Logger.warn(Module.Name, "failed to load extra ->", result);
		return nil
	end

	local Name, Extra = result.Name, result.Execute
	if not Name or not Extra then
		Logger.warn(Module.Name, "Couldn't to load extra ->", "no name or execute");
		continue
	end

	if not Extras[Name] then
		Logger.warn(Module.Name, "Extra '", Name, "' doesn't exist");
		continue
	end

	table.insert(Extras[Name], Extra)	
end

-- // SHARED VALUES \\ --
local _SharedData = {
	Settings = Settings,
	MT = MT
}

_SharedData["root"] = script
_SharedData["Lightos"] = Lightos
_SharedData["Extras"] = Extras
_SharedData["Shared"] = Shared
_SharedData["Effects"] = Effects
_SharedData["SetupPart"] = SetupPart

-- // LOGIC FUNCTIONS \\ --
function OnModuleUpdate(CarData, Module, ID)
	-- loop every functions
	local ToRun = {}
	for Name, Data in Module.Data do
		if (Data.Stopped and not Data.Running) and Module.Tasks[Name] then
			-- Logger.warn("Killing task", Name, "//", ID)
			CarData:KillTask(ID, Name)
			continue
		end

		if (Data.Started and not Data.Running and not Data.Stopped) or (Data.Started and not Data.Running and Data.Ended and not Data.Stopped) then
			--Logger.warn("Running task", Name, "//", ID)
			table.insert(ToRun, {ID, Name, Module.Content[Name]})
		end
	end

	for _,v in ToRun do
		local RunID, Name, Task = v[1], v[2], v[3]
		CarData:CreateTask(RunID, Name, Task)
	end
end

function DecendantsCheck(Ins: Instance)
	for _,v in AllowedLocations do
		if Ins:IsDescendantOf(v) then return true end
	end
	return false
end

function SetupPart(Module: ModuleScript) : {} | nil
	local status, result = pcall(require, Module)
	if not status then
		Logger.warn(Module.Name, "failed to load part ->", result);
		return nil
	end
	local env = getfenv(result)
	
	env._SharedData = _SharedData
	
	return result()
end

-- // SYSTEM INITIATION \\ --
local Initializer = SetupPart(Parts.Initializer)
local GameAssets = SetupPart(Parts.GameAssets)

local SirenValues = Instance.new("Folder")
SirenValues.Name = "SirenValues"
SirenValues.Parent = Assets

Initializer.InitializeScript()
GameAssets.SetUpSharedHandler(Shared)
GameAssets.GenerateSirenValues(SirenValues)

function RemoveVehicle(Ins: Instance)
	if not Ins then return end
	if not Ins:HasTag(Settings.SystemName) then return end
	
	--Logging.warn("Running remove on", Ins)
	if DecendantsConnection[Ins] then
		DecendantsConnection[Ins]:Disconnect()
		DecendantsConnection:Remove(Ins)
	end

	local ID = Ins:GetAttribute("LB_ID") :: string
	
	local Data = SystemData[ID]
	if not Data then return end
	Ins:RemoveTag(Settings.SystemName)
	SystemData:Remove(Data.ID)
	Data:CleanUp()
end

function CreateVehicle(Ins: Instance)
	--Logging.warn("Running create on", Ins)
	if DecendantsConnection[Ins] then
		DecendantsConnection[Ins]:Disconnect()
		DecendantsConnection:Remove(Ins)
	end
	
	local Data: Helper.SystemData = Initializer.InitializeVehicle(Ins, {
		["TaskUpdate"] = OnModuleUpdate
	})
	if not Data then return end
	
	SystemData[Data.ID] = Data
	
	DecendantsConnection[Ins] = Ins.AncestryChanged:Connect(function(child: Instance, parent: Instance?) 
		if parent == nil then
			DecendantsConnection[Ins]:Disconnect()
			DecendantsConnection:Remove(Ins)
			return
		end	
		
		if DecendantsCheck(child) then return end
		RemoveVehicle(Ins)
	end)
end

function OnTag(Ins: Instance)
	-- Logging.print("New tag", Ins)
	if not DecendantsCheck(Ins) then
		-- Logging.print("Invalid parent, starting connection")
		DecendantsConnection[Ins] = Ins.AncestryChanged:Connect(function(child: Instance, parent: Instance?) 
			-- Logging.print("new parent")
			if parent == nil then
				DecendantsConnection[Ins]:Disconnect()
				DecendantsConnection:Remove(Ins)
				return
			end	

			if not DecendantsCheck(child) then return end

			CreateVehicle(Ins)
		end)
		return
	end
	
	CreateVehicle(Ins)
end

CS:GetInstanceAddedSignal(Settings.SystemName):Connect(OnTag)
for _,v in CS:GetTagged(Settings.SystemName) do
	OnTag(v)
end
CS:GetInstanceRemovedSignal(Settings.SystemName):Connect(RemoveVehicle)

-- // CLIENT + SERVER RELAY \\ --
function TurnOffCheck(CarData: Helper.SystemData)
	if CarData.Settings.TurnOff then
		for ToggleName,Data in CarData.Settings.TurnOff._getTable do
			for Name,List in Data do
				local ToCheck = CarData.System.Values:FindFirstChild(Name)
				if not ToCheck then
					Logger.warn("invalid toggle name", Name);
					continue
				end

				if not table.find(List, ToCheck.Value) then continue end

				if ToggleName == "Siren" then
					CarData:DisableSiren("All", true, {"Airhorn", "Manual"})
				end
			end
		end
	end
end

function TurnOnCheck(CarData: Helper.SystemData, ToggleName: string)
	if CarData.Settings.TurnOn then
		local ToggleData = CarData.Settings.TurnOn[ToggleName]
		if ToggleData then
			ToggleData = ToggleData._getTable
			for Name,List in ToggleData do
				local ToCheck = CarData.System.Values:FindFirstChild(Name)
				if not ToCheck then
					Logger.warn("invalid toggle name", Name);
					continue
				end
				if not table.find(List, ToCheck.Value) then continue end
				
				return true
			end
			
			return false
		end
	end
	
	return true
end

local SirenNames = {"Wail", "Yelp", "Airhorn", "Manual", "Hyper", "Phaser", "PA"}
Shared.Handler.OnServerEvent:Connect(function(player: Player, Content: {}) 
	if typeof(Content) ~= "table" then return end
	-- warn("Got content from", player, "//", Content)
	local Mode: string = Content["Mode"]
	local Data: any = Content["Content"]
	local System: Model = Content["System"]
	
	if typeof(System) ~= "Instance" then return end
	if not System:HasTag(Settings.SystemName) then return end

	local LB_ID = System:GetAttribute("LB_ID")
	if not LB_ID then return end
	
	local CarData: Helper.SystemData = SystemData[LB_ID]
	if not CarData then return end
	
	local Values = CarData.System.Values
	
	--Logging.print("Ran mode", Mode)
	
	if Mode == "Stage" then
		local ID = Data
		if typeof(ID) ~= "number" and ID ~= nil then return end

		if ID == nil then
			ID = Values.Stage.Value + 1
		end
		
		if ID > CarData.MaxStage then
			ID = 0
		end

		if ID < 0 then
			ID = 0
		end
		
		for _,v in _SharedData.Extras.Stage do
			v(ID, CarData)
		end
		
		if CarData.Settings.OnInterfaceUse then
			CarData.Settings.OnInterfaceUse(CarData, "Stage", ID)
		end
		
		Values.Stage.Value = ID
		TurnOffCheck(CarData)
		return
	end
	
	if Mode == "Directional" then
		local ID = Data
		if typeof(ID) ~= "number" and ID ~= nil then return end
		
		if ID == nil then
			ID = Values.Dir.Value + 1
		end
		
		if ID > CarData.MaxDir then
			ID = 0
		end
		if ID < 0 then
			ID = 0
		end
		
		for _,v in _SharedData.Extras.Dir do
			v(ID, CarData)
		end
		
		if CarData.Settings.OnInterfaceUse then
			CarData.Settings.OnInterfaceUse(CarData, "Dir", ID)
		end
		
		Values.Dir.Value = ID
		TurnOffCheck(CarData)
		return
	end
	
	if table.find(SirenNames, Mode) then
		Data = typeof(Content) ~= "table" and Content or {}
		local Siren = Mode
		local Toggle = Data["Toggle"]
		
		-- allows for nil values while only allowing bools
		if typeof(Toggle) ~= "boolean" and Toggle ~= nil then return end
		
		local SirenID = Data["ID"] or 1
		if typeof(SirenID) ~= "number" then return end
		local ID = tostring(SirenID)
		
		local SirenFolder = CarData.System.SirenValues:FindFirstChild(ID)
		if not SirenFolder then
			Logger.warn("Siren folder not found =>", ID)
			return
		end
		
		local SirenIns = SirenFolder:FindFirstChild(Siren)
		if not SirenIns then
			Logger.warn("No siren Instance =>", Siren)
			return
		end
		
		-- if toggle is nil, make it the opposite of the current status
		if Toggle == nil then
			Toggle = not SirenIns.Value
		end
		
		-- whenever the old siren is saved (turning it off plays the old siren)
		local IsSpecial = ((Siren == "Airhorn") or (Siren == "Manual") or (Siren == "PA"))
		
		for _,v in _SharedData.Extras.Siren do
			v(Siren, Toggle, CarData)
		end
		
		if Toggle then
			if IsSpecial then
				local MainCheck = TurnOnCheck(CarData, "Special")
				local SecCheck  = TurnOnCheck(CarData, Siren)
				
				if MainCheck and SecCheck then
					local Status = CarData:EnableSiren(Siren, ID, false, (Siren == "PA" and player or nil))
					if Status and CarData.Settings.OnInterfaceUse then
						CarData.Settings.OnInterfaceUse(CarData, "SpecialSiren", Siren, true)
					end
				end
			else
				local MainCheck = TurnOnCheck(CarData, "Special")
				local SecCheck  = TurnOnCheck(CarData, Siren)
				
				if MainCheck and SecCheck then
					print(MainCheck, SecCheck)
					local Status = CarData:EnableSiren(Siren, ID, true)
					if Status and CarData.Settings.OnInterfaceUse then
						CarData.Settings.OnInterfaceUse(CarData, "Siren", Siren, true)
					end
				end
			end
		else
			if IsSpecial then
				CarData:ResumeSiren(ID)
				if CarData.Settings.OnInterfaceUse then
					CarData.Settings.OnInterfaceUse(CarData, "SpecialSiren", Siren, true)
				end
			else
				CarData:DisableSiren(ID, true)
				if CarData.Settings.OnInterfaceUse then
					CarData.Settings.OnInterfaceUse(CarData, "Siren", Siren, false)
				end
			end
		end
		return
	end

	if table.find((CarData.SpecialNames :: MT.MetaTable<{any}>)._getTable, Mode) then
		Data = typeof(Content) ~= "table" and Content or {}
		local Special = Mode
		local Toggle = Data["Toggle"]
		-- allows for nil values while only allowing bools
		if typeof(Toggle) ~= "boolean" and Toggle ~= nil then return end

		local ValueIns = Values:FindFirstChild(Special)
		if not ValueIns then
			Logger.warn("No siren instance =>", Special)
			return
		end
		
		-- if toggle is nil, make it the opposite of the current status
		if Toggle == nil then
			Toggle = not ValueIns.Value
		end
		
		for _,v in _SharedData.Extras.Special do
			v(Special, Toggle, CarData)
		end
		
		if CarData.Settings.OnInterfaceUse then
			CarData.Settings.OnInterfaceUse(CarData, "Special", Special, Toggle)
		end
		
		ValueIns.Value = Toggle
		TurnOffCheck(CarData)
		return
	end
	
	if Mode == "Rumbler" then
		Data = typeof(Content) ~= "table" and Content or {}
		local SirenID = Data["ID"] or 1
		if typeof(SirenID) ~= "number" then return end
		local ID = tostring(SirenID)
		
		local Toggle = Data["Toggle"]
		-- allows for nil values while only allowing bools
		if typeof(Toggle) ~= "boolean" and Toggle ~= nil then return end
		
		local SirenFolder = CarData.System.SirenValues:FindFirstChild(ID)
		if not SirenFolder then return end

		local SirenConfig = SirenFolder.Config
		local ValueIns = SirenConfig.IsAlt
		if Toggle == nil then
			Toggle = not ValueIns.Value
		end
		
		for _,v in _SharedData.Extras.Special do
			v("Alt", Toggle, CarData)
		end
		
		if CarData.Settings.OnInterfaceUse then
			CarData.Settings.OnInterfaceUse(CarData, "Rumbler", Toggle)
		end
		
		SirenConfig.IsAlt.Value = Toggle
		
		TurnOffCheck(CarData)
		CarData:RefreshSiren(ID)
	end
end)
