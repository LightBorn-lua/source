SharedData = {}

local module = {}

local SirenValues = {
	["Airhorn"] = "BoolValue",
	["Hyper"] = "BoolValue",
	["Manual"] = "BoolValue",
	["PA"] = "BoolValue",
	["Phaser"] = "BoolValue",
	["Wail"] = "BoolValue",
	["Yelp"] = "BoolValue",
	
	["Config"] = {
		["Current"] = "StringValue",
		["IsAlt"] = "BoolValue",
		["Old"] = "StringValue",
	}
}

function module.GenerateSirenValues(Target: Instance)
	for Name, Type in SirenValues do
		if typeof(Type) == "table" then
			local Folder_Target = Instance.new("Folder", Target)
			for FName, FType in Type do
				local Value = Instance.new(FType)
				Value.Name = FName
				Value.Parent = Folder_Target
			end
		else
			local Value = Instance.new(Type)
			Value.Name = Name
			Value.Parent = Target
		end
	end
end

function module.SetUpSharedHandler(Shared: Folder)
	local Handler = Instance.new("RemoteEvent")
	Handler.Name = "Handler"
	Handler.Parent = Shared
end

return function()
	return module
end
