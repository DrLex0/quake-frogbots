// DECOMPILED FROM WAYPOINTS PROGS.DAT with fteqcc and some rudimentary
// cleanup because the original source is nowhere to be found.
// The FrogBot source was given a GPL license by Robert Field in 2007.
// And even if you think that message was fake, this is all so old that
// copyright doesn't mean much anymore anyhow.

#ifdef MANUAL

void() ConnectMarker;
void() DisconnectMarker;
void(string print_string) DescriptionMarker;
void() SaveCoords;
void() SavePaths;
float(entity marker) changed_view_ofs_z;
void() ZoneInfo;

// Artifact from decompiling. TODO: replace with normal calls
void (...) bprintold = #23;
void(float f) bprintold_ftos =
{
	str = ftos(f);
	bprintold(str);
};


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
	bprintold(ftos(test_count));
	bprintold("\n");
	if (test_count > 7)
	{
		bprintold("Reachanble TOO FAR\n");
		self.movetype = 0;
		self.solid = 0;
		self = test_enemy;
		return;
	}
	while (test_count)
	{
		if (!walkmove(yaw, 32))
		{
			bprintold("Reachanble FAIL\n");
			self.movetype = 0;
			self.solid = 0;
			self = test_enemy;
			return;
		}
		test_count = (test_count - 1);
	}
	bprintold("Reachable SUCCESS\n");
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
			mode = (mode - CONNECT_MARKERS);
		}
		if (mode & DISPLAY_TRAVEL_TIME)
		{
			path_normal = TRUE;
			from_marker = active_marker;
			marker.zone_marker();
			marker.sub_arrival_time();
			bprintold("time from active marker = ");
			bprintold(ftos(traveltime));
			bprintold("\n");
			from_marker = marker;
			active_marker.zone_marker();
			active_marker.sub_arrival_time();
			bprintold("time to active marker = ");
			bprintold(ftos(traveltime));
			bprintold("\n");
			mode = (mode - DISPLAY_TRAVEL_TIME);
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
			mode = (mode - DISPLAY_REACHABLE);
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
		bprintold("no active marker\n");
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
		bprintold("active marker removed\n");
		active_marker = world;
		self.touch_marker = world;
	}
	else
	{
		bprintold("Active marker cannot be removed\n");
	}
};

void() DisableActiveMarker =
{
	if (!active_marker)
	{
		bprintold("no active marker\n");
		return;
	}
	bprintold("active marker disabled\n");
	active_marker.display.frame = 12;
	active_marker = world;
	if (!(mode & STATIC_ACTIVE_MARKER))
	{
		mode = (mode | STATIC_ACTIVE_MARKER);
		bprintold("static active marker ON\n");
	}
};

