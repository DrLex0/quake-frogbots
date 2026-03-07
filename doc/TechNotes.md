# Frogbot v2 Tech Notes

The goal of this document is to offer some low-level information about how the Frogbot mod works under the hood. This is useful for debugging, troubleshooting unexpected bot behaviour in specific maps, or just for whomever is interested how it is possible to implement something like this in a programming language that does not even have the concept of arrays.

This document is currently rather unstructured, it's just various information thrown together, but even in this state it should already be useful.


## General code flow for each game frame

Figuring this out was essential to fix a lot of bugs and to know how to implement new features.

This has been obtained by littering the code with debug print statements in all important methods, and then running it in QuakeWorld (ezQuake). A NetQuake engine may follow a different flow, but general principles should be the same. At some point I might repeat this experiment in vkQuake to see where the differences are, which would also be very useful information.

1. **StartFrame** (`world.qc`)
   - **FrogbotPrePhysics1** (`botphys.qc`)
     - Loops over all clients, applies friction, and invokes for Frogbots:
     - Keeps copy of velocity with only friction applied in `.pre_arrow_velocity`
     - **VelocityForArrow** (`botphys.qc`)  
       - Sets `self.velocity` based on arrow keys set in `self.arrow`, hence keys set in a frame are only effective in the next frame.
       - When the bot is airborne, it simulates air strafing; this is not controlled by arrow keys, but directly by the relative position to the linked marker. It assumes the bot is always holding one of the strafe keys, and then turns towards the target.
     - **AvoidHazards** (`bothazd.qc`), clocked through `hazard_time`, 40/s
       - Handles jumping across gaps, avoiding falling from ledges, etc.
       - May instantly set and apply different arrow keys using `OverrideArrowVelocity` which replaces velocity set by `VelocityForArrow`
2. **FrogbotPrePhysics2** (`botphys.qc`)
   - Invoked through `.think` on `prephysics`; also loops over all clients
   - **PlayerPreThink_apply** (`client.qc`)
     - Applies water movement
     - Applies jumping when button2 is set
       - In QW, only bots need to be given vertical velocity, the engine applies it to players
       - Finalize wall strafe jumping
     - Stores current velocity in `.prephys_velocity`
3. **FrogbotPostPhysics** (`botphys.qc`)
   - Invoked through `.think` on `postphysics`; split up in 2 parts that each loop over all clients
   - **FrogbotPostPhysics1** (`botphys.qc`)
     - this ends with obstruction detection which then tries a `walkmove` as fallback for interrupted velocity-driven movement. Obstruction detection relies on comparing `.prephys_velocity` against current velocity which has been adjusted by engine physics.
   - **FrogbotPostPhysics2** (`botphys.qc`)
     - **PlayerPostThink_apply** (`client.qc`)
       - **ThinkTime** (`botthink.qc`), clocked through `.frogbot_nextthink`, about 6/s, but can be forced by certain events like being teleported.
         - **frogbot_marker_touch** (`botpath.qc`)
           - Invoked when the winner of all `check_marker` calls in this frame differs from the bot's previously touched marker.
           - Also invoked when `.linked_marker_time` expires.  
             This ensures that if the bot is stuck and keeps touching the same marker, its touch is re-evaluated at regular intervals (typically 5s), to allow the bot to take a different path if the last chosen one is blocked and goals have changed in the meantime.
           - Important to remember: due to the clocking, there can be multiple frames in between the bot activating a marker and the touch being actually processed here.
           - _skipped_ if the bot is in `WAIT_GROUND` state and is not yet touching ground!
             _Unless_ it was a sticky touch (as set by switches activating and such).
           - sets `self.look_object` in various ways
         - **BestArrowForDirection** (`botutil.qc`) sets `best_arrow` to optimal movement key(s) for `dir_move`
         - `self.arrow = best_arrow`
         - `SelectWeapon`
         - `SetFireButton` is invoked to decide whether to fire the weapon
         - `self.pitchaccel` and `self.yawaccel` are computed by using `self.look_object`, this is clocked through `.firing_reflex`, which varies from 0.5 to 0.1s depending on bot skill.
       - **SetFrogbotAngles** (`botthink.qc`)
         - **FrogTrackSimple** if `.look_here` exists and not looking at enemy.
           - forces `.pitchaccel, .yawaccel, .pitchspeed, .yawspeed` to 0, and only sets `track_pitchspeed` and `track_yawspeed` for simple rotation.
         - Total `pitchspeed` and `real_pitch` are calculated using current `pitchspeed` and `.pitchaccel`.
         - **a_rocketjump** and **SpecialAccurateMoves** (`botjump.qc`), clocked through `special_moves_clock`, 64/s
           - may override `real_pitch`, and the Quad RJ hack also overrides `real_yaw`.  
             (which is actually the only reason for the ugly fact that this logic is here in the flow)
           - **AccurateRJump** updates arrow keys to come closer to the marker, and sets jump & fire keys if position and angles are good enough
         - `yawspeed` and `real_yaw` are calculated using current `yawspeed` and `.yawaccel`.
         - actual angles, i.e. yaw and pitch are set using `real_pitch, real_yaw`


