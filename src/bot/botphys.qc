/*
	bot/botphys.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
	Improvements by DrLex 2025-2026
*/

#include "../settings.h"

/*
============
obstruction

Sets self.obstruction_normal to be horizontal normal direction into wall obstruction encountered
during quake physics (ie. between PlayerPreThink and PlayerPostThink)
============
*/
void() obstruction =
{
	delta_velocity = self.oldvelocity - self.velocity;
	if (delta_velocity_x < 0.1)
	if (delta_velocity_x > -0.1)
	if (delta_velocity_y < 0.1)
	if (delta_velocity_y > -0.1)
	{
		self.obstruction_normal = '0 0 0';
		return;
	}

	if (!(self.flags & FL_ONGROUND))
	if ((!self.waterlevel) || (self.flags & FL_WATERJUMP))
	{
		self.obstruction_normal = '0 0 0';
#ifdef DEBUG_OBSTRUCT
			dprint("Air obstruction ", vtos(self.origin), "\n");
#endif
		return;
	}

	if (delta_velocity_z < 0.1)
	if (delta_velocity_z > -0.1)
	{
		hor_velocity = self.velocity;
		hor_velocity_z = 0;

		if (hor_velocity != '0 0 0')
		{
			if (self.player)
			{
				hor_direction = normalize(hor_velocity);
				hor_velocity = hor_direction * (hor_direction * self.oldvelocity);
				self.velocity_x = hor_velocity_x;
				self.velocity_y = hor_velocity_y;
			}

			self.velocity_normal = self.oldvelocity - hor_velocity;
			self.velocity_normal_z = 0;
			self.obstruction_normal = normalize(self.velocity_normal);
			return;
		}

		hor_velocity = self.oldvelocity;
		hor_velocity_z = 0;
		if (hor_velocity != '0 0 0')
		{
			self.velocity_normal = self.oldvelocity - (self.obstruction_normal * (self.obstruction_normal * self.oldvelocity));
			self.velocity_normal_z = 0;
			self.obstruction_normal = normalize(self.velocity_normal);
			return;
		}
	}
	self.obstruction_normal = '0 0 0';
};

/*
============
TryAirStrafe

Simulates air strafing if possible. Returns whether air strafing is performed or not.
============
*/
float() TryAirStrafe =
{
	hor_velocity = self.velocity;
	hor_velocity_z = 0;
	hor_speed = vlen(hor_velocity);

	if (hor_speed <= 100)
	if (! (self.path_state & AIR_ACCELERATION))
		return FALSE;

	if (! turning_speed)  // not overridden: auto-calculate
	{
		hor_normal_vec_x = 0 - self.velocity_y;
		hor_normal_vec_y = self.velocity_x;
		// (hor_normal_vec_z = 0;)
		hor_normal_vec = normalize(hor_normal_vec);

		rel_pos = (self.linked_marker.absmin + self.linked_marker.view_ofs) - self.origin;
		rel_pos_z = 0;

		local float vec_prod = rel_pos * rel_pos;
		if (vec_prod != 0)
			turning_speed = 114.59156 * hor_speed *
				(rel_pos * hor_normal_vec) / vec_prod;	// 114.59156 = 360 / PI
	}

	// Clamp rotation to avoid excessive values that cause negative acceleration.
	// However, when adding intentional inaccuracy, allow going beyond the sane
	// range to mimic unskilled human players.
	if (fabs(turning_speed) > 270)
	{
		if (self.path_state & AIR_ACCELERATION)
		{
			if (turning_speed > 0)
				turning_speed = 270 + self.airstrafe_inaccuracy;
			else
				turning_speed = -270 + self.airstrafe_inaccuracy;
		}
		else  // If no intent to air strafe, give up 
			turning_speed = 0;
	}
	else
		turning_speed = turning_speed + self.airstrafe_inaccuracy;

	if (self.flags & FL_ONGROUND)
		return FALSE;

	// Air strafing needs at least some speed. Fall back to regular
	// arrow key movement if it still allows accelerating.
	if (hor_speed < 29.5)
		return FALSE;

	// This simulates classic Quake air movement logic, with v_forward
	// acting as the 'wishdir'.
	velocity_hor_angle_y = vectoyaw(hor_velocity) + (turning_speed * frametime);
	makevectors(velocity_hor_angle);

	desired_accel = (v_forward * hor_speed) - hor_velocity;

	dir_forward = normalize(desired_accel);
	accel_forward = vlen(desired_accel);

	if (accel_forward > max_accel_forward)
		accel_forward = max_accel_forward;

	velocity_forward = self.velocity * dir_forward;

	if ((velocity_forward + accel_forward) > 30)
	{
		accel_forward = 30 - velocity_forward;
		if (accel_forward < 0)
			accel_forward = 0;
	}

	self.velocity = self.velocity + (accel_forward * dir_forward);
	return TRUE;
};

