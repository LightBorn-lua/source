local src = script.Parent.Parent
local Root = src.Parent
-----------------
local Helpers = Root.Helpers

local Helper = require(Helpers.Helper)

local API = {} :: Helper.SystemData

local SurfaceLayout = {
	["Stage"] = {Name = "s", NumberFill = true},
	["Dir"] = {Name = "d", NumberFill = true},
	["Phaser"] = {Name = nil, NumberFill = false},
	["Airhorn"] = {Name = nil, NumberFill = false},
	["Q2"] = {Name = nil, NumberFill = false},
	["Hyper"] = {Name = nil, NumberFill = false},
	["Manual"] = {Name = nil, NumberFill = false},
	["Yelp"] = {Name = nil, NumberFill = false},
	["Wail"] = {Name = nil, NumberFill = false},
}

function API:InitializeSurfaceControl()
	local Area: Model = self.System:FindFirstChild("Controller")
	if not Area then return end
	
	for _,v: Instance in Area:GetDescendants() do
		if not v:IsA("BasePart") then continue end
		local ModeStr = v:GetAttribute("Mode")
		if not ModeStr then continue end
		local ModeList = string.split(string.lower(ModeStr), ",")
		
		for _,vName in ModeList do	
			for SName, SData in SurfaceLayout do
				local loweredSName = string.lower(SData.Name or SName)
				if not SData["NumberFill"] and vName ~= loweredSName then continue end
				local pattern = "^" .. loweredSName .. "%d*$"
				if SData["NumberFill"] and not string.match(vName, pattern) then continue end
				
				if not self.SurfaceElements[SName] then
					self.SurfaceElements[SName] = {}
				end
				
				if SData["NumberFill"] then
					local num = tonumber(string.match(vName, "%d+"))
					if not self.SurfaceElements[SName][num] then
						self.SurfaceElements[SName][num] = {}
					end
					self.SurfaceElements[SName][num]:Insert(v)
				else
					self.SurfaceElements[SName]:Insert(v)
				end
			end
		end
	end
end

return API