void() ClearActiveMarker =
{
	if (!active_marker)
	{
		bprintold("no active marker\n");
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
	bprintold("Active marker path cleared\n");
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
	if (self.touch_marker)
	{
		manual_marker_touch(self.touch_marker);
	}
	origin_ = self.origin;
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
	if (mode & CLOSEST_MARKER)
	{
		if (active_marker)
		{
			active_marker.display.frame = 12;
		}
		active_marker = LocateMarker(self.origin);
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
		bprintold("marker connected on path 0\n");
		from_marker.P0 = to_marker;
		from_marker.D0 = 0;
	}
	else if (!from_marker.P1)
	{
		bprintold("marker connected on path 1\n");
		from_marker.P1 = to_marker;
		from_marker.D1 = 0;
	}
	else if (!from_marker.P2)
	{
		bprintold("marker connected on path 2\n");
		from_marker.P2 = to_marker;
		from_marker.D2 = 0;
	}
	else if (!from_marker.P3)
	{
		bprintold("marker connected on path 3\n");
		from_marker.P3 = to_marker;
		from_marker.D3 = 0;
	}
	else if (!from_marker.P4)
	{
		bprintold("marker connected on path 4\n");
		from_marker.P4 = to_marker;
		from_marker.D4 = 0;
	}
	else if (!from_marker.P5)
	{
		bprintold("marker connected on path 5\n");
		from_marker.P5 = to_marker;
		from_marker.D5 = 0;
	}
	else if (!from_marker.P6)
	{
		bprintold("marker connected on path 6\n");
		from_marker.P6 = to_marker;
		from_marker.D6 = 0;
	}
	else if (!from_marker.P7)
	{
		bprintold("marker connected on path 7\n");
		from_marker.P7 = to_marker;
		from_marker.D7 = 0;
	}
	else
	{
		bprintold("to_markers full.\n");
	}
};

void() DisconnectMarker =
{
	if (from_marker.P0 == to_marker)
	{
		bprintold("marker disconnected on path 0\n");
		from_marker.P0 = world;
		from_marker.D0 = 0;
	}
	else if (from_marker.P1 == to_marker)
	{
		bprintold("marker disconnected on path 1\n");
		from_marker.P1 = world;
		from_marker.D1 = 0;
	}
	else if (from_marker.P2 == to_marker)
	{
		bprintold("marker disconnected on path 2\n");
		from_marker.P2 = world;
		from_marker.D2 = 0;
	}
	else if (from_marker.P3 == to_marker)
	{
		bprintold("marker disconnected on path 3\n");
		from_marker.P3 = world;
		from_marker.D3 = 0;
	}
	else if (from_marker.P4 == to_marker)
	{
		bprintold("marker disconnected on path 4\n");
		from_marker.P4 = world;
		from_marker.D4 = 0;
	}
	else if (from_marker.P5 == to_marker)
	{
		bprintold("marker disconnected on path 5\n");
		from_marker.P5 = world;
		from_marker.D5 = 0;
	}
	else if (from_marker.P6 == to_marker)
	{
		bprintold("marker disconnected on path 6\n");
		from_marker.P6 = world;
		from_marker.D6 = 0;
	}
	else if (from_marker.P7 == to_marker)
	{
		bprintold("marker disconnected on path 7\n");
		from_marker.P7 = world;
		from_marker.D7 = 0;
	}
};

void(string print_string, float path_number) PrintDescription =
{
	bprintold("marker ");
	bprintold(print_string);
	bprintold(" on path ");
	bprintold(ftos(path_number));
	bprintold("\n");
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
		bprintold("m");
		bprintold(ftos(m.index));
		bprintold(".");
		bprintold(field);
		bprintold("=m");
		bprintold(ftos(m_P.index));
		bprintold(";");
		count_ = (count_ + 1);
	}
};

void(string field) Save_m_D =
{
	if (m_P)
	{
		if (m_D & SAVED_DESCRIPTION)
		{
			bprintold("m");
			bprintold(ftos(m.index));
			bprintold(".");
			bprintold(field);
			bprintold("=");
			bprintold(ftos(m_D & SAVED_DESCRIPTION));
			bprintold(";");
			count_ = (count_ + 1);
		}
	}
};

void() Save_dm6_door =
{
	bprintold("dm6_door=m");
	bprintold(ftos(m.index));
	bprintold(";");
	count_ = (count_ + 1);
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
		m = world;
		save_state = 0;
		bprintold("\nvoid() map_");
		bprintold(mapname);
		bprintold(" =\n{\n");
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
		bprintold("N('");
		bprintold(ftos(m.origin_x));
		bprintold(" ");
		bprintold(ftos(m.origin_y));
		bprintold(" ");
		bprintold(ftos(m.origin_z));
		bprintold("');");
		count_ = count_ + 1;
		if (count_ == 10)
		{
			bprintold("\n");
			return;
		}
		m = find(m, classname, "marker");
	}
	if (count_)
	{
		bprintold("\n");
	}
	bprintold("LSQ();\n");
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
				bprintold("Z");
				bprintold_ftos(m.Z_);
				bprintold("(m");
				bprintold_ftos(m.index);
				bprintold(");");
				count_ = (count_ + 1);
			}
		}
		else
		{
			if (save_state == 1)
			{
				if (m.G_)
				{
					if ((m.classname != "item_cells") || (m.G_ != 19))
					{
						if ((m.classname != "weapon_supernailgun") || (m.G_ != 20))
						{
							if ((m.classname != "weapon_supershotgun") || (m.G_ != 21))
							{
								if ((m.classname != "weapon_nailgun") || (m.G_ != 22))
								{
									if ((m.classname != "item_spikes") || (m.G_ != 23))
									{
										if ((m.classname != "item_shells") || (m.G_ != 24))
										{
											bprintold("G");
											bprintold_ftos(m.G_);
											bprintold("(m");
											bprintold_ftos(m.index);
											bprintold(");");
											count_ = (count_ + 1);
										}
									}
								}
							}
						}
					}
				}
			}
			else if (save_state == 2)
			{
				if (changed_view_ofs_z(m))
				{
					bprintold("m");
					bprintold(ftos(m.index));
					bprintold(".view_ofs_z=");
					bprintold(ftos(m.view_ofs_z));
					bprintold(";");
					count_ = (count_ + 1);
				}
			}
			else if (save_state == 3)
			{
				if (m.T & SAVED_T)
				{
					bprintold("m");
					bprintold(ftos(m.index));
					bprintold(".T=");
					bprintold(ftos(m.T & SAVED_T));
					bprintold(";");
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
				if (mapname == "dm6")
				{
					if (m.classname == "door")
					{
						Save_dm6_door();
					}
				}
			}
		}
		m = m.marker_link;
		if (count_ >= 10)
		{
			bprintold("\n");
			return;
		}
	}
	if (count_)
	{
		bprintold("\n");
	}
	if (save_state < 6)
	{
		save_state = (save_state + 1);
		m = first_marker;
	}
	else
	{
		bprintold("};\n\n");
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
		bprintold("no active marker\n");
		return;
	}
	if (active_marker.classname == "marker")
	{
		bprintold("active marker moved\n");
		active_marker.origin_x = rint(self.origin_x);
		active_marker.origin_y = rint(self.origin_y);
		active_marker.origin_z = rint(self.origin_z);
		setsize(active_marker, VEC_HULL_MIN, VEC_HULL_MAX);
	}
	else
	{
		bprintold("Active marker cannot be moved\n");
	}
};