/*
============
VelocityForArrow

self is a Frogbot.
Sets self.velocity according to current state and the value of self.arrow.
============
*/
void() VelocityForArrow =
{
	// This global is used further down the line; must reset to avoid
	// that value from previous bot leaks to other bot in client loop
	turning_speed = self.airstrafe_override;

	if (self.path_state & ROCKET_JUMP)
	if (self.path_from_marker.look_here)
	if (self.rocketjumping || ! (self.flags & FL_ONGROUND))
	{
		// Accurate RJ in progress, don't try to move, or it will be messed up
		return;
	}

	if (self.t_velocity_override == -1)
	{
		self.velocity = self.velocity_override;
		self.t_velocity_override = 0;
		return;
	}
	else if (self.t_velocity_override)
	{
		if (time < self.t_velocity_override)
		{
			self.velocity = self.velocity_override;
			return;
		}
		self.t_velocity_override = 0;
	}

	// first check air circle turning
	if (!self.waterlevel)
	if (time > self.arrow_time2)
	if (TryAirStrafe())
		return;

	arrow_ = self.arrow;

#ifdef QUAKE
	// NetQuake suppresses going backwards immediately after exiting a teleport. QW does not.
	// Note that teleport_time is also used somewhere in waterjump logic, but we don't do that here.
	if (time < self.teleport_time)
	{
		arrow_ = self.arrow - (self.arrow & BACK);
	}
#endif

	if (!arrow_)
	{
		if (self.waterlevel <= 1)
		{
			return;
		}
		else
		{
			if (self.swim_arrow)
			{
				if (self.swim_arrow == UP)
					dir_forward = '0 0 1';
				else if (self.swim_arrow == FORCE_UP)
					dir_forward = '0 0 1';
				else
					dir_forward = '0 0 -1';

				current_maxspeed = 200;
			}
			else
			{
				dir_forward = '0 0 -1';
				current_maxspeed = 42;
			}
		}
	}
	else
	{
		makevectors(self.v_angle);

		if (arrow_ & FORWARD)
		{
			if (arrow_ == FORWARD)
				dir_forward = v_forward;
			else if (arrow_ == FORWARD_LEFT)
				dir_forward = (v_forward * 0.7525767) - (v_right * 0.6585046);
			else	// (arrow_ == FORWARD_RIGHT)
				dir_forward = (v_forward * 0.7525767) + (v_right * 0.6585046);

			// Slightly ugly hack to make wall strafing for bots similar to players.
			// Only when actually strafing, otherwise it would be a mild speedhack.
			if (self.wallstrafe_key > FORWARD)
				current_maxspeed = sv_maxspeed * 1.07;
			else
				current_maxspeed = sv_maxspeed;
		}
		else if (arrow_ & BACK)
		{
			if (arrow_ == BACK)
				dir_forward = '0 0 0' - v_forward;
			else if (arrow_ == BACK_LEFT)
				dir_forward = '0 0 0' - (v_forward * 0.7525767) - (v_right * 0.6585046);
			else	// (arrow_ == BACK_RIGHT)
				dir_forward = (v_right * 0.6585046) - (v_forward * 0.7525767);

			current_maxspeed = sv_maxspeed;
		}
		else
		{
			if (arrow_ == LEFT)
				dir_forward = '0 0 0' - v_right;
			else	// (arrow_ == RIGHT)
				dir_forward = v_right;

			current_maxspeed = sv_maxstrafespeed;
		}

		if (self.waterlevel <= 1)
		{
			dir_forward_z = 0;
			dir_forward = normalize(dir_forward);
		}
		else
		{
			if (self.swim_arrow)
			{
				if (self.swim_arrow == UP)
					dir_forward = normalize(dir_forward + '0 0 0.5');
				else if (self.swim_arrow == FORCE_UP)
				{
					dir_forward_z = 0.5;
					dir_forward = normalize(dir_forward);
				}
				else
					dir_forward = normalize(dir_forward + '0 0 -0.5');
			}

			current_maxspeed = 0.7 * current_maxspeed;
		}
	}

	// Slow down for accurate movements
	if (self.precise_speed && current_maxspeed > self.precise_speed)
		current_maxspeed = self.precise_speed;

	accel_forward = sv_accelerate_frametime * current_maxspeed;

	velocity_forward = self.velocity * dir_forward;

	if (!(self.flags & FL_ONGROUND))
		if (self.waterlevel <= 1)
			if (current_maxspeed > 30)
				current_maxspeed = 30;

	if ((velocity_forward + accel_forward) > (current_maxspeed))
	{
		accel_forward = current_maxspeed - velocity_forward;
		if (accel_forward < 0)
			accel_forward = 0;
	}

	self.velocity = self.velocity + (accel_forward * dir_forward);
};

