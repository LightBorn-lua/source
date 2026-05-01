local Module = {}

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local LBShared = RS.LB_Shared
local Event = LBShared.Handler
local Data = {
	Connections = {},
	Actions = {},
	UIIns = {}
}

export type UI = ScreenGui & {
	System: ObjectValue,
	Info: ModuleScript,
}

type SirenFolder = Folder & {
	Config: Folder & {
		IsAlt: BoolValue
	},
}

function Data:AddConnect(Connect: RBXScriptConnection)
	table.insert(self.Connections, Connect)
end

function Data:SendEvent(Mode: string, Content: any, ID: string?)
	-- print("Send event", Mode, "//", Data)
	Event:FireServer({["Mode"]=Mode, ["Content"]=Content, ["System"]=self.System, ID=ID})
end

function Data:Remove()
	for n,v: RBXScriptConnection in self.Connections do
		v:Disconnect()
		self.Connections[n] = nil
	end
	
	
end

function Data:ClickEvent(Button: GuiButton, CalbackName: string, ...)
	self.UIIns[CalbackName] = Button
	local Arguments = { ... }
	self:AddConnect(Button.MouseButton1Click:Connect(function()
		local Callback = self.Actions.Press[CalbackName]
		if not Callback then return end
		Callback(self, table.unpack(Arguments))
	end))
end

function Data:HoldEvent(Button: GuiButton, CalbackName: string, OnArgs: {}, OffArgs: {})
	OnArgs, OffArgs = OnArgs or {}, OffArgs or {}
	self.UIIns[CalbackName] = Button

	local OnCallback  = self.Actions.Press[CalbackName]
	local OffCallback = self.Actions.Release[CalbackName]

	local Holding = false
	self:AddConnect(Button.MouseButton1Down:Connect(function()
		if not OnCallback or Holding then return end
		Holding = true
		OnCallback(self, table.unpack(OnArgs))
	end))

	self:AddConnect(Button.MouseButton1Up:Connect(function()
		if not OffCallback or not Holding then return end
		Holding = false
		OffCallback(self, table.unpack(OffArgs))
	end))

	self:AddConnect(Button.MouseLeave:Connect(function()
		if not OffCallback or not Holding then return end
		Holding = false
		OffCallback(self, table.unpack(OffArgs))
	end))
end

function Module.Initiate(UI: UI)
	local self = {}
	setmetatable(self, {__index = Data})
	
	local ActionsList = UI:FindFirstChild("Actions") or script.Parent.Actions
	ActionsList = require(ActionsList)
	
	self.CurrentSiren = {1}
	
	self.UIObj = UI :: ScreenGui
	self.System = UI.System.Value :: Instance
	
	self.SystemValues = self.System.Values :: Instance
	self.SirenValues = self.System.SirenValues :: Instance
	
	for n,v in require(UI.Info) do
		self[n] = v
	end
	self.Settings = require(self.System.Settings)
	
	local Allowed = UI:GetAttribute("Allowed") :: string
	local Denied = UI:GetAttribute("Denied") :: string
	
	self.Allowed = Allowed and string.split(Allowed, ",") or {} :: {}
	self.Denied = Denied and string.split(Denied, ",") or {} :: {}
	
	if #self.Allowed > 0 and #self.Denied > 0  then
		warn("UIMODE :: ALLOWED AND DENIED ARE BOTH DEFINED, ALLOWED PRIORITIZED")
		self.Denied = {}
	end

	if #self.Allowed < 1 then
		self.Allowed = nil
	end

	if #self.Denied < 1 then
		self.Denied = nil
	end
	
	for Name, ListContent in ActionsList do
		self.Actions[Name] = {}
		for ID, Content in ListContent do
			local execute: () -> () = Content
			if Content == "Send" then
				execute = function(_self)
					_self:SendEvent(ID, nil)
				end
			end

			if Content == "SendOverride" then
				execute = function(_self, Override: any)
					_self:SendEvent(ID, Override)
				end
			end
			
			if Content == "SendOverrideWithID" then
				execute = function(_self, Override: any, SID: string?)
					_self:SendEvent(ID, Override, SID)
				end
			end
			
			self.Actions[Name][ID] = execute
		end
	end
	
	if self.Execute then
		self:Execute()
	end
	
	local Keybinds = {}
	
	for n: string, v: InputObject in self.Settings.Keybinds or {} do
		if not v then continue end
		Keybinds[string.upper(v.Name)] = n
	end
	
	for Name,d in self.Actions do
		for n,_ in d do
			if self.Allowed and not table.find(self.Allowed, n) then
				self.Actions[Name][n] = nil
				continue
			end

			if self.Denied and table.find(self.Denied, n) then
				self.Actions[Name][n] = nil
				continue
			end
		end
	end
	
	self:NewStage()
	self:AddConnect(self.SystemValues.Stage.Changed:Connect(function()
		self:NewStage()
	end))
	
	for _,Folder: SirenFolder in self.SirenValues:GetChildren() do
		if not Folder:IsA("Folder") then continue end
		for _,v in Folder:GetChildren() do
			if not v:IsA("ValueBase") then continue end
			self:OnSirenUsed(v.Name, v.Value, Folder.Name)
			self:AddConnect(v.Changed:Connect(function()
				self:OnSirenUsed(v.Name, v.Value, Folder.Name)
			end))
		end
		
		self:OnSirenUsed("Rum", Folder.Config.IsAlt.Value, Folder.Name)
		self:AddConnect(Folder.Config.IsAlt.Changed:Connect(function()
			self:OnSirenUsed("Rum", Folder.Config.IsAlt.Value, Folder.Name)
		end))
	end
	
	self:AddConnect(UIS.InputBegan:Connect(function(i,gp)
		if gp then return end
		local KeyCode = i.KeyCode
		if not KeyCode then return end
		local KeyEvent = Keybinds[string.upper(KeyCode.Name)]
		if not KeyEvent then return end
		local action_event = self.Actions.Press[KeyEvent]
		if not action_event then return end
		action_event(self)
	end))

	self:AddConnect(UIS.InputEnded:Connect(function(i,gp)
		if gp then return end
		local KeyCode = i.KeyCode
		if not KeyCode then return end
		local KeyEvent = Keybinds[string.upper(KeyCode.Name)]
		if not KeyEvent then return end
		local action_event = self.Actions.Release[KeyEvent]
		if not action_event then return end
		action_event(self)
	end))
	
	return self
end


return Module
