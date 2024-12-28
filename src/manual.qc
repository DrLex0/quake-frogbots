/*
	manual.qc

	Original author unsure, but probably Robert 'Frog' Field.
	Restored by DrLex 2024/12 by decompiling the waypoint progs.dat.
	The FrogBot source was given a GPL license by Robert Field in 2007.
	And even if you think that message was fake, this is all so old
	that copyright doesn't mean much anymore anyhow.
*/

#include "settings.h"

#ifdef MANUAL

void() ConnectMarker;
void() DisconnectMarker;
void(string print_string) DescriptionMarker;
void() SaveCoords;
void() SavePaths;
float(entity marker) changed_view_ofs_z;
void() ZoneInfo;


void(entity marker) CheckReachable =
{
	rel_pos = ((marker.absmin + marker.view_ofs) -
	           (active_marker.absmin + active_marker.view_ofs));
	rel_pos_z = 0;
	yaw = vectoyaw(rel_pos);
	dist = vlen(rel_pos);
	test_enemy = self;
	self = spawn();
	self.model = "/";
	self.modelindex = modelindex_player;
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin(self, (active_marker.absmin + active_marker.view_ofs));
	self.flags = FL_ONGROUND_PARTIALGROUND;
	self.movetype = MOVETYPE_STEP;
	self.solid = SOLID_SLIDEBOX;
	test_count = floor(dist * 0.03125);
	bprint(ftos(test_count), "\n");
	if (test_count > 7)
	{
		bprint("Reachable TOO FAR\n");
		self.movetype = 0;
		self.solid = 0;
		self = test_enemy;
		return;
	}
	while (test_count)
	{
		if (!walkmove(yaw, 32))
		{
			bprint("Reachable FAIL\n");
			self.movetype = 0;
			self.solid = 0;
			self = test_enemy;
			return;
		}
		test_count = (test_count - 1);
	}
	bprint("Reachable SUCCESS\n");
	self.movetype = 0;
	self.solid = 0;
	self = test_enemy;
};

void(entity marker) manual_marker_touch =
{
	if (mode & STATIC_ACTIVE_MARKER)
	{
		if (!active_marker)
		{
			return;
		}
		if (marker == active_marker)
		{
			return;
		}
		if (mode & CONNECT_MARKERS)
		{
			from_marker = active_marker;
			to_marker = marker;
			if (path_mode == DISCONNECT_MARKERS)
			{
				DisconnectMarker();
			}
			else
			{
				ConnectMarker();
				if (mode & ONE_WAY)
				{
					description = DM6_DOOR;
					DescriptionMarker("dm6 door");
					description = JUMP_LEDGE;
					DescriptionMarker("jump ledge");
					description = ROCKET_JUMP;
					DescriptionMarker("rocket jump");
				}
				else
				{
					from_marker = marker;
					to_marker = active_marker;
					ConnectMarker();
				}
			}
			mode = mode - CONNECT_MARKERS;
		}
		if (mode & DISPLAY_TRAVEL_TIME)
		{
			path_normal = TRUE;
			from_marker = active_marker;
			marker.zone_marker();
			marker.sub_arrival_time();
			bprint("time from active marker = ", ftos(traveltime), "\n");
			from_marker = marker;
			active_marker.zone_marker();
			active_marker.sub_arrival_time();
			bprint("time to active marker = ", ftos(traveltime), "\n");
			mode = mode - DISPLAY_TRAVEL_TIME;
		}
		if (mode & DISPLAY_REACHABLE)
		{
			test_enemy = first_client;
			while (test_enemy)
			{
				test_enemy.oldsolid = test_enemy.solid;
				test_enemy.solid = SOLID_NOT;
				test_enemy = test_enemy.next;
			}
			CheckReachable(marker);
			test_enemy = first_client;
			while (test_enemy)
			{
				test_enemy.solid = test_enemy.oldsolid;
				test_enemy = test_enemy.next;
			}
			mode = mode - DISPLAY_REACHABLE;
		}
	}
	else
	{
		if (active_marker)
		{
			active_marker.display.frame = 12;
		}
		active_marker = marker;
		active_marker.display.frame = 0;
	}
};

void() RemoveActiveMarker =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	if (active_marker.classname == "marker")
	{
		m = first_marker;
		while (m)
		{
			if (m.P0 == active_marker)
			{
				m.P0 = world;
			}
			if (m.P1 == active_marker)
			{
				m.P1 = world;
			}
			if (m.P2 == active_marker)
			{
				m.P2 = world;
			}
			if (m.P3 == active_marker)
			{
				m.P3 = world;
			}
			if (m.P4 == active_marker)
			{
				m.P4 = world;
			}
			if (m.P5 == active_marker)
			{
				m.P5 = world;
			}
			if (m.P6 == active_marker)
			{
				m.P6 = world;
			}
			if (m.P7 == active_marker)
			{
				m.P7 = world;
			}
			m = m.marker_link;
		}
		RemoveMarker(active_marker);
		remove(active_marker);
		bprint("active marker removed\n");
		active_marker = world;
		self.touch_marker = world;
	}
	else
	{
		bprint("Active marker cannot be removed\n");
	}
};

