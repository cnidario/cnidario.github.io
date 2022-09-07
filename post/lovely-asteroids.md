---
title: Lovely asteroids
date: 2021-04-10
description: "A weekend clone of asteroids game project"
---

Last month I wanted to test the only-code game engine [LÖVE](https://love2d.org/) which is based in [Lua](http://www.lua.org/). Even not having ever touched Lua, it was very straightforward to go. It took me maybe 15 hours split into two days, plus some more hours, days after, polishing it.
It's mostly a single file plus assets and a vector utility library.

Getting into code is pretty fast, in Arch `pacman -S love` and you can start coding. Aswell as running the game. Just `love .` from the game directory. Could be easier? :)

You need then 1 file, `main.lua` containing 3 functions:
 - `love.load()`
 - `love.update(dt)`
 - `love.draw(dt)`

Let's see an example which draws a rectangle
``` {.lua}
function love.draw(dt)
    love.graphics.setColor(0.5,0.1,0.2)
    love.graphics.rectangle('fill', 100, 100, 250, 400)
end
```

You can even do without load and update. If you now `love .` you will see this ugly rectangle.
![Image of a rectangle drew by LÖVE](../img/lovely-asteroids-1.png)

## Asteroids

It's a very simple clone with program generated graphics. Doesn't have a menu, just get into action.

Features of the game
 - Spawn & generation of random asteroids (ellipse based, some look really ugly, had to fix 8).
 - Collision of asterois with bullets & player.
 - Asteroids have a 'dimension', when you destroy one with dimension > 1 it explodes into multiple of dimension-1.
 - Sounds! ([with sfxr.me! fun!](https://sfxr.me/))
 - Lose condition.
 - No win condition *BUT* you have a score.
 - Particle effects and random bizarre juicing, especially explosions.
 - About 400 lines of spaguetti code.

I tried also to export it to Javascript but failed miserably. There are some attempts in GitHub to port it through Emscripten but I couldn't manage to make it to work after some tries.

Probably more fun to code than to play, anyway...

Enjoy coding!

![Image of the game](../img/lovely-asteroids-2.png)
