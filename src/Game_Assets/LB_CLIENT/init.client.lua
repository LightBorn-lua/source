repeat
	task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

repeat
	task.wait(.5)
until LP.Character

local UIM = require(script.UIHandle)

local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService('CollectionService')
local HTTP = game:GetService("HttpService")
local UIHandle = require(script.UIHandle)

local Shared = RS.LB_Shared
local SharedModules = Shared.Modules

local LightoHandler = require(SharedModules.LightoHandler :: ModuleScript)

local UIData = {}

function DecodeColorTable(Table: string)
	local source = HTTP:JSONDecode(Table)
	local res = {}
	for n,v in source do
		res[n] = Color3.new(v[1], v[2], v[3])
	end
	return res
end

function OnUI(UI: Instance)	
	local UIName = HTTP:GenerateGUID(true)
	UI.AncestryChanged:Connect(function(_: Instance, parent: Instance?)
		if parent then return end
		local Data = UIData[UIName]

		if not Data then
			repeat
				Data = UIData[UIName];
				task.wait(.5);
			until Data
		end

		Data:Remove()
		Data = nil
	end)

	UIData[UIName] = UIM.Initiate(UI :: UIHandle.UI)
end

function OnLight(Light: Instance)
	local Colors = Light:GetAttribute("Colors") or "[]"
	Colors = DecodeColorTable(Colors)
	LightoHandler(Light, Colors, true)
end

function InitializeCS(Tag: string, Callback: (Instance: Instance) -> ())
	for _,v: Instance in CollectionService:GetTagged(Tag) do
		task.spawn(Callback, v)
	end
	
	CollectionService:GetInstanceAddedSignal(Tag):Connect(Callback)
end

InitializeCS("LB_INTERFACE", OnUI)
InitializeCS("LB_LIGHT_CLIENT", OnLight)