<p align="center">
  <img src=https://i.imgur.com/DnBMqSZ.png alt="Pollen Logo" width="50%">
</p>
<h1 align="center">Pollen 1.0</h1>

<p align="center">
A live updating particle effects builder library for GameMaker based on JujuAdams' <a href="https://www.jujuadams.com/Vinyl/#/6.2/README">Vinyl</a>.<br>
<a href="https://github.com/MorphoMonarchy/Pollen">Download the latest version here!</a>
</p>

<p class="warn">Pollen was built and tested on GameMaker v2024.13 but may work with some older versions as well.</p>

## Features

* A simpler & more flexible interface for creating GM particles in runtime  
* Can use particles & GM particle assets as templates for new particles to reduce boilerplate  
* Getter methods to directly get specific data from a particle instead of using the particle-info struct every time  
* Setter methods with default args that can be chained together to "build" particles without redundant properties  
* A simple JSON format for defining particles that can be live-reloaded  
* Supports all of GameMaker's built-in properties for Types, Emitters, & Systems, + more!

## Why Pollen?

I've always found GM's particle API tedious to use, especially for larger projects that require more particle effects. The introduction of GM's [built-in particle editor](https://manual.gamemaker.io/monthly/en/The_Asset_Editors/Particle_Systems.htm) definitely helps with this issue. However, I found that editors did not fully solve the problem since I still had to recompile the game every time I made a small tweak. 

Of course, a library like [GMLive](https://yellowafterlife.itch.io/gamemaker-live) could solve this issue, though, as far as I know, it does not support live-updating particle assets, so it would still require using GM's tedious API. But even if it did support GM particle assets, I still think it would be nice to have a free library out there that's easy to figure out and gives you different options for creating particle effects. That's what I aim to do with Pollen.  

In the spirit of making it "easy to figure out", I wanted to base the library off one that many people are already familiar with so they can jump in and use it without having to peruse too much documentation right away. So that's why Pollen was stolen...er I mean "inspired by" [Vinyl](https://www.jujuadams.com/Vinyl/#/6.2/README), a popular audio library for GameMaker made by [JujuAdams](https://github.com/jujuadams) that not only has live-reload capabilities, but, in my opinion, its 'JSON' format works perfectly for editing particles. (Thank you Juju...and thank you MIT license). 

However, I also aimed to make the library flexible for different users/projects, so I've included additional util methods besides the live-reload 'JSON' to create, control, & clean up particles for users with different requirements, or who prefer organizing their particle effects in a different way.  

## Special Thanks

Huge shout out to [JujuAdams](https://github.com/jujuadams) for all the work done on Vinyl and for the GameMaker community in general. This library would not exist without your work, so thank you!

Also major thanks to [CataclysmicStudios](https://github.com/CataclysmicStudios) for the ["Tome"](https://github.com/CataclysmicStudios/Tome) library which helped generate this documentation!