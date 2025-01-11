# Quake Frogbot Clan Arena v2

Based on:
- FBCA, Frogbot Clan Arena - mod that combines Frogbot, ParboiL's Clan Arena and Kombat Teams (KTPro)
- Trinca and Spike's last known sources
- Decompiled source file from the old waypoint tool (how dare I decompile a 25-year old abandoned program, so sue me)


## What in Shub-Nigguraths name is a Frogbot?

The Quake Frogbot allows to add computer-controlled players to the first _Quake_ game. (Not to be confused with some JFrog thing.) It was created by _Robert 'Frog' Field_ in 1997. The Frogbot is regarded as one of the better performing bots. With a properly crafted waypoint file, the bots simulate a real human opponent rather well, and are still impressive despite their age and the fact that it is all implemented in QuakeC.

The bot relies on _waypoint files_ that have to be created for each map. In previous Frogbot incarnations, waypoints needed to be compiled into the _qwprogs.dat._ In the first decade of the 21st century, _Trinca_ did a gargantuan job of making and collecting waypoints for about 400 maps.

The old Frogbot had a few issues that lead to practically nobody creating new waypoints after Trinca's anymore:
- Building the qwprogs with support for more than a few 100 maps was only possible with a very specific Windows build of the FTEQCC compiler.
- It was not possible to add Frogbot support to a map without recompiling the _qwprogs.dat,_ which lead to an obvious problem of getting one's new maps added to whatever was the most popularly distributed Frogbot build.
- The waypoint creation tool had quite a few usability problems, making the workflow awkward.
- The source for the waypoint tool had become unavailable (or near impossible to find), making it infeasible to resume editing existing waypoints. Either one had to do a whole map in one go (insane for larger maps), or manually edit the code.


## Why this project?

The goal: revive the Frogbots in a way that:
- makes it easier to build the qwprogs.dat (with any recent version of fteqcc or maybe other compilers);
- makes it easier to create and edit waypoints;
- makes it possible to resume editing existing waypoint data;
- makes it possible to embed waypoint data in maps, to avoid the need to compile them into the qwprogs;
- fixes some issues.

**Done so far:**
1. Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. This allows to build with any recent fteqcc, and basically now allows an _infinite_ number of maps to be built into the qwprogs, until we hit some other QuakeC limit.
2. Simpler management of map waypoint files, with a Python script that can also convert existing files for the above fix.
3. Restored ability to build the **waypoint tool** as shown in [Mick's guide](https://mickkn.mooo.com/quakeworld/frogbot/), and improved the usability of the tool.  
   It is now possible to _resume editing_ from existing waypoints, if you compile them into the tool and then simply load the map. This makes creating waypoints _way more feasible_ through an edit-test cycle.  
   This also allows to examine waypoints for existing maps, and better understand how to create good waypoints for new maps.  
   Usability improvements implemented in the tool:
   - made _closest marker mode_ way more useful, by fixing reliability issues and also allowing to cycle between 3 nearest markers; this allows to reliably select hard-to-reach markers like teleport triggers;
   - print more info next to goal and zone, like coordinates and marker type;
   - made it much easier to check how markers are connected, by printing paths going out and coming into the active marker (including special modes), and visualising them through flying spikes;
   - fixed various bugs, for instance the tool would often crash after deleting a marker.
4. Made _shootable doors_ work across more maps than only _dm6_ (I kept the `dm6_door` name for the sake of legacy and because it's a good example). Works with both horizontal and vertical doors.
5. Added _precision jump mode_ for paths. This allows bots to navigate small steps much more reliably. The ordinary ledge jump mode does not work well for this, they would often jump around way too erratically. I applied this to the yellow armor zone of `e1m2`, it works really well.
6. Allowed to set bot _‘smartness’_ through a cvar. Default (if zero or not set) is to link smartness to bot skill level (maxing out at 10 and above), making the bots easier on lower skill settings.  
   To override smartness, set `fb_smartness` to a value between 1 to 10, or negative (= dumbest). In classic Frogbot, it was hard-coded at 10.
7. Various smaller bug and robustness fixes.

**Planned:**
- Allow using waypoint data embedded in entity fields of maps, and provide a tool to inject marker data created with the waypoint tool into a `.map` file. This means no more need to recompile qwprogs to add bot support to a map for which the source is available! (Mechanism implemented, still need script to inject WP into map.)
- Add Trinca's waypoints… and perhaps some new ones.
- Something resembling documentation.
- Improve upon Mick's waypoint guide. Figure out the more advanced things.
- Maybe try to keep the bots from wallhacking on skill levels up to 10. I shouldn't get a rocket accurately launched from a long distance in my face when turning around a corner.

No promises about dates or reaching these goals whatsoever. It is done when it's done.

Not really planned, but who knows:
- Make Frogbot work in non-Quakeworld engines. Currently it builds and runs, but _very weird things_ happen, it is not usable.

Wild ideas:
- Make shootable doors even more universal, bots should be able to open any door on the path it wants to follow, without having to tie it to specific goals/zones. Maybe even extend to also allow shooting switches to open doors.
- Find a way to load waypoints from a separate file at runtime, but I'm not sure if possible at all.
- Construct reasonable waypoints automatically with AI and evolutionary algorithms and blockchain and all other buzzwords we can throw against it.


Regards,

Dr. Lex, the Code Necromancer
