local HTTP = game:GetService("HttpService")
local SS = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local src = script.Parent.Parent
local Parts = src.Parts
local Root = src.Parent
-----------------
local Helpers = Root.Helpers
local Modules = Root.Modules

local Logger = require(Modules.Logger)
local Helper = require(Helpers.Helper)
local MT = require(Modules.MetaTable)

local EnvHelper = require(Parts.Env)
local Lighto = require(Parts.Lighto)

local LB_Settings = SS.LB_Settings
local Settings = require(LB_Settings:FindFirstChild("Settings") :: ModuleScript)

local mod = {
	Initializer = nil
}

local API = {} :: Helper.SystemData

function CheckIfInterfaceIsValid(Interface: ScreenGui)
	if typeof(Interface) ~= "Instance" or not Interface:IsA("ScreenGui") then return end
	
	local System = Interface:FindFirstChild("System")
	if not System or not System:IsA("ObjectValue") then return end
	
	local Controller = Interface:FindFirstChild("Controller")
	if not Controller or not Controller:IsA("LocalScript") then return end
	
	return true
end

function GetContent(MS: ModuleScript)
	local success, res = pcall(require, MS)

	if not success then return false, `Error loading module :: {res}` end
	if success and typeof(res) ~= "function" then return false, "Invalid return type (expected function)" end

	return res
end

function API:CleanUp()
	-- warn("Cleaning up")
	self.Halted = true
	self:KillAllTask()
	self:Clear()
	-- warn("Clean up done")
	return
end

function API:InitializeUI(Player: Player, Seat: Seat)
	local UIName = self.Settings.Interface or "Default"
	local UI = LB_Settings.UIs:FindFirstChild(UIName) or LB_Settings.UIs:FindFirstChild("Default")
	if not UI then return end
	if not CheckIfInterfaceIsValid(UI) then
		Logger.warn("UI failed =>", UI)
		return
	end
	Seat:SetAttribute("Owned", Player.UserId)
	local Interface = UI:Clone()
	Interface:AddTag("LB_INTERFACE")
	
	Interface.Controller.Enabled = false
	Interface.Name = "LB_INTERFACE"
	
	Interface.Parent = Player:FindFirstChildWhichIsA("PlayerGui")
	
	Interface.System.Value = self.System
	Interface.Controller.Enabled = true
end

function API:RemoveUI(Seat: Seat)
	local Owner = Seat:GetAttribute("Owned")
	if not Owner then return end
	Seat:SetAttribute("Owned", nil)
	local Player = Players:GetPlayerByUserId(Owner)
	if not Player then return end
	local UI = Player:FindFirstChildWhichIsA("PlayerGui"):FindFirstChild("LB_INTERFACE")
	if not UI then return end
	UI:Destroy()
end

function API:InitializeController()
	if not self.Settings.SeatLocations then
		Logger.warn("No seat locations found, skipping controller initialization")
		return
	end

	for _,v: Instance in self.Settings.SeatLocations._getTable do
		if typeof(v) ~= "Instance" then continue end
		for _,Seat: Instance in v:GetDescendants() do
			if not Seat:IsA("Seat") and not Seat:IsA("VehicleSeat") then continue end
			if not Seat:HasTag(Settings.ControllerName) then continue end
			
			Seat:GetPropertyChangedSignal("Occupant"):Connect(function()
				-- print("New Occupant", Seat.Occupant)
				local Occupant = Seat.Occupant
				if not Occupant then
					self:RemoveUI(Seat)
					return
				end
				
				local Player = Players:GetPlayerFromCharacter(Occupant.Parent)
				-- print(Player)
				if not Player then return end
				
				self:InitializeUI(Player, Seat)
			end)
		end
	end
end

function API:ChangeStatus(From: string, NewVal: any)
	--warn("// CHANGE START FROM :: '", From, "' \\")
	--print("status change ::", From)
	
	if self.Halted then return end
	
	if typeof(NewVal) == "boolean" then
		NewVal = NewVal and 1 or 0
	end
	
	NewVal = tostring(NewVal)
	
	for ModName,ModData in self.Modules._getTable do
		local Changed = false
		local PrioData = {}
		
		local RunningPrio: number = nil
		for ID,v in ModData.Data do
			local split = string.split(ID, "_")
			local FuncID, Val, AltID, GroupID = split[1], split[2] or "1", split[3] or "0", split[4] or split[1]
			
			--warn(FuncID)
			-- print("CHECK ID ::", FuncID , "//", Val, "::", AltID, "// ", NewVal)
			
			local ShouldRun = false
			
			if FuncID == From and Val ~= NewVal then
				-- warn("turn off : different val", "//", FuncID, "==", ID)
				Changed = true
				v.Running = false
				v.Cancelled = false
				v.Started = false
				v.Stopped = true
				continue
			end
			
			if FuncID == From and Val == NewVal then
				if AltID ~= tostring(self.CurrentAlt) then
					-- print("turn off", AltID, "// CURRENT:", tostring(self.CurrentAlt))
					Changed = true
					v.Running = false
					v.Cancelled = false
					v.Started = false
					v.Stopped = true
					continue
				end
				
				--print("turning on", FuncID, AltID)
				ShouldRun = true
			end
			
			if v.Started or v.Cancelled then
				ShouldRun = true
			end
			
			if ShouldRun then
				Changed = true
				local prio = self.Settings.Priority[GroupID] or self.Settings.DefaultPriority
				-- warn("Allowing :", FuncID, "::", prio)
				v.Started = true
				
				if not PrioData[prio] then
					PrioData[prio] = {}
				end
				
				if not RunningPrio or prio < RunningPrio then
					RunningPrio = prio
				end
				
				table.insert(PrioData[prio], v)
			end
		end
		
		for prioID, Data in PrioData do
			-- print(prioID, ">", RunningPrio)
			if prioID > RunningPrio then
				-- print("turn off > priority")
				Changed = true
				for _,v in Data do
					if v.Started then
						v.Cancelled = true
					end
					v.Running = false
					v.Started = false
					v.Stopped = true
				end
				continue
			end
			
			for _,v in Data do
				Changed = true
				v.Cancelled = false
				v.Stopped = false
				v.Started = true
				
			end
		end
		
		if Changed and self.InitConnections["TaskUpdate"] then
			self.InitConnections["TaskUpdate"](self, self.Modules[ModName]._getTable, ModName)
		end	
	end
	
	--warn("// CHANGE END \\")