#ifdef QUAKE
/*
============
TestEdgeFriction

`SV_UserFriction` in QUAKE, and `PM_Friction` in QW, will apply extra friction
when the player approaches a gap. The motivation is likely to reduce risk of
falling off the edge when letting go of the run key.
This function mimics the same edge probing logic as QUAKE's C code.

That's the simple explanation. When continuing to stare at the Id source code
for hours, and performing experiments involving thousands of lines of console
debug spam, the following additional insights about this rabbit hole emerge.

Both QUAKE and QW have this "edge friction" mechanism. Their implementations
seem identical at first glance, but they are not.
- QUAKE will perform a trace in front of the player, but will do this on
  original unmodified geometry because it passes a single point as 'mins' and
  'maxs' parameters in SV_Move.
- QW does the same trace, but uses PM_PlayerMove, which will actually set 'mins'
  and 'maxs' to the player's bounding box to inflate the clipping hull.
The result is that the trace in QW actually sees a geometry with smaller holes
than QUAKE, and the edge friction will engage much later.

Whoever implemented the original Frogbot code either was not aware of these
details, or did know about it and decided to simplify it, and pretend there is
no edge friction at all in QW. This is why in the Frogbot code:
- #ifndef QUAKE, there is no edge probing at all;
- effort is being done to undo edge friction applied by the engine when
  qwphysics is enabled in QUAKE.

Since QuakeC traceline lacks support to perform the same hull-based trace as QW
uses, only crude approximations would be possible, and indeed the edge friction
effect in QW is much more subtle, and we care much less about it for bot
movement. Hence I have decided to preserve my sanity and stick to pretending
there is no edge friction in QW, and there is also no attempt at re-applying
QW-style edge friction when qwphysics is enabled. This means it causes a bit of
extra risk of falling off edges for players, but as a bonus, wall strafe jumps
will not suffer from any velocity degradation.
============
*/
float() TestEdgeFriction =
{
	if (self.waterlevel <= 1)
	if (self.flags & FL_ONGROUND)
	{
		// Same test as in SV_UserFriction
		hor_velocity = self.postvelocity;
		hor_velocity_z = 0;
		if (vlen(hor_velocity) < 1) return FALSE;
		start = self.origin + normalize(hor_velocity) * 16;
		start_z = self.origin_z + self.mins_z;
		end = start - '0 0 34';
		traceline (start, end, TRUE, self);
		return (trace_fraction == 1);
	}
	return FALSE;
};
#endif

