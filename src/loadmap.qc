/*
	loadmap.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
	Changed to Spike/Trinca map management by DrLex
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

	LoadWaypoints();

	// assertion: map is invalid
	StartItems();
};
