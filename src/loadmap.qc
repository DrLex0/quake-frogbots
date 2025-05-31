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
LoadMap

============
*/
void() LoadMap =
{
	frogbot_loading = map_lacks_waypoints = TRUE;
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
}

void() AddMissingBits =
{
	local entity ent;
	if (mapname == "amphi")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '1244 -337 570';
		ent.mangle = '40 -135 10';
	}
	else if (mapname == "dm4ish")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '-310 -293 404';
		ent.mangle = '25 32 0';
	}
	else if (mapname == "dmz1++")
	{
		MoveItem(m48, '15 0 6');  // health pack in wall
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '-198 727 -190';
		ent.mangle = '26 -115 0';
	}
	else if (mapname == "e1m4")
	{
		MoveItem(m20, '0 0 -444');  // YA does not drop down with platform
	}
	else if (mapname == "endif")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '-227 -732 800';
		ent.mangle = '54 45 8';
	}
	else if (mapname == "four")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '-35 0 11';
		ent.mangle = '-30 0 0';
	}
	else if (mapname == "genocide")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '-592 -563 56';
		ent.mangle = '28 40 0';
	}
	else if(mapname == "oktest1")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '513 -281 1167';
		ent.mangle = '37 -147 -13';
	}
	else if (mapname == "thf")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '-1265 358 386';
		ent.mangle = '-10 -36 0';
	}
	else if (mapname == "ukpak2")
	{
		ent = spawn();
		ent.classname = "info_intermission";
		ent.origin = '398 -572 353';
		ent.mangle = '32 -150 5';
	}
}
