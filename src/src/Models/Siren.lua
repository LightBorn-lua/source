local ServerScriptService = game:GetService("ServerScriptService")
local src = script.Parent.Parent
local Root = src.Parent
-----------------
local Helpers = Root.Helpers
local Modules = Root.Modules
local Assets = Root.Assets

local Logger = require(ServerScriptService.LightBorn.Modules.Logger)
local Helper = require(Helpers.Helper)
local MT = require(Modules.MetaTable)

local API = {} :: Helper.SystemData

function CreateWire(Starter: Instance, End: Instance)
	local Wire = Instance.new("Wire")
	Wire.SourceInstance = Starter
	Wire.TargetInstance = End
	Wire.Parent = Starter
	return Wire
end

function CreatePlayer(Location: Instance)
	local Player = Instance.new("AudioPlayer")
	local Emitter = Instance.new("AudioEmitter")
	Emitter.Name = "Emitter"
	Player.Name = "Player"
	--
	local Effects = Instance.new("Folder")
	Effects.Name = "Effects"
	Effects.Parent = Location
	----
	Player.Parent = Location
	Emitter.Parent = Location
	----
	return {["Player"] = Player, ["Emitter"] = Emitter, ["Effects"] = Effects}
end

function CreateLegacyPlayer(Location: Instance)
	local Player = Instance.new("Sound")
	Player.Name = "LegacyPlayer"
	--
	local Effects = Instance.new("Folder")
	Effects.Name = "LegacyEffects"
	Effects.Parent = Location
	----
	Player.Parent = Location
	----
	return {["Player"] = Player, ["Emitter"] = nil, ["Effects"] = Effects}
end

function API:IntializeSiren()
	-- siren parts initialization
	self.SirenParts = {}
	local SirenValueFolder = self.System:FindFirstChild("SirenValues")
	if not SirenValueFolder then
		SirenValueFolder = Instance.new("Folder")
		SirenValueFolder.Name = "SirenValues"
		SirenValueFolder.Parent = self.System
	end

	-- SELF NOTE: CHANGE THAT TO BE STUPIDPROOF
	local SirensLocation: Instance = self.System.Sirens

	for _,v: Instance in SirensLocation:GetChildren() do
		local SirenID = v:GetAttribute("SirenID")
		if not SirenID then continue end
		SirenID = tonumber(SirenID)
		if not SirenID then
			Logger.warn("ID MUST BE A NUMBER");
			continue
		end

		if not self.SirenParts[SirenID] then
			self.SirenParts[SirenID] = {}
		end
		
		local TableID = #self.SirenParts[SirenID]._getTable + 1

		-- I somehow clutched that parenting on the first try
		local SirenValues = Assets.SirenValues:Clone()
		SirenValues.Parent = SirenValueFolder
		SirenValues.Name = tostring(SirenID)
		
		local IsLegacy = self.Settings.UseLegacyAudio
		
		local Data = CreatePlayer(v)
		local LegacyData = CreateLegacyPlayer(v)

		self.SirenParts[SirenID][TableID] = {
			Player = Data.Player,
			LegacyPlayer = LegacyData.Player,
			Emitter = Data.Emitter,
			Effects = Data.Effects,
			LegacyEffects = LegacyData.Effects,
			Wires = MT.new({
				["Player"] = nil,
				["Effects"] = MT.new({})
			})
		}
		

		if self.Settings.SirenProperties then
			for Property, Value in self.Settings.SirenProperties._getTable do
				if Property == "Volume" then
					Data.Player.Volume = Value
				elseif Property == "Speed" then
					Data.Player.PlaybackSpeed = Value
				elseif Property == "Looped" then
					Data.Player.Looping = Value
				elseif Property == "AcousticSimulation" then
					Data.Emitter.AcousticSimulationEnabled = Value
				elseif Property == "Distance" then
					Data.Emitter:SetDistanceAttenuation(Value)
				elseif Property == "Angle" then
					Data.Emitter:SetAngleAttenuation(Value)
				end
			end
		end
		
		if self.Settings.LegacySirenProperties and IsLegacy then
			for Property, Value in self.Settings.SirenProperties._getTable do
				if Property == "Volume" then
					LegacyData.Player.Volume = Value
				elseif Property == "Speed" then
					LegacyData.Player.PlaybackSpeed = Value
				elseif Property == "Looped" then
					LegacyData.Player.Looped = Value
				elseif Property == "RollOffMinDistance" then
					LegacyData.Player.RollOffMinDistance = Value
				elseif Property == "RollOffMaxDistance" then
					LegacyData.Player.RollOffMaxDistance = Value
				elseif Property == "RollOffMode" then
					LegacyData.Player.RollOffMode = Value
				end
			end
		end
		
		self.SirenDefaultProp = {
			Volume = Data.Player.Volume,
			Speed = Data.Player.PlaybackSpeed,
		}

		if not self.AvailableSirens then
			self.AvailableSirens = {}
		end
		self.AvailableSirens[SirenID] = {}
		if self.Settings.Sirens[SirenID] then
			for Name,_ in self.Settings.Sirens[SirenID]._getTable do
				self.AvailableSirens[SirenID]:Insert(Name)
			end
		end
	end
