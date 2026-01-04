# Frogbot embedded waypoint example

This directory contains a (very) small map to demonstrate embedded Frogbot waypoint data.  

As documented in the other READMEs, there are 3 ways to play against Frogbots in this map. In a nutshell:

1. You can simply drop `gibpantry.bsp` in your Quake maps folder, launch the frogbot mod, and start playing. This file has the waypoint entity fields built into it.
2. You can drop `gibpantry-plain.bsp` and `gibpantry-plain.ent` in your Quake maps folder, and it should work the same way, if your Quake engine can load `.ent` files.
3. You can add `map_gibpantry.qc` to the `src/maps` folder, rebuild the maplist, and rebuild the `qwprogs.dat.` Then you can also load `gibpantry-plain.bsp` (renamed to `gibpantry.bsp`), and it will work within your Frogbot build.


## Details about the map

The map, called `gibpantry` or _‘Pantry of Gibbage,’_ is something I quickly cobbled together in TrenchBroom. Expect a very hectic game experience, especially if you're adding more than 1 bot. If you are in dire need of a dose of total chaos, try adding 8 level 10 bots.

The map originally used textures from the Id PAK; to avoid any legal issues, I replaced them with lookalike textures. The map and textures may be considered GPL like the rest of the Frogbot mod.

The map was lit with `light` 2.0.0a8 from EricW-Tools to use self-emitting textures:
```bash
light -extra4 -bounce 1 -emissivequality HIGH -threads 6 ${MAP_BASE_NAME}.bsp
```

I stuck to `vis` version 0.18.1 because the 2.x version is said to be not optimized (yet) for Quake 1, FWIW.

DrLex, 2026-01-03
