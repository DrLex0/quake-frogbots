# Frogbot v2 Map Waypoint Files

Compiling waypoints for a certain map into the Frogbot `qwprogs.dat`, allows playing against bots on that map.  
Similarly, compiling waypoints into the waypoint tool `progs.dat`, allows to view and edit those waypoints in the tool by loading the map in it.

It will soon also be possible to inject waypoint data into a `.map` file to build the map with embedded waypoints, or into an `.ent` file to allow loading the map with waypoints, without having to recompile anything.

Managing waypoint files for compiling them into the Frogbot `qwprogs.dat`, or the waypoint tool `progs.dat`, should be done through the `generate_maplist.py` Python script. It can generate and use text files with lists of map files, and then use those files to generate the QuakeC code that is used by the Frogbot and waypoint tool builds. One can manually edit the list files to add or remove specific maps.

Using the script is straightforward, usage instructions are shown by running with `-h` or `--help` argument. The script has no dependencies and should run in any recent Python3 environment.

Subfolders are supported, and can be used to facilitate building for a specific set of maps. Specify one or more subfolders after the `-d` argument of the script.

To use a different maplist file than the default `maplist.txt`, specify it with the `-f` argument.

Because the format of waypoint files has changed compared to the older Frogbot code, waypoint files created with the older waypoint tool must be _transformed._ Do this by enabling the `-t` option of the script, it can't hurt to always enable this because it auto-detects the format.

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
