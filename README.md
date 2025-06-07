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


## Basic instructions

This section could be improved, but here's something to begin with.

At this time I recommend to obtain the `frogbot.pk3` that is bundled with [nQuake](https://nquake.com/), unzip it, replace the `qwprogs.dat` with the one from this repository, and then zip the file again, and ensure the file extension is `pk3`. The Frogbot package bundled with nQuake has a good set of configs, as opposed to the ones in this repository which are old and need to be improved. (Eventually it might make sense to just bundle the v2 Frogbot with nQuake, when enough waypoints have been ported to cover the classic set of maps.)

Of course, if you're familiar with Quake config tweaking, go wild.

Playing against bots is only possible on supported maps, i.e., maps for which waypoints were built into the qwprogs. You can find this list of maps in the `src/maps/maplist.txt` file, but it will also be printed in-game after loading a map that is not supported.

The list of supported maps is currently much smaller than what used to be bundled with nQuake. The goal is to port as many of the old huge collection to the v2 Frogbot, but each map needs to go through some QA to fix problems and possibly upgrade it to benefit from the new features. Check back here for newer releases.

The default mode is FFA, other modes are available. After loading a map, use the `addbot` and `removebot` commands to add or remove bots. Bots will be carried over when changing maps (if the next map is supported of course).

If you want to change the skill level of the bots, you can use the `skilldown` and `skillup` commands, or impulses _114_ and _115_ respectively. The new skill level will only be applied to bots spawned afterwards, not to bots already active in the current game. This means you can mix bots of different skill levels in a single game. The simplest way to ensure all bots run at the adjusted skill level, is to reload the map.

The skill level required to make things a bit challenging, will depend on your own Quake experience, and it also tends to vary per map. Bots tend to be more challenging in smaller maps with multiple floors and teleports, and easier in maps with large open spaces. If you have never played Quake before, you may want to start at level 0 and gradually go up. Seasoned players may want to try level 10. It goes up to 20, at which point the bots have inhumanly fast aim and situational awareness. True hardcore Quake players may still be able to outwit level 20 bots by exploiting their limitations.

As for running the `waypoint` tool to create or edit waypoints, see the README in the `waypoint` directory.


## Caveats

### Customized .ent files may crash the Frogbot

Be careful with `.ent` files. If they add item entities like weapons, ammo, teleport destinations, or the like, in all likelihood **the game will crash** when loading a Frogbot-supported map, because the extra entities will cause entity numbers to be shifted, causing a fatal mess with the waypoint data. This usually manifests itself as an error `<NO FUNCTION>` or `NULL function` in the console or log. Even if the game would not crash, the bot would act very weird.

If this happens, either disable the loading of `.ent` files, or just move the `.ent` file aside (to a separate folder).

When making waypoints in an engine that supports `.ent` files, by all means ensure no custom file is loaded for the map.

The good news is that if I ever get to finish the script that can inject waypoint data into an `.ent` file to allow loading waypoints without recompiling the qwprogs, then custom `.ent` files will likely work, as long as they do not try to remove entities from the original set (is that even possible anyway?) Any added entities will then not be usable for the bot, unless they are annotated inside the `.ent` file with their own zone, goal, and path info, but this is all speculative at this moment…


## What is the difference with the KTX Frogbot?

Although born from the same origin, this is a different Frogbot fork than [the one included in KTX](https://github.com/QW-Group/ktx). The differences are:

- The Frogbots from this fork can run directly as a mod in a QuakeWorld _client_ like ezQuake, while KTX is a _server_ mod, which can only run on one of the supported platforms.
- This fork is branched from the [FBCA repository](https://github.com/ezQuake/fbca) whose last change was in 2016, while the bot and arena code in KTX has seen some recent changes, even in 2025.
- The KTX bots are (re)implemented in plain C, while this fork of the older Frogbot is implemented in QuakeC. Try these oldschool bots however, and you'll see that QuakeC can kick some serious butt, and one can still learn an old bot new tricks.
- There are (currently) some differences in features, the KTX bot has some things not in the v2 bot and the other way round.


## Why this project?

In short, the main 2 goals are to allow the casual Quake player to have easy instant fun with the Frogbots, and to enable people to easily produce new waypoints.

In more detail, the purpose is to revive the classic Frogbot Quake(World) mod in a way that:
- makes it much easier to build the `qwprogs.dat` with any recent version of fteqcc or maybe other compilers;
- makes it much easier to create and edit waypoints — doing this is fun enough that I already did it for a few maps, and more may follow;
- makes it possible and easy to resume editing existing waypoint data;
- makes it possible to embed waypoint data in maps, or load them through an `.ent` file, to avoid the need to compile them into the qwprogs;
- fixes issues and adds new features to the bots.

Reviving and improving the _waypoint tool_ was one of the main goals, to make it much easier to create new waypoints for maps, because there would be little use in reviving the classic Frogbot if we would be stuck with a set of maps from before 2012.  
The output of the tool might also be usable to generate waypoints for the KTX Frogbots, if some kind of translation tool is available.

However, while working on the tool and testing newly created waypoints, I also noticed some things I could improve about the bots themselves.

### Done so far

1. Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. Formerly it was impossible to make a Frogbot build that includes Trinca's complete latest collection of 378 maps, unless a very specific old Windows build of fteqcc was used. Now it is possible to build with _any_ recent fteqcc on _any_ platform, and basically an _infinite_ number of maps can now be built into the qwprogs, until we hit some other QuakeC limit.

2. Simpler management of map waypoint files, with a Python script that can also convert existing files for the above fix, which requires a (simple) format change.

3. Restored ability to build the **waypoint tool** as shown in Mick's guide, and greatly improved the usability of the tool. (Mick's guide is now defunct, but there is a much more detailed guide in this repository.)  
   It is now possible to _resume editing_ from existing waypoints, if one compiles them into the tool and then simply loads the map (soon it will also be possible to load work-in-progress from `.ent` files without recompiling anything).  
   This means:
   - creating waypoints is again _way more feasible_ through an edit-test cycle;
   - one can examine waypoints for existing maps, and better understand how to create good waypoints for new maps;
   - one can actually toggle bot mode from within the tool to see how the bot behaves from a given starting situation.

   **Usability improvements implemented in the tool:**
   - made _closest marker mode_ way more usable, by fixing reliability issues and also allowing to cycle between 4 nearest markers; this allows to reliably select hard-to-reach markers like teleport triggers, and deal with overlapping markers;
   - print more info next to goal and zone, like coordinates and marker type;
   - made it much easier to check how markers are connected, by printing paths going out and coming into the active marker (including special modes), and visualising them through flying spikes;
   - auto-connect teleport triggers to destinations, way less tedious/error-prone;
   - fixed various bugs, for instance the tool would often crash after deleting a marker;
   - waypoint output format is now deterministic and mostly sorted in a sensible way.

4. Added _precision jump mode_ for paths. The ordinary ledge jump mode is too crude for certain jumps, bots would often jump around way too erratically. The new modes enable jumps where accuracy matters. The bot will automatically retreat and do a run-up when necessary. The jump can also be combined with a new _slow path mode_ to reliably jump onto small ledges/steps like in the yellow armor zone of `e1m2`.  
   There are other new path modes and marker types that allow to better handle specific situations.

5. Fixed the pretty much broken _rocket jump_ system. Bots will now rocket-jump much more often, and plan paths that include RJs, if of course the conditions for a RJ are satisfied. Next to the regular running RJ, there are also slower ‘mortar’ and ‘cannon’ RJ modes for when accuracy is crucial.

6. Added _exclusive paths_ that allow to make the bot do seemingly smart things by selectively ignoring markers depending on chosen paths, or depending on whether a door is open. This has allowed to upgrade some previously crippled maps to feature-complete waypoints, like `dm5`, `e1m5`, and `ultrav`.

7. Greatly improved **water navigation,** which was all over the place (despite being a _Frog_ bot, it was surprisingly bad at swimming). Bots are more robust against less-than-ideally-placed underwater markers, will no longer get stuck on the water surface for no good reason, and will avoid drowning.

8. Waypoints through **slime** or **lava** areas can now be provided if the map has a biosuit and/or pentagram. In that case, the bot will avoid those paths until it has picked up the power-up that protects against the hazard. It will desire to pick up the biosuit when it desires to fetch an item from slime. Try `efdm13`.

9. Improved _platform/lift handling,_ especially for button-activated lifts. Bots can wait for a platform to come down to avoid being squished, and can handle exits at multiple floors.

10. Bots can _strafe run_ along a wall to boost their speed and make longer jumps.

11. Made _shootable doors_ work across more maps than only _dm6_ (I kept the `dm6_door` name for the sake of legacy and because it's a good example). Works with both horizontal and vertical doors, of various sizes. (Still only 1 door per map though.)

12. Allowed to set bot _‘smartness’_ through a cvar. Default (if zero or not set) is to link smartness to bot skill level (maxing out at 10 and above), making the bots easier on lower skill settings.  
    To override smartness, set the `fb_smartness` cvar to a value between 1 to 10, or negative (= dumbest). In classic Frogbot, it was hard-coded at 10.

13. Allow to set _custom bot names_ through localinfo `frobo_name1` through `frobo_name16` variables.

14. Various smaller bug and robustness fixes, like the ability to ascend fake ‘ladders,’ and reduced risk of bots getting stuck.

15. Created waypoints for some newer maps, for instance `hohoho2`, `catalyst`, `burialb10`, `dmz1++`, `e1m4`, `tox`.   
    Also updated a bunch of existing waypoints to fix errors and benefit from new functionality. For instance `efdm13` is now an entirely different experience, and a whole lot more challenging.

### Planned

- Allow embedding and using waypoint data in entity fields of maps, and provide a tool to inject marker data created with the waypoint tool into a `.map` or `.ent` file. This means no more need to recompile qwprogs to add bot support to a map.  
  It will be possible to build a BSP with embedded waypoints, or load them from an `.ent` file in engines that support these.   
  _(Status: mechanism implemented, PoC works, working on script to inject WP into map/ent.)_
- Add more—ideally all—of Trinca's waypoints, with errors fixed and updated to benefit from the new features.
- Create new waypoints for some more recent popular maps.
- Some more documentation, like how the whole thing works at a technical level. Don't expect me to explain all voodoo in `route_calc.qc` though…

No promises about dates or reaching these goals whatsoever. It is done when it's done. Obviously, if you want to jump in and help: fork and branch this repository, do your thing, and create a pull request.

### Not really planned, but who knows…
- Make shootable doors even more universal, and extend to any shootable trigger. Bots should be able to open _any_ door or activate _any_ bridge on _any_ path they want to follow by shooting at a trigger, without having to tie it to specific goals/zones. The current `dm6_door` system is overly complicated.
- Improve Frogbot functionality in non-Quakeworld engines. It is already possible to build and run a plain Quake `progs.dat` by setting the `QUAKE` preprocessor macro, but some things are broken. If you want to try this: remember to start a network game, or very weird things will happen when attempting to add a bot in single-player mode. However, one extra feature that the Quake build has, is that you can turn yourself into a bot through `impulse 123`, both in single-player and multiplayer. Try it!
- Disable or reduce advanced tactics on lower bot skill levels. For instance, I shouldn't get a rocket accurately launched from a long distance in my face when turning around a corner on the very lowest skill levels. Bots also shouldn't do smart things on low smartness settings, like deliberately damaging themselves to be able to pick up armor such that other players cannot, and a level zero bot should have zero advance knowledge of when an item will spawn.


## License

Although the only real evidence is [in a casual forum post](https://www.quakeworld.nu/news/177/frogbot-gets-gpl), Robert ‘Frog’ Field released the Frogbot under the **GPL,** hence this fork is also GPL. Perhaps the situation is a bit complicated due to others also contributing to this, and perhaps it is not totally legal to distribute Trinca's waypoint collection in this repository, but the alternative is for all his work to vanish into oblivion, which makes no sense.


Regards,

Dr. Lex, the Code Necromancer
