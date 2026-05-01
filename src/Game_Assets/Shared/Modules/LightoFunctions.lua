local module = {}

function module.Color(Part: BasePart, Value: any, Colors: {})
	local Color: Color3 | string = Colors[Value]
	if not Color then Color = "off" end
	local LightoClone = Part:FindFirstChild("Lighto") :: SurfaceGui
	local Light: SpotLight = Part:FindFirstChild("Light") :: SpotLight

	if Color == "off" then
		if LightoClone then LightoClone.Enabled = false end
		Light.Enabled = false
		if Part:GetAttribute("Type") == "part" then
			Part.Transparency = 1
		end
		return
	end
	
	Light.Enabled = true
	if Part:GetAttribute("Type") == "part" then
		Part.Transparency = 0
		Part.Color = Color :: Color3
	end
	
	if LightoClone then
		LightoClone.Enabled = true
		if LightoClone:IsA("SurfaceGui") then
			LightoClone.Glare.ImageColor3 = Color
		else
			LightoClone.Color = ColorSequence.new(Color :: Color3)
		end
	end
	Light.Color = Color :: Color3
end

function module.LightBright(Part: BasePart, Value: any)
	if Value < 0 then return end
	(Part:FindFirstChild("Light") :: SpotLight).Brightness = Value
end

function module.LightoBright(Part: BasePart, Value: any)
	do
		if Value < 0 then return end
		
		if Part:GetAttribute("Type") == "part" then
			Part.Transparency = 1 - Value
			return
		end
		
		local Lighto: Instance = Part:FindFirstChild("Lighto") :: SurfaceGui
		if not Lighto then return end

		local Glare = Lighto:FindFirstChild("Glare") :: ImageLabel
		local Blue = Lighto:FindFirstChild("Blue") :: ImageLabel
		
		Blue.ImageTransparency = Value
		Glare.ImageTransparency = Value
	end
end

function module.Effect(Part: BasePart, Value: any)
	(Part:FindFirstChild("Lighto") :: SurfaceGui).Enabled = Value
end


return module
