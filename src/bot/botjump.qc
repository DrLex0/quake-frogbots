/*
	bot/botjump.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2001 Justice
	Copyright (C) 2000-2007 ParboiL
	Improvements by DrLex 2025-2026
*/

#include "../settings.h"

void() VelocityForArrow;
void() NewVelocityForArrow;
void() SetArrowForLinkedMarker;
float(float x_ofs, float z_ofs) OffsetProbeObstacle;
float(float a) anglemod;
float(entity me) near_teammate;
void() MarkerUnTouch;
void(float force) CheckAccurateRunUp;


// Moving in right direction to rocket-jump or precise jump?
// If not, dir_move can be used to adjust direction.
// rel_pos will contain vector to destination.
// Argument is maximum allowed deviation angle.
float(float max_angle) right_direction =
{
	local float current_dir, wish_dir, right_dir;
	local float min_one, min_two;
	local entity target_m;

	if (self.path_from_marker.jump_direction)  // T_JUMP_HINT marker
	{
		if (self.path_state & PRECISE_JUMP)
		{
			if (self.special_p_jump < 3)
				target_m = self.path_from_marker.jump_direction;
			else
				target_m = linked_marker_;
		}
		else
			target_m = linked_marker_;
	}
	else
		target_m = linked_marker_;

	dir_move = normalize(self.oldvelocity);  // before physics
	current_dir = vectoyaw(dir_move);
	rel_pos = target_m.absmin + target_m.view_ofs - origin_;
	dir_move = rel_pos;
	dir_move_z = 0;
	dir_move = normalize(dir_move);

	if (self.special_p_jump)
	{
		if (self.special_p_jump > 2)
			return TRUE;
		// Ideally it should be possible to configure the velocity threshold,
		// but would add even more clutter; these defaults should do the trick
		if (self.special_p_jump == 1)
		{
			if (self.velocity_z > 72)
			if (self.oldvelocity_z > 72)
				return TRUE;
			return FALSE;
		}
		// self.special_p_jump == 2
		if (self.velocity_z < -72)
		if (self.oldvelocity_z < -72)
			return TRUE;
		return FALSE;
	}

	wish_dir = vectoyaw(dir_move);
	min_one = fabs(wish_dir - current_dir);
	if (wish_dir >= 180)
		wish_dir = wish_dir - 360;
	if (current_dir >= 180)
		current_dir = current_dir - 360;
	min_two = fabs(wish_dir - current_dir);
	right_dir = min_one;
	if (min_two < right_dir)
		right_dir = min_two;
	return (right_dir <= max_angle);
};

// enough health & items to rocket-jump
float() able_rj =
{
	// Don't repeat the whole decision process within a frame, not just
	// for efficiency but also because it involves random()
	if (self.able_rj_cache < 0) return FALSE;
	if (self.able_rj_cache) return TRUE;
	self.able_rj_cache = -1;

	local float health_after;
	if (! (self.items & IT_ROCKET_LAUNCHER))
		return FALSE;
	if (! self.ammo_rockets)
		return FALSE;
	if (self.items & IT_INVULNERABILITY)
	{
		// If Quad + Pentagram, sort of a hack is needed to make RJs reliable.
		// Hacky things should only happen on higher skill levels; don't even
		// try RJ on lower levels because it will almost always fail.
		if (self.items & IT_QUAD)
		if (self.bot_skill < 10)
			return FALSE;
		self.able_rj_cache = 1;
		return TRUE;
	}
	if (self.items & IT_QUAD)
		return FALSE;  // let's not gib ourselves
	if (self.ammo_rockets < 3)
		return FALSE;

	health_after = ceil(self.armortype * 50);
	if (health_after > self.armorvalue)
		health_after = self.armorvalue;
	health_after = self.health - ceil(50 - health_after);
	if ((health_after > 50) || (teamplay == 1) || (teamplay == 5))
#ifdef ARENA
	if ((!game_arena) || (arenastate == A_PLAYING))
#endif
	if (!beQuiet)
#ifndef MANUAL
	if (random() > 0.33 || health_after > 99)
#else
	if (!no_rocketjump)
#endif
	{
		self.able_rj_cache = 1;
		return TRUE;
	}
	return FALSE;
};

