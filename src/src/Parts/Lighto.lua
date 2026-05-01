local Module = {}

local Parts = script.Parent
local src = Parts.Parent
local Root = src.Parent
-----------------
local Helpers = Root.Helpers

local Helper = require(Helpers.Helper)

Module.newELSData = function(Lighto: BasePart)
	local Data = {} :: Helper.LightData
	
	Data.Color = Lighto:FindFirstChild("ColorValue") :: StringValue?
	Data.Light = Lighto:FindFirstChild("LightValue") :: NumberValue?
	Data.Lighto = Lighto:FindFirstChild("BrightValue") :: NumberValue?
	
	Data.Status = Lighto:FindFirstChild("Status") :: BoolValue?
	Data.GlowColor = Lighto:FindFirstChild("GlowValue") :: StringValue?
	
	return Data
end

Module.new = function(self: Helper.SystemData, Lighto: BasePart, Face: Enum.NormalId)
	local Light: SpotLight = Instance.new("SpotLight")
	Light.Enabled = false
	Light.Name = "Light"
	Light.Face = Face
	
	local Shadow = self.DefaultLightProp["Shadow"]
	local Angle = self.DefaultLightProp["Angle"]
	local Range = self.DefaultLightProp["Range"]
	
	if Angle then
		Light.Angle = Angle
	end
	
	if Range then
		Light.Range = Range
	end
	
	if Shadow then
		Light.Shadows = Shadow
	end
	
	Light.Parent = Lighto
end

return Module