## Bot Movement

Important to know is that movement for bots is not governed by the same source code as for players, which is why the code has a lot of tests on `MOVETYPE_STEP` which applies to bots, while regular players should have `MOVETYPE_WALK`. The bot code reimplements some of the movement logic that is hard-coded in the game engine, and there may be differences that are usually subtle, but sometimes not. Mind that when becoming a Frogbot in the waypoint tool or in Quake, the move type remains `WALK`, hence testing things this way might not be perfectly reliable to know how a pure bot will behave, although I haven't seen any evidence of this.

## Marker touch quirks

Markers will no longer be touched when they are _57 units_ or more below the player. This can be used to place markers in liquids close to solid ground markers, when it is important that the liquid markers are not activated while walking on the surface. Of course it also applies to nearby paths with only a small height difference: you may need to put markers on one of the levels higher or lower if you want to ensure that there is no interference between them.

## Item clusters

Items will only be treated as a cluster as long as there are _direct paths_ between them. This means that if some map maker found it funny to place 8 ammo packs together, and you want the bot to consider this entire cluster a single source of that ammo, you must make paths between _each_ pair of packs in that cluster. In practice you probably shouldn't, and instead create several clusters, ideally each with a different goal number.


# Random fact dump

TODO: make this more structured and extend with other info.

## Essential Quake Numbers

