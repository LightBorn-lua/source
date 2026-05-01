type ActionName = "Send" | "SendOverride" | "SendOverrideWithID"
type ActionElement = {
	Press: {
		[string]: ActionName | () -> ()
	},
	Release: {
		[string]: ActionName | () -> ()
	}
}

local mod : ActionElement = {
	Press = {},
	Release = {}
}

mod.Press["Stage"] = "SendOverride"
mod.Press["Directional"] = "SendOverride"

mod.Press["Cruise"] = "Send"
mod.Press["LAlley"] = "Send"
mod.Press["RAlley"] = "Send"
mod.Press["Park"] = "Send"
mod.Press["Takedown"] = "Send"

mod.Press["Brake"] = "SendOverride"
mod.Press["Reverse"] = "SendOverride"

mod.Press["Wail"] = "SendOverrideWithID"
mod.Press["Yelp"] = "SendOverrideWithID"
mod.Press["Phaser"] = "SendOverrideWithID"
mod.Press["Hyper"] = "SendOverrideWithID"

mod.Press["Airhorn"] = "SendOverrideWithID"
mod.Release["Airhorn"] = "SendOverrideWithID"

mod.Press["Manual"] = "SendOverrideWithID"
mod.Release["Manual"] = "SendOverrideWithID"

mod.Press["PA"] = "SendOverrideWithID"
mod.Release["PA"] = "SendOverrideWithID"

mod.Press["Rumbler"] = "SendOverrideWithID"

return mod