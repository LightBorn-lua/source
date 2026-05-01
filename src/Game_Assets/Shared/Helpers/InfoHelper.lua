local module = {}

export type Info = {
	OnNewSiren: (SirenID: number) -> (),
	OnNewStage: (Stage: number) -> (),
	OnSirenUsed: (SirenName: string, IsOn: boolean, SirenID: number) -> (),
	OnExecute: (self: any, Override: any, SID: string?) -> (),
}

export type InfoData = {
	Send: (Mode: string, Data: any) -> (),
	AddConnect: (Connect: RBXScriptConnection) -> (),
	ClickEvent: (Button: GuiButton, CalbackName: string, any) -> (),
	HoldEvent: (Button: GuiButton, CalbackName: string, OnArgs: {}, OffArgs: {}) -> (),	
}

return module
