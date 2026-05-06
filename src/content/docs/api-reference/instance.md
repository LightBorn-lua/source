---
title: Instance API Reference
---

This section refers to every method and property available on a `SystemData` instance.

---

:::tip

All methods and properties are accessible on the `SystemData` object returned during system initialization.

:::

## Methods

### `InitializeSurfaceControl`
- **Type:** `(self: SystemData) -> ()`
- Intiates the controller (if available)

---

### `IntializeSiren`
- **Type:** `(self: SystemData, Siren: string, SirenIDs: {number} | number) -> ()`
- Intiates the siren

---

### `RefreshSiren`
- **Type:** `(self: SystemData, IDs: {number} | number) -> ()`
- Refreshes a siren

---

### `SirenOn`
- **Type:** `(self: SystemData, SirenCategory: number, Name: string, Asset: {AssetID: string, Volume: number, Speed: number}, Playing: boolean, NoEffectCheck: boolean?, Player: Player?) -> ()`
- Play a siren

---

### `SirenOff`
- **Type:** `(self: SystemData, SirenCategory: number) -> ()`
- Stop a siren

---

### `EnableSiren`
- **Type:** `(self: SystemData, Siren: string, IDs: {number} | number, Overwrite: boolean?, Player: Player | boolean | nil) -> ()`
- Logic for siren handling - enabling

---

### `DisableSiren`
- **Type:** `(self: SystemData, IDs: {number} | number | "All", Stop: boolean?, Ignore: {string}?) -> ()`
- Logic for siren handling - disabling

---

### `ResumeSiren`
- **Type:** `(self: SystemData, IDs: {number} | number) -> ()`
- Logic for siren handling - resuming

---

### `CleanUp`
- **Type:** `(self: SystemData) -> ()`
- Clean up the instance

---

### `InitializeUI`
- **Type:** `(self: SystemData, Player: Player, Seat: Seat) -> ()`
- Initialize the controller UI for a player seated (if any)

---

### `RemoveUI`
- **Type:** `(self: SystemData, Seat: Seat) -> ()`
- remove the controller UI from the player seated

---

### `InitializeController`
- **Type:** `(self: SystemData) -> ()`
- Initialize the logic for the controller

---

### `ChangeStatus`
- **Type:** `(self: SystemData, From: string, NewVal: any) -> ()`
- Update the pattern when an update occures

---

### `Int_Lightos`
- **Type:** `(self: SystemData) -> ()`
- Initialize the lights

---

### `InitializeModules`
- **Type:** `(self: SystemData, ModulesLocation: Instance) -> ()`
- Initialize the pattern modules

---

### `CreateTask`
- **Type:** `(self: SystemData, module: string, name: string, exe: () -> ()) -> ()`
- Create a pattern task

---

### `KillTask`
- **Type:** `(self: SystemData, module: string, name: string, NoDL: boolean?) -> ()`
- Kill a pattern task

---

### `KillAllTask`
- **Type:** `(self: SystemData) -> ()`
- Kill all pattern tasks

---

## Properties

### `Halted`
- **Type:** `boolean`
- Whenever the system is halted (for clean up)

---

### `DefaultLightProp`
- **Type:** `{ Shadow: boolean?, Range: number?, Angle: number?, Brightness: number? }`
- **DefaultLightProp** propriety

---

### `SirenDefaultProp`
- **Type:** `{ Volume: number, Speed: number }`
- **SirenDefaultProp** propriety

---

### `SpecialNames`
- **Type:** `{}`
- List of states that are considered "special", uses a different logic

---

### `ID`
- **Type:** `string`
- ID of the instance

---

### `System`
- **Type:** `Instance`
- The instance

---

### `CurrentStage`
- **Type:** `number`
- The current stage

---

### `MaxStage`
- **Type:** `number`
- **MaxStage** propriety

---

### `MaxDir`
- **Type:** `number`
- **MaxDir** propriety

---

### `CurrentDir`
- **Type:** `number`
- The current directional stage

---

### `CurrentAlt`
- **Type:** `number`
- The current alternative value

---

### `Toggles`
- **Type:** `{[string]: boolean}`
- Unused

---

### `Settings`
- **Type:** `Config`
- The instance configuration

---

### `SurfaceElements`
- **Type:** `{[string]: Instance}`
- All of the surfaces from the controller

---

### `AvailableSirens`
- **Type:** `{[number]: string}`
- List of every available siren instances

---

### `SirenParts`
- **Type:** 
  ```lua
  {
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
  }
  ```
- List of every siren parts

---

### `SirenSounds`
- **Type:** `{[number]: Instance}`
- Unused

---

### `Modules`
- **Type:**
  ```lua
  {
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
  }
  ```
- List of every pattern modules

---
