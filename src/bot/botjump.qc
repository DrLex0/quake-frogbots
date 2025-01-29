/*
	bot/botjump.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2001 Justice
	Copyright (C) 2000-2007 ParboiL
*/

#include "../settings.h"

void() VelocityForArrow;
void() BestArrowForDirection;
float(entity me) near_teammate;

// Moving in right direction to rocket-jump or precise jump?
// If not, dir_move can be used to adjust direction.
float() right_direction =
{
	local float current_dir, wish_dir, right_dir;
	local float min_one, min_two;

	dir_move = normalize(self.oldvelocity);  // before physics
	current_dir = vectoyaw(dir_move);
	dir_move = normalize(self.linked_marker.origin - self.origin);
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
	return (right_dir <= 72);
};

// enough health & items to rocket-jump
float() able_rj =
{
	local float health_after;
	if (! (self.items & IT_ROCKET_LAUNCHER))
		return 0;
	if (! self.ammo_rockets)
		return 0;
	if (self.items & IT_INVULNERABILITY)
		return 1;
	if (self.items & IT_QUAD)
		return 0;  // let's not gib ourselves
	if (self.ammo_rockets < 3)
		return 0;

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
	if (random() > 0.33)
#endif
		return 1;
	return 0;
};

// boven = Dutch for above ;)
float() checkboven =
{
	traceline(self.origin, self.origin + '0 0 140', TRUE, self);
	return (trace_fraction == 1);
};

float() checkground =
{
	makevectors(self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 10;
	traceline (self.origin, (self.origin + v_forward) + '0 0 -40', TRUE, self);
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

void() a_rocketjump =
{
	self.rocketjumping = 0;

	if (pre_game && counting_down)
		return;
	if (self.waterlevel > 1)
	{
		local float pc = pointcontents(self.origin + '0 0 -24');
		if (pc == CONTENT_LAVA)
		{
			// Don't bother checking health, we'll die soon anyway
			if (! (self.items & IT_INVULNERABILITY))
			if (checkboven())
			{
				lava_jump();
				return;
			}
		}
		else if (pc == CONTENT_SLIME)
		{
			if (! (self.items & IT_SLIME_PROOF))
			if (self.health > 75)
			if (checkboven())
			{
				lava_jump();
				return;
			}
		}
	}
	if (! self.touch_marker)
		return;
	if (! (self.path_state & ROCKET_JUMP))
		return;
	if (! able_rj())
		return;
	// Even when we're at the destination marker that has no outgoing paths with RJ flag,
	// path_state will still have the flag (which is arguably a bug), ignore this
	if (! (ROCKET_JUMP & (
		(self.touch_marker.D0 | self.touch_marker.D1 |
		 self.touch_marker.D2 | self.touch_marker.D3 |
		 self.touch_marker.D4 | self.touch_marker.D5 |
		 self.touch_marker.D6 | self.touch_marker.D7))))
	{
		return;
	}
	if (self.button0_)
		return;
	if (self.button2_)
		return;
	if (near_teammate(self))
		return;
	if (self.attack_finished > time)
		return;
	if (!(self.flags & FL_ONGROUND))
		return;
	if (vlen(self.origin - self.touch_marker.origin) > 100)
		return;
	if (!checkboven())
		return;
	if (!checkground())
		return;
	if (!right_direction())
	{
		BestArrowForDirection();
		VelocityForArrow();
		return;
	}
	BestArrowForDirection();
	VelocityForArrow();
	new_pitch = 78.75;
	self.real_pitch = 78.75;
	self.pitchspeed = 0;
	self.pitchaccel = 0;
	self.rocketjumping = 1;
	self.botchose = 1;
	self.impulse = 7;
	self.button0_ = 1;
	self.button2_ = 1;
};

// DrLex: more reliable jumping onto small steps.
// Requires the bot to be able to come within 48 units of the marker from where to jump.
void() PreciseJump =
{
	self.precise_speed = 0;
	if (! self.touch_marker)
		return;
	if (self.waterlevel > 1)
		return;
	if (self.rocketjumping)
		return;
	if (!(self.path_state & PRECISE_JUMP))
		return;
	// Even when we're at the destination marker that has no outgoing paths with PJ flag,
	// path_state will still have the flag (which is arguably a bug), ignore this
	if (! (PRECISE_JUMP & (
		(self.touch_marker.D0 | self.touch_marker.D1 |
		 self.touch_marker.D2 | self.touch_marker.D3 |
		 self.touch_marker.D4 | self.touch_marker.D5 |
		 self.touch_marker.D6 | self.touch_marker.D7))))
	{
		return;
	}
	local float touch_dist = vlen(self.origin - self.touch_marker.origin);
	// slow down as target is approached
	if (touch_dist < 80)
		self.precise_speed = 100;
	else if (touch_dist < 140)
		self.precise_speed = 180;
	if (self.button2_)
		return;
	if (!(self.flags & FL_ONGROUND))
		return;
	if (!right_direction())
	{
		BestArrowForDirection();
		VelocityForArrow();
		return;
	}
	VelocityForArrow();
	// Only jump when close enough
	if (touch_dist > 48)
		return;
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
			BestArrowForDirection();
			VelocityForArrow();
			self.button2_ = 1;
		}
	}
};
