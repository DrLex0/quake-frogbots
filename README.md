# Quake Frogbot Clan Arena v2

Based on:
- _FBCA, Frogbot Clan Arena_ - mod that combines Frogbot, ParboiL's Clan Arena and Kombat Teams (KTPro)
- _Trinca_ and _Spike's_ last known sources
- Decompiled source file from the _old waypoint tool_ (how dare I decompile a 25-year old abandoned program, so sue me)


## What in Shub-Nigguraths name is a Frogbot?

The Quake Frogbot allows to add computer-controlled players to the first _Quake_ game. (Not to be confused with some JFrog thing.) It was created by _Robert 'Frog' Field_ in 1997. The Frogbot is regarded as one of the better performing bots. With a properly crafted waypoint file, the bots simulate a real human opponent rather well, and are still impressive despite their age and the fact that it is all implemented in QuakeC, a language that lacks things like arrays, dictionaries, or string manipulation.  
Simply put, _the Frogbot is a load of fun._ It is great for some offline practice or warm-up.

The bot relies on _waypoint files_ that have to be created for each map. In older Frogbot incarnations, waypoints needed to be compiled into the _qwprogs.dat._ In the first decade of the 21st century, _Trinca_ did a gargantuan job of making and collecting waypoints for a total of about 400 maps.

The old Frogbot had a few issues that lead to its development grinding to a halt and practically nobody creating new waypoints after Trinca's anymore:
- Building the qwprogs with support for more than a few 100 maps was only possible with a very specific Windows build of the FTEQCC compiler.
- It was not possible to add Frogbot support to a map without recompiling the _qwprogs.dat,_ which lead to an obvious problem of getting one's new maps added to whatever was the most popularly distributed Frogbot build.
- Only 1 waypoint creation tool was available, and it had quite a few usability problems, making the workflow awkward and risky (certain actions would crash it).
- The source for the waypoint tool had become unavailable (or near impossible to find), making it infeasible to resume editing existing waypoints. Either one had to do a whole map in one go (insane for larger maps), or manually edit the waypoints (just plain insane even for tiny maps).


## What is the difference with the KTX Frogbot?