// boven = Dutch for above ;)
float() checkboven =
{
	traceline(origin_, origin_ + '0 0 140', TRUE, self);
	return (trace_fraction == 1);
};

float() checkground =
{
	makevectors(self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 10;
	traceline (origin_, (origin_ + v_forward) + '0 0 -40', TRUE, self);
	return (trace_fraction != 1);
};

// Try to escape death with a RJ.
// If currently touching an unreachable marker, and linked marker is not unreachable,
// assume it's the best way out. Otherwise pick the nearest non-unreachable marker.
void() lava_jump =
{
	local entity e, way_out;
	local float ldist, bdist, byaw;

	// Dumb bots will simply let themselves be fried
	if (self.bot_smartness < 5.5)
		return;

	// Don't care about Quad, this is a last ditch effort,
	// the extra blast might help to escape if it doesn't kill us
	if (!(self.items & IT_ROCKET_LAUNCHER))
		return;
	if (!self.ammo_rockets)
		return;

	way_out = world;
	if (self.path_from_marker.T & T_UNREACHABLE)
	if (! (linked_marker_.T & T_UNREACHABLE))
		way_out = linked_marker_;
	if (! way_out)
	{
		bdist = 501;
		e = findradius(self.origin, 500);
		while(e) {
			if (e.fl_marker)
			if (!(e.T & T_DO_NOT_WANT))
			{
				ldist = vlen(self.origin - e.origin);
				if (ldist < bdist) {
					bdist = ldist;
					way_out = e;
				}
			}
			e = e.chain;
		}
	}
	byaw = vectoyaw(way_out.absmin + way_out.view_ofs - self.origin);
	self.real_yaw = anglemod(byaw + 180);
	self.yawaccel = 0;
	self.yawspeed = 0;

	if (self.waterlevel == 3) {
		self.real_pitch = 78.75;
		new_pitch = 78.75;
		self.pitchaccel = 0;
		self.pitchspeed = 0;
		self.arrow = BACK;
		VelocityForArrow();
	}
	else if (self.waterlevel == 2) {
		if (self.arrow == BACK) {
			self.real_pitch = 78.75;
			new_pitch = 78.75;
			self.pitchaccel = 0;
			self.pitchspeed = 0;
			self.arrow = BACK;
			VelocityForArrow();
			self.rocketjumping = 1;
			self.botchose = 1;
			self.impulse = 7;
			self.button0_ = 1;
			self.up_finished = time + 0.1;
		} else {
			if (time > self.up_finished) {
				self.swim_arrow = DOWN;
				VelocityForArrow();
			}
		}
	}
};

// Accurate rocket jump. The bot will home in on the marker and set its view angles,
// and launch when everything is close enough to the ideal values.
void() AccurateRJump =
{
	self.precise_speed = 0;
	rel_pos = self.path_from_marker.absmin + self.path_from_marker.view_ofs - origin_;
	rel_pos_z = 0;  // avoid problems with steps
	rel_dist = vlen(rel_pos);
	if (rel_dist < 2.5 + 12 * self.bot_inaccuracy)
	{
		self.velocity = '0 0 0';
		self.arrow = 0;
		if (fabs(angle_error_x) < 1.5 + 12 * self.bot_inaccuracy)
		if (fabs(angle_error_y) < 1.5 + 12 * self.bot_inaccuracy)
		{
			self.rocketjumping = 1;
			self.botchose = 1;
			self.impulse = 7;
			self.button0_ = 1;
			self.button2_ = 1;
			self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND | JUST_GO;
			return;
		}
		return;
	}
	self.precise_speed = 10 + 5 * rel_dist;
	dir_move = normalize(rel_pos);
	NewVelocityForArrow();
};

void() a_rocketjump =
{
	self.rocketjumping = 0;

	if (pre_game && counting_down)
		return;
	if (self.path_state & NARROW_PATH)
	if (self.narrow_path_state)
		return;

	if (self.waterlevel > 1)
	if (pointcontents(origin_ + '0 0 -24') == CONTENT_LAVA)
	if (! (self.items & IT_INVULNERABILITY))
	if (checkboven())
	{
		lava_jump();
		return;
	}

	if (! self.path_from_marker)
		return;
	if (! (self.path_state & ROCKET_JUMP))
		return;
	if (self.button0_)
		return;
	if (self.button2_)
		return;
	if (! able_rj())
		return;
	if (near_teammate(self))
		return;
	if (self.attack_finished > time)
		return;
	if (!(self.flags & FL_ONGROUND))
		return;
	if (self.path_state & WAIT_GROUND)
	{
		// Bot has landed. Clear air-related states, including RJ and jump/slow combos
		// to ensure the bot will not attempt to re-initiate one of those path modes
		// in the time between now and touching the destination marker.
		self.path_state = self.path_state & REACHED_GROUND_RJ;
		return;
	}
	if (self.path_from_marker.look_here)
	{
		AccurateRJump();
		return;
	}
	if (vlen(origin_ - (self.path_from_marker.absmin + self.path_from_marker.view_ofs)) > 100)
		return;
	if (!checkboven())
		return;
	if (!checkground())
		return;
	if (!right_direction(50 + 40 * self.bot_inaccuracy))
	{
		NewVelocityForArrow();
		return;
	}
	// Now dir_move contains the optimal horizontal direction, and rel_pos the vector to the target
	NewVelocityForArrow();
	if (self.items & IT_QUAD)
	{
		// Regular RJ logic would totally fail with Quad power, cheat a bit.
		// Could consider using this same system for regular RJs as well on
		// highest skill levels where the bot is expected to cheat.
		dir_move = normalize(rel_pos);
		local vector dest_angles = vectoangles(dir_move);
		new_pitch = dest_angles_x + 12;  // aim a bit higher to help with (l)edges
		if (new_pitch > 78.75)
			new_pitch = 78.75;
		self.real_yaw = 180 + dest_angles_y;
		if (self.real_yaw > 180)
			self.real_yaw = self.real_yaw - 360;
		self.yawaccel = 0;
		self.yawspeed = 0;
	}
	else
	{
		// Crude heuristics to avoid jumps doomed to fail. Might be improved,
		// although we will not want to do calculations involving sqrt() here.
		// Maybe also reduce speed for very short distances, although I haven't
		// seen any situations yet where this would help.
		rel_pos_z = 0;
		rel_dist = vlen(rel_pos);
		local float velo = vlen(self.velocity);
		if (velo < 140)
			return;
		if (velo < sv_maxspeed)
		if (rel_dist / velo > 1.5)
			return;
		if (self.path_from_marker.rj_angles)
		{
			new_pitch = self.path_from_marker.rj_angles_x;
			if (new_pitch > 78.75)
				new_pitch = 78.75;
			self.real_yaw = self.path_from_marker.rj_angles_y;
			self.yawaccel = 0;
			self.yawspeed = 0;
		}
		else
			new_pitch = 78.75;
	}
	self.real_pitch = new_pitch;
	self.pitchspeed = 0;
	self.pitchaccel = 0;
	self.rocketjumping = 1;
	self.botchose = 1;
	self.impulse = 7;
	self.button0_ = 1;
	self.button2_ = 1;
	self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
};

/*
All the *Logic() functions return TRUE if any remaning special moves logic must be skipped.
*/

// Overrides everything else as long as .wallstrafe_key is set.
// Marker touch will also be suppressed. Ensure deadlines are checked.
float() WallStrafeJumpLogic =
{
	if (! self.wallstrafe_key)
		return FALSE;
	if (time > self.wallstrafe_deadline)
	{
		self.wallstrafe_key = 0;
		return TRUE;
	}

	// Narrow path logic will be suppressed, do the relevant bit here
	if (self.path_state & NARROW_PATH)
	{
		rel_pos = self.path_from_marker.absmin + self.path_from_marker.view_ofs - origin_;
		rel_pos_z = 0;
		if (vlen(rel_pos) > 16 + 8 * self.bot_inaccuracy)
		{
			dir_move = normalize(rel_pos);
			NewVelocityForArrow();
			return TRUE;
		}
		// homed in: start actual wall strafe, refresh deadline
		self.path_state = self.path_state - NARROW_PATH;
		self.wallstrafe_deadline = time + 3;
		self.arrow = self.wallstrafe_key;
	}

	if (vlen(self.run_up_point - origin_) > 24)
		return TRUE;

#ifdef DEBUG_TOUCH
	dprint("WSJ: sticky touch of jump spot m", ftos(linked_marker_.index), "\n");
#endif
	self.touch_marker = linked_marker_;
	self.sticky_touch = TRUE;
	self.wallstrafe_vec = self.velocity;  // see PlayerPreThink_apply
	self.wallstrafe_jump = 1;
	self.wallstrafe_key = 0;
	self.button2_ = 1;
	self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
	return TRUE;
};

float() PreciseRunUpLogic =
{
	if (self.running_up > 0)
	{
		dir_move = self.run_up_point - origin_;
		// Begin the actual run-up when either:
		// - it takes suspiciously long to reach the run-up spot
		//   (probably because is inside wall due to tight space);
		if (time > self.running_up)
			self.running_up = -(time + 1.0);
		// - or we did come sufficiently near the spot.
		else if (vlen(dir_move) < 40)
			self.running_up = -(time + 1.0);
		dir_move = normalize(dir_move);
		if (time > self.arrow_time2)
			NewVelocityForArrow();
		return TRUE;
	}
	if (self.running_up < 0)
	{
		// Either something went awry, bot probably fell off a ledge or something;
		// but we also use this to clear RU state when doing the actual jump.
		if (time > -self.running_up)
		{
			self.running_up = 0;
			return TRUE;
		}
	}
	return FALSE;
};

// Make bots reliably go through narrow openings. How hard could it be?
float() NarrowPathLogic =
{
	if (! (self.path_state & NARROW_PATH))
		return FALSE;
	if (! self.narrow_path_state)
	{
		// Despite all the fancy logic below, bots may sometimes still
		// get stuck on geometry after homing in on the marker. Use similar
		// obstacle probing as for water movement to strafe-nudge the bot.
		// Make lower-skill bots clumsier.
		if (self.obstruction_normal != '0 0 0')
		if (random() >= self.bot_inaccuracy) {
			rel_pos = normalize(linked_marker_.absmin + linked_marker_.view_ofs - origin_);
			// Must be true obstruction: bot can slide forward on anything at enough
			// of an angle (unless someone tries to be fancy by adding a sharp frame
			// around a door without wrapping it in a transparent straight-angled box).
			if (self.obstruction_normal * rel_pos < 0.85)
				return FALSE;
			local vector facing = '0 0 0';
			facing_y = self.v_angle_y;
			// v_forward, v_up will also be used by OffsetProbeObstacle
			makevectors(facing);
			// Bot must be sufficiently facing towards path for strafing to work
			if (v_forward * rel_pos < 0.75)
				return FALSE;
			// Probe randomly at left and right edges
			if (OffsetProbeObstacle(-15.9, -23 + 54 * random())) {
				self.arrow = FORWARD_RIGHT;
				self.arrow_time = self.arrow_time2 = time + 0.1;
				return TRUE;
			}
			if (OffsetProbeObstacle(15.9, -23 + 54 * random())) {
				self.arrow = FORWARD_LEFT;
				self.arrow_time = self.arrow_time2 = time + 0.1;
				return TRUE;
			}
		}
		return FALSE;
	}

	local float test_dist;
	local vector vec_touch;
	vec_touch = self.path_from_marker.absmin + self.path_from_marker.view_ofs - origin_;
	if (self.narrow_path_state < 2)
	{
		// Skip init until landed
		if (!(self.flags & FL_ONGROUND))
			return TRUE;

		rel_pos = linked_marker_.absmin + linked_marker_.view_ofs - (self.path_from_marker.absmin + self.path_from_marker.view_ofs);
		test_dist = rel_pos_z;
		rel_pos_z = 0;

		// Check whether we can avoid losing speed by skipping homing:
		// - narrow path is sufficiently horizontal
		// - already moving mostly in direction of linked marker
		// - assuming unchanged velocity, will bot pass the touched marker close enough
		if (vlen(rel_pos) > 10)  // markers not too near in XY plane (and avoid zero division)
		if (fabs(test_dist / vlen(rel_pos)) < 2)  // path not too vertical
		if (right_direction(16))
		{
			local vector vnorm;
			local float vec_length;
			rel_pos = vec_touch;
			rel_pos_z = 0;  // stick to 2D to keep things simple
			vnorm = self.oldvelocity;
			vnorm_z = 0;
			vnorm = normalize(vnorm);
			// Compute how close bot will come to the marker
			vec_length = rel_pos * vnorm;
			if (vec_length > 0)  // otherwise bot has already overshot the marker
			{
				vec_length = vlen(rel_pos - vec_length * vnorm);
				// A bit stricter than when homing, due to extra uncertainty
				if (self.path_state & SLOW_DOWN)
					test_dist = 7 + 8 * self.bot_inaccuracy;
				else
					test_dist = 12 + 8 * self.bot_inaccuracy;
				if (vec_length < test_dist)
				{
					self.narrow_path_state = 0;
					self.look_object = look_object_ = linked_marker_;
					return FALSE;
				}
			}
		}
		// Focus on touched marker while homing if not yet near it, otherwise on linked marker
		if (vlen(vec_touch) < 32)
			self.look_object = look_object_ = linked_marker_;
		else if (vlen(vec_touch) > 48)
			self.look_object = look_object_ = self.path_from_marker;
		else
		{
			if (self.path_state & SLOW_DOWN)
				self.look_object = look_object_ = self.path_from_marker;
			else
				self.look_object = look_object_ = linked_marker_;
		}
		self.narrow_path_state = 2;
	}

	if (!(self.flags & FL_ONGROUND))
	{
		// If (again) airborne for more than a few frames: must have fallen off ledge; stop homing
		self.narrow_path_state = self.narrow_path_state + 1;
		if (self.narrow_path_state > 8)
		{
#ifdef DEBUG_TOUCH
			dprint("Narrow path homing stopped because airborne\n");
#endif
			self.narrow_path_state = 0;
			self.look_object = look_object_ = linked_marker_;
		}
		return TRUE;
	}
	self.narrow_path_state = 2;

	// Home in on the touched marker
	if (vec_touch_z > 48)
	{
		// Failsafe against weird situations; abort the whole thing. In normal gameplay,
		// markers should only be touched when the player is at most 18u below them,
		// hence in theory a smaller value would be safe, but in practice use 48 to protect
		// against weirdness of Quake touch logic. In experiments, I have seen markers getting
		// touched even 80u higher, but should not happen when normally running around.
#ifdef DEBUG_TOUCH
		dprint("Narrow path aborted because unexpected dZ=", ftos(vec_touch_z), "\n");
#endif
		MarkerUnTouch();
		return TRUE;
	}
	rel_pos = vec_touch;
	rel_pos_z = 0;
	rel_dist = vlen(rel_pos);
	if (self.path_state & SLOW_DOWN)
		test_dist = 10 + 8 * self.bot_inaccuracy;
	else
		test_dist = 16 + 8 * self.bot_inaccuracy;
	if (rel_dist < test_dist)
	{
		self.narrow_path_state = 0;
		self.arrow = 0;
		self.arrow_time = 0;
		self.arrow_time2 = 0;
		self.look_object = look_object_ = linked_marker_;
		// Cap velocity to ensure bot is not dashing past the marker in undesired direction
		if (self.path_state & SLOW_DOWN)
		{
			if (vlen(self.velocity) > slow_landspeed1)
				self.velocity = slow_landspeed1 * normalize(self.velocity);
		}
		else if (vlen(self.velocity) > slow_landspeed2)
			self.velocity = slow_landspeed2 * normalize(self.velocity);
		return TRUE;
	}
	self.precise_speed = 120 + 3 * (rel_dist - 16);
	if (self.path_state & SLOW_DOWN)
	{
		if (rel_dist < 80)
		{
			if (self.precise_speed > slow_landspeed1)
				self.precise_speed = slow_landspeed1;
		}
		else if (rel_dist < 140)
		{
			if (self.precise_speed > slow_landspeed2)
				self.precise_speed = slow_landspeed2;
		}
	}
	dir_move = normalize(rel_pos);
	NewVelocityForArrow();
	return TRUE;
};

// Accurate jumps and/or slow moves  -- DrLex
void() SpecialAccurateMoves =
{
	self.precise_speed = 0;
	if (WallStrafeJumpLogic())
		return;
	if (PreciseRunUpLogic())
		return;

	if (! self.path_from_marker)
		return;
	if (self.waterlevel > 1)
	{
		// only special move applicable under water is slow path
		if (self.path_state & SLOW_DOWN)
		if (vlen(origin_ - (self.path_from_marker.absmin + self.path_from_marker.view_ofs)) < 80)
			self.precise_speed = slow_waterspeed;
		return;
	}
	if (NarrowPathLogic())
		return;
	// This auto path mode is set on each path with PRECISE_JUMP, SLOW_DOWN,
	// NARROW_PATH, and each path leading to a marker that has any such
	// outgoing path.
	if (!(self.path_state & ACCURATE_PATH))
		return;
	if (self.path_state & ROCKET_JUMP)
		return;  // accurate RJ combo is handled in a_rocketjump
	if (self.rocketjumping)
		return;
	if (self.button2_)
		return;
	if (!(self.flags & FL_ONGROUND))
	{
		if (self.path_state & PRECISE_JUMP)
		if (self.path_state & SLOW_DOWN) {
			// The bot may have lost all velocity in the direction of the target due
			// to bumping into the wall. Give it a nudge if this is the case.
			rel_pos = linked_marker_.absmin + linked_marker_.view_ofs - origin_;
			rel_pos_z = 0;
			dir_move = self.velocity;
			dir_move_z = 0;
			if (rel_pos * dir_move < 10) {
				self.velocity = self.velocity + 32 * normalize(rel_pos);
			}
		}
		return;
	}
	local vector v_touch = self.path_from_marker.absmin + self.path_from_marker.view_ofs - origin_;
	local float z_touch = v_touch_z;
	v_touch_z = 0;
	local float touch_dist = vlen(v_touch);

	// right_direction() sets the ideal direction vector dir_move,
	// NewVelocityForArrow() will try to better match this direction
	if (self.path_state & SLOW_DOWN)
	{
		// slow down near path start
		if (touch_dist < 80)
			self.precise_speed = slow_landspeed1;
		else if (touch_dist < 140)
		{
			self.precise_speed = slow_landspeed2;
		}
	}
	if (!right_direction(20 + 20 * self.bot_inaccuracy))
	{
		if (time > self.arrow_time2)
			NewVelocityForArrow();
		return;
	}
	if (time > self.arrow_time2)
		NewVelocityForArrow();
	if (!(self.path_state & PRECISE_JUMP))
		return;

	if (z_touch > 48)  // Bot likely missed jump and fell off a ledge; abort the whole thing
	{
#ifdef DEBUG_TOUCH
		dprint("Precise jump aborted because unexpected dZ=", ftos(z_touch), "\n");
#endif
		return MarkerUnTouch();
	}

	if (touch_dist > 40)  // Only jump when close enough...
	{
		if (! (self.path_state & SLOW_DOWN))
		if (normalize(self.velocity) * normalize(v_touch) < -0.5)
		{
			// Passed the jump spot without jumping; restart run-up
			touch_marker_ = self.path_from_marker;
			self.running_up = 0;
			self.velocity = '0 0 0';
			self.arrow = 0;
			CheckAccurateRunUp(TRUE);
		}
		return;
	}
	local vector v_link = linked_marker_.absmin + linked_marker_.view_ofs - origin_;
	// ... but not when:
	// - already at the destination waiting for marker touch
	if (fabs(v_link_z) < 2)
	if (vlen(v_link) <= 32)
		return;
	// - already on the ledge the bot wanted to jump on
	if (z_touch < -18)
	if (v_link_z <= 18)
	if (! self.special_p_jump)
		return;

	local float velo;
	if (self.special_p_jump)
		velo = sv_maxspeed;  // bypass velocity check below
	else
		velo = vlen(self.velocity);

	if (self.path_state & SLOW_DOWN)
	{
		if (velo > half_sv_maxspeed)  // and not moving too fast
			return;
	}
	else if (velo < 0.8 * sv_maxspeed)  // or too slow
	{
		if (self.obstruction_normal != '0 0 0')
		{
			// When obstructed, restart run-up
			v_link_z = 0;
			if (self.obstruction_normal * normalize(v_link) > 0.5)
			{
				touch_marker_ = self.path_from_marker;
				CheckAccurateRunUp(TRUE);
			}
		}
		return;
	}
	// Keep RU status until actually airborne; the above logic will clear it later on
	if (self.running_up)
		self.running_up = -(time + 0.1);

	if (! self.special_p_jump)
	{
		// Make the jump increasingly perfect with increasing bot skill level.
		hor_velocity = self.velocity;
		hor_velocity_z = 0;
		dir_move = vlen(hor_velocity) * normalize(
			self.bot_inaccuracy * normalize(hor_velocity) +
			(1.0 - self.bot_inaccuracy) * dir_move
		);
		// Must preserve vertical velocity for jumps on a slope
		dir_move_z = self.velocity_z;
		self.velocity = dir_move;
	}
	else if (self.special_p_jump < 3)
	{
		// At this point, arrow is still aiming for the JH marker.
		// To give tricky jumps the best chances of success, instantly
		// update to aim for linked marker instead.
		SetArrowForLinkedMarker();
	}

	if (self.path_state & SLOW_DOWN)
	{
		// Do not clear AP mode for a slow PJ upon jumping,
		// because it often requires multiple attempts.
		self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
	}
	else
	{
		// Clear AP mode, its job here is done
		self.path_state = (self.path_state - ACCURATE_PATH) | DELIBERATE_AIR_WAIT_GROUND;
		// For some reason, bots are unable to bridge the widest gaps that players can
		// still traverse. I gave up trying to figure out what causes this, and just
		// slap a fudge factor onto the velocity to compensate. And of course the factor
		// differs between regular Quake and QW.
#ifdef QUAKE
		self.velocity = 1.25 * self.velocity;
#else
		self.velocity = 1.33 * self.velocity;
#endif
	}
	if (self.path_from_marker.jump_direction)
	{
		self.path_state = self.path_state | AIR_ACCELERATION;
		if (self.path_from_marker.airstrafe_delay)
		{
			self.arrow_time2 = time + self.path_from_marker.airstrafe_delay;
		}
	}
	self.button2_ = 1;
};

void() CheckCombatJump =
{
#ifdef ARENA
	if (game_botjump)
#endif
	if (self.frogbot)
	{
		if (!self.waterlevel)
		if (self.allowedMakeNoise)
		if (self.flags & FL_ONGROUND)
		if (self.weapon != IT_LIGHTNING)
		if (look_object_ == enemy_)
		if (random() < 0.2)
		if (!self.rocketjumping)
		{
			self.button2_ = 1;
		}
	}
};

void() BotInLava =
{
	if (mapname == "amphi2")
	if (self.frogbot)
	{
		if (time > self.arrow_time)
		if (self.waterlevel == 1)
		if (pointcontents(self.origin + '0 0 -24') == CONTENT_LAVA)
		if (self.flags & FL_ONGROUND)
		if (!enemy_shaft_attack())
		if (!self.rocketjumping)
		{
			NewVelocityForArrow();
			self.button2_ = 1;
		}
	}
};
