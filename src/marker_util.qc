/*
	marker_util.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Improvements by DrLex 2025/02
*/

#include "settings.h"

#ifdef MANUAL
void() SetGoal;
#endif

/*
============
BecomeMarker

============
*/
void(entity marker) BecomeMarker =
{
	marker.fl_marker = TRUE;
	marker.marker_link = first_marker;
	first_marker = marker;
	dropper.marker_link = first_marker;
};

/*
============
RemoveMarker

============
*/
void(entity marker) RemoveMarker =
{
	local entity e;

	marker.fl_marker = FALSE;
	e = dropper;
	while (e.marker_link != marker)
		e = e.marker_link;
	e.marker_link = marker.marker_link;
	if(e == dropper)
		first_marker = e.marker_link;
};

/*
============
spawn_marker

============
*/
void(vector org) spawn_marker =
{
	marker_ = spawn();
	marker_.classname = "marker";
	marker_.flags = FL_ITEM;
	BecomeMarker(marker_);
	marker_.origin_x = rint(org_x);
	marker_.origin_y = rint(org_y);
	marker_.origin_z = rint(org_z);
	marker_.solid = SOLID_TRIGGER;
	marker_.touch = marker_touch;
	marker_.view_ofs = '80 80 24';
#ifdef MANUAL
	marker_.display = marker_;
	setmodel(marker_, "progs/player.mdl");
	marker_.frame = 12;
	marker_.model = "";
	if (goal_index > NUMBER_GOALS)  // assign zone to new marker
	{
		local entity last_active = active_marker;
		active_marker = marker_;
		SetGoal();
		if(mode & STATIC_ACTIVE_MARKER) active_marker = last_active;
		else if (last_active) last_active.display.frame = 12;
	}
#endif

	setsize (marker_, '-65 -65 -24', '65 65 32');
};

/*
============
set_marker

============
*/
void(entity client, entity marker) set_marker =
{
	client.touch_distance = 0;
	client.touch_marker = marker;
	client.Z_ = marker.Z_;
	client.touch_marker_time = time + 5;
};

/*
============
check_marker

============
*/
void() check_marker =
{
#ifdef MANUAL
	if (!manual_mode)
#endif
	if (self.T & T_EXCLUSIVE)
	if (! (other.path_state & EXCLUSIVE_PATH))
	{
		// Ignore exclusive marker unless EXCLUSIVE_DOOR links to an open door
		if (! self.exclu_door_ent)
			return;
		// and bot is not in cooldown period
		if (time < other.exclu_door_cooldown)
			return;
		if (vlen(self.exclu_door_ent.origin - self.exclu_door_ent.pos2) > 10)
			return;
	}

	if (random() < 0.25)  // what is this for?!
	{
		self.touchPlayer = other;
		self.touchPlayerTime = time + 2.5;
	}

	// Take the nearest touching marker (except see below)
	distance = vlen(self.absmin + self.view_ofs - other.origin);
	if (distance > other.touch_distance)
		return;
	if (self.absmin_z - 20 >= other.absmin_z)
		return;

	// Give priority to the path destination if it (nearly) overlaps with
	// the current marker. Otherwise bots may get stuck waiting on a touch
	// that keeps being obscured by a nearby marker. However, don't do this
	// for accurate path mode, it could mess up accuracy.
	if (other.touch_marker == other.linked_marker)
	if (other.touch_distance - distance < 20)
	if (! (other.path_state & ACCURATE_PATH))
		return;

	if (other.path_state & EXCLUSIVE_PATH)
	{
		if (other.linked_marker != self)
		{
			if (time < other.exclusive_deadline)
				return;  // ignore all but exclusive destination marker
			other.path_state = other.path_state - EXCLUSIVE_PATH;
		}
	}

	other.touch_distance = distance;
	other.touch_marker = self;
	other.Z_ = self.Z_;
	other.touch_marker_time = time + 5;
};

/*
============
marker_touch

============
*/
void() marker_touch =
{
	if (marker_time)
	{
		if (other.client_)
			check_marker();
	}
};

/*
============
adjust_view_ofs

============
*/
void() adjust_view_ofs_z =
{
	fallspot_self = self;
	self = dropper;
	self.origin = testplace = fallspot_self.absmin + fallspot_self.view_ofs + '0 0 1';
	self.flags = FL_ONGROUND_PARTIALGROUND;
	if (walkmove(0, 0))
	{
		if (self.origin_z <= testplace_z)
		{
			if (droptofloor())
			{
				if (self.origin_z > testplace_z - 56)
					fallspot_self.view_ofs_z = self.origin_z - fallspot_self.absmin_z;
			}
		}
	}
	self = fallspot_self;
#ifdef MANUAL
	self.arrow = self.view_ofs_z;
#endif

};

