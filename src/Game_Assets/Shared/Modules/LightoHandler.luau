local LightoFunctions = require(script.Parent.LightoFunctions)

local Elements = {
	-- function, run before
	["ColorValue"] = {execute = LightoFunctions.Color, autorun = true},
	["LightValue"] = {execute = LightoFunctions.LightBright, autorun = true},
	["BrightValue"] = {execute = LightoFunctions.LightoBright, autorun = true},
	
	["Status"] = {execute = LightoFunctions.Effect, autorun = true},
}

return function(Part: Instance, Colors: {}, Client: boolean?)
	if not Part then return end
	
	for n,v in Elements do
		task.spawn(function()
			local FoundEl: Instance = Client and Part:WaitForChild(n, 5) or Part:FindFirstChild(n) :: ValueBase
			if not FoundEl then return end

			if not FoundEl:IsA("ValueBase") then return end
			FoundEl.Changed:Connect(function(Value: any) 
				v["execute"](Part, Value, Colors)
			end)

			if v["autorun"] then
				-- why does it not find value, it's a value base????
				v["execute"](Part, (FoundEl :: any).Value, Colors)
			end
		end)
	end
end