/*
============
DoFriction

============
*/
void() DoFriction =
{
	if (self.flags & FL_ONGROUND)
	{
		hor_velocity = self.velocity;
		hor_velocity_z = 0;
		hor_speed = vlen(hor_velocity);

	#ifdef QUAKE
		if (hor_speed > sv_stopspeed)
		{
			if (use_edge_friction)
			{
				self.velocity_x = self.velocity_x * inv_sv_friction_frametime_edge;
				self.velocity_y = self.velocity_y * inv_sv_friction_frametime_edge;
				return;
			}
			else
			{
				self.velocity_x = self.velocity_x * inv_sv_friction_frametime;
				self.velocity_y = self.velocity_y * inv_sv_friction_frametime;
				return;
			}
		}
		else
		{
			if (use_edge_friction)
			{
				friction_factor = (1 - (sv_friction_frametime_estop / hor_speed));
				if (friction_factor < 0)
					friction_factor = 0;
			}
			else
			{
				friction_factor = (1 - (sv_friction_frametime_stop / hor_speed));
				if (friction_factor < 0)
					friction_factor = 0;
			}

			self.velocity_x = self.velocity_x * friction_factor;
			self.velocity_y = self.velocity_y * friction_factor;
			return;
		}
	#else
		if (hor_speed > sv_stopspeed)
		{
			self.velocity_x = self.velocity_x * inv_sv_friction_frametime;
			self.velocity_y = self.velocity_y * inv_sv_friction_frametime;
			return;
		}
		else
		{
			friction_factor = (1 - (sv_friction_frametime_stop / hor_speed));
			if (friction_factor < 0)
				friction_factor = 0;

			self.velocity_x = self.velocity_x * friction_factor;
			self.velocity_y = self.velocity_y * friction_factor;
			return;
		}
	#endif
	}
};

/*
============
ApplyFriction

============
*/
void() ApplyFriction =
{
#ifdef QUAKE
	if (game_qwphysics)
		use_edge_friction = FALSE;
	else
		use_edge_friction = TestEdgeFriction();
#endif

	if (self.flags & FL_WATERJUMP)
		return;
	if (self.waterlevel <= 1)
		DoFriction();
	else	// do water friction
		self.velocity = self.velocity * inv_sv_friction_frametime;
};

/*
============
ApplyWaterJump

Apply forward push for bots or QUAKE clients until jump has succeeded.
Mimic the QW implementation as much as possible.
============
*/
void() ApplyWaterJump =
{
	if (self.flags & FL_WATERJUMPING)
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;

		// Keep applying push until timeout, or going down, or on solid ground
		if (time >= self.waterjump_time)
		{
			self.flags = self.flags - (self.flags & FL_WATERJUMPING);
			self.waterjump_time = 0;
		}
		else if(self.velocity_z <= 0)
		{
			self.flags = self.flags - (self.flags & FL_WATERJUMPING);
			self.waterjump_time = 0;
		}
		else if (!self.waterlevel)
		{
			// Only QUAKE clears FL_WATERJUMP when exiting water, but only for real
			// players; QW doesn't clear it at all. Hence just always clear it here,
			// or else bots will try to reach low earth orbit.
			if (self.flags & FL_WATERJUMP)
				self.flags = self.flags - FL_WATERJUMP;
			// Extra test also present in QW: check whether origin is above
			// something solid, although in practice the velocity test always
			// triggers before this one
			start = self.origin;
			end = self.origin;
			end_z = end_z + self.mins_z - 1;
			traceline (self.origin, end, TRUE, self);
			if (trace_fraction != 1)
			{
				self.flags = self.flags - (self.flags & FL_WATERJUMPING);
				self.waterjump_time = 0;
			}
		}
	}
};

