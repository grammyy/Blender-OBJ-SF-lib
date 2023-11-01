# Blender OBJ library for Starfall
This is a unique approach to blender objs and rendering them ingame, instead of using holos, this completely sidesteps that. This library uses customprops directly, allowing you to place and use however many your computer can handle (in most cases, servers will have you limited to 1000)

It uses an on-demand delivery system for clients, so there is no need for any worry for clients not seeing. Information is automatically requested from the client to the server whenever needed with a failsafe design.

Features
* Plug-and-play system for delivering and managing OBJs
* Global, model, or part-specific settings for both importing and spawning
* Allows you to import with settings baked into the model and infinite spawning of the same model with its own independent settings.
* Failsafe system to retry sending data should data fail to send or trigger a quota

Features in the future
* Vertex shader pipeline, currently only manually supported
  
![](https://github.com/Elias-bff/Elias.github.io/blob/main/packaging/Screenshot%202023-10-15%20030708.png?raw=true)
![](https://github.com/Elias-bff/Elias.github.io/blob/main/packaging/Screenshot%202023-10-15%20163806.png?raw=true)
![](https://github.com/Elias-bff/Elias.github.io/blob/main/packaging/Screenshot%202023-11-01%20183143.png?raw=true)