void() DisableActiveMarker =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	bprint("active marker disabled\n");
	active_marker.display.frame = 12;
	active_marker = world;
	if (!(mode & STATIC_ACTIVE_MARKER))
	{
		mode = (mode | STATIC_ACTIVE_MARKER);
		bprint("static active marker ON\n");
	}
};

void() ClearActiveMarker =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	active_marker.P7 = world;
	active_marker.P6 = world;
	active_marker.P5 = world;
	active_marker.P4 = world;
	active_marker.P3 = world;
	active_marker.P2 = world;
	active_marker.P1 = world;
	active_marker.P0 = world;
	active_marker.D7 = 0;
	active_marker.D6 = 0;
	active_marker.D5 = 0;
	active_marker.D4 = 0;
	active_marker.D3 = 0;
	active_marker.D2 = 0;
	active_marker.D1 = 0;
	active_marker.D0 = 0;
	bprint("Active marker path cleared\n");
};

void() DisplayZone =
{
	marker_ = first_marker;
	while (marker_)
	{
		if (marker_.Z_ == active_marker.Z_)
		{
			marker_.display.angles_y = (marker_.display.angles_y + (frametime * 90));
		}
		marker_ = marker_.marker_link;
	}
};

float(entity marker_P, float marker_D) Display =
{
	if (!marker_P)
	{
		return (FALSE);
	}
	return ((path_mode & marker_D) == path_mode);
};

