# Contributing to the repository

LightBorn is a community project and welcomes any kind of contribution from anyone.

All contributions should be made in accordance to the **[Code of Conduct](./CODE_OF_CONDUCT.md)**.
## How to contribute

Contributions can be sent via pull requests. If you're new to GitHub / Git, read **[this guide](https://opensource.com/article/19/7/create-pull-request-github)**.

Pull requests **needs** to follow the branches specified on this document, else it **WILL** be closed.

## Contributing to LightBorn

**Pull requests are to be made on the `dev` branch**, this is to avoid conflicts with the `main` branch and ensure a smooth workflow.

**Please consider the following before writing for LightBorn:**
- Follow the [Angular commit convention](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines) *(check 'How to commit')*
- Making sure that right branch is being pushed to
- Follow the **[Code of Conduct](./CODE_OF_CONDUCT.md)**

If you find bugs, feel free to fix them and pull request it.

If you want a new feature added, open a **feature request** so that we can discuss it first.

If a major change is to be made for a pull request, **open a feature request first** to make sure that it won't go to waste. *(saves the time of everyone)*

----

LightBorn uses **[Semantic Release](https://github.com/semantic-release/semantic-release)** to automate version management.

Sementic Releases stricly follows the **[Semantic Versioning](http://semver.org/)** standard, used by LightBorn.

Therefore it requires the following dependencies:
- RoKit
- Bun

To get setup the environment once you have the following dependencies, the following commands are to be run:
- `bun install` -- install **Commitizen, CommitLint**
- `bun prepare` -- configures **Husky**
- `rokit install` -- install **Rojo**

***NOTE: Commitizen and CommitLint are mandatory to use to follow the Semantic Release format with ease***

### How to commit ?

To commit, there isn't much differences.

The only difference is to use `bun cm` instead of `git commit` to choose the commit message thanks to **Commitizen**


## Helping the community

We have an open support channel in our **[Discord server](https://discord.gg/kZpxmSgnrN)**.
Helping out others is always appreciated!
