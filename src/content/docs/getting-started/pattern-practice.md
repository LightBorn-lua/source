---
title: Pattern Practices
---

LightBorn was developed in a way to be simple to use.

Yet there are "rules" to follow to make your experience comfortable.

## Module Rules
These rules cover what you need to follow to avoid unexpected issues with your pattern scripting.

### 1. Multiple modules cannot control the same light.

LightBorn works in a way where each module **MUST** control their own set of lights.

For example:

If I have a light called **"light 1"** with the module **"mod 1"** and **"mod 2"** controlling this light. Issues **WILL** start to appear.

The reason for this comes from the fact that **each modules works independently from each other.**

Therefore, **LightBorn does not handle assignment conflits by design**.


### 2. Name your modules properly.

This isn't exactly a requirement but something VERY recommanded.

The more and more complex your instance will be, the more modules there will be.

Therefore it is VERY recommanded to name your modules in a way that everyone can understand.


## Scripting Rules
These rules apply to the scripting of patterns inside of a module.

### 1. The content of a module must ALWAYS return a function

LightBorn hooks the environment of each modules to inject it's list of functions to control lights, etc.

Therefore, returning a function is a must for LightBorn to execute properly on a instance.

Failure to do so **results in a module expection**.

### 1. Define "RunOnce" on functions that requires it.

LightBorn works under a callback system, therefore modules are looped when needed and this can cause unneccesary usage if functions that needs to run only once gets loop.

For example: If a spotlight function only turns specific lights a white, this should not be looped as the light is already on.

To do so, the **RunOnce** attribute shall be defined in the module itself with the name of the function to be used, this will tell LightBorn to **only call this function once**.

### 2. DO NOT use the `task` library for threading.

Roblox integrates threading with `task.spawn` and `task.cancel`.

However, these tasks by default cannot be controlled by LightBorn **due to not being able to access the thread created**.

Thats where the `Environment` comes in place.

The pattern Environment **includes the `spawn` and `cancel` function** to be able to control those threads when needed *(shutdown, pattern switch, etc)*

Their function is **the same as the original function**, with the only difference that LightBorn has access to it.

# Function naming convention

:::warning
the naming convention is still experimental and is subject to change
:::

LightBorn's pattern scripting works under functions that follows a specific naming convention.

This convention is under the format `[TYPE]_[STAGE}`

For example: a function named `Stage_1` would activate once the `Stage` values is **1**

Simular to that, a function named `Horn` would activate whenever the `Horn` value is activated.


# Pattern scripting convention

The pattern scripting has a convention to follow too,∙self-explained

### ELSLocation must be defined at all times

Each LightBorn modules depends on the `ELSLocation` **global variable** to define which object will be used to fetch the lights the module will control.

Failure to do so will **result in a module exception**.

:::note
If the no lights are found, a warning will be given by LightBorn while still allowing the module to load.
:::