---
title: Your First System
---

:::tip

To start off, it is recommanded to also take base on the **existing example provided with LightBorn.**

:::

:::note

This guide considers that you are using the **default tag names provided with LightBorn.**

:::

## Creating the base

It comes down to a few simple steps

-----

<Steps>

1. Create a `Model` and add the *Tag* `LB_System` to it

    We will name it **"System"** for the sake of this guide, but any name works
    
    ***IMAGE SHOWCASE HERE***

2. Add a `ModuleScript` called " ***Configuration*** " and **[configure it as you wish](https://example.com)**

    :::danger

    Case sensitive, an error will be thrown if not named correctly

    :::

</Steps>

-----

This makes sure that every required parts of a system is there

allowing LightBorn to initialize it.


## Creating a simple light

LightBorn has a rather simple setup for preparing and controlling a light.

We will go over how to simply create a **light** that switch between **red and blue** every `0.5 seconds`

-----

<Steps>

1. Create a `Model` inside of your `System Model`

    We will name it **"Lights"**, but again any name works
    
    ***IMAGE SHOWCASE HERE***

2. Inside of said model, create a `Part` *(don't forget to anchor it)* and add the tag `LB_Lighto` to it
    *We will name it **"Light 1"**, but any name works as always*
    <Steps>
    
    1. Add a `String Attribute` to said part named **"Type"**
    2. Set this attribute to **"Part"**

    ***IMAGE SHOWCASE HERE***

</Steps>

-----
