export type Env = {
	Enable: (ELS: {}, ColorID: string, Time: number?) -> (),
	Flicker: (ELS: {}, Time: number, WaitBetween: number, Colors: {}?, Rotations: number?) -> (),
	Value: (ELS: {}, Type: {}, Value: {}, TI: TweenInfo?, Yield: boolean?) -> (),
	GetELS: (ELS: {}, Start: number, End: number, Prefix: string?) -> ({}),
	GetLen: (ELS: {}, Prefix: string) -> (number),
	spawn: (callback: () -> ()) -> (thread),
	cancel: (thread: thread) -> ()
}

return {}