/*
============
FrogbotPrePhysics1

============
*/
void() FrogbotPrePhysics1 =
{
#ifndef QUAKE
	frametime = real_frametime;
#endif

	// Remove_Obstacles for AvoidHazards
	if (hazard_time)
	{
		self = first_client;
		while (self)
		{
			self.oldsolid = self.solid;
			self.solid = SOLID_NOT;
			self = self.next;
		}
	}

	self = first_client;
	while (self)
	{
		if (self.frogbot)
		{
			self.able_rj_cache = 0;
			if (self.movetype == MOVETYPE_STEP)
				ApplyFriction();
		#ifdef QUAKE
			else if (self.player)  // Player that has become frogbot
			{
				self.v_angle = self.stored_angle;
				if (game_qwphysics)
				if (self.waterlevel <= 1)
				{
					// QW has much less noticeable edge friction. Pretend it has none when
					// emulating qwphysics: undo edge friction already applied by the engine.
					if (TestEdgeFriction())
					{
						// Acceleration will be applied later to the botified player. Only need
						// to repeat what SV_UserFriction did, but then with regular friction.
						self.velocity = self.postvelocity;
						use_edge_friction = FALSE;
						DoFriction();
					}
				}
			}
		#endif

			if (self.takedamage)
			{
				oldvelocity_ = self.velocity;
				VelocityForArrow();
				if (hazard_time)
					AvoidHazards();
			}
		}
	#ifdef QUAKE
		else
		{
			if (game_qwphysics)
			if (self.waterlevel <= 1)
			{
				// Same as above, but now we must consider acceleration from user input as well
				if (TestEdgeFriction())
				{
					// Current total velocity = last frame's velocity, with:
					// - edge friction applied by SV_UserFriction: need to undo this
					// - acceleration added by SV_Accelerate: need to preserve this
					arrow_velocity = self.velocity;

					// Repeat friction calculation from SV_UserFriction
					self.velocity = self.postvelocity;
					use_edge_friction = TRUE;
					DoFriction();

					// Subtract, now arrow_velocity == only what SV_Accelerate added
					arrow_velocity = arrow_velocity - self.velocity;

					// Re-apply regular friction
					self.velocity = self.postvelocity;
					use_edge_friction = FALSE;
					DoFriction();

					// Re-add acceleration, now velocity better approximates QW
					self.velocity = self.velocity + arrow_velocity;
				}
			}
		}

		if (game_qwaim)
		{
			if (self.v_angle_x > 0)
				self.v_angle = self.v_angle + '1.40625 0.703125 0';
			else
				self.v_angle_y = self.v_angle_y + 0.703125;
		}
	#endif

		ApplyWaterJump();

		self = self.next;
	}

	if (hazard_time)
	{
		// Restore_Obstacles for AvoidHazards
		self = first_client;
		while (self)
		{
			self.solid = self.oldsolid;
			self = self.next;
		}
	}
};

/*
============
FrogbotPrePhysics2

============
*/
void() FrogbotPrePhysics2 =
{
#ifndef QUAKE
	frametime = real_frametime;
#endif
	no_bots_stuck = TRUE;

	self = first_client;
	while (self)
	{
		if (!self.player)
		{
			content1 = pointcontents(self.origin + '0 0 -24');
			if (content1 == CONTENT_EMPTY)
			{
				self.oldwaterlevel = 0;
				self.oldwatertype = CONTENT_EMPTY;
			}
			else if (content1 == CONTENT_SOLID)
			{
				unstick_time = unstick_time + frametime;
				if (unstick_time <= numberofclients)
				{
					no_bots_stuck = FALSE;
					self.velocity_z = JUMPSPEED;
				}
				else
				{
					self.botchose = 1;
					self.impulse = CLIENTKILL;
				}
			}
			else
			{
				content2 = pointcontents(self.origin + '0 0 4');
				if (content2 == CONTENT_EMPTY)
				{
					self.oldwaterlevel = 1;
					self.oldwatertype = content1;
				}
				else
				{
					content3 = pointcontents(self.origin + '0 0 22');
					if (content3 == CONTENT_EMPTY)
					{
						self.oldwaterlevel = 2;
						self.oldwatertype = content2;
					}
					else
					{
						self.oldwaterlevel = 3;
						self.oldwatertype = content3;
					}
				}
			}

			if (self.takedamage)
			{
				PlayerPreThink_apply();

				if (self.flags & FL_ONGROUND)
				{
					if (self.velocity_z < 0)
						self.oldvelocity_z = self.velocity_z = 0;

					if (self.fl_ontrain)
						self.fl_ontrain = FALSE;
					else
						self.flags = self.flags - FL_ONGROUND;
				}
				else
				{
					self.jump_flag = self.velocity_z;
					self.fl_ontrain = FALSE;
				}

				if ((self.oldwaterlevel >= 2) || (self.flags & FL_WATERJUMP))
					self.velocity_z = self.velocity_z + (800 * frametime);	// 800 = sv_gravity

				self.oldorigin = self.origin;
				self.waterlevel = self.watertype = 0;
			}
			else
			{
				if (!intermission_running)
				if (self.deadflag >= DEAD_DEAD)
					PlayerDeathThink ();
			}
		}

		self = self.next;
	}

	if (no_bots_stuck)
		unstick_time = 0;

};

