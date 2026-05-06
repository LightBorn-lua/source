---
title: Pattern API Reference
---

Reference to the pattern scripting.

---


### `spawn`
- **Type:** `(callback: () -> ()) -> (thread)`
- Creates a thread

---

### `cancel`
- **Type:** `(thread: thread) -> ()`
- Cancel a thread

---

### `Enable`
- **Type:** `(ELS: {}, ColorID: string, Time: number?) -> ()`
- Enable *(or disable)* a light
- ***Can take multiple lights***

---

### `Flicker`
- **Type:** `(ELS: {}, Time: number, WaitBetween: number, Colors: {}?, Rotations: number?) -> ()`
- Flicker a light

---

### `Value`
- **Type:** `(ELS: {}, Type: {}, Value: {}, TI: TweenInfo?, Yield: boolean?) -> ()`
- Change a specific value of a light, can be tween'd

---

### `GetELS`
- **Type:** `(ELS: {}, Start: number, End: number, Prefix: string?) -> ({})`
- Get a list of lights with a specific number (prefix optional)
- **Example:** ` GetELS({}, 1, 5, "red")` returns a list of every lights that has **red** as a prefix ***AND*** has a number between 1 and 5.

---

### `GetLen`
- **Type:** `(ELS: {}, Prefix: string) -> (number)`
- Get the number of lights, prefix optional

---
