# Quake Frogbot Waypoint Tool v2

## TODO
- Add embedded waypoint instructions when scripts are ready
- Add some screenshots


## About

The Quake Frogbot needs _waypoints_ to be able to run around in a map. The waypoints need to be generated for each map, currently this is a manual process (it should in theory be possible to automatically generate sensible waypoints from map geometry, but manual tweaking will always provide the best results).

The waypoint tool runs inside plain Quake game engines (not QuakeWorld) and allows to create and edit waypoints. It is based on the one that _Mick K_ provided in his [waypoint guide](https://mickkn.mooo.com/quakeworld/frogbot/). It is built from the same source code as the Frogbot, but then with UI code added and some unneeded bits removed.  
The original UI source code is long lost or at least not easily found, hence it was reconstructed by DrLex through decompiling, and then enhanced for greater usability.

Once waypoints have been created, there are 2 ways to allow Frogbots to use them:

1. Recompile the Frogbot `qwprogs.dat` with the waypoint data included. This was the only way of doing it before DrLex implemented the next method in 2025 (hey, better late than never…)
2. Embed the waypoint data in a map BSP file. The information is stored as fields attached to entities, these fields all have a `FrB_` prefix. A script ~~is~~ will be provided that supports injecting the data into a `.map` or `.ent` file. This means this method can be used to build a BSP file with built-in waypoints, or provide them as a separate file for engines that support `.ent` files.

Whatever method is used, the most practical way of producing waypoint data is with this waypoint tool.  
(One could manually set up the `FrB_` fields in an editor like TrenchBroom, but that would be very time-consuming and error-prone. It would only be OK for making simple changes.)

## Deploying and Building

In this directory you will find a prebuilt `progs.dat`, and an `autoexec.cfg` that sets up similar key bindings as used in Mick's guide. Put both inside a `waypoint` subdirectory of your favourite Quake engine. I use _vkQuake,_ but any engine that can run the single player campaign should work.

If you're going to make new waypoints for Quake maps, it will be essential to rebuild the waypoint tool with your work-in-progress waypoint data included, as explained below.  
The waypoint tool is built from the same source code as the regular Frogbot, by enabling different options. To rebuild it with _fteqcc:_
```bash
fteqcc.bin -DWAYPOINT_BUILD=1 -O3 -srcfile progs-waypoint.src
```

Important: the regular build of this tool requires a Quake engine that supports the `stof()` function (#81). Most modern engines like QuakeSpasm or vkQuake are OK. (If you badly want to run this in the original Quake, it is possible by rebuilding the tool with the `VANILLA_QUAKE` macro defined, but this will break the loading of BSP-embedded waypoint data).

## Editing Existing Waypoints

One of the motivations for resurrecting the source code of the waypoint tool, is to allow loading existing waypoint data for a map, such that one can simply continue editing from where one left off. If the tool is built with the waypoint code for that map, or the map contains embedded waypoints, then they will be loaded together with the map when executing the `map <mapname>` command.

Saving work-in-progress, testing it with bots, and then continuing to edit, is the **only** sane workflow to make good waypoints for any map larger than a trivial 1-on-1. Making good waypoints for a larger map can take _days._ Trying to do it in a single session and hoping nothing crashes, and hoping it will be perfect from the first time, is _insane._

One can use the same 2 methods as described above to resume editing existing waypoints for a map:

1. Rebuild the waypoint tool with your latest waypoint code added to the `maps` directory.
2. Inject the waypoints into the `.map` file and rebuild the BSP, or, if the Quake engine you're using supports `.ent` files, inject the waypoints into such file.

Recompiling the tool or using an `.ent` file are the easiest methods. Building waypoints into a BSP should be kept as final step when both the map and waypoints are ready for release.


# Waypoint Creating and Editing Guide

This is an evolved version of Mick's guide, which should now be considered obsolete, although it was a great starting point without which all this stuff would never have existed.

If you want to create waypoints for a map, I advise to first get familiar with that map. Ideally, play the map with human opponents, although you can also learn a lot by observing it being played.  
The nice thing about the waypoint tool though, is that _it runs inside Quake,_ and one can also explore maps in it, and try out jumps and such.

## How the Frogbot works, in a nutshell

The Frogbot relies on **markers** to navigate the map. Bots can only run or jump from one marker to another in (usually) a straight line.

Markers are automatically generated for several entities in a map:
- deathmatch spawn points;
- weapons, ammo, health packs, armour, etc.;
- teleport triggers and destinations, doors, and platforms.

However, those alone don't suffice. _Extra markers_ must be added to guide the bots past corners, obstacles, etc. Then markers must be divided into **zones,** and the items that can be picked up must be given **goal** numbers to indicate preference. Last but not least, **connections** must be created between markers to tell the bot what paths can be followed, optionally with special descriptions for some of those connections.

## Key bindings

These are the bindings provided by the `autoexec.cfg`. Of course you are free to modify them. Unless your memory is flawless, you will want to print out this list, or have it on a second monitor while running the waypoint tool.
```
KEY	ALTKEY	OLD_IMP	NEW_IMP	FUNCTION
MOUSE1	3	119	132	SPAWN A MARKER
O		120	131	TOGGLE MANUAL-MODE
N		125	133	CHECK ALL GOALS
M		126	134	CHECK ALL ZONES
I	TAB	127	135	TOGGLE STATIC ACTIVE MARKER
P		128	136	REMOVE ACTIVE MARKER
H		129	137	DISABLE ACTIVE MARKER
J	6	130	138	TOGGLE ONEWAY-MODE
MOUSE2	4	131	139	TOGGLE CONNECT-MARKERS-MODE
G	9	132	142	DEFAULT MARKER-MODE
F	5	135	144	TOGGLE CLOSEST-MARKER-MODE
T		137	145	CLEAR ACTIVE MARKER
Y		138	146	MOVE ACTIVE MARKER
U		139	147	VERTICALLY MOVE ACTIVE MARKER
.	2	140	148	INCREASE GOAL/ZONES
,	1	141	149	DECREASE GOAL/ZONES
ENTER	Q	142	150	SET GOAL/ZONE
C	8	143	151	PRINT GOAL
R		none	157	PRINT PATHS
V	7	144	152	CYCLE PATH-MODES
				- disconnect-mode
				- jump ledge-mode
				- dm6 door-mode
				- rocket jump mode
			(new!)	- precision jump mode
				- reversible display-mode
				- water path display-mode
				- path mode OFF
B		145	153	DISPLAY TRAVELTIME
Z		146	154	CYCLE DISPLAY-MODE
X		147	155	DISPLAY REACHABLE
L	0	none	156	CYCLE BETWEEN 3 CLOSEST MARKERS
/		none	158	PRINT COORDINATES & EXTRA INFO
F1		133	143	SAVE MARKERS
F2		?	130	NOCLIP
F3		?	50	DISABLE DAMAGE FLASH
F5		-	-	CONDUMP COMMAND (dump console to file)
MOUSE3  	-	-	FIRE
```

## The workflow

Ensure the map is in your `id1/maps/` folder. Then Launch Quake. You may want to launch the engine with `-condebug` argument to automatically dump console output. Not essential, but provides a safeguard against unexpected crashes, although the new waypoint tool is more stable than the old one.

In the Quake console, type `game waypoint`. Then load the map with `map <mapname>`. Then you can start making waypoints as explained below.

After loading the map, it looks like you're in a regular Quake game with no opponents and everything made bright and low-contrast to better see what you're doing. To start editing waypoints, you must toggle **manual mode:** press `O`.

**Markers** are represented by the _Quake guy._ Inactive markers have the shotgun, the active marker wields the axe. Rotating markers indicate a relation to the current marker, depending on the current view mode.

By default, the tool will activate markers in the same way as in the game, i.e., when you're close enough to pick up something or trigger an action. Usually, you will want to enable the tool's custom **Closest-Marker-Mode** with `F`. CMM makes it generally easier to select markers. When markers are really close to each other or overlap, CMM also allows to cycle between the 3 nearest with the `L` or `0` (zero) key.

### Useful keys for displaying info
- `Z` changes the display mode, which is useful to verify things. For instance path display mode will make all other markers spin that are part of the active marker's outgoing paths.
- `C` prints information about the active marker, like its number, zone, goal, and coordinates.
- `R` prints outgoing and incoming paths for the active marker, and visualises them through flying spikes.


### Steps
These steps do not need to be done in this exact order, but you will typically move from the top to the bottom of this list as you progress.

1. Use `,` and `.` or the scroll wheel to select a **ZONE** number.  
   - Zones could be considered parts of the map where everything is within reach without having to cross obstacles or run a long distance. For instance 2 floors that require traversing a big staircase or elevator, must get a different zone. Zone numbers do not impose a preference, I usually start with 1 for the “main” zone where most of the action will happen and go up from there, but you can use any number for any part of the map, and you can skip numbers.
   - There can be up to _32 markers_ in one zone. If you exceed this, you must split up zones.
2. Activate the desired marker and set its zone: `ENTER` or `Q`. Do this for all markers you consider the same zone.
3. Add extra markers where needed for constructing paths such that bots won't get stuck on geometry: move to the spot and `MOUSE1`. Do not overdo this, but don't leave huge gaps between markers either.  
   Remember to also assign a zone to the new markers. If a zone number is currently selected, new markers automatically get this zone.
4. Assign **GOALS** to items: things the bot will want to fetch: weapons, ammo, health, powerups. Use `,.` or scroll to select GOAL number and again use `ENTER` or `Q` on the marker.
   - The **lower** the goal number, the **more likely** the bot will want to pick it up. Goal numbers are more like _suggestions_ than hard commands. The bot has its own logic for preferring items, but this logic can be influenced by goals. For instance, the bot will desire to pick up Red Armour when available. If it is better to first pick up yellow or even green armour before chasing the RA, you should give the RA a very high goal (possibly even 24), and the other a very low goal, to tweak this preference. For Mega Health, if not easily accessible, you may need to give it a very low goal number to make the bot want to fetch it. It depends on the map layout, and you may need to experiment a bit.
   - Mick recommends **not to reuse the lowest goal numbers,** and I can confirm that using the same goal number for 2 different nearby items is problematic, and may cause the bot to ignore one of them. It should be OK to use a low goal number for items in different zones, but I tend to avoid this and try to keep the lowest numbers unique.
   - You will notice that the following items are given high default goals because they are considered less desirable, but of course you can give particular instances of these items a different goal if you want:
     * 19 `item_cells`
     * 20 `weapon_supernailgun`
     * 21 `weapon_supershotgun`
     * 22 `weapon_nailgun`
     * 23 `item_spikes`
     * 24 `item_shells`
   - Clusters of the same ammo or health may be more worthwhile to take a detour than single scattered items, hence may deserve a lower goal number than isolated items of the same kind.
   - It is possible and valid to assign _no goal at all_ to items. This will not make the bot totally ignore them and it may still pick them up when nearby, but it will generally not do any effort to reach the items. This is useful if for instance chasing a particular Quad or invisibility is too risky and makes the bot an easy target.
5. Go to another zone and repeat steps 1 to 5.
6. Use `N` and `M` to check whether you didn't forget to set zones and goals (enable NOCLIP for this, `F2`).
   - Using the `C` key on an active marker will show its zone and goal, and some more info.  
   - It is recommended to give everything a zone, even if it will not be used in a path. It is OK to omit goals as explained above.
7. **Connect markers:** each marker can have up to 8 outgoing paths the bot may choose from. Normally the tool will create 2-way (bidirectional) paths, unless you enable one-way mode with `J`. Remember that you can use the `R` key to display paths for an active marker.   
   To add a path from marker _x_ to _y_ (and vice versa unless one-way mode):
   - Start at _x_, optionally press `G` to reset marker mode, then `MOUSE2` for Connect Marker Mode.
   - The next marker you touch will be linked. If there is any risk of activating the wrong marker on the way, first press `MOUSE2` again to temporarily disable CMM.
   - Move to marker _y_. If you didn't disable CMM, the link will be made instantly. Otherwise you again need to `MOUSE2`.
   - Once a path has been added, Connect Mode disables itself, but marker _x_ remains set as static active marker. You can then either make another path from _x_ to a different marker by moving to it and again using `MOUSE2`; or you can deselect _x_ by pressing `TAB` or `G`.
   - Avoid making paths _towards_ spawn points or teleport destinations, use one-way mode to only go away from them, _because telefrag._
   - Ensure every marker that can be reached in any way (even if only by being flung around by an explosion), has at least one outgoing path, otherwise the bot may get stuck on it.
   - If you added a path by mistake, you can remove it with _disconnect mode,_ see below.
8. Connecting **teleporters** is like creating any one-way path, but with something extra.
   - You must connect each `trigger_teleport` to the `info_teleport_destination` it connects to. To do so easily, it is _essential_ to first enable both NOCLIP with `F2` and closest-marker mode with `F`.
   - Then move into the teleport trigger zone, and ensure the `trigger_teleport` marker is selected.
   - Enable one-way mode `J`, then `MOUSE2` to start connecting.
   - Now disable manual mode `O` to be actually teleported, then re-enable `O`.
   - Since you are now on top of the `destination`, it should be immediately connected.  
     (If the level designer stacked another marker on top, the wrong one might get selected. In that case, remove the connection, and try again after changing overlap preference with `L` or zero `0`. When designing your own levels, _avoid_ giving info entities the exact same location as others, nudge them around a bit.)
   - If it is a 2-way teleporter, now do the same thing to connect its trigger to the destination at the other side.
   - It doesn't matter whether you assign a `trigger_teleport` the zone it is in, or its destination zone. (I stick with the zone it is in.)
9. **Special path modes.** You can apply these while making the paths, or afterwards. The modes for a marker's paths can be seen by pressing the `R` key.  
   Same workflow as above, only now you also have to select the mode with `V` before making the connection (not all are path modes, some affect display mode). Most of these require _one-way mode_ to be enabled (`J` key).
   - **Disconnect mode**: removes a path, but even though this also works without enabling one-way mode, it will only disconnect the path from the starting marker _x_ to target _y_. Repeat in the other direction unless you really want to have a one-way path.
   - **Jump ledge** (shown as ‘`J`’, number 1024 in code) is to make the bot jump _up onto_ or _down from_ ledges, or bridge gaps. You'll need this for anything that cannot be reached by merely running. The bot will refuse to take a downwards jump that may cause damage, _unless_ it has ledge mode. When unsure, it is better to assign ledge mode when unneeded than the other way round.
   - **Door mode** (shown as `‘D’`, number 256 in code) is for getting through doors like in _dm6_ that need to be shot/whacked to open. This is limited by certain constraints and requires extra configuration. More details in the advanced section below.
   - **Rocket jump mode** (shown as `‘R’`, number 512 in code) is to make the bot consider a RJ from that place to the destination. It will only do this if the conditions are right, and will also add a coin flip to the decision, so don't expect the bot to RJ all the time. See the advanced section below for some tips.
   - **Precision jump** (shown as `‘P’`, number 2048 in code) is _new_ compared to the older Frogbot, and allows to navigate small steps like the ones towards the yellow armour in _e1m2._ This must only be used when the bot can get within a distance of 48 units of the marker that has the `P` path flag. If not, the bot will get stuck. _Do not_ combine precision jump with any other path mode.  
     You may not need this mode often, but without it, getting onto certain small steps is often near impossible because the bots move too erratically when trying to use ledge mode.

At regular moments, and especially when you're done, use `F1` to dump the waypoint code to console. If you didn't run with `-condebug`, you must then use `condump` to write the console log to a file. The `autoexec` binds this to `F5` (think QuickSave).

### General Remarks
- You can ‘lock’ the active marker in Static Marker mode with `I` or `TAB`, allowing to move to other markers without activating them. It is also useful to watch the paths animation (`R`) from a distance, or check how far you are from the marker with the `/` key.
- It helps to draw a floor plan of the map with zones, goals and paths, although the visualisation modes of the tool make it easy to spot mistakes. It also is interesting to walk around in existing maps and see how waypoints were added.
- At any time when you are confused about what marker mode you're in, press `G` to reset. (The only thing this does not reset, is closest marker mode.)
- Moving an existing marker is preferable over deleting it and making a new one. Static marker mode (`I` or `TAB`) is your friend here.
- Paths through _push zones_ must be one-way. For simple pushes, one marker before the push brush and one at the exit may suffice. If there are corners and bends, an extra marker may be needed to guide the bot into the push.
- It is possible to apply multiple modes to a path, but this should almost never be needed.
- Vertically moving markers (`U`) can also be used on `func_button`, `teleport_trigger`, and `door` markers, but not on other non-manually created markers like weapons.
- I don't really know the purpose of the _‘display reachable’_ tool. It requires static active marker mode (`I` or `TAB`), and will try to trace a path towards the first marker you're ‘touching’ after activating this mode. It will fail if there is an obstacle, or the distance is “too far,” whatever that means.  
  It has nothing to do with unreachable marker flag (see advanced section).  
- Same for the _runaway_ thing: I don't know what it's for. The information printed on the second and third lines when pressing `C` is related to this ‘runaway’ concept, and the markers shown in runaway mode are the same ones listed in those lines. As far as I know, this is low-level information one should generally not care about, but if someone knows what it means, please explain!


## Adding your waypoint data to Frogbots and/or waypoint build

Again, use `F1` to dump the waypoint code to the console, and unless you launched Quake with `-condebug`, then use `F5` to save the console to a file. So, now you have this dump of waypoint code. What to do with it?

As stated above, you do not need to wait until the whole map is done. You can already test your first zones, although you may need to keep spawning new bots while others get stuck in unfinished areas.

The code that is spammed to the console when pressing `F1`, is actual QuakeC code that either needs to be added to the Frogbot source and then compiled, or converted into entity fields injected into a `.map` oor `.ent` file to embed the waypoint data in it.

Find your console dump file (often called `condump.txt`) and extract the entire `void() map_mapname {…};` function from the end. Save this to a file called `map_mapname.qc`. The `mapname` must be all lowercase and correspond exactly to the actual map name that is also used for the `map` command.

For the shell freaks, this bit of magic will extract the last waypoint code from the dump:
```bash
awk '/void\(\) map_.* =/ {found=NR} END {if (found) for (i=found; i<=NR; i++) print lines[i]} {lines[NR]=$0}' condump.txt
```
Ensure no unwanted newlines are introduced in the code: lines must _only_ be split after a `;`.  
You _can_ manually edit the waypoint code, like adding a goal or path mode you forgot, removing unwanted paths or path modes, or fixing other things. The format is straightforward. Don't waste time on reordering things, because if you compile the waypoints into the tool and then resume editing from it, your neat sorting will be screwed up anyway.

### Method 1: build waypoints into Frogbot progs

This is the classic method and is required for maps you cannot rebuild yourself (actually not, it will also be possible to use an `.ent` file when embedded waypoints are fully implemented—TODO).

Add the `map_mapname.qc` file to the `maps` folder of the Frogbot source code, then run the `generate_maplist.py` script with arguments `-vlg` to update the `maplist.txt` file and routines in the source code. Then build the Frogbot `qwprogs.dat`, deploy it, and you can test your waypoints in a QW supporting engine like ezQuake.

To resume editing your waypoints, rebuild the waypoint tool `progs.dat` and deploy it, then load the map again.  

If you want to include waypoints for a certain map in this repository, create a pull request.

### Method 2: embed waypoints into a `.map` or `.ent` file

**TODO.**

…

Once you have imported waypoint annotations into a `.map` file, you can safely edit the map because the annotations rely on IDs attached to entities. Only when you delete an entity, you will need to remove the `FrB_P*` annotations from other entities that referred to the deleted ID. (TODO: allow doing this automatically with the script.) The map can then be rebuilt and the BSP can be loaded in the waypoint tool, allowing to add zones, goals and paths to any newly added entities. In general however, it is recommended to wait with embedding waypoints in the map until it is considered final.

…

Converting embedded waypoints back to QuakeC code format is simple: load the map in the waypoint tool, and dump the code with `F1` as usual.

### Remarks

Mind that when loading a map with existing waypoints in the waypoint tool, there is _no guarantee_ that all markers will have the same numbers as in the waypoint code, i.e., as last time you edited the waypoints. I expect it to be more stable in this new version than the old, but still I cannot guarantee anything.


## Advanced

### Unreachable markers

This is optional, but can prevent the bot from doing certain dumb things. Markers can be flagged as being _unreachable,_ which means the bot should avoid getting near them. Bots will avoid making jumps that end up near an unreachable marker. The bot will also totally ignore items flagged as unreachable, no matter how juicy they may seem.

To set a marker as unreachable: set display mode `Z` to “Display type,” and use `V` to select “unreachable node.” Then activate the marker and right-click (`MOUSE2`).

If there are lava or slime pits, or deadly traps, it may be a good idea to place some unreachable markers in them. Look at `dm4`, `start`, or `tox` for examples. The markers should have some zone number, but do not need to have paths. If however there is a way out of the trap, by all means add an exit route.


### Reliable rocket jumps

Rocket jumps can be tricky, especially when the destination is a ledge that sticks out. If you notice that bots often smack their head against the bottom of the ledge, it usually means the target marker is too deep into the ledge. In that case, it helps to place an extra marker just on the edge of the ledge, perhaps even slightly above it, to improve the bot's aim. Only make that marker the destination for the rocket jump path, and give it a one-way path to the actual marker on the ledge.

Also, bots will only really RJ when the path is worth following and there is no quicker, easier path to the same destination.


### Ladders

Some maps simulate _ladders_ by means of what is basically the steepest possible staircase in a Quake map, with extremely thin steps, typically only 1 unit deep. The old Frogbot was unable to ascend these, but this has been fixed in v2. It should suffice to place one marker at the bottom of the ‘ladder’, one at the top, connect them, and the bot will climb up the ladder like a human player. (This may still fail if the map does not adhere to the best practice of using integer coordinates for all vertices.)


### Setting up a shootable door
This is for doors like the one in `dm6`. Originally, the Frogbot source had everything hard-coded for this level, it was the only door the bots could handle. This has been extended by _DrLex_ to allow other doors, also vertical ones like the bookcase in `hohoho2`. (For historical reasons, the `dm6_door` name was kept in the source code and the tool.)

This only works under certain conditions:
- Bots can only handle _one such door per map._ If a map has multiple, you will have to pick the most desirable one. Do not create paths through other doors that do not automatically open when approached, or the bot will get stuck.
- The bot will only want to open the door if there is something desirable behind it. This also means the bot can only go through the door in that direction.
- The marker in front of the door and the desirable item _must_ be in a different zone. (If you have not yet created zones, assign _zone 1_ behind the door, it makes things easier.)

This may require loading at least partial waypoint data into the waypoint tool, because if the door is too different from the one in `dm6`, you will need to manually add some values to your waypoint code and then rebuild the tool.

#### Workflow
1. Assign door mode to the path that goes from outside to beyond the door. Enable _one-way mode,_ and select `dm6 door mode` with `V`. There must be no path in the other direction. You may now want to dump the code with `F1`.

2. Find the **entity** of the door. It will have a marker standing _on top_ of it, which means that for vertical doors, it will likely be inside a wall. (In that case it may be good to use `U` to move the marker to the middle of the door, although it will usually work as-is.)  
   Enable NOCLIP (`F2`) and closest-marker (`F`) to easily select the marker. Then, use `C` to print the marker number. In this example, assume it is `m42`. Then, add at the end of the dumped waypoint code, before the closing `};`:
   ```
   dm6_door=m42;
   ```
3. Find the **zone number** of the thing behind the door, which the bot will want to obtain, for instance a mega health. If you haven't started assigning zones yet, or it is easy to change them, by all means use zone 1 for this area, because it's the default and then you can skip the following step. As noted above, it is _essential_ that the zone behind the door differs from the zone from which the bot will be shooting the door.

4. If the zone behind the door is not 1, for instance 7 in this example, you must add another piece of code before the closing `};`:
   ```
   door_targetZ=7;
   ```
5. Now comes the _trickiest part:_ bots need to know when the door is **sufficiently open.** By default, this is when the door has moved _67 units_ from its closed position. For doors similar in size and design as the one in `dm6`, this default will work fine.  
If the door is much smaller or larger, or moves differently, you will need to override the `door_open_dist` parameter. You could guess, but if you rebuild the waypoint tool with the above parameters added to your waypoint code, you can actually measure inside the tool how far the door has moved.  
To do this, disable Manual Mode (`O`), shoot the door (`MOUSE3` = scroll wheel button), quickly re-enable MM, and press `/` when you think the door is sufficiently open to walk through. (Smaller doors usually need to be open all the way.)  
You should then see something like “`dm6_door dist 48.7`.” Round down the number (48 in this example), and add before the closing `};`:
   ```
   door_open_dist=48;
   ```

As you can see, pretty complicated, but having bots open these doors and obtain the precious item behind it, makes them more realistic and challenging. Look at `hohoho2` for a full example of all the above.

(Nerdy detail: the lower the zone number you use for the thing behind the door (ideally 1), the more efficient the program will run. But unless you want to run the bots on an ancient machine, this doesn't matter at all of course.)
