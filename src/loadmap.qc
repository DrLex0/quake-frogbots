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
	sprint_fb(self, 2, " �� ��� � ��������� ���\n");
	// The list of supported maps is:
	sprint_fb(self, 2, "��� ���� �� ��������� ���� ��:\n");
	SprintMaps();
	// ... or load a map with built-in waypoints.
	sprint_fb(self, 2, " ��� �� ���� � ��� ���� �������� ���������\n");
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