end

function API:RefreshSiren(IDs: {number} | number)
	local FinalIDs = typeof(IDs) == "number" and {IDs} or IDs :: {number}

	for _, IDName in FinalIDs do
		local SirenInstance = self.SirenParts[IDName]
		if not SirenInstance then continue end
		local SirenValues = self.System.SirenValues[IDName]
		local Siren: string = SirenValues.Config.Current.Value
		local IsAlt: boolean = SirenValues.Config.IsAlt.Value

		if not table.find(self.AvailableSirens[IDName]._getTable, Siren) then continue end
		
		local SirenData = self.Settings.Sirens[IDName][Siren]
		
		if not SirenData.SoundID then continue end

		if IsAlt and not SirenData.SoundID["alternative"] then continue end
		if not IsAlt and not SirenData.SoundID["default"] then continue end
		
		local AssetID = SirenData.SoundID[IsAlt and "alternative" or "default"]
		local Volume = SirenData.Volume or self.SirenDefaultProp["Volume"]
		local Speed = SirenData.Speed or self.SirenDefaultProp["Speed"]

		self:SirenOn(IDName, Siren, {AssetID = AssetID, Volume = Volume, Speed = Speed}, nil, true)
	end
end

function LinkWires(Instances: {}, StartPos: Instance, Data: {})
	local InsID = 1
	local OldEffect = nil
	--print(Instances)
	for _,v in Instances do
		-- print(v)
		local Effect: Instance = Instance.new(v[1])
		for Property,Value in v[2] do
			Effect[Property] = Value
		end
		Effect.Parent = Data["Effects"]

		if InsID == 1 then
			--print("Run 1", v)
			if Data["Wires"]["Player"] then
				Data["Wires"]["Player"]:Destroy()
			end
			local Wire = CreateWire(StartPos, Effect)
			Data["Wires"]["Player"] = Wire
		elseif InsID == #Instances then
			--print("Last", v)
			local Wire1 = CreateWire(OldEffect, Effect)
			local Wire2 = CreateWire(Effect, Data["Emitter"])
			Data["Wires"]["Effects"]:Insert(Wire1)
			Data["Wires"]["Effects"]:Insert(Wire2)
		else
			--print("Normal", v)
			local Wire = CreateWire(OldEffect, Effect)
			Data["Wires"]["Effects"]:Insert(Wire)
		end

		OldEffect = Effect
		InsID += 1
	end
end

function UnlinkWires(StartPos: Instance, Data: {})
	if Data["Wires"]["Player"] then
		Data["Wires"]["Player"]:Destroy()
	end
	Data["Wires"]["Player"] = CreateWire(StartPos, Data["Emitter"])
end