void() VerMoveActiveMarker =
{
	if (!active_marker)
	{
		bprintold("no active marker\n");
		return;
	}
	bprintold("active marker vertically moved\n");

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
		bprintold("Active marker cannot be moved\n");
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
		bprintold("clear goal");
	}
	else if (goal_index <= NUMBER_GOALS)
	{
		bprintold("goal index = ");
		bprintold_ftos(goal_index);
	}
	else
	{
		bprintold("zone index = ");
		bprintold_ftos(goal_index - NUMBER_GOALS);
	}
	
	bprintold("\n");
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
	bprintold_ftos(Z_index);
	bprintold(" set (total = ");
	bprintold_ftos(S_index);
	bprintold(")\n");
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
					bprintold("goal ");
					PrintGoalZoneIndex();
				}
				else
				{
					bprintold("goal cleared\n");
				}
			}
			else
			{
				bprintold("goal must be an item.\n");
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
				bprintold("zone ");
				PrintGoalZoneIndex();
			}
			else
			{
				bprintold("Zone full.\n");
			}
		}
	}
	else
	{
		bprintold("no active marker\n");
	}
};

void() PrintGoal =
{
	if (!active_marker)
	{
		bprintold("no active marker\n");
		return;
	}
	SetMarkerIndexes();
	bprintold("m");
	bprintold_ftos(active_marker.index);
	if (active_marker.Z_)
	{
		bprintold(", Z");
		bprintold_ftos(active_marker.Z_);
	}
	if (active_marker.G_)
	{
		bprintold(", G");
		bprintold_ftos(active_marker.G_);
	}
	bprintold("\n");

	if (active_marker.RA0)
	{
		bprintold(ftos(active_marker.RA0_time));
		bprintold(" ");
	}
	if (active_marker.RA1)
	{
		bprintold(ftos(active_marker.RA1_time));
		bprintold(" ");
	}
	if (active_marker.RA2)
	{
		bprintold(ftos(active_marker.RA2_time));
		bprintold(" ");
	}
	if (active_marker.RA3)
	{
		bprintold(ftos(active_marker.RA3_time));
		bprintold(" ");
	}
	if (active_marker.RA4)
	{
		bprintold(ftos(active_marker.RA4_time));
		bprintold(" ");
	}
	if (active_marker.RA5)
	{
		bprintold(ftos(active_marker.RA5_time));
		bprintold(" ");
	}
	if (active_marker.RA6)
	{
		bprintold(ftos(active_marker.RA6_time));
		bprintold(" ");
	}
	if (active_marker.RA7)
	{
		bprintold(ftos(active_marker.RA7_time));
	}
	bprintold("\n");

	if (active_marker.RA0)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA0.index));
		bprintold(" ");
	}
	if (active_marker.RA1)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA1.index));
		bprintold(" ");
	}
	if (active_marker.RA2)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA2.index));
		bprintold(" ");
	}
	if (active_marker.RA3)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA3.index));
		bprintold(" ");
	}
	if (active_marker.RA4)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA4.index));
		bprintold(" ");
	}
	if (active_marker.RA5)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA5.index));
		bprintold(" ");
	}
	if (active_marker.RA6)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA6.index));
		bprintold(" ");
	}
	if (active_marker.RA7)
	{
		bprintold("  m");
		bprintold(ftos(active_marker.RA7.index));
	}
	bprintold("\n\n");
};

