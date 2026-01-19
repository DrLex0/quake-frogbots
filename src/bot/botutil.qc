/*
	bot/botutil.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

#include "../settings.h"

float() JumpInWater;
void() VelocityForArrow;


/*
============
BestArrowForDirection

Sets best_arrow to the optimal arrow keys to steer towards
dir_move (which must be a unit vector)
============
*/
void() BestArrowForDirection =
{
	if (self.wallstrafe_key)
	if (! (self.path_state & NARROW_PATH))
	{
		best_arrow = self.wallstrafe_key;
		return;
	}
	makevectors(self.v_angle);

	best_dotproduct = best_arrow = 0;

	test_forward = v_forward * dir_move;
	if (test_forward > best_dotproduct)
	{
		best_dotproduct = test_forward;
		best_arrow = FORWARD;
	}

	test_forward_left = normalize(v_forward - (v_right * 0.875)) * dir_move;
	if (test_forward_left > best_dotproduct)
	{
		best_dotproduct = test_forward_left;
		best_arrow = FORWARD_LEFT;
	}

	test_forward_right = normalize(v_forward + (v_right * 0.875)) * dir_move;
	if (test_forward_right > best_dotproduct)
	{
		best_dotproduct = test_forward_right;
		best_arrow = FORWARD_RIGHT;
	}

	test_right = v_right * dir_move;
	if (test_right > best_dotproduct)
	{
		best_dotproduct = test_right;
		best_arrow = RIGHT;
	}

	test_left = 0 - test_right;
	if (test_left > best_dotproduct)
	{
		best_dotproduct = test_left;
		best_arrow = LEFT;
	}

	test_back = 0 - test_forward;
	if (test_back > best_dotproduct)
	{
		best_dotproduct = test_back;
		best_arrow = BACK;
	}

	test_back_left = 0 - test_forward_right;
	if (test_back_left > best_dotproduct)
	{
		best_dotproduct = test_back_left;
		best_arrow = BACK_LEFT;
	}

	test_back_right = 0 - test_forward_left;
	if (test_back_right > best_dotproduct)
	{
		best_dotproduct = test_back_right;
		best_arrow = BACK_RIGHT;
	}
};

/*
============
NewVelocityForArrow

Adjusts self.arrow according to dir_move and if changed, instantly updates velocity
============
*/
void() NewVelocityForArrow =
{
	BestArrowForDirection();

	if (self.arrow != best_arrow)
	{
		self.dir_move_ = dir_move;
		self.arrow = best_arrow;
		self.arrow_time = time + 0.15;
		// Don't update velocity in the air, or it would interfere with gravity,
		// and bots would be able to do things players cannot.
		if (! (self.flags & FL_ONGROUND))
			return;
		self.velocity = oldvelocity_;
		VelocityForArrow();
	}
};

/*
============
SetArrowForLinkedMarker

Adjusts self.arrow to aim for linked_marker_ (no velocity update)
============
*/
void() SetArrowForLinkedMarker =
{
	dir_move = linked_marker_.absmin + linked_marker_.view_ofs - origin_;
	dir_move_z = 0;
	dir_move = normalize(dir_move);
	self.dir_move_ = dir_move;
	BestArrowForDirection();
	self.arrow = best_arrow;
	self.arrow_time = time + 0.15;
};


/*
============
Visible_360

============
*/
void() Visible_360 =
{
	if (visible_object.takedamage)
	{
		if (time < visible_object.invisible_finished)
		{
			if (time >= visible_object.attack_finished)
			{
				enemy_visible = FALSE;	// invisible and not shooting
				return;
			}
		}

		traceline(self.origin + '0 0 32', visible_object.origin + '0 0 32', TRUE, self);
		if (trace_fraction == 1)
		{
			enemy_visible = TRUE;
			return;
		}
	}
	enemy_visible = FALSE;
};

/*
============
Visible_infront

120 degree fov
============
*/
void() Visible_infront =
{
	if (visible_object.takedamage)
	{
		if (time < visible_object.invisible_finished)
		{
			if (time >= visible_object.attack_finished)
			{
				enemy_visible = FALSE;	// invisible and not shooting
				return;
			}
		}

		traceline(self.origin + '0 0 32', visible_object.origin + '0 0 32', TRUE, self);
		if (trace_fraction == 1)
		{
			makevectors(self.v_angle);
			if ((v_forward * normalize(visible_object.origin - self.origin)) > 0.7071067)
			{
				enemy_visible = TRUE;
				return;
			}
		}
	}
	enemy_visible = FALSE;
};