/*
============
thud_touch

Stops thud landing sound
============
*/
void() thud_touch =
{
	if (self.flags & FL_ONGROUND)
	{
		self.flags = self.flags - FL_ONGROUND;
		self.fl_thud = TRUE;
	}
};

/*
============
FrogbotPostPhysics

============
*/
void() FrogbotPostPhysics1 =
{
#ifndef QUAKE
	frametime = real_frametime;
#endif

	self = first_client;
	while (self)
	{
		if (self.movetype == MOVETYPE_STEP)
		{
			if (self.fl_thud)
			{
				self.flags = self.flags | FL_ONGROUND;
				self.fl_thud = FALSE;
			}

			self.waterlevel = self.oldwaterlevel;
			self.watertype = self.oldwatertype;
			obstruction();

			//
			// CheckStep
			//

			if (self.obstruction_normal != '0 0 0')
			{
				new_velocity = self.velocity + self.velocity_normal;
				yaw = vectoyaw(self.obstruction_normal);
				// Normally, movement is handled by the engine applying self.velocity, but
				// cannot cope with any kind of obstruction, not even a 1 unit tall step.
				// The following tries to walkmove across the remainder of the distance
				// we expected to move before being obstructed.
				dist = ((new_velocity * frametime) - (self.origin - self.oldorigin)) * self.obstruction_normal;
				oldflags = self.flags;
				self.flags = self.flags | FL_ONGROUND_PARTIALGROUND;
				local float moved_ok = walkmove(yaw, dist);
				// DrLex: fix ascending very steep stairs (fake ladders)
				if (! moved_ok)
					moved_ok = walkmove(yaw, 0.95);  // rounding error paranoia
				if (moved_ok)
				{
					self.velocity = new_velocity;
					self.velocity_z = 0;
					self.obstruction_normal = '0 0 0';
				}
				else
					self.flags = oldflags;
			}

		// check to see if player landed and play landing sound
			if (self.jump_flag)
			if (self.flags & FL_ONGROUND)
				CheckLand();
		}

		// cap wallstrafe speed, see CheckWallStrafe
		if(self.wallstrafe_key)
		{
			local vector vhor = self.velocity;
			vhor_z = 0;
			if (vlen(vhor) > self.max_wallstrafespeed)
			{
				vhor = self.max_wallstrafespeed * normalize(vhor);
				self.velocity_x = vhor_x;
				self.velocity_y = vhor_y;
			}
		}
		self = self.next;
	}
};

/*
============
FrogbotPostPhysics2

============
*/
void() FrogbotPostPhysics2 =
{
#ifndef QUAKE
	frametime = real_frametime;
#endif

	self = first_client;
	while (self)
	{
		if (self.movetype == MOVETYPE_STEP)
			PlayerPostThink_apply();

	#ifdef QUAKE
		self_aiment = self.aiment;
		if (self_aiment.modelindex)
		{
			setorigin(self_aiment, self.origin);
			self_aiment.angles = self.angles;
			self_aiment.frame = self.frame;
		}
	#else
		if (game_qizmo)
		{
			if (!self.player)
				SetPlayerInfo();
		}
	#endif

		self = self.next;
	}

#ifdef QUAKE
	self = first_bodyque;
	while (self)
	{
		self_aiment = self.aiment;
		if (self_aiment.modelindex > 1)
			setorigin(self_aiment, self.origin);
		self = self.next;
	}
#endif
};

/*
============
FrogbotPostPhysics

============
*/
void() FrogbotPostPhysics =
{
	FrogbotPostPhysics1();
	FrogbotPostPhysics2();
};
