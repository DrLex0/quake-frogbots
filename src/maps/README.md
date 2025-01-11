# Frogbot v2 Map Waypoint Files

Compiling waypoints for a certain map into the Frogbot `qwprogs.dat`, allows playing against bots on that map.  
Similarly, compiling waypoints into the waypoint tool `progs.dat`, allows to view and edit those waypoints in the tool by loading the map in it.

Managing waypoint files should be done through the `generate_maplist.py` Python script. It can generate and use text files with lists of map files, and then use those files to generate the QuakeC code that is used by the Frogbot and waypoint tool builds. One can manually edit the list files to add or remove specific maps.

Using the script is straightforward, usage instructions are shown by running with `-h` or `--help` argument. The script has no dependencies and should run in any recent Python3 environment.

Subfolders are supported, and can be used to facilitate building for a specific set of maps. Specify one or more subfolders after the `-d` argument of the script.

To use a different maplist file than the default `maplist.txt`, specify it with the `-f` argument.

Because the format of waypoint files has changed compared to the older Frogbot code, waypoint files created with the older waypoint tool must be _transformed._ Do this by enabling the `-t` option of the script, it can't hurt to always enable this because it auto-detects the format.

## Example

Re-generate the maplist file using all map QC files in this directory and the `trinca` subfolder:
```bash
./generate_maplist.py -vtl -d trinca
```

Render the QuakeC source code from the maplist file:
```bash
./generate_maplist.py -vg
```

Or, do all of the above in a single invocation:
```bash
./generate_maplist.py -vtlg -d trinca
```