/*
============
PredictSpot

============
*/
void() PredictSpot =
{
	fallspot_self = self;
	self = dropper;
	self.origin = testplace;
	self.flags = FL_ONGROUND_PARTIALGROUND;
	if (walkmove(0, 0))
	{
		if (!(droptofloor()))
		{
			predict_spot = FALSE;
			self = fallspot_self;
			testplace_z = testplace_z - 400 * (rel_time * rel_time) - 38;
			return;
		}

		if (self.origin_z < fallheight)
		{
			predict_spot = FALSE;
			self = fallspot_self;
			testplace_z = testplace_z - 400 * (rel_time * rel_time) - 38;
			return;
		}

		predict_spot = TRUE;
		self = fallspot_self;
		return;
	}

	predict_spot = FALSE;
	self = fallspot_self;
	testplace = enemy_.origin;
};

/*
============
FallSpotGround

============
*/
void() FallSpotGround =
{
	fallspot_self = self;
	self = dropper;
	self.origin = testplace;
	self.flags = FL_ONGROUND_PARTIALGROUND;
	if (walkmove(0, 0))
	{
		if (!JumpInWater()) 		// no water below
		{
			if (!(droptofloor()))
			{
				self.origin = testplace + '0 0 -256';
				if (!(droptofloor()))
				{
					fall = FALL_DEATH;	// too far to fall (no need further check)
					self = fallspot_self;
					return;
				}
			}
		}
		content = pointcontents(self.origin + '0 0 -24');

		if (content == CONTENT_LAVA && (fallspot_self.invincible_finished - time < 5))
			fall = FALL_DEATH;
		else if (self.origin_z < fallheight)
			fall = FALL_LAND;
		else
			fall = FALL_FALSE;
		self = fallspot_self;
		return;
	}
	else
	{
		fall = FALL_BLOCKED;
		self = fallspot_self;
	}
};

/*
============
FallSpotAir

============
*/
void() FallSpotAir =
{
	fallspot_self = self;
	self = dropper;
	self.origin = testplace;
	self.flags = FL_ONGROUND_PARTIALGROUND;
	if (walkmove(0, 0))
	{
		if (!JumpInWater()) 		// no water below
		{
			if (self.origin_z > testplace_z)
			{
				fall = FALL_BLOCKED;
				self = fallspot_self;
				return;
			}
		}
	}
	else
	{
		fall = FALL_BLOCKED;
		self = fallspot_self;
		return;
	}
	if (!JumpInWater()) 			// no water below
	{
		if (!(droptofloor()))
		{
			self.origin = testplace + '0 0 -256';
			if (!(droptofloor()))
			{
				fall = FALL_DEATH;	// too far to fall (no need further check)
				self = fallspot_self;
				return;
			}
		}
	}
	content = pointcontents(self.origin + '0 0 -24');

	if (content == CONTENT_LAVA && (fallspot_self.invincible_finished - time < 5))
		fall = FALL_DEATH;
	else if (self.origin_z < fallheight)
		fall = FALL_LAND;
	else
		fall = FALL_FALSE;
	self = fallspot_self;
};

/*
============
TestTopBlock

============
*/
void() TestTopBlock =
{
	traceline(last_clear_point + '-16 -16 32', testplace + '-16 -16 32', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z <= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}

	traceline(last_clear_point + '16 -16 32', testplace + '16 -16 32', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z <= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}

	traceline(last_clear_point + '-16 16 32', testplace + '-16 16 32', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z <= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}

	traceline(last_clear_point + '16 16 32', testplace + '16 16 32', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z <= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}
};

/*
============
TestBottomBlock

============
*/
void() TestBottomBlock =
{
	traceline(last_clear_point + '-16 -16 -24', testplace + '-16 -16 -24', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z >= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}

	traceline(last_clear_point + '16 -16 -24', testplace + '16 -16 -24', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z >= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}

	traceline(last_clear_point + '-16 16 -24', testplace + '-16 16 -24', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z >= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}

	traceline(last_clear_point + '16 16 -24', testplace + '16 16 -24', TRUE, self);
	if (trace_fraction != 1)
	{
		if (trace_plane_normal_z >= 0)
		{
			if (first_trace_fraction > trace_fraction)
			{
				first_trace_fraction = trace_fraction;
				first_trace_plane_normal = trace_plane_normal;
			}
		}
	}
};

