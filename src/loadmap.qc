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

	// For tweaking desirability of G1 and/or G2, value is a multiplication factor
	desire_adj_G1 = desire_adj_G2 = 1;

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

Hard-coded fixes for certain maps, mostly missing intermission cameras
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
	if (mapname == "amphi")
		SpawnIntermission('1244 -337 570', '40 -135 10');
	else if (mapname == "dark-terror-ffa")
		SpawnIntermission('-840 1330 136', '30 -36 4');
	else if (mapname == "dm4ish")
		SpawnIntermission('-310 -293 404', '25 32 0');
	else if (mapname == "dmz1++")
	{
		MoveItem(m48, '15 0 6');  // health pack in wall
		SpawnIntermission('-198 727 -190', '26 -115 0');
	}
	else if (mapname == "e1m4")
		MoveItem(m20, '0 0 -444');  // YA does not drop down with platform
	else if (mapname == "end")
		m100.touch = null;  // Sabotage Shub's hurt trigger
	else if (mapname == "endif")
		SpawnIntermission('-227 -732 800', '54 45 8');
	else if (mapname == "filthy")
		SpawnIntermission('-5 -722 -136', '-12 56 0');
	else if (mapname == "four")
		SpawnIntermission('-35 0 11', '-30 0 0');
	else if (mapname == "genocide")
		SpawnIntermission('-592 -563 56', '28 40 0');
	else if(mapname == "oktest1")
		SpawnIntermission('513 -281 1167', '37 -147 -13');
	else if (mapname == "thf")
		SpawnIntermission('-1265 358 386', '-10 -36 0');
	else if (mapname == "tridm1" || mapname == "trindm1")
	{
		// For some reason, bots in ezQuake get stuck on this button if it moves less than this distance
		m55.pos2 = '0 0 -4';
	}
	else if (mapname == "ukpak2")
		SpawnIntermission('398 -572 353', '32 -150 5');
};
