local TS = game:GetService("TweenService")

local Parts = script.Parent
local src = Parts.Parent
local Root = src.Parent
-----------------
local Helpers = Root.Helpers
local Modules = Root.Modules

local ENVHelper = require(Helpers.EnvHelper)
local Logger = require(Modules.Logger)

local env = {} :: ENVHelper.Env

env.Flicker = function(ELS: {}, Time: number, WaitBetween: number, Colors: {}, Rotations: number?)
	if not ELS then return end
	local RotationCount = typeof(Rotations) == "number" and Rotations or 1

	local ColorNum = #Colors
	local CurColor = 1
	for ID = 1, RotationCount do 
		ELS["Color"].Value = Colors[CurColor]
		CurColor += 1
		if CurColor > ColorNum then CurColor = 1 end
		task.wait(Time)
		ELS["Color"].Value = "Off"
		task.wait(WaitBetween)
	end
end

env.Enable = function(ELS: {}, Color: string, Time: number?)
	if not ELS then return Logger.warn("'Enable' was given an empty Lighto") end
	Color = typeof(Color) == "string" and Color or "Off"
	
	ELS = (ELS["Color"] or ELS["Status"]) and {ELS} or ELS
	
	for n,v in ELS do
		if typeof(v) ~= "table" then continue end
		
		if Time then
			v["Color"].Value = Color
			if Color == "Off" and v["Status"] then
				v["Status"].Value = false
			end
			if n ~= #ELS then task.wait(Time) end
		else
			task.spawn(function()
				v["Color"].Value = Color
				if Color == "Off" and v["Status"] then
					v["Status"].Value = false
				end
			end)
		end
	end
	return
end

env.Value = function(ELS: {}, Type: {}, Value: {}, TI: TweenInfo?, Yield: boolean?)
	if not ELS then return end
	
	if typeof(Type) ~= "table" then Type = {Type} end
	if typeof(Type) ~= "table" then error("Invalid Type, Table/String Expected At Argument #2"); return end
	
	if typeof(Value) ~= "table" then Value = {Value} end
	if typeof(Value) ~= "table" then error("Invalid Value, Table/String Expected At Argument #3"); return end
	
	for n,v in Type do 
		if not ELS[v] then continue end
		
		if TI then
			local Tween = TS:Create(ELS[v], TI, {["Value"] = Value[n] or Value[1]})
			Tween:Play()
			
			if Yield then Tween.Completed:Wait() end
			continue
		end
		
		ELS[v].Value = Value[n] or Value[1]
	end
	
	return true
end

env.GetELS = function(ELS: {}, Start: number, End: number, Prefix: string?)
	if not ELS then return end 
	
	local Send = {}
	local Area = Prefix and #Prefix or 1
	for Name,v in ELS do
		local PR = string.sub(Name, 1, Area)

		if Prefix and PR ~= Prefix then continue end
		local num = tonumber(string.sub(Name, Area + 1, -1))
		if num >= Start and num <= End then Send[num] = v end
	end

	return Send
end

env.GetLen = function(ELS: {}, Prefix: string)
	if not ELS then return end 
	
	local e = 0
	for Name,v in ELS do
		local PR = string.sub(Name, 1, 1)
		if Prefix and PR ~= Prefix then continue end
		e += 1
	end
	return e
end


return env