/*
============
CanJumpOver

============
*/
void() CanJumpOver =
{
	tries = 0;
	last_clear_point = jump_origin;
	last_clear_velocity = jump_velocity;
	last_clear_hor_velocity = last_clear_velocity;
	last_clear_hor_velocity_z = 0;
	last_clear_hor_speed = vlen(last_clear_hor_velocity);
	last_clear_velocity_z = jump_velocity_z - (12800 / last_clear_hor_speed);	// 12800 = sv_gravity * 16

	while ((tries < 20) && (last_clear_point_z >= fallheight))
	{
		testplace = last_clear_point + (last_clear_velocity * (32 / last_clear_hor_speed));

// Try this, it's pretty cool (but may kill your Quake engine)
#ifdef DEBUG_JUMPS
		local entity marker;
		marker = spawn();
		setmodel (marker, "progs/player.mdl");
		setorigin(marker, testplace);
		marker.think = SUB_Remove;
		marker.nextthink = time + 5;
#endif

		FallSpotAir();

		if (fall == FALL_BLOCKED)
		{
			first_trace_fraction = 1;
			TestTopBlock();
			TestBottomBlock();

			if (first_trace_fraction != 1)
			{
				testplace = last_clear_point + (last_clear_velocity * (first_trace_fraction * 32 / last_clear_hor_speed));
				last_clear_velocity = last_clear_velocity - (first_trace_plane_normal * (first_trace_plane_normal * last_clear_velocity));
				last_clear_hor_velocity = last_clear_velocity;
				last_clear_hor_velocity_z = 0;
				last_clear_hor_speed = vlen(last_clear_hor_velocity);
				testplace = testplace + (last_clear_velocity * (32 / last_clear_hor_speed) * (1 - first_trace_fraction));
			}

			FallSpotAir();
		}

		if (fall == FALL_BLOCKED)
		{
			do_jump = FALSE;
			return;
		}
		else
		{
			if (fall > current_fallspot)
			{
				last_clear_velocity_z = last_clear_velocity_z - (25600 / last_clear_hor_speed);	// 25600 = sv_gravity * 32
				last_clear_point = testplace;
			}
			else
			{
				do_jump = TRUE;

				if (self.flags & FL_ONGROUND)
				{
					// Restore_Obstacles for AvoidHazards
					test_enemy = first_client;
					while (test_enemy)
					{
						test_enemy.solid = test_enemy.oldsolid;
						test_enemy = test_enemy.next;
					}

					test_enemy = findradius(testplace, 84);
					while (test_enemy)
					{
						if (test_enemy.T & T_UNREACHABLE)	// includes clients and self
						{
							test_enemy = world;	// exit loop
							do_jump = FALSE;
						}
						test_enemy = test_enemy.chain;
					}

					// Remove_Obstacles for AvoidHazards
					test_enemy = first_client;
					while (test_enemy)
					{
						test_enemy.solid = SOLID_NOT;
						test_enemy = test_enemy.next;
					}
				}

				return;
			}
		}

		if (turning_speed)
		{
			last_clear_angle = vectoangles(last_clear_velocity);
			last_clear_angle_x = 0 - last_clear_angle_x;
			last_clear_angle_y = last_clear_angle_y + (turning_speed * 32 / last_clear_hor_speed);
			makevectors(last_clear_angle);
			last_clear_velocity = v_forward * vlen(last_clear_velocity);
		}

		tries = tries + 1;
	}

	do_jump = FALSE;
};

/*
============
OffsetProbeMarker

Traces a line towards linked_marker from self.origin plus
X, Z offsets in plane defined by v_right and v_up unit vectors.
Returns 1 if no obstacle encountered, 0 otherwise
============
*/
float(float x_ofs, float z_ofs) OffsetProbeMarker =
{
	local vector spot1, spot2;

	spot1 = self.origin + (x_ofs * v_right) + (z_ofs * v_up);
	spot2 = self.linked_marker.absmin + self.linked_marker.view_ofs;
	traceline (spot1, spot2, TRUE, self);
	// marker for switch, platform, etc may be inside its brush
	if (trace_ent == self.linked_marker) return 1;
	if (trace_fraction == 1) return 1;
	return 0;
};

/*
============
OffsetProbeObstacle

Simplified variant on OffsetProbeMarker, probes for obstacle
within 4u Y distance from player's front plane.
Returns TRUE if obstacle encountered.
============
*/
float(float x_ofs, float z_ofs) OffsetProbeObstacle =
{
	local vector spot1, spot2;

	spot1 = self.origin + (x_ofs * v_right) + (z_ofs * v_up);
	spot2 = spot1 + (20 * v_forward);  // measure 4u in front of player = 16u from origin
	traceline (spot1, spot2, TRUE, self);
	if (trace_fraction < 1) return TRUE;
	return FALSE;
};

/*
============
ForwardProbeMarker

Check if bot can move across f_dist * v_forward
and will then be able to see linked_marker
============
*/
float(float f_dist) ForwardProbeMarker =
{
	local vector spot1, spot2;

	spot1 = self.origin + '0 0 4';  // centre of player model
	spot2 = spot1 + (v_forward * f_dist);
	traceline(spot1, spot2, TRUE, self);
	if (trace_fraction < 1) return FALSE;

	spot1 = self.linked_marker.absmin + self.linked_marker.view_ofs;
	traceline(spot2, spot1, TRUE, self);
	if (trace_ent == self.linked_marker) return TRUE;
	return (trace_fraction == 1);
}
