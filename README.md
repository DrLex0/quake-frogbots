# Quake Frogbot v2

Based on:
- FBCA, Frogbot Clan Arena - mod that combines Frogbot, Clan Arena and Kombat Teams (KTPro)
- Trinca and Spike's last known sources
- 1 decompiled source file from the old waypoint tool (how dare I decompile a 25-year old abandoned program, so sue me)

## What in Shub-Nigguraths name is a Frogbot?

The Quake Frogbot allows to add computer-controlled players to the first Quake game. (Not to be confused with some JFrog thing.). It was created by _Robert 'Frog' Field_ in 1997. The Frogbot is regarded as one of the better performing bots. With a properly crafted waypoint file, the bots simulate a real human opponent rather well, and are still impressive despite their age and the fact that it is all implemented in QuakeC.

The bot relies on _waypoint files_ that have to be created for each map and that need to be compiled into the Frogbot. In the first decade of the 21st century, _Trinca_ did a gargantuan job of making and collecting waypoints for about 400 maps.  
The awkward workflow to make new waypoints, together with the fact that the qwprogs could only be built with support for that many maps by using a very specific version of a Windows build of the FTEQCC compiler, lead to practically nobody creating new waypoints after Trinca's anymore.

## Why this project?

The goal: revive the Frogbots in a way that:
- makes it easier to build the qwprogs.dat (with any recent version of fteqcc or maybe other compilers);
- makes it possible to resume editing existing waypoint data;
- perhaps improve some things.

**Done so far:**
- Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. This allows to build with any recent fteqcc, and basically allows an _infinite_ number of maps to be built into the qwprogs, until we hit some other QuakeC limit.
- Simpler management of map waypoint files, with a Python script that can also convert existing files for the above fix.
- Restored ability to build the *waypoint* tool as shown in [Mick's guide](https://mickkn.mooo.com/quakeworld/frogbot/).  
  It is now possible to *resume editing* from existing waypoints, if you compile them into the tool and then simply load the map. This makes creating waypoints **way** more feasible through an edit-test cycle.  
  The waypoint tool also allows to examine existing maps to better understand how to create good waypoints for new maps.  
  Also added improvements to the tool, like:
  - made closest marker mode way more usable to select hard-to-reach markers like teleport triggers;
  - print more info next to goal and zone, like coordinates and marker type;
  - print paths going out and coming into active marker (including special modes);
  - allow alternating between overlapping markers in closest-marker mode.
- Made *shootable doors* work across more maps than only _dm6_ (I kept the `dm6_door` name for the sake of legacy and because it's a good example). Works with both horizontal and vertical doors.

Planned:
- Add Trinca's waypoints.
- Something resembling documentation.
- Improve upon Mick's waypoint guide. Figure out the more advanced things.
- Tool to generate waypoint qc file from annotations in a `.map` file (currently only a concept, but should be easy).

No promises about dates or reaching these goals whatsoever. It is done when it's done.

Not really planned, but who knows:
- Make Frogbot work in non-Quakeworld engines (it builds and runs, but is not usable).

Wild ideas:
- Find a way to avoid having to compile waypoints into the (qw)progs.dat, but I'm not sure if possible at all.
- Construct reasonable waypoints automatically with AI and evolutionary algorithms and blockchain and all other buzzwords we can throw against it.


Regards,

Dr. Lex, the Code Necromancer
