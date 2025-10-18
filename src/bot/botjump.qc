/*
	bot/botjump.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2001 Justice
	Copyright (C) 2000-2007 ParboiL
	Improvements by DrLex 2025/01-02
*/

#include "../settings.h"

void() VelocityForArrow;
void() NewVelocityForArrow;
float(entity me) near_teammate;

// Moving in right direction to rocket-jump or precise jump?
// If not, dir_move can be used to adjust direction.
// rel_pos will contain vector to destination.
// Argument is maximum allowed deviation angle.
float(float max_angle) right_direction =
{
	local float current_dir, wish_dir, right_dir;
	local float min_one, min_two;
	local entity target_m;

	dir_move = normalize(self.oldvelocity);  // before physics
	current_dir = vectoyaw(dir_move);
	if (self.path_from_marker.jump_direction)
		target_m = self.path_from_marker.jump_direction;  // T_JUMP_HINT marker
	else
		target_m = linked_marker_;
	rel_pos = target_m.absmin + target_m.view_ofs - origin_;
	dir_move = rel_pos;
	dir_move_z = 0;
	dir_move = normalize(dir_move);
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
		return TRUE;
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

// try to escape death with a RJ
void() lava_jump =
{
	local entity e, pt;
	local float bdist, byaw;

	if (!(self.items & IT_ROCKET_LAUNCHER))
		return;
	if (!self.ammo_rockets)
		return;

	bdist = 1001;
	pt = self;
	e = self;
	e = findradius(e.origin,1000);
	while(e) {
		if (e.classname == "marker") {
			if (vlen(t.origin - e.origin) < bdist) {
				bdist = vlen(t.origin - e.origin);
				pt = e;
			}
		}
		e = e.chain;
	}
	byaw = vectoyaw(t.origin);
	self.real_yaw = (360 - byaw);
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
			self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
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

// Accurate jumps and/or slow moves  -- DrLex
void() SpecialAccurateMoves =
{
	self.precise_speed = 0;
	if (self.wallstrafe_key)  // WSJ logic
	{
		if (time > self.wallstrafe_deadline)
		{
			self.wallstrafe_key = 0;
			return;
		}
		if (vlen(self.run_up_point - origin_) > 24)
			return;
		self.wallstrafe_vec = self.velocity;  // See FrogbotPrePhysics1
		self.wallstrafe_jump = 1;
		self.wallstrafe_key = 0;
		self.button2_ = 1;
		self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
		return;
	}

	if (self.running_up > 0)  // Precise jump logic
	{
		if (time > self.running_up)
		{
			self.running_up = 0;
			return;
		}
		dir_move = self.run_up_point - origin_;
		if (vlen(dir_move) < 40)  // begin the actual run-up
			self.running_up = -self.running_up;
		dir_move = normalize(dir_move);
		NewVelocityForArrow();
		return;
	}
	else if(self.running_up < 0)
	{
		if (time > -self.running_up)
		{
			self.running_up = 0;
			return;
		}
	}

	if (! self.path_from_marker)
		return;
	if (self.waterlevel > 1)
		return;
	// This auto path mode is set on each path with PRECISE_JUMP or SLOW_DOWN,
	// and each path leading to a marker that has any such outgoing path;
	// also if the path leads to a T_NARROW marker.
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
		if(self.path_state & PRECISE_JUMP)
		if(self.path_state & SLOW_DOWN) {
			// The bot may have lost all velocity in the direction of the target due
			// to bumping into the wall. Give it a nudge if this is the case.
			rel_pos = linked_marker_.absmin + linked_marker_.view_ofs - origin_;
			rel_pos_z = 0;
			dir_move = self.velocity;
			dir_move_z = 0;
			if(rel_pos * dir_move < 10) {
				self.velocity = self.velocity + 32 * normalize(rel_pos);
			}
		}
		return;
	}
	local float touch_dist = vlen(origin_ - (self.path_from_marker.absmin + self.path_from_marker.view_ofs));

	// right_direction() sets the ideal direction vector dir_move,
	// NewVelocityForArrow() will try to better match this direction
	if (self.path_state & SLOW_DOWN)
	{
		// slow down near path start
		if (touch_dist < 80)
			self.precise_speed = 120;
		else if (touch_dist < 140)
		{
			self.precise_speed = 200;
		}
	}
	if (!right_direction(20 + 20 * self.bot_inaccuracy))
	{
		NewVelocityForArrow();
		return;
	}
	NewVelocityForArrow();
	if (!(self.path_state & PRECISE_JUMP))
		return;

	if (touch_dist > 40)  // Only jump when close enough
		return;
	local vector d_dest = origin_ - (linked_marker_.absmin + linked_marker_.view_ofs);
	if (vlen(d_dest) <= 32)
	if (fabs(d_dest_z) < 1)  // but not when already at the destination waiting for marker touch
		return;

	if (self.path_state & SLOW_DOWN)
	{
		if (vlen(self.velocity) > 150)  // and not moving too fast
			return;
	}
	else if(vlen(self.velocity) < 260)  // or too slow
		return;
	if (self.running_up)
		self.running_up = -(time + 0.1);
	// Make the jump increasingly perfect with increasing bot skill level
	self.velocity = (self.bot_inaccuracy * self.velocity) + 
		(1.0 - self.bot_inaccuracy) * vlen(self.velocity) * dir_move;
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
		self.path_state = self.path_state | AIR_ACCELERATION;
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