function LinkAudio(Instances: {}, Data: {})
	for _,v in Instances do
		-- print(v)
		local Effect: Instance = Instance.new(v[1])
		for Property,Value in v[2] do
			Effect[Property] = Value
		end
		Effect.Parent = Data["LegacyPlayer"]
	end
end

function UnlinkAudio(Data: {})
	for _,v in Data["LegacyPlayer"]:GetChildren() do
		v:Destroy()
	end
end

function API:SirenOn(SirenCategory: number, Name: string, Asset: {AssetID: string, Volume: number, Speed: number}, Playing: boolean, NoEffectCheck: boolean?, Player: Player?)
	--warn("Got a siren on")
	local Sirens = self.SirenParts[SirenCategory]
	if not Sirens then return end
	
	local OldAudio = self.Settings.UseLegacyAudio or false
	
	local StartPos = nil
	
	if Player then
		StartPos = Player:FindFirstChildWhichIsA("AudioDeviceInput")
		if not StartPos then return end
	end
	
	for ID,Data in Sirens._getTable do
		if not Player then
			StartPos = Data["Player"]
		end
		
		for _,v in NoEffectCheck and {} or Data["Effects"]:GetChildren() do
			v:Destroy()
		end
		
		--warn("Category:", SirenCategory, "Name:", Name, "NoEffect:", NoEffectCheck, "Player:", Player)
		
		local InsFold = self.Settings.Sirens[SirenCategory][Name]
		local Instances = not NoEffectCheck and (InsFold and InsFold.Instances or nil) or nil
		if Instances then
			Instances = Instances[ID]._getTable
		else
			Instances = {}
		end
		
		if not NoEffectCheck then
			if #Instances > 0 then
				if Player or not OldAudio then
					LinkWires(Instances, StartPos, Data)
				else
					LinkAudio(Instances, Data)
				end
			else
				UnlinkWires(StartPos, Data)
				UnlinkAudio(Data)
			end
		end
		
		if not Player then 
			if OldAudio then
				Data["LegacyPlayer"].SoundId = "rbxassetid://"..Asset.AssetID
				Data["LegacyPlayer"].Volume = Asset.Volume
				Data["LegacyPlayer"].PlaybackSpeed = Asset.Speed
			else
				Data["Player"].Asset = "rbxassetid://"..Asset.AssetID
				Data["Player"].Volume = Asset.Volume
				Data["Player"].PlaybackSpeed = Asset.Speed
			end
			if Playing or not Data["Player"].IsPlaying then
				if OldAudio then
					Data["LegacyPlayer"]:Play()
				else
					Data["Player"]:Play()
				end
			end
		end
	end
end

function API:SirenOff(SirenCategory: number)
	local Sirens = self.SirenParts[SirenCategory]
	if not Sirens then return end

	for _,Data in Sirens._getTable do
		for _,v in Data["Effects"]:GetChildren() do
			v:Destroy()
		end
		
		for _,v in Data["LegacyEffects"]:GetChildren() do
			v:Destroy()
		end
		
		if Data["Wires"]["Player"] then
			Data["Wires"]["Player"]:Destroy()
		end
		
		Data["Player"]:Stop()
		Data["Player"].TimePosition = 0
		-------------------
		Data["LegacyPlayer"]:Stop()
		Data["LegacyPlayer"].TimePosition = 0
	end
end

