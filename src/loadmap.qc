/*
	loadmap.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
	Changed to Spike/Trinca map management; universal doors by DrLex
*/

#include "settings.h"

//generated inside map_load_gen.qc
void() SprintMaps;
void() LoadWaypoints;


/*
============
InvalidMap

============
*/
void() InvalidMap =
{
	sprint_fb(self, 2, mapname);
	sprint_fb(self, 2, " ισ ξοτ α συπποςτεδ ναπ®\n");
	sprint_fb(self, 2, "Τθε μιστ οζ συπποςτεδ ναπσ ισ:\n");
	SprintMaps();
};

/*
============
LoadMap

============
*/
void() LoadMap =
{
	load_frogbots = invalid_map = TRUE;
	item_marker_index = marker_index;

	// DrLex fix: make dm6_door work outside dm6 as well.
	// Bots can only use 1 door in a map. The waypoint file must
	// assign this door's marker to dm6_door.
	dm6_door = world;
	// Vector distance dm6_door has to move to be considered open.
	// Value is good for dm6 and other doors that move about 128 units.
	// Map waypoint files can override this default.
	door_open_dist = 67;
	// The zone behind the door, containing target(s) the bot will
	// want to open the door for. If different from 1, door_targetZ
	// must be overridden in the waypoint code.
	door_targetZ = 1;

	LoadWaypoints();

	SetUpItems();
};