Although born from the same origin, this is a different Frogbot fork than [the one included in KTX](https://github.com/QW-Group/ktx). The differences are:

- The Frogbots from this fork can run directly as a mod in a QuakeWorld _client_ like ezQuake, while KTX is a _server_ mod, which can only run on one of the supported platforms.
- This fork is branched from the [FBCA repository](https://github.com/ezQuake/fbca) whose last change was in 2016, while the bot and arena code in KTX has seen some recent changes, even in 2025.
- The KTX bots are (re)implemented in plain C, while this fork of the older Frogbot is implemented in QuakeC. Try these oldschool bots however, and you'll see that QuakeC can kick some serious butt, and one can still learn an old bot new tricks.


## Why this project?

In short, the main 2 goals are to allow the casual Quake player to have easy instant fun with the Frogbots, and to enable people to easily produce new waypoints.

In more detail, the purpose is to revive the classic Frogbot Quake(world) mod in a way that:
- makes it much easier to build the `qwprogs.dat` with any recent version of fteqcc or maybe other compilers;
- makes it much easier to create and edit waypoints — doing this is fun enough that I already did it for a few maps, and more may follow;
- makes it possible and easy to resume editing existing waypoint data;
- makes it possible to embed waypoint data in maps, or load them through an `.ent` file, to avoid the need to compile them into the qwprogs;
- fixes some issues and adds some features to the bots.

Reviving and improving the _waypoint tool_ was one of the main goals, to make it much easier to create new waypoints for maps, because there would be little use in reviving the classic Frogbot if we would be stuck with a set of maps from before 2012.  
The output of the tool might also be usable to generate waypoints for the KTX Frogbots, if some kind of translation tool is available.

However, while working on the tool and testing newly created waypoints, I also noticed some things I could improve about the bots themselves.

### Done so far

1. Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. Formerly it was impossible to make a Frogbot build that includes Trinca's complete latest collection of 378 maps, unless a very specific old Windows build of fteqcc was used. Now it is possible to build with _any_ recent fteqcc on _any_ platform, and basically an _infinite_ number of maps can now be built into the qwprogs, until we hit some other QuakeC limit.
2. Simpler management of map waypoint files, with a Python script that can also convert existing files for the above fix, which requires a (simple) format change.
3. Restored ability to build the **waypoint tool** as shown in [Mick's guide](https://mickkn.mooo.com/quakeworld/frogbot/), and greatly improved the usability of the tool.  
   It is now possible to _resume editing_ from existing waypoints, if one compiles them into the tool and then simply loads the map (soon it will also be possible to load work-in-progress from `.ent` files without recompiling anything).  
   This makes creating waypoints _way more feasible_ through an edit-test cycle.  
   This also allows to examine waypoints for existing maps, and better understand how to create good waypoints for new maps.  
   **Usability improvements implemented in the tool:**
   - made _closest marker mode_ way more usable, by fixing reliability issues and also allowing to cycle between 3 nearest markers; this allows to reliably select hard-to-reach markers like teleport triggers, and deal with overlapping markers;
   - print more info next to goal and zone, like coordinates and marker type;
   - made it much easier to check how markers are connected, by printing paths going out and coming into the active marker (including special modes), and visualising them through flying spikes;
   - fixed various bugs, for instance the tool would often crash after deleting a marker.
4. Made _shootable doors_ work across more maps than only _dm6_ (I kept the `dm6_door` name for the sake of legacy and because it's a good example). Works with both horizontal and vertical doors, of various sizes. (Still only 1 door per map though.)
5. Added _precision jump mode_ for paths. This allows bots to navigate small steps much more reliably. The ordinary ledge jump mode does not work well for this, they would often jump around way too erratically. I applied this for instance to the yellow armor zone of `e1m2`, it works really well.
6. Fixed the pretty much broken _rocket jump_ system. Bots will now rocket-jump much more often, and plan paths that include RJs, if of course the conditions for a RJ are satisfied.
7. Waypoints through **slime** areas can now be provided if the map has a biosuit and/or pentagram. In that case, the bot will avoid those paths until it has picked up one of those items.
8. Greatly improved **water navigation,** which was all over the place (despite being a _Frog_bot, it was surprisingly bad at swimming). Bots are now more robust against less-than-ideally-placed underwater markers, and will no longer get stuck on the water surface for no good reason.
9. Added _exclusive paths_ that allow to make the bot do seemingly smart things by being forced to follow a specific path after touching specific markers, or depending on whether a door is open.
10. Allowed to set bot _‘smartness’_ through a cvar. Default (if zero or not set) is to link smartness to bot skill level (maxing out at 10 and above), making the bots easier on lower skill settings.  
   To override smartness, set the `fb_smartness` cvar to a value between 1 to 10, or negative (= dumbest). In classic Frogbot, it was hard-coded at 10.
11. Allow to set custom bot names through localinfo `frobo_name1` through `frobo_name16` variables.
12. Various smaller bug and robustness fixes, like the ability to ascend fake ‘ladders,’ and reduced risk of bots getting stuck.
13. Created waypoints for some newer maps. Already available: `hohoho2` and `tox`. Try them, they're fun.  
Also tweaked existing waypoints, for instance `efdm13` is now a whole lot more challenging.

### Planned

- Allow embedding and using waypoint data in entity fields of maps, and provide a tool to inject marker data created with the waypoint tool into a `.map` or `.ent` file. This means no more need to recompile qwprogs to add bot support to a map.  
  It will be possible to build a BSP with embedded waypoints, or load them from an `.ent` file in engines that support these.   
  _(Status: mechanism implemented, PoC works, working on script to inject WP into map/ent.)_
- Add Trinca's waypoints, possibly updated with the new features.
- Something resembling documentation.  
  _(Status: it is taking shape.)_
- Improve upon Mick's waypoint guide. Figure out the more advanced things.  
  _(Status: there is a usable guide, could use some screenshots though.)_

No promises about dates or reaching these goals whatsoever. It is done when it's done. Obviously, if you want to jump in and help: fork and branch this repository, do your thing, and create a pull request.

### Not really planned, but who knows
- Make shootable doors even more universal, bots should be able to open any door on the path it wants to follow, without having to tie it to specific goals/zones. Maybe even extend to also allow shooting switches to open doors.
- Improve Frogbot functionality in non-Quakeworld engines. It is already possible to build and run a plain Quake `progs.dat` by setting the `QUAKE` preprocessor macro, but some things are broken. If you want to try this: remember to start a network game, or very weird things will happen when attempting to add a bot.
- Maybe try to keep the bots from wallhacking on skill levels up to 10. At the lower levels, I shouldn't get a rocket accurately launched from a long distance in my face when turning around a corner.

### Wild ideas
- Construct reasonable waypoints automatically with AI and evolutionary algorithms and blockchain and all other buzzwords we can throw against it. Yet, manual editing may always be needed for the best results.

## License

Although the only real evidence is [in a casual forum post](https://www.quakeworld.nu/news/177/frogbot-gets-gpl), Robert ‘Frog’ Field released the Frogbot under the GPL, hence this fork is also GPL. Perhaps the situation is a bit complicated due to others also contributing to this, and perhaps it is not totally legal for me to distribute Trinca's waypoint collection in this repository, but the alternative is for all his work to vanish into oblivion, which makes no sense.


Regards,

Dr. Lex, the Code Necromancer