/*
============
LocateMarker

Bot disorientated / BackPacks.
============
*/
entity(vector org) LocateMarker =
{
	local float shortest_distance = 1000000;
	closest_marker = world;

	marker_ = findradius(org, 1000); // 1000
	while (marker_)
	{
		if (marker_.fl_marker)
		{
			marker_pos = marker_.absmin + marker_.view_ofs;
			distance = vlen(marker_pos - org);
			traceline(org, marker_pos, TRUE, dropper);
			if (trace_fraction != 1)
				distance = distance + 1000;
			if (distance < shortest_distance)
			{
			#ifndef ARENA
				// note by DrLex: unsure about this, near_teleport is only used
				// in dead code; maybe this may just be dropped
				if (marker_.classname != "trigger_teleport")
			#endif
				self.near_teleport = world;
				shortest_distance = distance;
				closest_marker = marker_;
			}
			else if (marker_.classname == "trigger_teleport")
			{
				self.near_teleport = marker_;
			}
		}
		marker_ = marker_.chain;
	}

	distance = shortest_distance;  // allow checking sanity of the "closest" marker
	return closest_marker;
};


/*
============
AssignVirtualGoal

If marker_ has nonzero goal, then set .virtual_goal to the marker itself,
unless its item is not available and we can find an available item on one
of the outgoing paths with same goal number.
============
*/
void() AssignVirtualGoal_apply =
{
	goal_number = marker_.G_;
	if (goal_number)
	{
		test_goal = marker_;
		if (test_goal.nextthink)  // something is pending for the item, likely waiting to respawn
		{
			test_goal = marker_.P0;
			if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
			{
				test_goal = marker_.P1;
				if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
				{
					test_goal = marker_.P2;
					if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
					{
						test_goal = marker_.P3;
						if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
						{
							test_goal = marker_.P4;
							if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
							{
								test_goal = marker_.P5;
								if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
								{
									test_goal = marker_.P6;
									if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
									{
										test_goal = marker_.P7;
										if ((test_goal.G_ != goal_number) || (test_goal.nextthink))
										{
											if ((marker_.nextthink > 0) && (marker_.think == SUB_regen))
												test_goal = marker_;
											else
												test_goal = dropper;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		marker_.virtual_goal = test_goal;
		return;
	}
};

void() AssignVirtualGoal =
{
	marker_ = self.Z_head;

	while (marker_)
	{
		AssignVirtualGoal_apply();
		marker_ = marker_.Z_next;
	}
};

/*
============
ExistsPath

============
*/
float() ExistsPath =
{
	if (from_marker.P0 == to_marker)
	{
		new_path_state = from_marker.D0;
		return TRUE;
	}
	if (from_marker.P1 == to_marker)
	{
		new_path_state = from_marker.D1;
		return TRUE;
	}
	if (from_marker.P2 == to_marker)
	{
		new_path_state = from_marker.D2;
		return TRUE;
	}
	if (from_marker.P3 == to_marker)
	{
		new_path_state = from_marker.D3;
		return TRUE;
	}
	if (from_marker.P4 == to_marker)
	{
		new_path_state = from_marker.D4;
		return TRUE;
	}
	if (from_marker.P5 == to_marker)
	{
		new_path_state = from_marker.D5;
		return TRUE;
	}
	if (from_marker.P6 == to_marker)
	{
		new_path_state = from_marker.D6;
		return TRUE;
	}
	if (from_marker.P7 == to_marker)
	{
		new_path_state = from_marker.D7;
		return TRUE;
	}
	if (from_marker == to_marker)
	{
		new_path_state = 0;
		return TRUE;  // obviously
	}
	return FALSE;
};

/*
============
CheckWaterColumn

============
*/
void() CheckWaterColumn =
{
	m.T = m.T | T_LIQUID;
	if (content == CONTENT_SLIME)
		m.T = m.T | T_BIOHZD;

	testplace = m_pos;
	while (TRUE)
	{
		self.origin = testplace + '0 0 16';
		self.flags = FL_ONGROUND_PARTIALGROUND;
		if (!walkmove(0, 0))
		{
			m.T = m.T | T_NO_AIR;
			return;
		}
/*
		if (total_entity_count < 500)
		{
			local entity marker;
			marker = spawn();
			setmodel (marker, "progs/player.mdl");
			setorigin(marker, testplace);
		}
*/
		if (pointcontents(testplace + '0 0 32') == CONTENT_EMPTY)
		{
			do
			{
				testplace_z = testplace_z - 1;
			} while (pointcontents(testplace + '0 0 32') == CONTENT_EMPTY);
			return;
		}

		testplace_z = testplace_z + 16;
	}
};
