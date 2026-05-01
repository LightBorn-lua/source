local src = script.Parent.Parent
local Root = src.Parent
-----------------
local Helpers = Root.Helpers
local Modules = Root.Modules

local Helper = require(Helpers.Helper)
local Logger = require(Modules.Logger)

local API = {} :: Helper.SystemData

function API:CreateTask(module: string, name: string, exe: () -> ())
	local CurModule = self.Modules[module]
	if not CurModule then
		Logger.warn("WARNING :: MODULE", module, "DOES NOT EXIST") 
		return false
	end
	
	if CurModule.Tasks[name] then
		self:KillTask(module, name, true)
	end
	
	CurModule.Tasks[name] = task.spawn(function()
		CurModule.Data[name].Ended = false
		CurModule.Data[name].Running = true

		exe()

		if table.find(CurModule.Settings.RunOnce._getTable, name) then
			CurModule.Data[name].Running = true
			CurModule.Data[name].Stopped = true
		else
			do
				CurModule.Data[name].Running = false
				CurModule.Data[name].Ended = true
				task.delay(0, function() self.InitConnections["TaskUpdate"](self, CurModule._getTable, module) end)
			end
		end
	end)

	return true
end

function API:KillTask(module: string, name: string, NoDL: boolean?)
	local CurModule = self.Modules[module]
	if not CurModule then return false end
	if not CurModule.Tasks[name] then return false end

	task.cancel(CurModule.Tasks[name])

	CurModule.Data[name].Running = false
	CurModule.Data[name].Ended = true

	if not NoDL then
		CurModule.DL()
	end

	CurModule.Tasks:Remove(name)

	return true
end

function API:KillAllTask()
	for modname, module in self.Modules._getTable do
		local CurModule = self.Modules[modname]
		for name,running in module.Tasks._getTable do
			task.cancel(running)
			CurModule.Tasks:Remove(name)
		end
		
		for name,running in module.Spawns._getTable do
			task.cancel(running)
			CurModule.Spawns:Remove(name)
		end
	end
end

return API
