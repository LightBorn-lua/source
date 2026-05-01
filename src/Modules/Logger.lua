function ISOTime() return os.date("!%Y-%m-%dT%H:%M:%SZ") end

local module = {}

function module.print(...: any)
	print(`[LightBorn - {ISOTime()}]`, ...)
end

function module.warn(...: any)
	warn(`[LightBorn - {ISOTime()}]`, ...)
end

function module.error(...: any)
	error(`[LightBorn - {ISOTime()}] {table.concat({...}, " ")}`)
end

return module
