
# Graphical User Interface for [MINDFulMakie.jl](https://github.com/UniStuttgart-IKR/MINDFulMakie.jl)

This project aims to interactively visualize created intents with [MINDFulMakie.jl](https://github.com/UniStuttgart-IKR/MINDFulMakie.jl) while being lightweight, trivial and flexible to use. 

It is still in a very early state, so there is much more to come. This only shows a small set of current features.


## Features

- Create and visualize intents.
- Add any compatible .graphml topologies, they get detected automatically!
- You can zoom, stretch and move all graphs. Or even make one fullscreen.


## Deployment

Installing deps

```bash
~$ git clone https://github.com/Niels1006/MINDFulGLMakieApp.jl-1
```
```bash
~$ cd MINDFulGLMakieApp.jl-1
```
```bash
~/MINDFulGLMakieApp.jl-1$ Julia --project
```
```bash
julia> ]
```
```bash
(MINDFulGLMakieApp) pkg> instantiate
```

To run this project

```bash
~/MINDFulGLMakieApp.jl-1$ Julia -i src/Main.jl
```


## Screenshots

![App Screenshot](https://github.com/Niels1006/MINDFulGLMakieApp.jl-1/assets/16525967/3ea3c678-493e-44ed-8ded-2f0adb175751)
Create intents.

![App Screenshot](https://github.com/Niels1006/MINDFulGLMakieApp.jl-1/assets/16525967/649a6db2-33cf-4701-a829-2926fe8c1747)
Change the intent's state.

![App Screenshot](https://github.com/Niels1006/MINDFulGLMakieApp.jl-1/assets/16525967/be186721-62d7-4d5e-a1dc-c713406172ca)
Visualize the intent with either an intent-tree or an IBN-plot. Plots are interactive, so it's possible to zoom in/stretch them.

![App Screenshot](https://github.com/Niels1006/MINDFulGLMakieApp.jl-1/assets/16525967/8019e895-a3e4-49b7-bfaf-11e227a8b3b9)
Or make one fullscreen.


## Authors

- [@Niels1006](https://www.github.com/niels1006)


## Credits

- [MINDFul.jl](https://github.com/UniStuttgart-IKR/MINDFul.jl)
- [MINDFulMakie.jl](https://github.com/UniStuttgart-IKR/MINDFulMakie.jl)


