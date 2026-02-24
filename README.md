# Quake Frogbot Clan Arena v2

Based on:
- _FBCA, Frogbot Clan Arena_ - mod that combines Frogbot, ParboiL's Clan Arena and Kombat Teams (KTPro) - forked from [the ezQuake sources](https://github.com/ezQuake/fbca)
- _Trinca_ and _Spike's_ last known sources, dug up from the depths of the Internet
- Decompiled source file from the _old waypoint tool._ (How dare I decompile a 25-year old abandoned program, so sue me. It has since been extensively modified anyway…)


## What in Shub-Nigguraths name is a Frogbot?

The Quake Frogbot allows to add computer-controlled players to the first _Quake_ game released in 1996. (Not to be confused with some JFrog thing.)  
The Frogbot was created by _Robert 'Frog' Field_ in 1997 and is regarded as one of the better performing bots. With a properly crafted waypoint file, the bots simulate a real human opponent rather well, and are still impressive despite their age and the fact that it is all implemented in QuakeC, a language that lacks niceties like arrays, dictionaries, or string manipulation.  
Simply put, _the Frogbot is a load of fun._ It is great for some offline practice or warm-up, or for initial play-testing of new maps.

The bot relies on _waypoint files_ that have to be created for each map. In previous Frogbot incarnations, the only way to add new waypoints was to compile them into the _(qw)progs.dat._ In the first decade of the 21st century, _Trinca_ did a gargantuan job of making and collecting waypoints for a total of about 400 maps. One of my goals is not to let all that work vanish into oblivion.

The old Frogbot had a few issues that had lead to its development grinding to a halt and practically nobody creating new waypoints after Trinca's anymore:
- Building the qwprogs with support for more than a few 100 maps was only possible with a very specific Windows build of the FTEQCC compiler.
- Only 1 waypoint creation tool was available, and it had quite a few usability problems, making the workflow awkward and risky (certain actions would crash it).
- The source for the waypoint tool had become unavailable (or near impossible to find), making it infeasible to resume editing existing waypoints. Either one had to do a whole map in one go (insane for larger maps), or manually edit the waypoint code (just plain insane even for tiny maps).
- It was not possible to add Frogbot support to a map without recompiling the _qwprogs.dat,_ which, especially in combination with what is mentioned above, lead to an obvious problem of getting one's new maps added to whatever was the most popularly distributed Frogbot build.
- The most recent codebase of the mod had all the NetQuake parts stripped from it, making it only support QuakeWorld engines.

The v2 Frogbot solves these problems:
- It is now possible to build with recent versions of FTEQCC on any platform;
- NetQuake support has been resurrected through the finest acts of _code necromancy;_
- the waypoint tool has been resurrected in a new incarnation that makes it way easier to use, and more stable;
- waypoints can be shipped with maps without having to compile them into the `qwprogs.dat`, by means of waypoint data embedded as entity fields via an `.ent` file, or even embedded in the BSP.

On top of that, the new bot has a whole lot of new features and skills. More details below.


## Basic instructions

### Deploying/Installing

The Frogbot mod can run both in:
- a _QuakeWorld_ engine like ezQuake (for which a prebuilt `qwprogs.dat` is provided);
- a classic _NetQuake_ engine like vkQuake (for which a prebuilt `progs.dat` is provided).

At this time, the QuakeWorld build has the most features and probably the least bugs. However, the NetQuake build is pretty usable, and will offer the most authentic classic Quake multiplayer experience without having to scour for friends who still want to play a +30 year old game. 😁

Of course, if you're familiar with Quake config tweaking, you can modify the `cfg` files, although it is better to override settings in your own `autoexec` file after the standard config has been loaded.

#### Deploying in ezQuake

Unless you want to compile the mod yourself (instructions below), you can use the prebuilt binaries (`.dat` files). Recent builds can be found in the _Releases_ section of GitHub.

