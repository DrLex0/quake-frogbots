# Frogbot v2 Map Waypoint Files

This directory contains waypoints in QuakeC format that can be built into the Frogbot `qwprogs.dat`, or the waypoint tool `progs.dat`. This allows to:
- play against Frogbots in the corresponding maps without requiring external files;
- view, explore, test, and edit existing waypoints in the waypoint tool.

Adding work-in-progress waypoints, rebuilding the waypoint tool, and using the _become Frogbot_ feature of the tool, is a good way to make new waypoints for a map.

Keep in mind that it is **hard** to update compiled waypoints to reflect major changes to a map. Adding or removing entities will break the QuakeC waypoint representation badly, because it relies on _indices_ that will shift when deleting or adding items. When removing or adding only a single item, the `entity_shifter.py` script can be used to patch existing waypoints (after which they must still be checked and updated). For larger changes, like when a map is still under development, the only sane way to work with waypoints is to use the _embedded workflow,_ and even that is only feasible if the changes are no longer expected to be extensive. More info about this can be found in the waypoint tool README.


## Updating the maplist

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

Re-generate the maplist and aliases file using all map QC files in this directory and the `drlex, ktx, trinca, other` subfolders:
```bash
./generate_maplist.py -vtl -d drlex ktx trinca other
```

Render the QuakeC source code from the maplist and aliases file:
```bash
./generate_maplist.py -vg
```

Or, what you'll usually want: do all of the above in a single invocation:
```bash
./generate_maplist.py -vtlg -d drlex ktx trinca other
```


## Special characters in map names

Some characters need special treatment, because they would otherwise conflict with QuakeC source code. However, if you use the `getmapdump.py` script to extract waypoint code from a Quake log, and then the `generate_maplist.py` script to update the sources, this is all done _automatically_ and you can skip the rest of this explanation.

At this time, the following characters must be (and are by the scripts) converted as follows from the original map name to the function name that defines the waypoints:
- `+` becomes `PLUS`;
- `-` becomes `DASH`. 

For instance, `dmz1++.bsp` will get a waypoint loading function called `map_dmz1PLUSPLUS`.

More may need to be added if someone wants to make waypoints for maps with other funky characters. However, if you make a new map, and have to choose a file name, by all means **please just stick to the ASCII alphabet, numbers, and underscores.** Don't even think about Unicode in file names, because that is totally out of reach for QuakeC.


# Hints for converting old waypoints

Waypoints exist for the older Frogbot versions and can be readily converted using the `generate_maplist.py` script. However, usually the waypoints will require extra clean-up to fix flaws and bring them up-to-date with the v2 features.

The last known older Frogbot builds had almost 380 waypoints, most of which were made by Trinca. Quality varies, which I assume to be for the most part due to the awkwardness of the old waypoint tool. It lacked good ways to visualise paths, and made connecting teleports a pain. Moreover, there was no clear guide, for instance how to assign goals and what not to do when assigning zones. The only guide I know of was Mick's, and although a good starting point, it was still rather basic.

A checklist of things I usually have to fix when converting old waypoints:
- **Teleports.** See the instructions in the waypoint tool README. The `K` key is now your friend: when used on teleport triggers, it will set the single correct outgoing path and drop the others. What it won't fix, is bad assignment of incoming paths, you must check and fix this yourself.
- **Unwanted paths.** These may exist due to the old waypoint tool having no easy way to detect superfluous paths, especially if a far away marker got accidentally connected. The new tool makes this easier: use the `R` key, and if you see unexpected markers being listed, or the spikes for non-teleport markers flying through walls and ceilings, then it means incorrect paths need to be removed. It is often easier to just clear all paths with `T` and then re-link the correct paths.
- **Markers without zone or goal.** The `N` and `M` keys are your friend here. This will especially be the case for `trigger_push` and `trigger_multiple`, because the old Frogbot did not create markers for these.
  - For `trigger_push`: you really should remove any existing kludge based on manual markers, and make the one-way path go through the (first) push marker (making any others on the same trajectory untouchable).
  - For `trigger_multiple`: in most cases they should be untouchable, but sometimes not, see the README.
- **Goal assignment.** Unfortunately one of the harder things to get right. In some maps, the waypoint maker obviously just ran around and incremented goal numbers, which is not a good way of working. It is often better to just go through all items again, than to try to nudge the existing goal assignments. Things to keep in mind:
  - give lowest goal numbers to the most important things. Mind that power-ups are useless without decent weapons: easy to reach weapons and armour should get a lower goal number than an invisibility ring somewhere in a corner of the map;
  - only same type items directly linked and close together within the same zone, should get the same goal number; otherwise ensure that different items within the same zone all have different goals, and preferably give same type items in the same zone different goals if not clustered;
  - _never ever_ give important items (ammo, powerups) the same goal within the same zone as other items!