end

function API:Int_Lightos()
	local LightoLocation = self.Settings.LightLocation and self.Settings.LightLocation._getTable
	for _,location: Instance in LightoLocation or {self.System} do
		for _,v: Instance in location:GetDescendants() do
			if not v:IsA("BasePart") or not v:HasTag("LB_Lighto") then continue end
			mod.Initializer.InitializeLight(self, v)
		end
	end
end

function API:InitializeModules(ModulesLocation: Instance)
	for _,Module in ModulesLocation:GetChildren() do
		if not Module:IsA("ModuleScript") then continue end
		local content, _ = GetContent(Module)
		if not content then
			-- warn(v.Name, "//", extra)
			continue
		end
		
		local env = getfenv(content)
		
		for n,v in EnvHelper do
			if env.Environment[n] then continue end
			env.Environment[n] = v
		end
		
		env.Environment.spawn = function(exe: () -> (), ID: string?)
			ID = ID or HTTP:GenerateGUID(true)
			
			self.Modules[Module.Name].Spawns:ValInsert(ID, task.spawn(function()
				exe()
				self.Modules[Module.Name].Spawns:Remove(ID)
			end))
			
			return ID
		end
		
		env.Environment.cancel = function(ID: string)
			local thread = self.Modules[Module.Name].Spawns[ID]
			if not thread then return false end
			
			task.cancel(thread)
			self.Modules[Module.Name].Spawns:Remove(ID)
			
			return true
		end
		
		env.self.DL = (function()
			for ID,_ in self.Modules[Module.Name].Spawns._getTable do
				env.Environment.cancel(ID)
			end
			
			for _,v in env.ELS do
				env.Environment.Enable(v, "Off")
				-------------------
				env.Environment.Value(v, {"Lighto", "Light"}, {0, 1}, TweenInfo.new(.1, Enum.EasingStyle.Linear))
			end
		end)
		
		env.self.Initialize = (function()
			if not env.ELSLocation then
				Logger.warn("'ELSLocation' ENV VARIABLE DOES NOT EXIST =>", Module); 
				return;
			end
			if typeof(env.ELSLocation) ~= "Instance" then
				Logger.warn("'ELSLocation' IS NOT AN INSTANCE =>", Module); 
				return; 
			end
			
			local Empty = true
			for _,v: Instance in env.ELSLocation:GetDescendants() do
				if not v:IsA("BasePart") or not v:HasTag("LB_Lighto") then continue end
				local ELSData = Lighto.newELSData(v)
				
				if ELSData then
					Empty = false
					env.ELS[v.Name] = ELSData
				end
			end
			
			if Empty then
				Logger.warn("'ELS' GLOBAL IS EMPTY, NO LIGHTOS WERE FOUND // BE AWARE =>", Module)
			end
		end)
		
		local inside = content()
		
		inside.Initialize()
		if inside.ExtraInitialize then
			inside.ExtraInitialize()
		end
		
		local DataGen = {}
		
		for n,v in inside do
			if typeof(v) ~= "function" then continue end
			if n == "DL" or n == "Initialize" then continue end
			DataGen[n] = MT.new({
				Started = false,
				Running = false,
				Ended   = false,
				Stopped = true
			})
		end

		self.Modules[Module.Name] = {
			Content = inside,
			Tasks = MT.new({}),
			Settings = {
				RunOnce = inside.RunOnce or {}
			},
			DL = env.self.DL,
			Spawns = MT.new({}),
			Data = DataGen
		}
		
		-- warn("Initialized", v:GetFullName())
	end
end

function mod.new(Halted: boolean?, CurrentStage: number?, CurrentDir: number?)
	local Data: Helper.SystemData = MT.new(API)

	Data.ID = HTTP:GenerateGUID(true)
	Data.Halted = Halted or false
	Data.CurrentStage = CurrentStage or 0
	Data.CurrentDir = CurrentDir or 0
	Data.Modules = {}
	
	return Data
end


return mod