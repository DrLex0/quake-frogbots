/*
	buttons.qc

	button and multiple button

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field 
*/

#include "settings.h"

// button and multiple button

void() button_wait;
void() button_return;

void() AddToQue;
void() adjust_view_ofs_z;
void(entity marker) BecomeMarker;
void(entity mk) SetFrB_Props;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	self.state = STATE_DOWN;
	self.think1 = button_done;
	SUB_CalcMove (self.pos1, self.speed);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{	// do nothing, just don't ome all the way back out
};


void() button_fire =
{
	if (pre_game)
		return;

	if (self.state != STATE_UP)
	{
		if (self.state != STATE_TOP)
		{
			// Only consider the marker touched when the button activates,
			// and ignore marker_time clock, because:
			// - this event only happens once;
			// - timing is often essential when pushing switches
			check_marker(TRUE);
			msg_entity = self;
			sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);
			enemy_ = self.enemy;
			check_sound();
			self.state = STATE_UP;
			self.think1 = button_wait;
			SUB_CalcMove (self.pos2, self.speed);
		}
	}
};

void() button_touch =
{
	if (pre_game)
		return;

	if (other.client_)
	{
		self.enemy = other;
		button_fire ();
	}
};

void() button_killed =
{
	if (pre_game)
		return;

	self.enemy = attacker;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};


/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void() func_button =
{
// put on save que
	AddToQue();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	if (!self.lip)
		self.lip = 4;

	SetMovedir ();

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);

	if (self.wait < 0)
	{
		setorigin (self, self.pos2);
		self.state = STATE_TOP;
		self.frame = 1;			// use alternate textures
	}
	else
	{
		if (self.sounds == 0)
		{
			precache_sound ("buttons/airbut1.wav");
			self.noise = "buttons/airbut1.wav";
		}
		if (self.sounds == 1)
		{
			precache_sound ("buttons/switch21.wav");
			self.noise = "buttons/switch21.wav";
		}
		if (self.sounds == 2)
		{
			precache_sound ("buttons/switch02.wav");
			self.noise = "buttons/switch02.wav";
		}
		if (self.sounds == 3)
		{
			precache_sound ("buttons/switch04.wav");
			self.noise = "buttons/switch04.wav";
		}
	
		self.blocked = button_blocked;

		if (self.health)
		{
			self.max_health = self.health;
			self.th_die = button_killed;
			Add_takedamage();
		}
		else
		{
			self.touch = button_touch;
			self.view_ofs = 0.5 * (self.absmax - self.absmin);
			BecomeMarker(self);
			SetFrB_Props(self);
			adjust_view_ofs_z();
		}

		if (!self.speed)
			self.speed = 40;
		if (!self.wait)
			self.wait = 1;

		self.state = STATE_BOTTOM;

		self.oldorigin = self.origin;
	}

	self.targetname = "";
	// DrLex: fix game crashing on shootable buttons like in lilith.bsp
	self.th_pain = null;
};
