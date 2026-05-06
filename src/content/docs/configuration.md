---
title: Instance Configuration
---

## Configuration Reference

This section refers to every configuration values of a LightBorn instance.

----

:::tip

Everything here can be considered as **optional**

Default values are generated if a required configuration is missing

:::

### `Renderer`
- **Type:** `"Client" | "Server"`
- Specifies whether the rendering should be handled on the client or server side. Defaults to the global config

---

### `OnInterfaceUse`
- **Type:** `(self: SystemData, Mode: "Stage" | "Dir" | "Siren" | "SpecialSiren" | "Rumbler" | "Special", Value: any, Status: boolean?) -> ()?`
- A callback function triggered when an interface element is used.
- **Parameters:**
  - `self`: The `SystemData` context.
  - `Mode`: The type triggered.
  - `Value`: The value being pushed.
  - `Status`: For toggles, the status of it.

---

### `UseLegacyAudio`
- **Type:** `boolean?`
- If `true`, enables legacy audio system for compatibility.

---

### `CustomTypes`
- **Type:** `{[string]: { IsStatus: boolean?, Type: string }}`
- Defines custom types for system components.
- **Keys:** String identifiers.
- **Values:** Objects with:
  - `IsStatus`: Indicate if the type represents a status.
  - `Type`: String name of the custom type.

---

### `SeatLocations`
- **Type:** `{Instance}`
- List of `Instance` objects representing vehicle seats where systems are attached.

---

### `TurnOff`
- **Type:** `{[string]: {[string]: {number | boolean}}}`
- Automatic turn off of specific statuses when requirements are met.
- ADD EX

---

### `TurnOn`
- **Type:** `{[string]: {[string]: {number | boolean}}}`
- Requirements for turning   on a status.
- ADD EX

---

### `DefaultStage`
- **Type:** `number?`
- Stage state set by default.

---

### `MaxStage`
- **Type:** `number?`
- Maximum state for stage.

---

### `DefaultDir`
- **Type:** `number?`
- Directional state set by default.

---

### `MaxDir`
- **Type:** `number?`
- Maximum state for directional.

---

### `LightLocation`
- **Type:** `{Instance}?`
- List of `Instance`s reference indicating where lights are located.

---

### `LightProperties`
- **Type:** `{ Shadow: boolean?, Range: number?, Angle: number?, Brightness: number? }`
- Default properties for lights:
  - `Shadow`: Enables shadow casting.
  - `Range`: Light reach distance.
  - `Angle`: Cone angle (for spotlights).
  - `Brightness`: Intensity level.

---

### `Colors`
- **Type:** `{[string]: Color3}`
- Named color definitions lights colors.
- **Example:** `"Blue": Color3.fromRGB(0, 0, 255)`

---

### `Interface`
- **Type:** `string?`
- Identifier for the UI interface to load.

---

### `Keybinds`
- **Type:** `{[string]: Enum.KeyCode}`
- Maps action names to inputs.
- **Example:** `"ToggleSiren": Enum.KeyCode.E`

---

### `Sirens`
- **Type:** `{[SirenType]: SirenData}?`
- Map of siren configurations.
- Uses [`SirenType`](#sirentype) as key and [`SirenData`](#sirendata) object as value.

---

### `SirenProperties`
- **Type:** 
  ```lua
  {
    Volume: number,
    Speed: number,
    Looped: boolean,
    AcousticSimulation: boolean,
    Distance: {[string]: any},
    Angle: {[string]: any}
  }
  ```

---

### `Lighto`
- **Type:** `string?`
- Identifier for the light display to use for the standard type.

---

### `Face`
- **Type:** `string?`
- Identifier for the Face to use on the standard type.

---

### `PA`
- **Type:** `boolean?`
- Whenever the speaker system is enabled.

---

### `Priority`
- **Type:** `{[string]: number}?`
- Map of priority to set for specific tasks.

---

### `DefaultPriority`
- **Type:** `number?`
- The default priority for tasks.

---

## Configuration Types

### `SirenType`
- **Type:** ``"Wail" | "Yelp" | "Phaser" | "Manual" | "Airhorn" | "Hyper" | "Q2"``
- Different type of Siren that can exist. Used in **[Sirens](#sirens)** 

### `SirenData`
- **Type:**
 ```lua
  {
    SoundID: {default: number, alternative: number?},
    Volume: number,
    Speed: number,
    Instances: {
      [number]: {
        {class: string, properties: {}}
      }
    }?
  }
  ```
- Data of a siren instance. Used in **[Sirens](#sirens)**
- **SoundID:** **Default** and **alternative** `SoundID` for the siren.
- **Volume:** Default volume of the siren.
- **Speed:** Default playback speed of the siren.
- **Instances:** Map of instances added to siren. (can be used for effects, etc)