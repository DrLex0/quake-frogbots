# Quake Frogbot v2

Based on:
- FBCA, Frogbot Clan Arena - mod that combines Frogbot, Clan Arena and Kombat Teams (KTPro)
- Trinca and Spike's last known sources

The goal: revive the Frogbots in a way that makes it less awkward to build them.

Sneak preview:
- Solved the `numpr_globals` problem without requiring the `-Ovectorcalls` option in fteqcc, which has been broken for ages when trying to compile for many maps. This basically allows an infinite number of maps to be built into the qwprogs, until we hit some other QuakeC limit.
- Simpler management of map waypoint files, with a Python script that also does the conversion for the above fix.
- Restore the waypoint tool as shown in Mick's guide. It will be possible to resume editing from existing waypoints (if you compile them into the tool). (WIP, it's still broken.)
- Generate waypoint qc file from annotations in a `.map` file (concept, but should be easy).

No promises about dates or reaching these goals whatsoever. It's done when it's done.

(Ideally we should find a way to avoid having to compile waypoints into the qwprogs, but I'm not sure if that is possible at all.)


Regards,

Dr. Lex, the Code Necromancer
