/*
	loadmap.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
	Changed to Spike/Trinca map management and other changes by DrLex 2024-2025
*/

#include "settings.h"

//generated inside map_load_gen.qc
void() SprintMaps;
float() LoadWaypoints;

void() AddMissingBits;


/*
============
InvalidMap

============
*/
void() InvalidMap =
{
	sprint_fb(self, 2, mapname);
	// is not a supported map.
	sprint_fb(self, 2, " ισ ξοτ α συπποςτεδ ναπ®\n");
	// The list of supported maps is:
	sprint_fb(self, 2, "Τθε μιστ οζ συπποςτεδ ναπσ ισ:\n");
	SprintMaps();
	// ... or load a map with built-in waypoints.
	sprint_fb(self, 2, " ®®® ος μοαδ α ναπ χιτθ βυιμτ­ιξ χαωποιξτσ®\n");
};

/*
============
CountMapEdicts

Sets num_map_load_edicts to the number of non-null edicts
============
*/
void() CountMapEdicts =
{
	local entity e;
	e = nextent(world);
	num_map_load_edicts = 0;
	while (e)
	{
		if (e.classname)
			num_map_load_edicts = num_map_load_edicts + 1;
		e = nextent(e);
	}
};

/*
============
LoadMap

============
*/
void() LoadMap =
{
	frogbot_loading = map_lacks_waypoints = TRUE;
	item_marker_index = marker_index;
	custom_marker_start = 0;

	// For tweaking desirability of G1 and/or G2, value is a multiplication factor
	desire_adj_G1 = desire_adj_G2 = 1;

	interm_origin = '0 0 0';
	interm_mangle = '0 0 0';

	// For QuakeC n00bs like me:
	// never do if(clause1 || function()); function is _always_ evaluated.
	if (has_embedded_wp)
		map_lacks_waypoints = FALSE;
	else if(LoadWaypoints())
		map_lacks_waypoints = FALSE;

	if (! map_lacks_waypoints)
	{
		ApplyFrB_props();
		frogbot_loading = FALSE;
	}

	SetUpItems();
	AddMissingBits();
	CountMapEdicts();
};


/*
============
AddMissingBits

Hard-coded fixes for certain maps. Most common is lack of intermission camera,
causing ugly scoreboard backgrounds. Please think of this when creating new maps!
Missing intermissions should not be coded here, the waypoint tool now has provisions
to easily configure it.
This is for remaining special things like moving items or modifying properties.
============
*/
void(entity it, vector offset) MoveItem =
{
	it.origin = it.origin + offset;
	setorigin(it, it.origin);
	it.virtual_mins = it.virtual_mins + offset;
	it.virtual_maxs = it.virtual_maxs + offset;
};

void(vector ori, vector mang) SpawnIntermission =
{
	local entity ent;
	ent = spawn();
	ent.classname = "info_intermission";
	ent.origin = ori;
	ent.mangle = mang;
};

void() AddMissingBits =
{
	if (interm_origin || interm_mangle)
		SpawnIntermission(interm_origin, interm_mangle);

	if (mapname == "dmz1++")
	{
		MoveItem(m48, '15 0 6');  // health pack in wall
	}
	else if (mapname == "e1m4")
		MoveItem(m20, '0 0 -444');  // YA does not drop down with platform
	else if (mapname == "end")
		m100.touch = null;  // Sabotage Shub's hurt trigger
	else if (mapname == "tridm1" || mapname == "trindm1")
	{
		// For some reason, bots in ezQuake get stuck on this button if it moves less than this distance
		m55.pos2 = '0 0 -4';
	}
};
