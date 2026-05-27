---
title: Your First Instance
---

:::tip

To start off, it is recommanded to also take base on the **existing example provided with LightBorn.**

:::

:::note

This guide considers that you are using the **default tag names provided with LightBorn.**

To find more content such as configuration and others. __**please read the API Reference**__

:::

## Creating the base

The base of your instance, only a few steps are needed to do so:

-----

<Steps>

1. Create a `Model` and add the **Tag** `LB_System` to it.

    We will name it **"System"** for the sake of this guide, but any name works
    
    ***IMAGE SHOWCASE HERE***

2. Create another `Model` called `Lights` **inside of the `Model` created on step 1.**

</Steps>


## Creating a simple light

Now that your instance is able to be initiated, you won't see much during play-testing.

To fix that, lets add a simple **light** that switch between **red and blue** every `0.5 seconds`

-----

Inside of your `Lights` Model, create a `Part` *(anchor it too)* and add the tag `LB_Lighto` to it

*We will name it **"Light 1"**, but any name works as always*
<Steps>

1. Add a `String Attribute` to said part named **"Type"**
2. Set this attribute to **"Part"**

there are **multiple types to choose from**, read about it [here](https://example.com).

***For the sake of this guide, we will be using the Part type.***

***IMAGE SHOWCASE HERE***

</Steps>

-----

### Scripting the light

Now that the light is setup, we can finally script it.

To do so, create a `Folder` called `Modules`.

This folder is what will store all of our pattern scripts.

:::caution

Read the **[pattern practices](https://example.com)** page to read about the best practices.

:::

From this folder, we can create a `ModuleScript` inside of it. *(the name does not matter)*