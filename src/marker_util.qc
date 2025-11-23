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
	// backwards linked list
	marker.marker_linkrev = last_marker;
	last_marker = marker;
	dropper.marker_linkrev = last_marker;
	// forwards linked list
	if (! first_marker)
		first_marker = marker;
	else
		marker.marker_linkrev.marker_linkfwd = marker;
	if (marker.classname == "door")
	if (! marker.d_door_open)
		marker.d_door_open = 10;  // default
};

/*
============
RemoveMarker

Updates linked lists to cater for removal of this marker, entity itself will
not yet be removed.
This will _not_ ensure continuity of .index properties of other markers;
that should be done when it matters. (In theory it should only matter for the
waypoint tool. There is one other place that removes a marker, but I think it
makes no sense anyway.  --DrLex)
============
*/
void(entity marker) RemoveMarker =
{
	marker.fl_marker = FALSE;
	if (marker.marker_linkfwd)
		marker.marker_linkfwd.marker_linkrev = marker.marker_linkrev;
	else
	{
		dropper.marker_linkrev = marker.marker_linkrev;
		last_marker = marker.marker_linkrev;
	}
	if (marker.marker_linkrev)
		marker.marker_linkrev.marker_linkfwd = marker.marker_linkfwd;
	else
	{
		// Technically this can never happen, but let's be complete anyway
		first_marker = marker.marker_linkfwd;
	}
	if (marker == first_extra_marker)
	{
		first_extra_marker = marker.marker_linkfwd;
	}
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
	if (! first_extra_marker)
		first_extra_marker = marker_;
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

Check marker as candidate for being touched.
If prioritize, and the touching bot has this marker as linked_marker,
its .touch_marker will be forced to this marker, and sticky_touch will
be set to ignore all next touches until the bot processes the touch in
frogbot_marker_touch().
============
*/
void(float prioritize) check_marker =
{
	if (! other)
	{
		// Shouldn't happen, but if it does, avoid crashing the game
		dprint("check_marker invoked on ", self.classname, " with other=world\n");
		return;
	}
#ifdef MANUAL
	if (!manual_mode)
#endif
	if (self.T & T_EXCLUSIVE)
	if (! (other.path_state & EXCLUSIVE_PATH))
	if (other.path_from_marker != self)
	{
		// Ignore exclusive marker unless:
		// - current path originates from it (don't let a distant marker
		//   hijack the touch just because we're exiting EP mode)
		// - LINKED_DOOR links to an open door
		if (! self.link_door_ent)
			return;
		if (vlen(self.link_door_ent.origin - self.link_door_ent.pos2) > self.link_door_ent.d_door_open)
			return;
	}
	if (self.T & T_NOTOUCH)
		return;  // DENIED.
	if (other.running_up)  // ignore everything, freeze touch state until run-up is done
		return;

	if (random() < 0.25)  // what is this for?!
	{
		self.touchPlayer = other;
		self.touchPlayerTime = time + 2.5;
	}

	if (other.sticky_touch)
	if (! prioritize)
		return;

	// Take the nearest touching marker (except see below)
	distance = vlen(self.absmin + self.view_ofs - other.origin);
	if (!prioritize)
	{
		if (distance > other.touch_distance)
			return;
		// Do not touch markers higher up than the maximum step size that
		// can be ascended without a jump; unless we're swimming.
		// Mind that player/bot absmin_z seems to be 1u lower than the actual floor.
		if (self.absmin_z - 19 > other.absmin_z)
		{
			if (!(self.T & T_LIQUID))
				return;
			if (other.waterlevel < 3)
				return;
		}

		// Give priority to the path destination if it (nearly) overlaps with
		// the current marker. Otherwise bots may get stuck waiting on a touch
		// that keeps being obscured by a nearby marker. However, don't do this
		// for accurate path mode, it could mess up accuracy.
		if (other.touch_marker == other.linked_marker)
		if (other.touch_distance - distance < 20)
		if (! (other.path_state & ACCURATE_PATH))
			return;
	}

	if (other.path_state & EXCLUSIVE_PATH)
	{
		if (other.linked_marker != self)
		{
			if (time < other.exclusive_deadline)
				return;  // ignore all but exclusive destination marker
			other.path_state = other.path_state - EXCLUSIVE_PATH;
		}
	}

	if (prioritize)
	if (other.linked_marker == self)
		other.sticky_touch = TRUE;
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
			check_marker(FALSE);
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
entity(vector org, float not_above) LocateMarker =
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
			if (not_above && (marker_pos_z - org_z > not_above))
				distance = distance + 1000;
			else
			{
				traceline(org, marker_pos, TRUE, dropper);
				if (trace_fraction != 1)
					distance = distance + 1000;
			}

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
	else if(content == CONTENT_LAVA)
		m.T = m.T | T_HOTMAGMA;

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

/*
============
MarkerHasZoneTask

Remnant of dm6_door system, currently unused.
Still unclear to me what the Zx_task property really represents, but if anyone
sees a use for it, this heavily optimised method may come in handy. -- DrLex
============
*/
float(entity marker, float zone, float flag) MarkerHasZoneTask
{
	if (marker.taskClus1 & flag) {
		if (zone == 1) return (marker.Z1_task & flag);
		if (zone == 2) return (marker.Z2_task & flag);
		if (zone == 3) return (marker.Z3_task & flag);
		if (zone == 4) return (marker.Z4_task & flag);
		if (zone == 5) return (marker.Z5_task & flag);
		return (marker.Z6_task & flag);
	}
	if (marker.taskClus2 & flag) {
		if (zone == 7) return (marker.Z7_task & flag);
		if (zone == 8) return (marker.Z8_task & flag);
		if (zone == 9) return (marker.Z9_task & flag);
		if (zone == 10) return (marker.Z10_task & flag);
		if (zone == 11) return (marker.Z11_task & flag);
		return (marker.Z12_task & flag);
	}
	if (marker.taskClus3 & flag) {
		if (zone == 13) return (marker.Z13_task & flag);
		if (zone == 14) return (marker.Z14_task & flag);
		if (zone == 15) return (marker.Z15_task & flag);
		if (zone == 16) return (marker.Z16_task & flag);
		if (zone == 17) return (marker.Z17_task & flag);
		return (marker.Z18_task & flag);
	}
	if (marker.taskClus4 & flag) {
		if (zone == 19) return (marker.Z19_task & flag);
		if (zone == 20) return (marker.Z20_task & flag);
		if (zone == 21) return (marker.Z21_task & flag);
		if (zone == 22) return (marker.Z22_task & flag);
		if (zone == 23) return (marker.Z23_task & flag);
		return (marker.Z24_task & flag);
	}
	return FALSE;
}
