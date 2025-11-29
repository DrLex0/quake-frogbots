# Frogbot v2 Map Waypoint Files

Compiling waypoints for a certain map into the Frogbot `qwprogs.dat`, allows playing against bots on that map.  
Similarly, compiling waypoints into the waypoint tool `progs.dat`, allows to view and edit those waypoints in the tool by loading the map in it.

It will soon also be possible to inject waypoint data into a `.map` file to build the map with embedded waypoints, or into an `.ent` file to allow loading the map with waypoints, without having to recompile anything.

Managing waypoint files for compiling them into the Frogbot `qwprogs.dat`, or the waypoint tool `progs.dat`, should be done through the `generate_maplist.py` Python script. It can generate and use text files with lists of map files, and then use those files to generate the QuakeC code that is used by the Frogbot and waypoint tool builds. One can manually edit the list files to add or remove specific maps.

Using the script is straightforward, usage instructions are shown by running with `-h` or `--help` argument. The script has no dependencies and should run in any recent Python3 environment.

Subfolders are supported, and can be used to facilitate building for a specific set of maps. Specify one or more subfolders after the `-d` argument of the script.

To use a different maplist file than the default `maplist.txt`, specify it with the `-f` argument.

Because the format of waypoint files has changed compared to the older Frogbot code, waypoint files created with the older waypoint tool must be _transformed._ Do this by enabling the `-t` option of the script, it can't hurt to always enable this because it auto-detects the format. If the old source file contains any `#include, #ifdef, #endif` lines, erase them before doing the conversion (TODO: let the script do this too).


## Aliases

It is possible to have _aliases_ for maps, for instance if `trindm2.bsp` and `blorkination.bsp` are the exact same map files as `tridm2.bsp`, then you can add this kind of line to the top of the `map_tridm2.qc` file:
```
// ALIASES trindm2 blorkination
```

The script will then automatically generate a `mapaliases.txt` file containing the following line, which will reuse the waypoints created for `tridm2` without having to copy-paste them:
```
tridm2 trindm2 blorkination
```

## Example

Re-generate the maplist and aliases file using all map QC files in this directory and the `drlex, ktx, trinca` subfolders:
```bash
./generate_maplist.py -vtl -d drlex ktx trinca
```

Render the QuakeC source code from the maplist and aliases file:
```bash
./generate_maplist.py -vg
```

Or, do all of the above in a single invocation:
```bash
./generate_maplist.py -vtlg -d drlex ktx trinca
```


## Special characters in map names

Some characters need special treatment, because they would otherwise conflict with QuakeC source code. However, if you use the `getmapdump.sh` script to extract waypoint code from a Quake log, and then the `generate_maplist.py` script to update the sources, this is all done automatically.

At this time, the following characters must be (and are by the scripts) converted as follows from the original map name to the function name that defines the waypoints:
- `+` becomes `PLUS`;
- `-` becomes `DASH`. 

For instance, `dmz1++.bsp` will get a waypoint loading function called `map_dmz1PLUSPLUS`.

More may need to be added if someone wants to make waypoints for maps with other funky characters. However, if you make a new map, and have to choose a file name, by all means **please just stick to the ASCII alphabet, numbers, and underscores.** Don't even think about Unicode in file names, because that is totally out of reach for QuakeC.


# Universal remarks for anyone making Quake maps

- Don't forget to add at least 1 `info_intermission`. Otherwise players will likely see the scoreboard from somewhere inside a wall, making the author of the map seem like an amateur.
- Please also add an `info_player_start,` even though your map is not meant for single-player. It makes it easier to explore the map in any Quake engine.


## Random rant inspired by some recent Quake DM maps

The Frogbot is designed to mimic a human player. If it takes hours of tweaking waypoints just to give the bot a mere 60% chance of getting past a certain spot in the map, then this spot will likely also be annoying for human players (unless it is due to a bug in the bot code). Some things I have observed in some recent maps:

- Extremely tricky jumps that require some perfect sequence of bunny hops to reach an essential part of the map, will _not_ make it fun to play for anyone else than the ever shrinking group of veteran players, and will _not_ help to keep newer generations interested in this classic game.  
  It is perfectly OK to design such things in niche training or competition maps, or add it as a shortcut to give skilled players a _slight_ advantage. But, if your goal is to make a new map that has a chance of joining the ranks of classics like Aerowalk, making the map rely on tricks is a guarantee to thwart that goal.

- Same for tricky geometry, platforms with specific timing, or other things that break the flow of fast-paced deathmatch gameplay. What makes a single-player map fun or challenging, will often make a multiplayer map _annoying._ Arguably the main reason why people still play maps like `dm2` in 2025, is not because of its traps, but rather likely nostalgia, it was one of the very first maps available at all.

- You are making a map for **Quake,** not for _insert-name-of-latest-AAA-game-here._ The engine dates from 1996 and has _limitations,_ which give it one of the fastest gaming experiences possible, combined with a certain aesthetic. Embrace the limitations and respect the aesthetic, instead of trying to “upgrade” it to look like any recent game. The goal of Quake is to _gib opponents,_ not to stand still and gawk at ultra-high res pixels. Getting distracted by eye-candy _will_ and _must_ be punished by getting mercilessly **gibbed.**  
  Yes, one can enhance the looks of a map through recent advances in some implementations of the game engine, like skyboxes and high-res or transparent textures, but your map must still look good and be playable in simpler engines, or by people who don't want to download a bunch of extra files. Provide sensible fallback textures embedded within the BSP.

- Maps that contain a lot of near-pitch-black zones are _not_ fun and are a lame way to try to make it more challenging. (Note that lighting is irrelevant for bots; they will kick your ass just as hard whether it is hiding in some dark zone or not.) Not being able to see anything is just plain annoying, and gets even more annoying if lethal traps are hidden in the dark zones.

- ‘Secrets’ are OK… but only if they are _not really secrets._ Look at the classic DM maps, and you'll notice that doors or switches which need to be pushed or shot to reach some power-up, are in plain sight, indicated with a visual cue, and triggers are always near the thing they activate. Putting a switch at one end of the map that opens a door at the other end that can only be reached by making a perfect undisturbed run, is fine in a single-player map. In a net map, it is _pointless._

- Some examples:
  - Good: _Panzer, Nova, Halo, Joi Zite._ All made by _Alice,_ who IMO knows what constitutes a good Quake multiplayer map. My only gripe is that they all look similar; some variation in textures would give each map more of a unique character.
  - Meh: _Abyssinia_ by _bps,_ looks nice and would be a fine single player map, but is terribly dark, sprawls in all directions, has annoying geometry and traps hidden in dark places. Similar remarks for _Sanctuary of the Silent Scribes_ by _infinity._ Also looks nice, but _way too dark_ overall, large complicated geometry with dead-ends, and reaching certain items requires too much fuss. Again, looks like a SP map hastily promoted to MP.
  - Ugh: _pocket infinity_ by _fourier/infiniti._ Annoying geometry, Quad only reachable by performing speed run tricks after pushing a button, and one of the teleports in the final version is only good for breaking kneecaps unless one knows that it requires air strafing. This is OK as a trick map, not as a regular net map that could invite new players to Quake.