- **Zones.** This is generally OK, but sometimes you will find overly large or scattered zones. Again, ensure zones follow the guidelines from the waypoint README.


# Universal remarks for anyone making Quake maps

- Don't forget to add at least one `info_intermission` entity, showing a nice view of the map. Otherwise players will likely see the scoreboard from somewhere inside a wall, making the author of the map seem like an amateur. (The _custom intermission_ feature of the waypoint tool may be useful to determine the `origin` and `mangle` values, but you should then use these to add an actual `info_intermission` entity in your map editor; the custom intermission itself will only work inside the Frogbot mod and is only meant for duct-taping existing maps.)
- Please also add an `info_player_start,` even though your map is not meant for single-player. It makes it easier to explore the map in any Quake engine.
- Avoid complicated lift or other platform setups. If you have a hard time setting up waypoints to make the bots handle your nifty contraption, then real players will likely also have problems with it, especially in the heat of battle.


## Random rant inspired by some recent Quake DM maps

The Frogbot is designed to mimic a human player. If it takes hours of tweaking waypoints just to give the bot a mere 60% chance of getting past a certain spot in the map, then this spot will likely also be annoying for human players (unless it is due to a bug in the bot code). Some things I have observed in some recent maps:

- Extremely tricky jumps that require some perfect sequence of bunny hops to reach an essential part of the map, will _not_ make it fun to play for anyone else than the ever shrinking group of veteran players, and will _not_ help to keep newer generations interested in this classic game.  
  It is perfectly OK to design such things in niche training or competition maps, or to add it as a shortcut to give skilled players a _slight_ advantage. But, if your goal is to make a new map that has a chance of joining the ranks of classics like Aerowalk, making the map rely on tricks is a guarantee to thwart that goal.

- Same for tricky geometry, platforms with specific timing, or other things that break the flow of fast-paced deathmatch gameplay. What makes a single-player map fun or challenging, will often make a multiplayer map _annoying._ Arguably the main reason why people still play maps like `dm2` in 2025, is not because of its traps, but rather likely nostalgia, it was one of the very first maps available at all.

- You are making a map for **Quake,** not for _insert-name-of-latest-AAA-game-here._ The engine dates from 1996 and has _limitations,_ which give it one of the fastest gaming experiences possible, combined with a certain aesthetic. Embrace the limitations and respect the aesthetic, instead of trying to “upgrade” it to look like any recent game. The goal of Quake is to _gib opponents,_ not to stand still and gawk at ultra-high res pixels. Getting distracted by eye-candy _will_ and _must_ be punished by getting mercilessly **gibbed.**  
  Yes, one can enhance the looks of a map through recent advances in some implementations of the game engine, like skyboxes and high-res or transparent textures, but your map must still look good and be playable in simpler engines, or by people who don't want to download a bunch of extra files. Provide sensible fallback textures embedded within the BSP.

- Maps that contain a lot of near-pitch-black zones are _not_ fun and are a lame way to try to make it more challenging. (Note that lighting is irrelevant for bots; they will kick your ass just as hard whether it is hiding in some dark zone or not.) Not being able to see anything is plain annoying, and gets even more annoying if lethal traps are hidden in the dark zones.

- ‘Secrets’ are OK… but only if they are _not really secrets._ Look at the classic DM maps, and you'll notice that doors or switches which need to be pushed or shot to reach some power-up, are in plain sight, indicated with a visual cue, and triggers are always near the thing they activate. Putting a switch at one end of the map that opens a door at the other end that can only be reached by making a perfect undisturbed run, is fine in a single-player map. In a net map, it is _pointless._

- Some examples:
  - Good: _Panzer, Nova, Halo, Joi Zite._ All made by _Alice,_ who IMO knows what constitutes a good Quake multiplayer map. (Only nitpick: maybe some more texture variation to make each map stand out more.)
  - Meh: _Abyssinia_ by _bps,_ looks nice and would be a fine single player map, but is terribly dark, sprawls in all directions, has annoying geometry and traps hidden in dark places. Similar remarks for _Sanctuary of the Silent Scribes_ by _infinity._ Also looks nice, but _way too dark_ overall, large complicated geometry with dead-ends, and reaching certain items requires too much fuss.
  - Meh: _pocket infinity_ by _fourier/infiniti._ Annoying geometry, Quad only reachable by performing speed run tricks after pushing a button (no way the Frogbot can be set up to do this without adding straight hacks), and air strafing is mandatory for one of the teleports in the final version to be useful instead of a hazard. OK as a trick map, not as a map that could invite new players to Quake.