It used to be simplest to start out with [nQuake](https://nquake.com/) because it used to ship with an older version of the Frogbot mod, and already had everything set up. The v2 bots were a drop-in replacement, meaning that if you still have an older Frogbot-based nQuake installation, the simplest way to run the v2 bots, is to unzip nQuake's `frogbot.pk3`, replace its `qwprogs.dat` with the one from this repository, and then zip the file again, and ensure the file extension is `pk3`.

To deploy the mod from scratch in ezQuake, some more work is needed:
- Create a new zip archive from the following files in this repository, change the extension to `pk3`, and drop it into ezQuake's `qw` directory. This approach should also work for other engines (perhaps the uncompressed files should be copied instead, I am not too familiar with this stuff.)
  - `qwprogs.dat`
  - `frogbot.cfg`
  - `configs-qw`
  - `doc`
  - `sound`
- Ensure `frogbot.cfg` is executed in the `qw/autoexec.cfg` file which your ezQuake app uses.
  - For older frogbot-based deployments, this should already be the case.
  - For newer ezQuake / nQuake deployments, blatantly ignore the `do not edit` instruction and place the following line somewhere at the start of the file, after any existing other `exec` lines:
  - `exec frogbot.cfg`
- In newer _nQuake_ deployments, sabotaging the `ktx.pk3` file by renaming it to `ktx.pk3.disabled` may be needed to avoid conflicts. If you want to use nQuake as intended, I would suggest starting out with a vanilla ezQuake installation instead.

#### Deploying in NetQuake engines like vkQuake

- Create a new directory `frogbot` inside the same directory as where the game's `id1` directory resides. Copy the following files and directories into this `frogbot/` directory:
  - `progs.dat`
  - `frogbot-quake.cfg`
  - `configs-quake`
  - `doc` (for license compliance, you may skip it, but _Asmodeus will dislike)_
  - `sound`
- Create a file `autoexec.cfg` inside the `frogbot/` folder with inside it the line:
  - `exec frogbot-quake.cfg`

### Playing

In ezQuake, if deployed as instructed above, you will immediately be inside the mod, and can load any map with the `map` command. In NetQuake, you will first have to load the mod with the command `game frogbot`, or using the GUI menu.

Playing against bots is only possible on _supported maps,_ i.e., maps for which waypoints were built into the qwprogs, or that have waypoints embedded in an `.ent` file or in the `.bsp` itself.  
The current list of built-in maps can be found in the `src/maps/maplist.txt` file, but will also be printed in-game after loading a map that is not supported. Depending on whether you are using a QW engine or NetQuake engine, downloaded BSP files must be placed in respectively `qw/maps/` or `id1/maps/.`

The list of supported maps is currently much smaller than what used to be bundled with nQuake, although it does support some newer maps. The goal is to port the entire old huge collection to the v2 Frogbot, but each map needs to go through some QA to fix problems and possibly upgrade it to benefit from the new features. Check back here for newer releases, or if you want to lend a helping hand, look in the `waypoint` README.

The default mode is _FFA,_ other modes are available. Try the commands starting with `bot_`, like `bot_arena` which is great for practicing your aim or just instant mayhem. After loading a map, use the `addbot` and `removebot` commands to add or remove bots. Bots will be carried over when changing maps (if the next map is supported of course).  
The default configs have some maplists built-in (only works in QW). Look in the `configs` folder to see which BSP files you need to obtain to play those lists, or override the lists with your own config, or just manually switch maps with the `map` command.

Disclaimer: the v2 mod has not been extensively tested with multiple human players joining a server. There may be bugs when other people connect, or maybe not. For non-casual servers, it may make more sense to run KTX. Still, a crude test with 2 Quake instances on the same machine seems to work fine. If you encounter multi-player bugs, please report them, or better: try to fix them.

#### Bot skill
Bots can have a **skill** level from 0 to 20, default is 5. The level required to make things challenging, will depend on your own Quake skills, and it also tends to vary per map. Bots tend to be more challenging in smaller maps with multiple floors and teleports, and easier in maps with large open spaces.  
If you want to change the skill level of the bots, you can use the `skilldown` and `skillup` commands, or impulses _114_ and _115_ respectively. The new skill level will only be applied to new bots spawned afterwards, not to bots already active in the current game, and bots also preserve their skill level across map changes. This means you can mix bots of different skill levels in a single game for even higher realism. To bring all bots to the currently selected skill, `removeallbots` and then re-add them.  
A custom bot spawn level that overrides the built-in configs can be persisted across game sessions by setting the `fb_custom_skill` cvar to a non-zero value (value -1 represents skill level 0).

If you have never played Quake before, you may want to start at skill level 0 and gradually go up. Seasoned players may want to try level 10. It goes up to 20, at which point the bots have inhumanly fast aim and situational awareness. True hardcore Quake players may still be able to outwit level 20 bots by exploiting their limitations.

#### Engine quirks
If you're using _ezQuake,_ it is possible that _all_ players will have the same red pants and yellow shirts, making it very hard to play team games because the only way to discern between enemies and teammates, is to see whether they are shooting at you. This seems to be a bug in _ezQuake_ itself and the only decent workaround I have found so far, is `/r_skincolormode 5` and then `r_teamskincolor 96 255 96` to give your teammates a green tint (change the RGB numbers for different colors). Even if the bug is fixed in newer versions, this may still be helpful to avoid teamkills.

Also, if you have tried ‘coop’ mode in ezQuake, mind that traces of it tend to stick until you have again explicitly selected the single-player menu item or cleared the `coop` variable. If it is nonzero, weird things may happen, like deathmatch mode always being forced to 1. You _can_ start a cooperative game with bots, which will make them act as teammates, but this is currently of limited use.

#### Embedded waypoints
By default, the mod will prefer waypoints embedded in `.ent` files or the `.bsp` itself, overriding any waypoints built into the mod itself for that map. If you want to disable the loading of embedded waypoints and only use the ones built-in, set `sv_frog_only_builtin` to 1, otherwise undefine it or set it to 0.

### Making your own waypoints
This can be done with the ‘waypoint’ tool running as a separate mod in any NetQuake engine. See the README in the `waypoint` directory.


## Building from source

You need a not too mothballed build of [FTEQCC](https://www.fteqcc.org/), no guarantees are given that the code will build with anything else.

### Building the QuakeWorld runtime
The progs specification is in `progs.src,` which is the default for FTEQCC. This means it suffices to execute from within the `src` directory:
```bash
mkdir -p ../Release/qw  # can skip if it already exists
fteqcc.bin -O3
```

The output `qwprogs.dat` will be placed in the `Release/qw/` folder 1 level up. To actually deploy the Frogbot progs, see instructions above for creating the correct `pk3` file.

As with the waypoint build, if you have access to a `bash` shell, you can also use the provided `build-qwbot` script, and edit it (or preferably a copy) to do everything for you and even put the `pk3` file in your QuakeWorld installation directory.

### Building the NetQuake runtime
It uses a custom `src` file and needs the `QUAKE` macro to be defined. Execute from within the `src` directory:
```bash
mkdir -p ../Release/quake  # can skip if it already exists
fteqcc.bin -DQUAKE=1 -O3 -srcfile progs-quake.src
```

The output `progs.dat` will be placed in the `Release/quake/` folder 1 level up. Same here, see instructions above for how to deploy.

And also here, a script `build-quakebot.sh` is provided that can make your life easier.


## Why this project?

Originally I only had 2 goals. Eventually though, a third goal emerged:
1. Allow the casual Quake player to have easy instant fun with the Frogbots, or use them for offline practice. This may lower the threshold for novices who want to experience online Quake mayhem, but due to lack of experience, are afraid to be totally dominated by veterans who have been playing it for decades.
2. Allow people to easily produce new waypoints or edit existing ones — also useful to playtest new maps.
3. Make the Frogbot more capable, such that it is no longer disadvantaged by certain map features it could previously not handle.

In more detail, the purpose is to revive the classic Frogbot Quake(World) mod in a way that:
- makes it much easier to build the `(qw)progs.dat` with any recent version of fteqcc or maybe other compilers;
- makes it much easier to create waypoints — doing this is fun enough that I already did it for a few maps, and more may follow;
- makes it possible and easy to resume editing existing waypoint data;
- makes it possible to embed waypoint data in maps, or load them through an `.ent` file, to avoid the need to compile them into the qwprogs;
- fixes issues and adds new features to the bots to make them more challenging.

Reviving and improving the _waypoint tool_ was one of the main goals, to make it much easier to create new waypoints for maps, because there would be little use in reviving the classic Frogbot if we would be stuck with a set of maps from before 2012.  
The output of the tool might also be usable to generate waypoints for the KTX Frogbot, if some kind of translation tool is available. However, the feature set will first need to be synced to support the v2 path and marker types.

While working on the tool and testing newly created waypoints, I noticed things I could improve about the bots themselves. This began as simple bug fixes, but escalated into adding entire new functionality. The changes became so substantial that I deemed it appropriate to call this the _‘v2’ Frogbot._


## What is the difference with the old Frogbot?

Numerous problems have been fixed and new features have been added since the last major build that used to be shipped with nQuake. The most important ones:

1. Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. Formerly it was impossible to make a Frogbot build that includes Trinca's complete latest collection of 378 maps, unless a very specific old Windows build of fteqcc was used. Now it is possible to build with _any_ recent fteqcc on _any_ platform, and basically an _infinite_ number of maps can now be built into the qwprogs, until we hit some other QuakeC limit. But even that wouldn't be a show-stopper anymore, due to the following.

2. Enabled loading waypoints through `.ent` files, or even building them into a map. This means it is no longer required to recompile the (qw)progs to provide bot support for a map. See details in the waypoint README.

3. Simpler management of map waypoint files, with a Python script that can also convert existing files for the above fix, which requires a (simple) format change.

4. Restored ability to build the **waypoint tool** featured in Mick's (former) guide, and greatly improved the usability of the tool. (Mick's guide is now defunct, but there is a _much_ more detailed guide in this repository.)  
   This means it is now possible to easily _resume editing_ from existing waypoints, if one compiles them into the tool and then simply loads the map; of course they could also be injected into an `.ent` file or the `.bsp` itself and can then be reloaded without recompiling anything, but this is slightly more cumbersome.  
   This means:
   - creating waypoints is again _way more feasible_ through an edit-test cycle;
   - one can examine or edit waypoints for existing maps, and better understand how to create good waypoints for new maps;
   - one can actually toggle bot mode from within the tool to see how the bot behaves from a given starting situation.

   **Usability improvements implemented in the tool:**
   - _closest marker mode_ is way more usable, by fixing reliability issues and also allowing to cycle between 4 nearest markers; this allows to reliably select hard-to-reach markers like teleport triggers, and deal with overlapping markers;
   - print more info next to goal and zone, like coordinates and marker type;
   - made it much easier to check how markers are connected, by printing paths going out and coming into the active marker (including special modes), and visualising them through flying spikes;
   - auto-connect teleport triggers to destinations: way less tedious/error-prone;
   - fixed various bugs, for instance the old tool would often crash after deleting a marker;
   - waypoint output format is now deterministic and mostly sorted in a sensible way;
   - bot mode can be forced to reach a certain target spot;
   - other functions that make it much easier to find and check things.

5. Added _precision jump mode_ for paths. The ordinary ledge jump mode is too crude for certain jumps, bots would often jump around way too erratically. The new modes enable jumps where accuracy matters. The bot will automatically retreat and do a run-up when necessary. The jump can also be combined with a new _slow path mode_ to reliably jump onto small ledges/steps like in the yellow armor zone of `e1m2`, or can be given an initial direction to perform an air strafe.  
   Next to this, other new path modes and marker types have been added to better handle specific situations, like smoothly getting through narrow openings.

6. Fixed the pretty much broken _rocket jump_ system. Bots will now rocket-jump much more often, and plan paths that include RJs, if of course the conditions for a RJ are satisfied. Next to the regular running RJ, there are also slower ‘mortar’ and ‘cannon’ RJ modes for when accuracy is crucial.

7. Added _exclusive paths_ that allow the bot to do seemingly smart things by selectively ignoring markers depending on chosen paths, or depending on whether a door is open. This has allowed to upgrade some previously crippled maps to feature-complete waypoints, like `dm5`, `e1m5`, and `ultrav`.

8. Extended **shootable triggers** from merely the door in `dm6` towards _anything_ that requires shooting a trigger before a path can be traversed. Try `e1m1` or `eodm3`.

9. Greatly improved **water navigation,** which was all over the place (despite being a _Frog_ bot, it was surprisingly bad at swimming). Bots are more robust against less-than-ideally-placed underwater markers, will no longer get stuck on the water surface for no good reason, and will avoid drowning.

10. Waypoints through **slime** or **lava** areas can now be provided if the map has a biosuit and/or pentagram. In that case, the bot will avoid those paths until it has picked up the power-up that protects against the hazard. It will desire to pick up the biosuit when it desires to fetch an item from slime. Try `efdm13`.

11. Improved _platform/lift handling,_ especially for button-activated lifts. Bots can wait for a platform to come down to avoid being squished, and can handle exits at multiple floors.

12. Bots can _strafe run_ along a wall to boost their speed and make longer jumps.

13. Better skill handling: bots preserve their skill across matches and map changes. Allow to override default bot skill level, and also to separately override bot ‘smartness,’ through cvars.
    - If the `fb_custom_skill` cvar is nonzero, it will be used when spawning new bots, ignoring any `d_skill` info value from configs. A value of zero causes the cvar to be ignored, skill level 0 is represented by value -1. The cvar is updated when using the `skilldown/up` commands, which means changes will be persistent in engines like ezQuake that automatically store cvars.
    - If the `fb_custom_smart` cvar is nonzero, it overrides _smartness._ Smartness controls some advanced bot behavior. By default, it is derived from bot skill level (maxing out at 10 and above), making the bots easier on lower skill settings (in classic Frogbot, it was hard-coded at 10). The value can be between 0 to 10, but again, the cvar is ignored if its value is 0, use a negative value to represent minimum smartness 0.

14. Allow to set _custom bot names_ through localinfo `frobo_name1` through `frobo_name16` variables.

15. Many big and small bug and robustness fixes, like the ability to ascend fake ‘ladders,’ reduced risk of bots getting stuck, and crashes when attempting to spawn bots in some maps.

16. Created waypoints for previously unavailable maps, for instance `hohoho`, `hohoho2`, `catalyst`, `burialb10`, `dmz1++`, `e1m4`, and more.  
    Also updated a bunch of existing waypoints to fix errors and benefit from new functionality. For instance `efdm13` is now an entirely different experience, and a whole lot more challenging. Or try `e1m1,` which is now feature-complete, secrets and all. I have high quality standards: waypoints are only committed to this repository after I have watched bots running on them without any obvious problems.


## What is the difference with the KTX Frogbot?

Although born from the same origin, this is a different Frogbot fork than [the one included in KTX](https://github.com/QW-Group/ktx). The differences are:

- The v2 Frogbot is a _client_ mod, all you need to run it is a QuakeWorld client like ezQuake, while KTX is a _server_ mod, requiring to launch a server which can only run on one of the supported platforms.
- This fork is branched from the [FBCA repository](https://github.com/ezQuake/fbca) whose last change was in 2016, while the bot and arena code in KTX has seen some recent changes, even in 2025.
- The KTX bots are (re)implemented in plain C, while this fork of the older Frogbot is still implemented in QuakeC. Try these oldschool bots however, and you'll see that QuakeC can kick some serious butt, and one can still learn an old bot new tricks.
- There are (currently) some differences in features, the KTX bot has some things not in the v2 bot and the other way round.


## Caveats

### Customized .ent files may crash the Frogbot

Be careful with `.ent` files. If they add item entities like weapons, ammo, teleport destinations, or the like, in all likelihood **the game will crash** when loading a Frogbot-supported map, because the extra entities will cause marker numbers to be shifted, causing a fatal mess with the waypoint data. This usually manifests itself as an error `<NO FUNCTION>` or `NULL function` in the console or log. Even if the game would not crash, the bot would act very weird.

If this happens, either disable the loading of `.ent` files, or just move the `.ent` file aside (to a separate folder).

The mod will print a warning when recognising some of the typical `.ent` files that are distributed with certain engines.

When making waypoints in an engine that supports `.ent` files, by all means ensure no custom file is loaded for the map while editing the waypoints. It will work, but the resulting waypoints will only be usable with that particular `.ent` file. If you would go this route anyway, it makes sense to embed the waypoint data in the `.ent` file as well.


## Planned

- Improve Frogbot functionality in NetQuake engines. It already works pretty well and you can even play against bots in the waypoint tool if you start a network game and use manual impulse commands, but this has been tested less than the QW build and is likely to have more bugs and some missing functionality. However, one extra feature the Quake build has, is that you can turn yourself into a bot, both in single-player and multiplayer, through the `frogbot` command, `impulse 123,` or in the waypoint tool with the `F4` key. Try it!
- Add more—ideally all—of Trinca's waypoints, with errors fixed and updated to benefit from the new features.
- Create new waypoints for popular maps, new and old. Anyone can help with this, check out the extensive documentation in the `waypoint` folder!
- Some more documentation, like how the whole thing works at a technical level. Don't expect me to explain all the voodoo in `route_calc.qc` though…

No promises about dates or reaching these goals whatsoever. It is done when it's done. Obviously, if you want to jump in and help: fork and branch this repository, do your thing, and create a pull request.

### Not really planned, but who knows…

- Disable or reduce advanced tactics on lower bot skill levels. For instance, I shouldn't get a rocket accurately launched from a long distance in my face when turning around a corner on the very lowest skill levels. Bots also shouldn't do smart things on low smartness settings, like deliberately damaging themselves to be able to pick up armor such that other players cannot, and a bot with smartness 0 should have zero advance knowledge of when an item will spawn.
- Find a way to spectate bots. This may be impossible, at least that's what ChatGPT claims, but I have learned that it tends to be full of 💩 when it comes to Quake knowledge.
- Find a way to automatically generate sensible waypoints as a starting point, to avoid the need to make every map from scratch. This will likely never work fully unsupervised, but it could reduce the amount of work per map to merely fine-tuning the tricky parts and special things. Having near-Trinca-quality waypoints automatically generated, would already be very helpful.


## License

Although the only real evidence is [in a casual forum post](https://www.quakeworld.nu/news/177/frogbot-gets-gpl), Robert ‘Frog’ Field released the Frogbot under the **GPL,** hence this fork is also GPL. Perhaps the situation is a bit complicated due to others also contributing to this, and I have no clue what license would apply to Trinca's waypoint collection, but I do not think anyone objects to preventing all his work from vanishing into oblivion.


Regards,

Dr. Lex, the Code Necromancer