function API:EnableSiren(Siren: string, IDs: {number} | number, Overwrite: boolean?, Player: Player | boolean | nil)
	local FinalIDs = typeof(IDs) == "number" and {IDs} or IDs :: {number}
	
	local Changes = false
	for _, IDName in FinalIDs do
		local SirenInstance = self.SirenParts[IDName]
		if not SirenInstance then continue end

		if not table.find(self.AvailableSirens[IDName]._getTable, Siren) then continue end

		local SirenValues = self.System.SirenValues[IDName]
		local SirenData = self.Settings.Sirens[IDName][Siren]
		local CurrentSiren: string = SirenValues.Config.Current.Value
		local IsAlt: boolean = SirenValues.Config.IsAlt.Value
		
		local AssetID = nil
		local Volume = SirenData.Volume or self.SirenDefaultProp["Volume"]
		local Speed = SirenData.Speed or self.SirenDefaultProp["Speed"]
		
		if not Player then
			if not SirenData.SoundID then continue end
			if IsAlt and not SirenData.SoundID["alternative"] then continue end
			if not IsAlt and not SirenData.SoundID["default"] then continue end
			
			AssetID = SirenData.SoundID[IsAlt and "alternative" or "default"]
		end

		if #CurrentSiren > 1 then
			self:DisableSiren(IDName, Overwrite or false)
		end
		
		
		self:SirenOn(IDName, Siren, {AssetID = AssetID, Volume = Volume, Speed = Speed}, Overwrite, nil, Player)
		SirenValues.Config.Current.Value = Siren
		
		Changes = true
		SirenValues[Siren].Value = true
		if self.SurfaceElements[Siren] then
			for _,v in self.SurfaceElements[Siren]._getTable do
				v.Transparency = 0
			end
		end
	end
	return Changes
end

function API:DisableSiren(IDs: {number} | number | "All", Stop: boolean?, Ignore: {string}?)
	local FinalIDs = typeof(IDs) == "number" and {IDs} or IDs :: {number} | "All"
	
	if IDs == "All" then
		FinalIDs = {}
		for Name,_ in self.SirenParts._getTable do
			table.insert(FinalIDs, Name)
		end
	end
	
	for _, IDName in FinalIDs do
		local SirenValues = self.System.SirenValues[IDName]

		local SirenInstance: {AudioPlayer} = self.SirenParts[IDName]
		if not SirenInstance then continue end

		local CurrentSiren: string = SirenValues.Config.Current.Value 
		if #CurrentSiren == 0 then continue end
		
		if Ignore and table.find(Ignore, CurrentSiren) then continue end

		SirenValues.Config.Old.Value = Stop and "" or CurrentSiren
		SirenValues.Config.Current.Value = ""

		self:SirenOff(IDName)
		
		SirenValues[CurrentSiren].Value = false
		
		if self.SurfaceElements[CurrentSiren] then
			for _,v in self.SurfaceElements[CurrentSiren]._getTable do
				v.Transparency = 1
			end
		end
	end
end

function API:ResumeSiren(IDs: {number} | number)
	local FinalIDs = typeof(IDs) == "number" and {IDs} or IDs :: {number}

	for _, IDName in FinalIDs do
		local SirenInstance = self.SirenParts[IDName]
		if not SirenInstance then continue end
		local SirenValues = self.System.SirenValues[IDName]

		local Siren = SirenValues.Config.Old.Value
		if #Siren == 0 then
			self:DisableSiren(FinalIDs, true)
			return
		end

		if not table.find(self.AvailableSirens[IDName]._getTable, Siren) then continue end

		local CurrentSiren: string = SirenValues.Config.Current.Value
		local IsAlt: boolean = SirenValues.Config.IsAlt.Value
		
		local SirenData = self.Settings.Sirens[IDName][Siren]

		if IsAlt and not SirenData.SoundID["alternative"] then continue end
		if not IsAlt and not SirenData.SoundID["default"] then continue end

		if #CurrentSiren > 1 then
			self:DisableSiren(IDName)
		end
		
		local AssetID = SirenData.SoundID[IsAlt and "alternative" or "default"]
		local Volume = SirenData.Volume or self.SirenDefaultProp["Volume"]
		local Speed = SirenData.Speed or self.SirenDefaultProp["Speed"]

		self:SirenOn(IDName, Siren, {AssetID = AssetID, Volume = Volume, Speed = Speed})
		SirenValues.Config.Current.Value = Siren
		
		SirenValues[Siren].Value = true

		if self.SurfaceElements[Siren] then
			for _,v in self.SurfaceElements[Siren]._getTable do
				v.Transparency = 0
			end
		end
	end
end

return API