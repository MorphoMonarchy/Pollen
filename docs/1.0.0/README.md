<h1 align="center">Pollen</h1>

<p align="center">
  <img src="Pollen/1.0.0/pollen_logo.png" alt="Pollen Logo" width="200">
</p>

<p align="center">
Pollen is a live updating particle effects builder library for GameMaker.<br>
<a href="https://github.com/MorphoMonarchy/Pollen">Download the latest version here</a>
</p>

<p class="warn">Pollen was built and tested on GameMaker v2024.13 but should work with some earlier versions as well.</p>

---

## Why Pollen?

I've always found GM's particle effects API very clunky & tedious to use, especially for larger projects that require more particle effects. The introduction of GM's [built-in particle editor](https://manual.gamemaker.io/monthly/en/The_Asset_Editors/Particle_Systems.htm) definitely helps with this issue. However, I still found editors did not fully solve the issue, since I still had to recompile the game every time to test them. Although I could hack together a solution using something like [GMLive](https://yellowafterlife.itch.io/gamemaker-live), there are times where it would be nice to have a free library that's easy to figure out and does all that work for you. That's what I aim to do with Pollen.  

To keep with the goal of making it "easy to figure out", I wanted to base the library off of one that many people are already familiar with so they can jump in and use it without having to peruse too much documentation at first. So I stole...er I mean "based" the library off of [Vinyl](https://www.jujuadams.com/Vinyl/#/6.2/README), a popular audio library for GameMaker that not only has live-reload capabilities, but its "JSON" format works perfectly for editing particle effects. (Thank you JuJu...and thank you MIT license).  

So as much as I hate admitting to riding off the coattails of another person's work, I would be lying if I didn't say that Pollen is basically "Vinyl but for particle effects". However, I also aimed to make the library flexible for different users/projects, so I've included additional util methods besides the live-reload 'JSON' to create, control, & clean up particles for users with different requirements or who don't prefer organizing their particle effects in that way.

---

## Features

* A simpler & more flexible interface for creating GM particles in runtime  
* Can use particles & GM particle assets as templates for new particles to reduce boilerplate  
* Getter methods to directly get specific data from a particle instead of using the particle-info struct every time  
* Setter methods with default args that can be chained together to "build" a particle without having to set redundant properties  
* A simple JSON format for defining particles that can be live-reloaded  
* Supports all of GameMaker's built-in properties for Types, Emitters, & Systems + more!

---

## Special Thanks

Huge shout out to [JuJuAdams](https://github.com/jujuadams) for all the work done on Vinyl and for the GameMaker community in general. This library would not exist without your work, so thank you!!