void() ToggleManualMode =
{
	if (manual_mode)
	{
		manual_mode = FALSE;
		HideAllMarkers();
		bprintold("Manual mode OFF\n");
	}
	else
	{
		manual_mode = TRUE;
		DisplayAllMarkers();
		bprintold("Manual mode ON\n");
	}
};

void() ToggleActiveMarker =
{
	if (mode & STATIC_ACTIVE_MARKER)
	{
		mode = (mode - STATIC_ACTIVE_MARKER);
		bprintold("static active marker OFF\n");
	}
	else
	{
		mode = (mode | STATIC_ACTIVE_MARKER);
		bprintold("static active marker ON\n");
	}
};

void() ToggleOneWayMode =
{
	if (mode & ONE_WAY)
	{
		mode = (mode - ONE_WAY);
		bprintold("one way mode OFF\n");
	}
	else
	{
		mode = (mode | ONE_WAY);
		bprintold("one way mode ON\n");
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
			bprintold("active marker type SET\n");
		}
		else
		{
			active_marker.T = SAVED_T;
			bprintold("active marker type CLEARED\n");
		}
		return;
	}
	if (mode & CONNECT_MARKERS)
	{
		mode = (mode - CONNECT_MARKERS);
		bprintold("connect markers mode OFF\n");
	}
	else
	{
		mode = (mode | CONNECT_MARKERS);
		bprintold("connect markers mode ON\n");
		if (!(mode & STATIC_ACTIVE_MARKER))
		{
			mode = (mode | STATIC_ACTIVE_MARKER);
			bprintold("static active marker ON\n");
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
			bprintold("unreachable node ON\n");
		}
		else //if (type_mode == UNREACHABLE)
		{
			type_mode = 0;
			bprintold("type mode OFF\n");
		}
	}
	else if (path_mode == 0)
	{
		path_mode = JUMP_LEDGE;
		bprintold("jump ledge mode ON\n");
	}
	else if (path_mode == JUMP_LEDGE)
	{
		path_mode = DM6_DOOR;
		bprintold("dm6 door mode ON\n");
	}
	else if (path_mode == DM6_DOOR)
	{
		path_mode = DISCONNECT_MARKERS;
		bprintold("disconnect mode ON\n");
	}
	else if (path_mode == DISCONNECT_MARKERS)
	{
		path_mode = REVERSIBLE;
		bprintold("reversible display mode ON\n");
	}
	else if (path_mode == REVERSIBLE)
	{
		path_mode = WATER_PATH;
		bprintold("water path display mode ON\n");
	}
	else if (path_mode == WATER_PATH)
	{
		path_mode = ROCKET_JUMP;
		bprintold("rocket jump mode ON\n");
	}
	else //if (path_mode == ROCKET_JUMP)
	{
		path_mode = 0;
		bprintold("path mode OFF\n");
	}
};

void() DefaultMarkerMode =
{
	type_mode = 0;
	path_mode = 0;
	mode = 0;
	bprintold("default marker mode\n");
};

void() ToggleClosestMarkerMode =
{
	if (mode & CLOSEST_MARKER)
	{
		mode = (mode - CLOSEST_MARKER);
		bprintold("Closest marker mode OFF\n");
	}
	else
	{
		mode = (mode | CLOSEST_MARKER);
		bprintold("Closest marker mode ON\n");
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
		bprintold("Display type ON\n");
	}
	else if (mode & DISPLAY_TYPE)
	{
		mode = ((mode - DISPLAY_TYPE) | DISPLAY_RUNAWAY);
		bprintold("Display runaway ON\n");
	}
	else if (mode & DISPLAY_RUNAWAY)
	{
		mode = (mode - DISPLAY_RUNAWAY);
		bprintold("Display path ON\n");
	}
	else
	{
		mode = (mode | DISPLAY_ZONE);
		bprintold("Display zone ON\n");
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
			bprintold("Zone missing\n");
			setorigin(self, (((active_marker.absmin + active_marker.view_ofs) + '0 0 22') - self.view_ofs));
			return;
		}
		marker_ = marker_.marker_link;
	}
	bprintold("Zones completed\n");
};

void() CheckAllGoals =
{
	marker_ = first_item;
	while (marker_)
	{
		if (!marker_.G_)
		{
			active_marker = marker_;
			bprintold("Goal missing\n");
			setorigin(self, (((active_marker.absmin + active_marker.view_ofs) + '0 0 22') - self.view_ofs));
			return;
		}
		marker_ = marker_.next;
	}
	bprintold("Goals completed\n");
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
};

#endif

