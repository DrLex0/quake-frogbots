/*
	load.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

#include "settings.h"

void() marker_touch;
void() SetUpItems;
void() AssignVirtualGoal_apply;

/*
============
spawn_load

============
*/
void() spawn_load =
{
	load_position = dropper;
	while (load_position)
	{
		if (!load_position.think)
		{
			load_position.nextthink = 0.001;
			load_position.think = dropper.think;
			load_position.next_load = current_load_position;
			current_load_position = load_position;
		}
		load_position = nextent(load_position);
	}

	while (total_entity_count < 400)
	{
		load_position = spawn();
		load_position.classname = "load";
		load_position.nextthink = 0.001;
		load_position.think = dropper.think;
		load_position.next_load = current_load_position;
		current_load_position = load_position;
	}
};

/*
============
set_load

============
*/
void() set_load =
{
	load_position = current_load_position;
	while (load_position)
	{
		load_position.think = dropper.think;
		load_position = load_position.next_load;
	}
};

/*
============
remove_load

============
*/
void() remove_load =
{
	time_start = time;
	framecount_start = framecount;

	paths_computed = frogbot_loading = TRUE;

	while (current_load_position)
	{
		if (current_load_position.classname == "load")
			remove(current_load_position);
		else
			current_load_position.nextthink = 0;
		current_load_position = current_load_position.next_load;	// current_load_position still has values
	}

	SetUpItems();

	marker_ = first_item;
	while (marker_)
	{
		AssignVirtualGoal_apply();	// map file must have been called
		marker_ = marker_.next;
	}
};