void() MarkerDisplay =
{
	origin_ = self.origin;
	if(mode & CLOSEST_MARKER) {
		// override touch_marker
		closest_marker = LocateMarker(origin_);
		if(closest_marker != world) {
			self.touch_marker = closest_marker;
		}
	}
	if (self.touch_marker)
	{
		manual_marker_touch(self.touch_marker);
	}

	marker_ = first_marker;
	while (marker_)
	{
		if (marker_.classname == "marker")
		{
			display_origin = marker_.origin;
		}
		else
		{
			display_origin = (marker_.absmin + marker_.view_ofs);
			setorigin(marker_.display, display_origin);
		}
		if (marker_.display)
		{
			if (vlen(display_origin - origin_) <= 600)
			{
				marker_.display.model = "/";
			}
			else
			{
				marker_.display.model = "";
			}
		}
		marker_ = marker_.marker_link;
	}
	if ((mode & CLOSEST_MARKER) && ! (mode & STATIC_ACTIVE_MARKER))
	{
		if (active_marker)
		{
			active_marker.display.frame = 12;
		}
		active_marker = closest_marker;
	}
	if (!active_marker)
	{
		return;
	}
	active_marker.display.frame = 0;
	if (mode & DISPLAY_ZONE)
	{
		DisplayZone();
		return;
	}

	if (mode & DISPLAY_TYPE)
	{
		if (active_marker.T & SAVED_T)
		{
			if ((active_marker.T & type_mode) == type_mode)
			{
				active_marker.display.angles_y = (active_marker.display.angles_y + (frametime * 90));
			}
		}
	}
	else if (mode & DISPLAY_RUNAWAY)
	{
		if (active_marker.RA0)
		{
			if (!active_marker.RA0_type)
			{
				active_marker.RA0.display.angles_y = (active_marker.RA0.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA1)
		{
			if (!active_marker.RA1_type)
			{
				active_marker.RA1.display.angles_y = (active_marker.RA1.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA2)
		{
			if (!active_marker.RA2_type)
			{
				active_marker.RA2.display.angles_y = (active_marker.RA2.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA3)
		{
			if (!active_marker.RA3_type)
			{
				active_marker.RA3.display.angles_y = (active_marker.RA3.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA4)
		{
			if (!active_marker.RA4_type)
			{
				active_marker.RA4.display.angles_y = (active_marker.RA4.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA5)
		{
			if (!active_marker.RA5_type)
			{
				active_marker.RA5.display.angles_y = (active_marker.RA5.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA6)
		{
			if (!active_marker.RA6_type)
			{
				active_marker.RA6.display.angles_y = (active_marker.RA6.display.angles_y + (frametime * 90));
			}
		}
		if (active_marker.RA7)
		{
			if (!active_marker.RA7_type)
			{
				active_marker.RA7.display.angles_y = (active_marker.RA7.display.angles_y + (frametime * 90));
			}
		}
	}
	else
	{
		if (Display(active_marker.P0, active_marker.D0))
		{
			active_marker.P0.display.angles_y = (active_marker.P0.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P1, active_marker.D1))
		{
			active_marker.P1.display.angles_y = (active_marker.P1.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P2, active_marker.D2))
		{
			active_marker.P2.display.angles_y = (active_marker.P2.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P3, active_marker.D3))
		{
			active_marker.P3.display.angles_y = (active_marker.P3.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P4, active_marker.D4))
		{
			active_marker.P4.display.angles_y = (active_marker.P4.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P5, active_marker.D5))
		{
			active_marker.P5.display.angles_y = (active_marker.P5.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P6, active_marker.D6))
		{
			active_marker.P6.display.angles_y = (active_marker.P6.display.angles_y + (frametime * 90));
		}
		if (Display(active_marker.P7, active_marker.D7))
		{
			active_marker.P7.display.angles_y = (active_marker.P7.display.angles_y + (frametime * 90));
		}
	
	}
};

void() ConnectMarker =
{
	if (from_marker.P0 == to_marker)
	{
		return;
	}
	if (from_marker.P1 == to_marker)
	{
		return;
	}
	if (from_marker.P2 == to_marker)
	{
		return;
	}
	if (from_marker.P3 == to_marker)
	{
		return;
	}
	if (from_marker.P4 == to_marker)
	{
		return;
	}
	if (from_marker.P5 == to_marker)
	{
		return;
	}
	if (from_marker.P6 == to_marker)
	{
		return;
	}
	if (from_marker.P7 == to_marker)
	{
		return;
	}

	if (!from_marker.P0)
	{
		bprint("marker connected on path 0\n");
		from_marker.P0 = to_marker;
		from_marker.D0 = 0;
	}
	else if (!from_marker.P1)
	{
		bprint("marker connected on path 1\n");
		from_marker.P1 = to_marker;
		from_marker.D1 = 0;
	}
	else if (!from_marker.P2)
	{
		bprint("marker connected on path 2\n");
		from_marker.P2 = to_marker;
		from_marker.D2 = 0;
	}
	else if (!from_marker.P3)
	{
		bprint("marker connected on path 3\n");
		from_marker.P3 = to_marker;
		from_marker.D3 = 0;
	}
	else if (!from_marker.P4)
	{
		bprint("marker connected on path 4\n");
		from_marker.P4 = to_marker;
		from_marker.D4 = 0;
	}
	else if (!from_marker.P5)
	{
		bprint("marker connected on path 5\n");
		from_marker.P5 = to_marker;
		from_marker.D5 = 0;
	}
	else if (!from_marker.P6)
	{
		bprint("marker connected on path 6\n");
		from_marker.P6 = to_marker;
		from_marker.D6 = 0;
	}
	else if (!from_marker.P7)
	{
		bprint("marker connected on path 7\n");
		from_marker.P7 = to_marker;
		from_marker.D7 = 0;
	}
	else
	{
		bprint("to_markers full.\n");
	}
};

void() DisconnectMarker =
{
	if (from_marker.P0 == to_marker)
	{
		bprint("marker disconnected on path 0\n");
		from_marker.P0 = world;
		from_marker.D0 = 0;
	}
	else if (from_marker.P1 == to_marker)
	{
		bprint("marker disconnected on path 1\n");
		from_marker.P1 = world;
		from_marker.D1 = 0;
	}
	else if (from_marker.P2 == to_marker)
	{
		bprint("marker disconnected on path 2\n");
		from_marker.P2 = world;
		from_marker.D2 = 0;
	}
	else if (from_marker.P3 == to_marker)
	{
		bprint("marker disconnected on path 3\n");
		from_marker.P3 = world;
		from_marker.D3 = 0;
	}
	else if (from_marker.P4 == to_marker)
	{
		bprint("marker disconnected on path 4\n");
		from_marker.P4 = world;
		from_marker.D4 = 0;
	}
	else if (from_marker.P5 == to_marker)
	{
		bprint("marker disconnected on path 5\n");
		from_marker.P5 = world;
		from_marker.D5 = 0;
	}
	else if (from_marker.P6 == to_marker)
	{
		bprint("marker disconnected on path 6\n");
		from_marker.P6 = world;
		from_marker.D6 = 0;
	}
	else if (from_marker.P7 == to_marker)
	{
		bprint("marker disconnected on path 7\n");
		from_marker.P7 = world;
		from_marker.D7 = 0;
	}
};

void(string print_string, float path_number) PrintDescription =
{
	bprint("marker ", print_string, " on path ", ftos(path_number), "\n");
};

void(string print_string) DescriptionMarker =
{
	if (path_mode & description)
	{
		if (from_marker.P0 == to_marker)
		{
			PrintDescription(print_string, 0);
			from_marker.D0 = (from_marker.D0 | description);
		}
		else if (from_marker.P1 == to_marker)
		{
			PrintDescription(print_string, 1);
			from_marker.D1 = (from_marker.D1 | description);
		}
		else if (from_marker.P2 == to_marker)
		{
			PrintDescription(print_string, 2);
			from_marker.D2 = (from_marker.D2 | description);
		}
		else if (from_marker.P3 == to_marker)
		{
			PrintDescription(print_string, 3);
			from_marker.D3 = (from_marker.D3 | description);
		}
		else if (from_marker.P4 == to_marker)
		{
			PrintDescription(print_string, 4);
			from_marker.D4 = (from_marker.D4 | description);
		}
		else if (from_marker.P5 == to_marker)
		{
			PrintDescription(print_string, 5);
			from_marker.D5 = (from_marker.D5 | description);
		}
		else if (from_marker.P6 == to_marker)
		{
			PrintDescription(print_string, 6);
			from_marker.D6 = (from_marker.D6 | description);
		}
		else if (from_marker.P7 == to_marker)
		{
			PrintDescription(print_string, 7);
			from_marker.D7 = (from_marker.D7 | description);
		}
	}
};

void(string field) Save_m_P =
{
	if (m_P)
	{
		bprint("m", ftos(m.index), ".", field, "=m", ftos(m_P.index), ";");
		count_ = (count_ + 1);
	}
};

void(string field) Save_m_D =
{
	if (m_P && (m_D & SAVED_DESCRIPTION))
	{
		bprint("m", ftos(m.index), ".", field, "=", ftos(m_D & SAVED_DESCRIPTION), ";");
		count_ = (count_ + 1);
	}
};

void() Save_dm6_door =
{
	// Doors are no longer specific to dm6, but keep the name to avoid having to change sources
	bprint("dm6_door=m", ftos(m.index), ";");
	count_ = (count_ + 1);
	// Ensure overrides of the defaults are preserved
	if(door_open_dist != 67)
	{
		bprint("door_open_dist=", ftos(door_open_dist), ";");
		count_ = (count_ + 1);
	}
	if(door_targetZ != 1)
	{
		bprint("door_targetZ=", ftos(door_targetZ), ";");
		count_ = (count_ + 1);
	}
};

void() SetMarkerIndexes =
{
	marker_index = item_marker_index;
	marker_ = world;
	marker_ = find(marker_, classname, "marker");
	while (marker_)
	{
		marker_index = (marker_index + 1);
		marker_.index = marker_index;
		marker_ = find(marker_, classname, "marker");
	}
};

void() SaveMarkers =
{
	if (markers_loaded || invalid_map)
	{
		SetMarkerIndexes();
		save_state = 0;
		bprint("\nvoid() map_", mapname, " =\n{\n");
		m = find(world, classname, "marker");
		if(m)
			bprint("// first custom marker m", ftos(m.index), "\n");
		m = world;
		save_position = spawn();
		save_position.nextthink = 0.001;
		save_position.think = SaveCoords;
	}
};

void() SaveCoords =
{
	self.nextthink = 0.001;
	count_ = 0;
	m = find(m, classname, "marker");
	while (m)
	{
		bprint("N(", ftos(m.origin_x), ",", ftos(m.origin_y), ",", ftos(m.origin_z), ");");
		count_ = count_ + 1;
		if (count_ == 10)
		{
			bprint("\n");
			return;
		}
		m = find(m, classname, "marker");
	}
	if (count_)
	{
		bprint("\n");
	}
	bprint("LSQ();\n");
	m = first_marker;
	self.think = SavePaths;
};

void() SavePaths =
{
	self.nextthink = 0.001;
	count_ = 0;
	while (m)
	{
		if (save_state == 0)
		{
			if (m.Z_)
			{
				bprint("Z", ftos(m.Z_), "(m", ftos(m.index), ");");
				count_ = (count_ + 1);
			}
		}
		else if (save_state == 1)
		{
			if (
				m.G_ &&
				((m.classname != "item_cells") || (m.G_ != 19)) &&
				((m.classname != "weapon_supernailgun") || (m.G_ != 20)) &&
				((m.classname != "weapon_supershotgun") || (m.G_ != 21)) &&
				((m.classname != "weapon_nailgun") || (m.G_ != 22)) &&
				((m.classname != "item_spikes") || (m.G_ != 23)) &&
				((m.classname != "item_shells") || (m.G_ != 24))
			)
			{
				bprint("G", ftos(m.G_), "(m", ftos(m.index), ");");
				count_ = (count_ + 1);
			}
		}
		else if (save_state == 2)
		{
			if (changed_view_ofs_z(m))
			{
				bprint("m", ftos(m.index), ".view_ofs_z=",
					ftos(m.view_ofs_z), ";");
				count_ = (count_ + 1);
			}
		}
		else if (save_state == 3)
		{
			if (m.T & SAVED_T)
			{
				bprint("m", ftos(m.index), ".T=", ftos(m.T & SAVED_T), ";");
				count_ = (count_ + 1);
			}
		}
		else if (save_state == 4)
		{
			m_P = m.P0;
			Save_m_P("P0");
			m_P = m.P1;
			Save_m_P("P1");
			m_P = m.P2;
			Save_m_P("P2");
			m_P = m.P3;
			Save_m_P("P3");
			m_P = m.P4;
			Save_m_P("P4");
			m_P = m.P5;
			Save_m_P("P5");
			m_P = m.P6;
			Save_m_P("P6");
			m_P = m.P7;
			Save_m_P("P7");
		}
		else if (save_state == 5)
		{
			m_P = m.P0;
			m_D = m.D0;
			Save_m_D("D0");
			m_P = m.P1;
			m_D = m.D1;
			Save_m_D("D1");
			m_P = m.P2;
			m_D = m.D2;
			Save_m_D("D2");
			m_P = m.P3;
			m_D = m.D3;
			Save_m_D("D3");
			m_P = m.P4;
			m_D = m.D4;
			Save_m_D("D4");
			m_P = m.P5;
			m_D = m.D5;
			Save_m_D("D5");
			m_P = m.P6;
			m_D = m.D6;
			Save_m_D("D6");
			m_P = m.P7;
			m_D = m.D7;
			Save_m_D("D7");
		}
		else if (save_state == 6)
		{
			if (m.classname == "door" && m == dm6_door)
			{
				Save_dm6_door();
			}
		}

		m = m.marker_link;
		if (count_ >= 10)
		{
			bprint("\n");
			return;
		}
	}
	if (count_)
	{
		bprint("\n");
	}
	if (save_state < 6)
	{
		save_state = (save_state + 1);
		m = first_marker;
	}
	else
	{
		bprint("};\n\n");
		remove_self();
	}
};

void() DisplayAllMarkers =
{
	marker_ = first_marker;
	while (marker_)
	{
		if (marker_.classname == "marker")
		{
			marker_.model = "/";
		}
		else
		{
			virtual_marker = spawn();
			marker_.display = virtual_marker;
			setmodel(virtual_marker, "progs/player.mdl");
		}
		marker_.display.frame = 12;
		marker_ = marker_.marker_link;
	}
};

void() MoveActiveMarker =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	if (active_marker.classname == "marker")
	{
		bprint("active marker moved\n");
		active_marker.origin_x = rint(self.origin_x);
		active_marker.origin_y = rint(self.origin_y);
		active_marker.origin_z = rint(self.origin_z);
		setsize(active_marker, VEC_HULL_MIN, VEC_HULL_MAX);
	}
	else
	{
		bprint("Active marker cannot be moved\n");
	}
};

void() VerMoveActiveMarker =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	bprint("active marker vertically moved\n");

	if (active_marker.classname == "marker")
	{
		active_marker.origin_z = rint(self.origin_z);
	}
	else if ((active_marker.classname == "func_button") || (active_marker.classname == "trigger_teleport"))
	{
		active_marker.view_ofs_z = rint(self.origin_z - active_marker.absmin_z);
		active_marker.display.origin_z = rint(self.origin_z);
	}
	else
	{
		bprint("Active marker cannot be moved\n");
	}
	
};

void() HideAllMarkers =
{
	marker_ = first_marker;
	while (marker_)
	{
		if (marker_.classname == "marker")
		{
			marker_.model = "";
		}
		else
		{
			remove(marker_.display);
		}
		marker_ = marker_.marker_link;
	}
};

float(entity marker) changed_view_ofs_z =
{
	if ((marker.classname == "func_button") || (marker.classname == "trigger_teleport"))
	{
		if (marker.view_ofs_z != marker.arrow)
		{
			return (TRUE);
		}
	}
	return (FALSE);
};

void() print_goal =
{
	if (!goal_index)
	{
		bprint("clear goal");
	}
	else if (goal_index <= NUMBER_GOALS)
	{
		bprint("goal index = ", ftos(goal_index));
	}
	else
	{
		bprint("zone index = ", ftos(goal_index - NUMBER_GOALS));
	}
	
	bprint("\n");
};

void() IncGoal =
{
	goal_index = (goal_index + 1);
	if (goal_index > (NUMBER_GOALS + NUMBER_ZONES))
	{
		goal_index = 0;
	}
	print_goal();
};

void() DecGoal =
{
	goal_index = (goal_index - 1);
	if (goal_index < 0)
	{
		goal_index = (NUMBER_GOALS + NUMBER_ZONES);
	}
	print_goal();
};

void() PrintGoalZoneIndex =
{
	bprint(ftos(Z_index), " set (total = ", ftos(S_index), ")\n");
};

void() GoalInfo =
{
	local entity marker;

	S_index = 1;
	marker = first_marker;
	while (marker)
	{
		if (marker.G_ == Z_index)
		{
			S_index = (S_index + 1);
		}
		marker = marker.marker_link;
	}
};

void() ZoneInfo =
{
	local entity marker;

	S_index = 1;
	marker = first_marker;
	while (marker)
	{
		if (marker.Z_ == Z_index)
		{
			S_index = (S_index + 1);
		}
		marker = marker.marker_link;
	}
};

float() IsItem =
{
	marker_ = first_item;
	while (marker_)
	{
		if (marker_ == active_marker)
		{
			return (TRUE);
		}
		marker_ = marker_.next;
	}
	return (FALSE);
};

void() SetGoal =
{
	if (active_marker)
	{
		if (goal_index <= NUMBER_GOALS)
		{
			if (IsItem())
			{
				active_marker.G_ = 0;
				if (goal_index)
				{
					Z_index = goal_index;
					GoalInfo();
					active_marker.G_ = Z_index;
					bprint("goal ");
					PrintGoalZoneIndex();
				}
				else
				{
					bprint("goal cleared\n");
				}
			}
			else
			{
				bprint("goal must be an item.\n");
			}
		}
		else
		{
			Z_index = (goal_index - NUMBER_GOALS);
			active_marker.Z_ = 0;
			ZoneInfo();
			if (S_index <= NUMBER_SUBZONES)
			{
				active_marker.Z_ = Z_index;
				bprint("zone ");
				PrintGoalZoneIndex();
			}
			else
			{
				bprint("Zone full.\n");
			}
		}
	}
	else
	{
		bprint("no active marker\n");
	}
};

void() PrintGoal =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	SetMarkerIndexes();
	bprint("m", ftos(active_marker.index));
	if (active_marker.Z_)
	{
		bprint(", Z", ftos(active_marker.Z_));
	}
	if (active_marker.G_)
	{
		bprint(", G", ftos(active_marker.G_));
	}

	if ((active_marker.classname == "trigger_teleport") ||
	    (active_marker.classname == "door") ||
	    (active_marker.classname == "func_button"))
	{
		// These markers have no origin because they are brushes.
		// Approximate location by center of bounding box (likely
		// same way the display marker position is obtained).
		local vector v_temp = (active_marker.mins + active_marker.maxs) * 0.5;
		bprint(" ~(",
			ftos(rint(v_temp_x)), ",",
			ftos(rint(v_temp_y)), ",",
			ftos(rint(v_temp_z)), ")~ ");
	}
	else
	{
		bprint("  (",
		ftos(rint(active_marker.origin_x)), ",",
		ftos(rint(active_marker.origin_y)), ",",
		ftos(rint(active_marker.origin_z)), ")  ");
	}
	bprint(active_marker.classname, "\n");

	if (active_marker.RA0)
	{
		bprint(ftos(active_marker.RA0_time), " ");
	}
	if (active_marker.RA1)
	{
		bprint(ftos(active_marker.RA1_time), " ");
	}
	if (active_marker.RA2)
	{
		bprint(ftos(active_marker.RA2_time), " ");
	}
	if (active_marker.RA3)
	{
		bprint(ftos(active_marker.RA3_time), " ");
	}
	if (active_marker.RA4)
	{
		bprint(ftos(active_marker.RA4_time), " ");
	}
	if (active_marker.RA5)
	{
		bprint(ftos(active_marker.RA5_time), " ");
	}
	if (active_marker.RA6)
	{
		bprint(ftos(active_marker.RA6_time), " ");
	}
	if (active_marker.RA7)
	{
		bprint(ftos(active_marker.RA7_time));
	}
	bprint("\n");

	if (active_marker.RA0)
	{
		bprint("  m", ftos(active_marker.RA0.index), " ");
	}
	if (active_marker.RA1)
	{
		bprint("  m", ftos(active_marker.RA1.index), " ");
	}
	if (active_marker.RA2)
	{
		bprint("  m", ftos(active_marker.RA2.index), " ");
	}
	if (active_marker.RA3)
	{
		bprint("  m", ftos(active_marker.RA3.index), " ");
	}
	if (active_marker.RA4)
	{
		bprint("  m", ftos(active_marker.RA4.index), " ");
	}
	if (active_marker.RA5)
	{
		bprint("  m", ftos(active_marker.RA5.index), " ");
	}
	if (active_marker.RA6)
	{
		bprint("  m", ftos(active_marker.RA6.index), " ");
	}
	if (active_marker.RA7)
	{
		bprint("  m", ftos(active_marker.RA7.index));
	}
	bprint("\n\n");
};

void(float descbits) PrintDLabel
{
	if (descbits & JUMP_LEDGE)
		bprint("\xCA");  // J
	if (descbits & DM6_DOOR)
		bprint("\xC4");  // D
	if (descbits & ROCKET_JUMP)
		bprint("\xD2");  // R
}

// Makes checking teleport paths so much easier
void() PrintPathInfo =
{
	if (!active_marker)
	{
		bprint("no active marker\n");
		return;
	}
	SetMarkerIndexes();
	local float p_count = 0;
	m = active_marker;
	bprint("m", ftos(m.index), " paths\nout:");
	if (m.P0) {
		bprint(" m", ftos(m.P0.index));
		PrintDLabel (m.D0);
		p_count = p_count + 1;
	}
	if (m.P1) {
		bprint(" m", ftos(m.P1.index));
		PrintDLabel (m.D1);
		p_count = p_count + 1;
	}
	if (m.P2) {
		bprint(" m", ftos(m.P2.index));
		PrintDLabel (m.D2);
		p_count = p_count + 1;
	}
	if (m.P3) {
		bprint(" m", ftos(m.P3.index));
		PrintDLabel (m.D3);
		p_count = p_count + 1;
	}
	if (m.P4) {
		bprint(" m", ftos(m.P4.index));
		PrintDLabel (m.D4);
		p_count = p_count + 1;
	}
	if (m.P5) {
		bprint(" m", ftos(m.P5.index));
		PrintDLabel (m.D5);
		p_count = p_count + 1;
	}
	if (m.P6) {
		bprint(" m", ftos(m.P6.index));
		PrintDLabel (m.D6);
		p_count = p_count + 1;
	}
	if (m.P7) {
		bprint(" m", ftos(m.P7.index));
		PrintDLabel (m.D7);
		p_count = p_count + 1;
	}
	if (! p_count) bprint(" none\nin: ");
	else bprint(" [", ftos(p_count), "]\nin :");

	p_count = 0;
	m = first_marker;
	while (m)
	{
		if (m.P0 && (m.P0.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D0);
			p_count = p_count + 1;
		}
		else if (m.P1 && (m.P1.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D1);
			p_count = p_count + 1;
		}
		else if (m.P2 && (m.P2.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D2);
			p_count = p_count + 1;
		}
		else if (m.P3 && (m.P3.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D3);
			p_count = p_count + 1;
		}
		else if (m.P4 && (m.P4.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D4);
			p_count = p_count + 1;
		}
		else if (m.P5 && (m.P5.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D5);
			p_count = p_count + 1;
		}
		else if (m.P6 && (m.P6.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D6);
			p_count = p_count + 1;
		}
		else if (m.P7 && (m.P7.index == active_marker.index))
		{
			bprint(" m", ftos(m.index));
			PrintDLabel (m.D7);
			p_count = p_count + 1;
		}
		m = m.marker_link;
	}
	if (! p_count) bprint(" none\n\n");
	else bprint(" [", ftos(p_count), "]\n\n");
}

void() ToggleManualMode =
{
	if (manual_mode)
	{
		manual_mode = FALSE;
		HideAllMarkers();
		bprint("Manual mode OFF\n");
	}
	else
	{
		manual_mode = TRUE;
		alt_marker_idx = 0;
		DisplayAllMarkers();
		bprint("Manual mode ON\n");
	}
};

void() ToggleActiveMarker =
{
	if (mode & STATIC_ACTIVE_MARKER)
	{
		mode = (mode - STATIC_ACTIVE_MARKER);
		bprint("static active marker OFF\n");
	}
	else
	{
		mode = (mode | STATIC_ACTIVE_MARKER);
		bprint("static active marker ON\n");
	}
};

void() ToggleOneWayMode =
{
	if (mode & ONE_WAY)
	{
		mode = (mode - ONE_WAY);
		bprint("one way mode OFF\n");
	}
	else
	{
		mode = (mode | ONE_WAY);
		bprint("one way mode ON\n");
	}
};

void() ToggleConnectMarkersMode =
{
	if (mode & DISPLAY_TYPE)
	{
		if (!active_marker)
		{
			return;
		}
		if (type_mode)
		{
			active_marker.T = (active_marker.T | type_mode);
			bprint("active marker type SET\n");
		}
		else
		{
			active_marker.T = SAVED_T;
			bprint("active marker type CLEARED\n");
		}
		return;
	}
	if (mode & CONNECT_MARKERS)
	{
		mode = (mode - CONNECT_MARKERS);
		bprint("connect markers mode OFF\n");
	}
	else
	{
		mode = (mode | CONNECT_MARKERS);
		bprint("connect markers mode ON\n");
		if (!(mode & STATIC_ACTIVE_MARKER))
		{
			mode = (mode | STATIC_ACTIVE_MARKER);
			bprint("static active marker ON\n");
		}
	}
};

void() CycleDescriptionMode =
{
	if (mode & DISPLAY_TYPE)
	{
		if (type_mode == 0)
		{
			type_mode = UNREACHABLE;
			bprint("unreachable node ON\n");
		}
		else //if (type_mode == UNREACHABLE)
		{
			type_mode = 0;
			bprint("type mode OFF\n");
		}
	}
	else if (path_mode == 0)
	{
		path_mode = JUMP_LEDGE;
		bprint("jump ledge mode ON\n");
	}
	else if (path_mode == JUMP_LEDGE)
	{
		path_mode = DM6_DOOR;
		bprint("dm6 door mode ON\n");
	}
	else if (path_mode == DM6_DOOR)
	{
		path_mode = DISCONNECT_MARKERS;
		bprint("disconnect mode ON\n");
	}
	else if (path_mode == DISCONNECT_MARKERS)
	{
		path_mode = REVERSIBLE;
		bprint("reversible display mode ON\n");
	}
	else if (path_mode == REVERSIBLE)
	{
		path_mode = WATER_PATH;
		bprint("water path display mode ON\n");
	}
	else if (path_mode == WATER_PATH)
	{
		path_mode = ROCKET_JUMP;
		bprint("rocket jump mode ON\n");
	}
	else //if (path_mode == ROCKET_JUMP)
	{
		path_mode = 0;
		bprint("path mode OFF\n");
	}
};

/* To be able to select between markers that have the exact same coordinates,
 * like some in aerowalk. Only works in closest marker mode. */
void() CycleAltMarker =
{
	alt_marker_idx = alt_marker_idx + 1;
	if (alt_marker_idx > 2)
		alt_marker_idx = 0;
	if (! alt_marker_idx)
		bprint("preferring first closest marker\n");
	else
	{
		bprint("preferring alternate closest marker ", ftos(alt_marker_idx), "\n");
	}
}

void() DefaultMarkerMode =
{
	type_mode = 0;
	path_mode = 0;
	mode = 0;
	bprint("default marker mode\n");
};

void() ToggleClosestMarkerMode =
{
	if (mode & CLOSEST_MARKER)
	{
		mode = (mode - CLOSEST_MARKER);
		bprint("Closest marker mode OFF\n");
	}
	else
	{
		mode = (mode | CLOSEST_MARKER);
		bprint("Closest marker mode ON\n");
	}
};

void() DisplayTravelTime =
{
	mode = (mode | DISPLAY_TRAVEL_TIME);
};

void() DisplayReachable =
{
	mode = (mode | DISPLAY_REACHABLE);
};

void() CycleDisplayMode =
{
	if (mode & DISPLAY_ZONE)
	{
		mode = ((mode - DISPLAY_ZONE) | DISPLAY_TYPE);
		bprint("Display type ON\n");
	}
	else if (mode & DISPLAY_TYPE)
	{
		mode = ((mode - DISPLAY_TYPE) | DISPLAY_RUNAWAY);
		bprint("Display runaway ON\n");
	}
	else if (mode & DISPLAY_RUNAWAY)
	{
		mode = (mode - DISPLAY_RUNAWAY);
		bprint("Display path ON\n");
	}
	else
	{
		mode = (mode | DISPLAY_ZONE);
		bprint("Display zone ON\n");
	}
};

void() CheckAllZones =
{
	marker_ = first_marker;
	while (marker_)
	{
		if (!marker_.Z_)
		{
			active_marker = marker_;
			bprint("Zone missing\n");
			setorigin(self, (((active_marker.absmin + active_marker.view_ofs) + '0 0 22') - self.view_ofs));
			return;
		}
		marker_ = marker_.marker_link;
	}
	bprint("Zones completed\n");
};

void() CheckAllGoals =
{
	marker_ = first_item;
	while (marker_)
	{
		if (!marker_.G_)
		{
			active_marker = marker_;
			bprint("Goal missing\n");
			setorigin(self, (((active_marker.absmin + active_marker.view_ofs) + '0 0 22') - self.view_ofs));
			return;
		}
		marker_ = marker_.next;
	}
	bprint("Goals completed\n");
};

// NOTE: I had to change all impulses compared to the waypoint tool distributed
// by Mick, because extra impulses have been added in arena.qc.
// Skip over 140 and 141 because tied to f_jump and r_jump in botimp.qc.
void() ManualImpulseCommands =
{
	if (impulse_ == 132)
	{
		spawn_marker((self.origin - '0 0 22') + self.view_ofs);
	}
	else if (impulse_ == 133)
	{
		CheckAllGoals();
	}
	else if (impulse_ == 134)
	{
		CheckAllZones();
	}
	else if (impulse_ == 135)
	{
		ToggleActiveMarker();
	}
	else if (impulse_ == 136)
	{
		RemoveActiveMarker();
	}
	else if (impulse_ == 137)
	{
		DisableActiveMarker();
	}
	else if (impulse_ == 138)
	{
		ToggleOneWayMode();
	}
	else if (impulse_ == 139)
	{
		ToggleConnectMarkersMode();
	}
	else if (impulse_ == 142)
	{
		DefaultMarkerMode();
	}
	else if (impulse_ == 143)
	{
		SaveMarkers();
	}
	else if (impulse_ == 144)
	{
		ToggleClosestMarkerMode();
	}
	else if (impulse_ == 145)
	{
		ClearActiveMarker();
	}
	else if (impulse_ == 146)
	{
		MoveActiveMarker();
	}
	else if (impulse_ == 147)
	{
		VerMoveActiveMarker();
	}
	else if (impulse_ == 148)
	{
		IncGoal();
	}
	else if (impulse_ == 149)
	{
		DecGoal();
	}
	else if (impulse_ == 150)
	{
		SetGoal();
	}
	else if (impulse_ == 151)
	{
		PrintGoal();
	}
	else if (impulse_ == 152)
	{
		CycleDescriptionMode();
	}
	else if (impulse_ == 153)
	{
		DisplayTravelTime();
	}
	else if (impulse_ == 154)
	{
		CycleDisplayMode();
	}
	else if (impulse_ == 155)
	{
		DisplayReachable();
	}
	else if (impulse_ == 156)
	{
		CycleAltMarker();
	}
	else if (impulse_ == 157)
	{
		PrintPathInfo();
	}
};

#endif

