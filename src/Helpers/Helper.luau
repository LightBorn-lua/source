type SirenType = "Wail" | "Yelp" | "Phaser" | "Manual" | "Airhorn" | "Hyper" | "Q2"

export type SystemInstance = Instance & {
	Values: Folder,
	SirenValues: Folder,
	Sirens: Model?
}

export type SirenData = {
	SoundID: {default: number, alternative: number?},
	Volume: number,
	Speed: number,
	Instances: {
		[number]: {
			{class: string, properties: {}}
		}
	}?
}

export type Config = {
	Renderer: "Client" | "Server",
	
	OnInterfaceUse: (self: SystemData, Mode: "Stage" | "Dir" | "Siren" | "SpecialSiren" | "Rumbler" | "Special", Value: any, Status: boolean?) -> ()?,
	
	UseLegacyAudio: boolean?,
	
	CustomTypes: {
		[string]: {
			IsStatus: boolean?,
			Type: string
		}
	},
	
	SeatLocations: {Instance},
	TurnOff: {[string]: {[string]: {number | boolean}} },
	TurnOn: {[string]: {[string]: {number | boolean}} },
	
	DefaultStage: number?,
	DefaultDir: number?,
	MaxStage: number?,
	MaxDir: number?,
	
	LightProperties: {
		Shadow: boolean?,
		Range: number?,
		Angle: number?,
		Brightness: number?
	},
	LightLocation: {Instance}?,
	
	Colors: {[string]: Color3},
	
	Interface: string?,
	Keybinds: {[string]: Enum.KeyCode},
	
	Sirens: {
		[SirenType]: SirenData,
	}?,
	
	SirenProperties: {
		["Volume"]: number,
		["Speed"]: number,
		["Looped"]: boolean,
		["AcousticSimulation"]: boolean,
		
		["Distance"]: {[string]: any},
		["Angle"]: {[string]: any}
	},
	
	LegacySirenProperties: {
		["Volume"]: number,
		["Speed"]: number,
		["Looped"]: boolean,
		
		["RollOffMinDistance"]: number,
		["RollOffMaxDistance"]: number,
		["RollOffMode"]: Enum.RollOffMode,
	}?,
	
	Lighto: string?,
	Face: string?,
	
	Q2: {Up: number, Down: number, Max: number}?,
	
	PA: boolean?,
	ParkStage: number?,
	
	Priority: {[string]: number},
	DefaultPriority: number,
}

export type SystemData = {
	
	---------- FUNCTIONS ----------
	InitializeSurfaceControl: (self: SystemData) -> (),

	IntializeSiren: (self: SystemData, Siren: string, SirenIDs: {number} | number) -> (),
	RefreshSiren: (self: SystemData, IDs: {number} | number) -> (),
	SirenOn: (self: SystemData, SirenCategory: number, Name: string, Asset: {AssetID: string, Volume: number, Speed: number}, Playing: boolean, NoEffectCheck: boolean?, Player: Player?) -> (),
	SirenOff: (self: SystemData, SirenCategory: number) -> (),
	EnableSiren: (self: SystemData, Siren: string, IDs: {number} | number, Overwrite: boolean?, Player: Player | boolean | nil) -> (),
	DisableSiren: (self: SystemData, IDs: {number} | number | "All", Stop: boolean?, Ignore: {string}?) -> (),
	ResumeSiren: (self: SystemData, IDs: {number} | number) -> (),
	
	InitConnections: {[string]: () -> ()},
	CleanUp: (self: SystemData) -> (),
	InitializeUI: (self: SystemData, Player: Player, Seat: Seat) -> (),
	RemoveUI: (self: SystemData, Seat: Seat) -> (),
	InitializeController: (self: SystemData) -> (),
	ChangeStatus: (self: SystemData, From: string, NewVal: any) -> (),
	Int_Lightos: (self: SystemData) -> (),
	InitializeModules: (self: SystemData, ModulesLocation: Instance) -> (),
	
	CreateTask: (self: SystemData, module: string, name: string, exe: () -> ()) -> (),
	KillTask: (self: SystemData, module: string, name: string, NoDL: boolean?) -> (),
	KillAllTask: (self: SystemData) -> (),
	
	---------- VALUES ----------
	
	Halted: boolean,
	DefaultLightProp: {
		Shadow: boolean?,
		Range: number?,
		Angle: number?,
		Brightness: number?
	},
	SirenDefaultProp: {
		Volume: number,
		Speed: number,
	},
	SpecialNames: {},
	

	ID: string,
	System: SystemInstance,
	CurrentStage: number,
	MaxStage: number,
	MaxDir: number,
	CurrentDir: number, 
	CurrentAlt: number, 
	Toggles: {[string]: boolean},
	Settings: Config,
	SurfaceElements: {[string]: Instance},
	
	AvailableSirens: {[number]: string},
	SirenParts: {
		[number]: {
			[number]: {
				["Player"]: AudioPlayer,
				["Emitter"]: AudioEmitter,
				["Effects"]: Folder,
				["Wires"]: {
					["Player"]: Wire,
					["Effects"]: {Wire}
				}
			}		
		}
	},
	SirenSounds: {[number]: Instance},
	Modules: {
		[string]: {
			Content: {},
			Tasks: {[string]: thread},
			Spawns: {[string]: thread},
			DL: () -> (),
			Settings: {
				RunOnce: {string},
				
			},
			RunningData: string,
			Data: {
				[string]: {
					Started: boolean,
					Cancelled: boolean,
					Running: boolean,
					Ended: boolean,
					Stopped: boolean
				}
			}
		}	
	},

}

export type LightData = {
	Color: StringValue?,
	Light: NumberValue?,
	Lighto: NumberValue?,
	
	Status: BoolValue?,
	GlowColor: StringValue?
}

return {}