Useful for anyone working on any Quake mod or even to map makers. TODO: this kind of info also belongs in the [QuakeWiki](https://quakewiki.org/), especially now that it has been rescued from near-death.

- The geometry you see in the game is not actually the geometry being used to calculate collisions with the player model. The player is treated as a _point_ inside a ‘fattened’ hull transformation of the map geometry. See [this cool video from Matt's Random Ramblings](https://www.youtube.com/watch?v=3KjMjHJ3WQg) for more info.
- The player model is **56** units tall. Bottom to eyes is 46 units, eyes to top 10 units.  
  In QuakeC, the `.origin` is 24 units from the bottom hence 22 units below the eyes and 32 units below the top.
  - Mouth and eyes are considered to be at the same height (or another way to look at this, is that the player is able to _breathe through their eyes_ 👀). In other words, for a player to be able to breathe in a zone with water, there must be at least 11 units of air above the water surface.
  - Projectiles (rockets, nails, …) are launched from 16 units above the origin, hence 40 units from the bottom.
  - The player model is theoretically 64 units wide, but is considered to be marginally wider than 32 units when it comes to fitting inside corridors. Same for the depth: if the player has its face or back stuck to a wall, its origin is 16 units from the wall, hence the player is considered 32 units deep.
  - In other words, for players: `mins = '-16 -16 -24` and `maxs = '16 16 32`.
- Tallest step a player can ascend without jumping: **18 units**
  - One can make a really fast fake ‘ladder’ by creating 18 unit tall steps that are only 1 unit deep.
- Tallest height difference a player can **jump** onto without having to blow up their feet with a RJ: **43 units** (assuming standard gravity 800)
- Tallest height a player can realistically rocket-jump: about 256 units (but has to be really perfect, 240u is a more realistic max)
- Tallest height a player can fall without damage: 272 units. This actually depends on velocity, hence it would be different when changing gravity.
- Widest gap a player can traverse with a straightforward jump (running at 320u/s, no speed tricks): 240 units (but the jump has to be really perfect, this is really the absolute maximum). Again, would differ when altering gravity.
- Widest gap a player can traverse by using strafing tricks: given that the max obtainable speed is around 480u/s (for instance by wall strafing) versus the regular maximum of 320, then the maximum gap should be 360 units, although this seems optimistic (TODO: verify).


# QuakeC tidbits

Again, this is info that really belongs in QuakeWiki.

- The `float` type is IEEE-754, hence:
  - Accurately represented integer value range is `[-16777216, 16777216]`
    - This means at most 24 bits can be reliably represented using bitmask operations (in theory one extra bit by using the sign, but please don't).
  - Max ≈ 3.4e38
  - Smallest positive ≈ 1.4e-45
- The `&&` and `||` operators do not short-circuit! This means every argument is always evaluated. This is why you'll see chains of `if` statements instead of `&&`, and duplication instead of `||`. These operators will (and should) only be used for really trivial things or when all arguments need to be evaluated anyway.
- The `time` global var only changes per frame, it will be the same for all processing being done for that frame.
- `self.angles` for the player represents the mouse looking direction (or keyboard if you're really oldschool). Result is `'pitch yaw roll'` (roll will usually be 0). Yaw goes from -180 to 180.
  - Mind that in the FrogBot code and perhaps in QW code in general, the pitch value (x) used for player model display is scaled by a factor 6, hence only goes from -30 (down) to 30 (up), this is to make player models reflect them looking up and down without causing ridiculous effects like them hovering horizontally.
- `traceline` behaves differently between NetQuake and QuakeWorld when starting inside a solid: QuakeWorld will treat the solid start as an immediate hit and return a `trace_fraction` of 0, while NetQuake will not detect the solid start and return either 1.0 if the trace does not cross a second boundary between non-solid and solid, otherwise a value between 0 and 1.0.
- When spawning a new entity, and there are no holes in the entity allocation space, then if you start looping over all entities from `nextent(world)` and then keeping on using `nextent`, you will find that new entity as the very last one in your loop. But in general, this will _not_ be true and the new entity will be inserted somewhere at an unpredictable place. Never rely on `nextent` looping if ordering matters, except for the very first player entities that come after `world`.
- `nextent()` goes _forward_ in history for entities that were not assigned to recycled slots from previously deleted entities. See example below.
  - This means in theory, in NetQuake, using `nextent(world)` should give the first player entity, because those should be the very first entities created by the engine.

### Example: `nextent`
Assuming `.float index;` declared and enough entities have been created with none removed such that new entities will not be added in between existing ones:
```
local entity ent1 = spawn();
ent1.index = 1;
local entity ent2 = spawn();
ent2.index = 2;
dprint("nextent(ent1).index == ", ftos(nextent(ent1).index), "; nextent(ent2).index == ", ftos(nextent(ent2).index), "\n");
```
Will output: `nextent(ent1).index == 2; nextent(ent2).index == 0` because:
- `ent2` was created after `ent1`, hence `nextent(ent1) == ent2`
- `nextent(ent2) == world` and all float fields for `world` default to value 0.

Or, if you would spawn hundreds of new entities such that all holes in the entity list are certainly filled, then if you would loop starting from `ent = nextent(world)` and keeping on following `ent = nextent(ent)`, then you will encounter your most recently created entity last. However, in practice you should _never_ rely on such logic, this is just to illustrate how entity handling works.


# De-discombobulating the route planning

The path calculations and bot route planning are at the core of this mod, and it has proven to be a solid core, which is why this mod still holds its own 30 years after it was created by Robert ‘Frog’ Field.  
However, the path computations are also by far the most complicated part of the source code, and have long remained a mystery. I have quickly learnt to revert any changes that caused `<NO FUNCTION>` or `NULL` errors in the path calculations, because debugging this without understanding the code, is a royal pain and pretty futile.

Luckily today we have AI, which despite all the criticisms is admittedly very good at pattern recognition, therefore I got the idea of simply asking some questions to one of the state-of-the-art programming-related models, and this has effectively demystified most of the path code.

One of the most important things the A.I. figured out, is that the Frogbot implements the [_Bellman-Ford_ algorithm](https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm) for finding the shortest path between points. This simple fact already helps a lot to understand what is going on in `route_calc.qc` and related files.

Currently I'll simply dump the prompt I gave to the A.I., and its answer. TODO: restructure this question-answer format into a unified whole.

Note how extensive the prompt is. There is no such thing a a free lunch, the effort formerly required to do actual work has now shifted to crafting good instructions on how to do the actual work. Anyone getting subpar results from A.I. may learn from this; these things work much better when giving them correct context.

Both the AI instructions and its answer are useful for anyone wanting to know how the Frogbot mod works in general.

## Context and instructions for examining the path planning code

This is a classic mod for the first Quake game, and it is written in QuakeC, I hope you are more proficient in it than some other AI agents, but even if not, it is mostly a special hybrid of C and C++ with specific limitations and quirks.

A quick refresher:
- The QuakeC language has no arrays or dicts, it only has entities that may have property fields, which must be pre-defined (normally in `defs.qc`).
- There is only really a `float` numerical type, no special-purpose integer. The float type can represent integers accurately up to 2^24.
- The language does have first-class functions, i.e. a function can be assigned to a variable or property field, and then invoked from that.
- The `world` entity is often a representation for NULL. A test for `if(world)` will be false, any other entity will have a true value. One cannot assign values to `world` entity fields, this leads to an instant crash.
- Quake is a frame-based video game, and all logic is executed in a certain sequence per frame. To ensure excessive calculations will not slow down the graphics, there is a limit on the number of operations and loops within each function. An integral part of the logic is the `think` concept, where an entity can be given a function to be invoked in its `.think` field, and a `.nextthink` float value which specifies in seconds when the `.think` function is to be invoked in a frame when the current game time exceeds `.nextthink`.

This mod provides the ability to play against bots, called Frogbots. For bot navigation, the mod relies on _markers_ that are specified per game map in so-called waypoints. Markers are generated for items already present in the map, and extra markers are added as part of the waypoint specification for that map. The waypoints are normally implemented as QuakeC files, but the mod has been extended to also allow loading waypoints from extra fields attached to entities.

The QuakeC sources are in the `src` subdirectory.

Markers have coordinates. The effective position of a marker is determined by its absolute minimum coordinates (`absmin` vector property) with a view offset added to it (`view_ofs` vector property). This is the canonical way to determine the true position of a marker, the `origin` property is not always reliable.

Markers can have up to 8 outgoing paths towards other markers, and are organized into “zones,” which as far as I understand it, should be kept mostly convex to ensure the route calculations work as intended, but this is something that is not entirely clear.

More details about how the paths are set up in each map's waypoint specification:
- Markers are assigned to one of the 24 possible zones by invoking the `Z1` to `Z24` functions which are defined in `route_fields.qc`. These functions do way more than just setting a zone field.
- Markers for items can also have a goal property, assigned by invoking the `G1` to `G24` functions (which are simple, they only set some fields).
- Markers have property fields `P0` to `P7` that contain entities, specifying up to 8 outgoing paths towards other markers.
- Markers can have special types specified as a bit mask in their `T` property field.
- The paths can also have special types, specified in the `D0` to `D7` property fields.

The bot path decision logic is triggered from `frogbot_marker_touch()` in `botpath.qc`. Its most important end result is setting the `.linked_marker` property on the bot, which represents the next marker the bot wants to move towards.

One of the hardest things to understand, is how the Frogbot mod computes and looks up path travel times, which is at the core of how `frogbot_marker_touch` makes its decision. The original author of the mod has worked around the lack of arrays and dicts in QuakeC, by constructing an intricate system that stores travel time data in entity fields attached to marker entities. What further complicates this, is:
- extensive use of global variables,
- assigning functions to property fields of the markers and then invoking them from there,
- the need to split up the calculations into multiple phases through `think` logic, to ensure they are sufficiently distributed across game frames.

To further add to the complexity, the author had been working on a “runaway” feature that seems mostly finished, but nowhere is it being activated, and it is not even clear for what it was intended to be used. My best guess is to allow bots to choose an optimal path to run away when they encounter an enemy in a situation when escaping is a better option than fighting.

A few important functions are:
- `.sub_arrival_time()` which is dynamically set on markers, and will return a total estimate of travel time towards that marker, with the starting point somehow being set by previous function calls.
- `EvalPath()` in `botpath.qc` which will check if the path specified by certain global variable values, is better than the last evaluated one.
- `Calc_G_time_1` is the starting point for the path calculations. In the `LSQ()` function, it is set as `.think` function on the `dropper` entity, which is again something whose actual role is rather vague; it is the very first entity being created after the game's pre-defined player slot entities.

### The AI's task

Your task is to analyze the logic across all `.qc` files, especially in `route_calc.qc, route_fields.qc,` and `route_lookup.qc,`, and explain what data structures are being constructed, and how they are actually used when the bot evaluates its next path to follow in `frogbot_marker_touch()` in `botpath.qc`. You must ignore any information given in the README files, because part of this task is to validate what is currently in them, which is sometimes based on speculation.

Logic has been added to the original mod which adds _penalties_ to path travel times depending on whether the bot has the required attributes to follow a path. For instance, paths that can only be taken by rocket-jumping, will be given a penalty time of 1000 seconds added to their true time, effectively making this path forbidden. This penalty of 1000 will be subtracted from calculated path times when a bot does have the items to (safely) perform a rocket jump. A function `AdjustTravelPenalties` will subtract the appropriate penalties from the `traveltime` variable depending on the bot's attributes. This is not something you need to explain, except for what is asked below.

Keep the explanation concise, to outline the general principles of how the path time data is organized and how the travel time calculations work, without diving into too many small details.

I do have some specific questions that may explain certain aspects with more detail:
1. How is the starting point being set for `sub_arrival_time()`?
2. When calculating the travel time or “arrival time” between 2 markers, what gets actually invoked and where has it been calculated before?
3. What is the role of `middle_marker` in the calculations?
4. Why exactly do goal numbers need to be assigned to items, how are they used? There seems to be a preference for lower goal numbers over higher goal numbers, but this seems only a weak preference. Is there any part of the code that will the cause the bot to prefer an item with a lower goal number versus higher goal numbers?
5. Does the path computation logic indeed require zones to be mostly convex for them to work correctly, or are there other constraints?
6. What effect do the extra penalties have on the path calculations? Testing has shown they work well with the regular path planning, which focuses on selecting paths with minimal times. However, I have noticed that the bot will never select a path with penalties if there is any alternative path without penalties towards the same destination, even when the bot has the attributes for the penalties to be dropped. I suspect this is because the routines in `route_calc.qc` accumulate path times as part of their calculations, hence penalties will also be accumulated, and any paths with penalties become discarded. I am content with either confirming or debunking these assumptions; unless there is an obvious solution for this problem, you should not try to propose one.
7. What does the runaway logic actually compute? What is considered a good runaway destination given the bot's current situation (own position and enemy position)?
8. It seems the path penalty logic will also interfere with the runaway calculations that predate the introduction of that logic. From what I can see, the calculations involve looking for paths with maximum travel times, and will now . At this time, it is not a problem because this feature is not used. However, if it is ever activated, is there a way to make it compatible with the penalty logic? Doing the calculations on path times with the penalties removed would avoid problems, but on the other hand, paths with penalties should probably never be chosen as an escape path?

---

## The A.I.'s answer: Frogbot Path Logic Analysis

### Overview: The Data Structures

The Frogbot navigation system is built on a graph of **markers** (nodes) connected by **paths** (directed edges, up to 8 per marker via `P0`–`P7`). To work around QuakeC's lack of arrays/dictionaries, precomputed travel-time data is stored directly as **entity fields on each marker**. Three hierarchical levels of data are maintained:

#### 1. Sub-zones (S-data): Intra-zone routing
Each marker within a zone is assigned a unique **sub-zone index** (`S_`, 1–32). When `Z1()` through `Z24()` are called on a marker, they increment a per-zone counter and call `Set_sub_arrival_time()`, which assigns to that marker:
- `.sub_arrival_time` — a function pointer (e.g. `S5_time_`) that, when invoked, computes the travel time from some origin to this marker's sub-zone within the same zone.
- `.sub_path_marker` — a function pointer that returns the next hop on the shortest path to this sub-zone.

Each marker stores `S1_time` through `S32_time` — the shortest travel time from that marker to the marker with sub-zone index 1, 2, …, 32, **within the same zone**. Similarly, `S1_next` through `S32_next` store the next-hop marker on those shortest paths.

#### 2. Zones (Z-data): Inter-zone routing
Each marker stores for every zone Z1–Z24:
- `ZN_time` / `ZN_` / `ZN_next`: shortest time to reach the nearest marker **in zone N**, the identity of that nearest zone-N marker ("zone entry point"), and the next hop on the path. This is the **forward/normal** direction.
- `ZN_time_rev` / `ZN_rev` / `ZN_next_rev`: same but only along **reversible** paths (bidirectional edges).
- `ZN_next_zone`: the first marker in the **next zone** on the route towards zone N (the zone boundary crossing point).
- `ZN_from_time`: the shortest time to reach **this marker** from any marker in zone N (reverse direction — used for sight/runaway calculations).

#### 3. Goals (G-data): Item routing
Each marker stores for every goal G1–G24:
- `GN_time` / `GN_`: shortest time to reach the goal-N item, and the identity of that goal entity.

#### How the calculation pipeline works (`Calc_G_time_1` → `Calc_G_time_14`)

All calculations are launched from `LSQ()` via `dropper.think = Calc_G_time_1`. The `dropper` entity is the first entity created after player slots and serves as a coordination entity — its `.think` and `.use` fields are repurposed to hold the current and inner-loop calculation functions. Calculations are distributed across game frames via `nextthink = 0.001` and the `set_load()` mechanism which clones the current think function to many "load" entities for parallelism.

The pipeline phases:

1. **`Calc_G_time_1`**: Initialize each marker (detect water, lava, flag setup).
2. **`Calc_G_time_2`**: Compute direct edge travel times (`TravelTime()`) and store in `P0_time`–`P7_time`. Initialize all G, Z, and S time fields to 1000000 (infinity) except self-references (time=0).
3. **`Calc_G_time_3_path`** (via `Calc_G_time_path`): **Intra-zone Bellman-Ford** — propagate S-times along edges *within the same zone only* (`m.Z_ == m_P.Z_`). Iterates until no changes (convergence).
4. **`Calc_G_time_4_path`**: **Goal propagation** — Bellman-Ford for G-times across all edges (no zone restriction). Each marker learns the shortest time to each goal.
5. **`Calc_G_time_5_path`**: **Zone propagation** — Bellman-Ford for Z-times. Also tracks the zone-boundary crossing point (`ZN_next_zone`).
6. **`Calc_G_time_6_path`**: **Reverse zone propagation** — computes `ZN_from_time` (time to reach a marker from zone N).
7. **`Calc_G_time_7`**: Marks paths as `REVERSIBLE` if the destination's next-zone-marker is in the same zone as the source.
8. **`Calc_G_time_8_path`**: **Reverse-path zone propagation** — Bellman-Ford for `ZN_time_rev` along reversible edges only.
9. **`Calc_G_time_9`**: **Sight-from computation** — for every pair of markers with line-of-sight, records the best (lowest `ZN_from_time`) visible marker per zone, stored in `ZN_sight_from` and `ZN_sight_from_time_`.
10. **`Calc_G_time_10_path`**: Propagates sight-from times along edges.
11. **`Calc_G_time_11`**: **Runaway destination computation** — for each marker, finds up to 8 best "run away" destinations (`RA0`–`RA7`) across all zones.
12. **`Calc_G_time_12`**: Same-zone runaway: considers intra-zone markers not visible from the start as runaway candidates.
13. **`Calc_G_time_13`**: Classifies runaway paths as `THROUGH_NODE` type if the bot would pass through the runaway destination on the way.
14. **`Calc_G_time_14`**: Height-equal time calculations for Z1 and Z8 (special per-zone data about whether a path exists that avoids being seen from a higher position).

Steps 3–6 and 8, 10 use `Calc_G_time_path` as the iteration driver, which calls `dropper.use()` (the current phase function) for every edge of every marker, repeating until convergence (`no_change` stays TRUE).

### How `frogbot_marker_touch()` uses this

When the bot touches a marker, it evaluates every outgoing path (`P0`–`P7`) via `EvalPath()`. For each candidate `test_marker`:

1. Sets `from_marker = test_marker`, then calls `goalentity_marker.zone_marker()` then `goalentity_marker.sub_arrival_time()`.
2. This produces `traveltime` = estimated time from `test_marker` to the bot's current goal item.
3. `path_score` combines: direction alignment, randomness, and goal-time quality. The bot picks the path with the highest `path_score`.

---

### Answers to Specific Questions

#### 1. How is the starting point set for `sub_arrival_time()`?

The starting point is set by assigning the global variable **`from_marker`** before invoking `.sub_arrival_time()`. The chain works as follows:

1. Caller sets `from_marker` (e.g. `from_marker = touch_marker_` or `from_marker = test_marker`).
2. Caller invokes `goalentity_marker.zone_marker()` — this is a function pointer on the goal marker (e.g. `Z3_marker`). It reads `from_marker.Z3_` (or `Z3_rev` for reverse paths) into the global `middle_marker`, and `from_marker.Z3_time` into `zone_time`. So `middle_marker` becomes the zone-entry-point marker on the best route from `from_marker` to the goal's zone, and `zone_time` is the time to reach that entry point.
3. Caller invokes `goalentity_marker.sub_arrival_time()` — this is a function pointer (e.g. `S5_time_`). It sets `traveltime = zone_time + middle_marker.S5_time`, i.e. the time from `from_marker` to the zone entry point, plus the intra-zone time from that entry point to the goal's sub-zone.

So `from_marker` is the starting point, and it must be set before the `.zone_marker()` / `.sub_arrival_time()` call pair.

#### 2. What gets invoked when calculating travel time between 2 markers?

To get travel time from marker A to marker B:
1. Set `from_marker = A`.
2. Call `B.zone_marker()` — a function pointer set during zone assignment (e.g. `Z3_marker`). This reads the precomputed inter-zone time (`from_marker.Z3_time`) and the zone entry marker (`from_marker.Z3_`) into globals `zone_time` and `middle_marker`.
3. Call `B.sub_arrival_time()` — a function pointer set during zone assignment (e.g. `S5_time_`). This adds `zone_time + middle_marker.S5_time` to produce the final `traveltime`.

All the underlying times were precomputed during the `Calc_G_time_*` pipeline at map load. The inter-zone times come from the Bellman-Ford in phase 5, and the intra-zone times from the Bellman-Ford in phase 3.

#### 3. What is the role of `middle_marker`?

`middle_marker` is the **zone entry point** — the specific marker within the destination's zone that lies on the shortest path from `from_marker` to that zone. It is set by the `.zone_marker()` call (e.g. `Z3_marker` sets `middle_marker = from_marker.Z3_`).

The total travel time is decomposed as:
- **`zone_time`**: time from `from_marker` to `middle_marker` (the inter-zone leg)
- **`middle_marker.SN_time`**: time from `middle_marker` to the destination within the zone (the intra-zone leg)

This two-level decomposition (inter-zone + intra-zone) is the core of the routing system. It assumes that the optimal route into a zone always passes through the optimal zone entry point, which is why zones should be kept **mostly convex** — see question 5.

#### 4. Why do goal numbers need to be assigned to items?

Goal numbers serve as **indices into the precomputed routing tables**. The `G1`–`G24` functions ([route_fields.qc](cci:7://file:///home/athomas/Develop/Kweek2/src/route_fields.qc:0:0-0:0) lines 13–36) set `marker.GN_ = marker` and `marker.G_ = N`. During the Bellman-Ford in `Calc_G_time_4_path`, each marker learns the shortest time to every goal (`GN_time`) and which entity that goal is (`GN_`).

In `UpdateGoal()` ([botgoals.qc](cci:7://file:///home/athomas/Develop/Kweek2/src/bot/botgoals.qc:0:0-0:0)), the bot evaluates all 24 goals by looking up `touch_marker_.G1_.virtual_goal` through `touch_marker_.G24_.virtual_goal`. This allows efficient lookup: from the bot's current marker, it can immediately access the nearest entity for each goal number and its travel time.

**Regarding preference for lower goal numbers**: The comment at `@/home/athomas/Develop/Kweek2/src/bot/botgoals.qc:332-334` by DrLex is accurate. The only preference is that goals are evaluated sequentially from G1 to G24 in `EvalGoal()`, and `EvalGoal()` uses a strict `>` comparison (`goal_score > best_score`). If two goals produce exactly the same score, the earlier-evaluated one (lower number) wins by virtue of being evaluated first. This is an extremely weak tie-breaking effect — in practice, two different items will almost never produce identical scores due to different distances and desire values.

There is also a `desire_adj_G1` / `desire_adj_G2` mechanism: maps can set a multiplier for goals G1 and G2 specifically (e.g. `desire_adj_G1=1.7` in dm3). This gives an explicit boost to items with those goal numbers, making G1 (and sometimes G2) more desirable. This is the **intended** mechanism for giving certain important items priority — not the goal number ordering itself.

#### 5. Do zones need to be convex?

The routing system decomposes travel time as: **inter-zone time** (from source to the zone entry point `middle_marker`) + **intra-zone time** (from `middle_marker` to the destination within the zone).

This decomposition implicitly assumes that the optimal path into a zone to reach any sub-zone destination within it always goes through the same entry point. This is approximately true when zones are convex: if a zone is convex, then once you enter it at the nearest boundary point, you can reach any interior point without leaving the zone.

If a zone is **non-convex** (e.g. L-shaped), the optimal entry point for reaching one sub-zone might differ from the optimal entry point for another sub-zone, yet the precomputed data only stores **one** best entry point per source marker per zone. This can lead to **suboptimal routing** — the bot might take a longer path because it's routed through the wrong entry point.

However, "mostly convex" is the practical constraint, not strictly convex. Small concavities are unlikely to cause noticeable problems because:
- The Bellman-Ford converges on actual shortest paths along the graph, so the S-times within the zone are correct.
- The error only occurs when different destinations in the zone would benefit from different entry points and the time difference is significant.

An additional constraint is that all markers in a zone should be **reachable from each other** within the zone (i.e., the zone's subgraph should be connected). Otherwise the S-time routing breaks down entirely.

#### 6. Effect of penalties on path calculations

Your suspicion is **confirmed**. The penalties (1000 for RJ, 10000 for slime, 100000 for lava) are baked into the `P0_time`–`P7_time` values during `Calc_G_time_2` → `TravelTime()`. These penalized times then **propagate through all Bellman-Ford iterations** in phases 3–6 (S-times, G-times, Z-times).

When `sub_arrival_time()` is called at runtime, it returns a total that is the **sum of all edge times along the shortest path**, including all accumulated penalties. `AdjustTravelPenalties()` then subtracts penalties the bot can handle — but it can only subtract a **limited number** of penalty instances (e.g., up to 2 RJ penalties of 1000, up to 7 slime segments of 10000, up to 3 lava segments of 100000).

If a route passes through, say, 3+ RJ segments, the bot can only subtract 2×1000, leaving at least 1000 in the total. This makes the route appear 1000 seconds longer than it truly is. More critically: **during precomputation**, the Bellman-Ford finds shortest paths based on penalized times. A route with even one penalized segment will have its time inflated by 1000+, making it lose against any penalty-free alternative. Since the Bellman-Ford only stores the **single best** path per destination, penalty-laden routes get discarded at precomputation time if any penalty-free alternative exists, regardless of the bot's actual capabilities at runtime.

This is why a bot never selects a penalized path when a penalty-free alternative exists to the same destination — the penalty-free path won the Bellman-Ford and is the only one stored.

#### 7. What does the runaway logic compute?

The runaway logic (phases 11–13, `Calc_G_time_11` through `Calc_G_time_13`) precomputes, for each marker, up to **8 "run away" destinations** (`RA0`–`RA7`), sorted by a "runaway score."

**What makes a good runaway destination**: In `Calc_G_time_11`, for each marker `m`, the code iterates over all zones. For each zone, it finds the route from `m` to that zone's entry point (`middle_marker`), then walks along the path from `m` to that entry point. For each intermediate marker `next_marker` on this path:

- `runaway_time` = the zone travel time (total path length)
- `runaway_score` starts at `runaway_time`, then gets multiplied by `0.125` and offset by `+1.25` for each hop traversed

So destinations that are **far away** (high `runaway_time`) and **require many hops** (the score accumulates bonuses at each hop) get high scores. The `min_traveltime` threshold (starting at 1.25, incrementing by 1.25 each hop) ensures that only markers sufficiently far along the path are considered.

`Calc_G_time_12` adds intra-zone runaway candidates: markers in the same zone that are **not visible** from the starting marker (checked via `traceline`), favoring destinations you can hide behind cover.

At runtime in `EvalCloseRunAway()` ([botpath.qc](cci:7://file:///home/athomas/Develop/Kweek2/src/bot/botpath.qc:0:0-0:0) lines 307–330), the runaway score for each `RA` candidate is:

```
test_away_score = random() * RA_time * ((traveltime2² - (look_traveltime² + traveltime²)) / (look_traveltime * traveltime))
```

where:
- `traveltime2` = enemy's travel time to the runaway destination
- `traveltime` = bot's travel time to the runaway destination  
- `look_traveltime` = enemy's travel time to the bot's current position

A good runaway destination is one that is **far from the enemy** (`traveltime2` high) but **close to the bot** (`traveltime` low), and multiplied by the precomputed `RA_time` which favors destinations that are generally far/complex to reach. This maximizes the distance advantage over the enemy.

#### 8. Penalty logic interference with runaway calculations

You are correct that penalties would interfere with the runaway calculations. The runaway scoring in `EvalCloseRunAway()` uses `sub_arrival_time()` which returns penalized times, followed by `AdjustTravelPenalties()`. However:

- **During precomputation** (`Calc_G_time_11`): The `runaway_score` is based on `traveltime` from `sub_arrival_time()`. The code at line 1487–1488 even has a comment acknowledging this: *"If this runaway feature, whatever it is, is ever made usable, it may be necessary to invoke DropTravelPenalties here?"*. With penalties, paths through penalized edges would get **inflated scores** (since runaway wants high travel times), making penalized routes appear as excellent escape routes — which is clearly wrong, since the bot might not be able to actually traverse them.

- **At runtime** (`EvalCloseRunAway`): Both `traveltime` (bot→destination) and `traveltime2` (enemy→destination) would be inflated. Since the score formula involves a ratio/difference, the effects might partially cancel, but not reliably.

**Compatibility approach**: The comment on line 1488 suggests using `DropTravelPenalties()` during precomputation. However, as you note, paths with penalties should probably **never** be chosen as escape routes — a bot shouldn't be directed to rocket-jump its way out or run through lava when fleeing. A reasonable approach would be to:
1. Use `DropTravelPenalties()` during `Calc_G_time_11`/`12` to get true times for scoring purposes.
2. Then **discard** any runaway candidate whose true path involves penalty segments (checking if the raw traveltime exceeds the dropped-penalty traveltime by ≥1000 would indicate a penalty segment exists).

This way, the precomputed RA destinations would only include genuinely traversable paths, and their scores would reflect actual travel times.
