# Quake Frogbot v2

Based on:
- FBCA, Frogbot Clan Arena - mod that combines Frogbot, Clan Arena and Kombat Teams (KTPro)
- Trinca and Spike's last known sources

The goal: revive the Frogbots in a way that makes it less awkward to build them.

Done so far:
- Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. This basically allows an infinite number of maps to be built into the qwprogs, until we hit some other QuakeC limit.
- Simpler management of map waypoint files, with a Python script that also does the conversion for the above fix.
- Restore the waypoint tool as shown in Mick's guide. It is now possible to resume editing from existing waypoints, if you compile them into the tool and then simply load the map.

Planned:
- Add Trinca's waypoints.
- Something resembling documentation.
- Improve upon Mick's waypoint guide. Figure out the more advanced things.
- Generate waypoint qc file from annotations in a `.map` file (concept, but should be easy).

No promises about dates or reaching these goals whatsoever. It's done when it's done.

Wild ideas:
- Find a way to avoid having to compile waypoints into the (qw)progs.dat, but I'm not sure if that is possible at all.
- Construct reasonable waypoints automatically


Regards,

Dr. Lex, the Code Necromancer
