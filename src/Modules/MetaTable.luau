local Module = {}

export type MetaTable<T> = {
	Insert: (self: any, val: any) -> (),
	ValInsert: (self: any, ID: any, val: any) -> (),
	Remove: (self: any, val: any) -> (),
	Clear: (self: any) -> (),
	_getTable: T,
} & T

local IgnoreOnCopy = {"Clear", "Insert", "Remove", "ValInsert", "_indexUpdate"}

function copy(src: {})
	if type(src) ~= "table" then
		return error("src must be a table")
	end
	local result = {}
	for index, v in src do
		if table.find(IgnoreOnCopy, index) then continue end
		
		if type(v) == "table" then
			result[index] = copy(v)
		else
			result[index] = v
		end
	end
	return result
end

function proxify(tab: {}, Data: {}, mainprox: any, ran: boolean)
	if type(tab) ~= "table" or type(Data) ~= "table" then
		return error("tab and Data must be tables")
	end

	local proxy = newproxy(true)
	local meta = getmetatable(proxy)

	meta.__index = function(_, index)
		local idx = tab[index]

		if index == "_getTable" then 
			return copy(tab)
		end

		return type(idx) == "table" and proxify(idx, {}, ran and proxy or mainprox, false) or idx
	end

	meta.__newindex = function(self, index: any, value: any)
		if tab[index] == value then return end
		local old_tab = tab[index]
		tab[index] = value

		if self and self['_indexUpdate'] and type(value) ~= "function" then 
			self:_indexUpdate(index, value, old_tab)
		end
	end   

	function proxy:Insert(val)
		if not val then return end
		table.insert(tab, val)

		if mainprox and mainprox['_indexUpdate'] and type(val) ~= "function" then 
			mainprox:_indexUpdate(#tab, val, nil)
		end
	end

	function proxy:ValInsert(ID, val)
		if not ID then return end
		if tab[ID] then 
			warn("Overwriting existing value at index " .. tostring(ID))
		end
		tab[ID] = val

		if mainprox and mainprox['_indexUpdate'] and type(val) ~= "function" then 
			mainprox:_indexUpdate(ID, val, nil)
		end
	end

	function proxy:Clear()
		for n,_ in tab do
			if table.find(IgnoreOnCopy, n) then continue end
			tab[n] = nil
		end

		if mainprox and mainprox['_indexUpdate'] then 
			mainprox:_indexUpdate(nil, nil, nil)
		end
	end

	function proxy:Remove(val)
		if not val then return end
		if table.find(IgnoreOnCopy, val) then return end
		if tab[val] == nil then return end
		tab[val] = nil
		if mainprox and mainprox['_indexUpdate'] and type(val) ~= "function" then 
			mainprox:_indexUpdate(val, nil, nil)
		end
	end

	if ran then 
		for i,v in Data do 
			tab[i] = v
		end
	end

	return proxy
end

function Module.new(Data: {}) 
	if type(Data) ~= "table" then
		return error("Data must be a table")
	end
	return proxify({}, Data, nil, true) 
end

return Module
