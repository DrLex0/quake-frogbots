/*
	world.qc

	main/world setup functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

#include "settings.h"

void() InitBodyQue;
void() CheckParameters;
void() InitParameters;
void() LoadFrogbot;
void() InitFrogbots1;
void() InitFrogbots2;
void() FrogbotPrePhysics1;
void() FrogbotPrePhysics2;
void() ThinkTime;
void() TimerThink;
void() ApplyFrB_props;

#ifdef MANUAL
void() MarkerDisplay;
#endif

void() main = {};

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/

/*
============
Custom quad

============
*/
void() custom_quad_touch =
{
	if (other.client_)
	{
		if (self.nextthink) return;
		if (other.takedamage)
		{
			if (!pre_game)
			{
				if (other.goalentity == self)
					other.goal_refresh_time = 0;
				self.nextthink = self.goal_respawn_time = time + self.aflag;
				AssignVirtualGoal();
				self.frogbot_nextthink = time + 30;
				powerup_touch_apply();
				other.old_linked_marker = world;
				other.linked_marker = LocateMarker(other.origin, 0);
				other.linked_marker_time = time + 5;
				msg_entity = other;
				sprint_fb(other, 0, "You got the ");
				sprint_fb(other, 0, self.netname);
				sprint_fb(other, 0, "\n");
			}
		}
	}
	else if (!other)
		LocateDynamicItem();
};

void() custom_quad =
{
	local float s1;
	s1 = stof(infokey(world, "add_q_aerowalk"));
	if (s1)
	{
		item = spawn();
		item.classname = "dynamic_item";
		item.velocity_z = 300;
		item.flags = FL_ITEM;
		item.solid = SOLID_TRIGGER;
		item.movetype = MOVETYPE_TOSS;
		item.view_ofs = '31 31 25';
		item.origin = '-912.6 -898.9 248.0';
		item.aflag = 60;
		item.pickup = pickup_true;
		item.effects = item.effects | EF_BLUE;
		item_artifact_super_damage_apply();
		setsize (item, '-16 -16 -24', '16 16 32');
		item.touch = custom_quad_touch;
		item.nextthink = item.frogbot_nextthink = self.super_damage_finished;
		item.think = SUB_regen;
	}
};

/*
============
worldspawn

============
*/
void() worldspawn =
{
#ifdef QUAKE
	InitParameters();
#endif

	if (self.model == "maps/e1m8.bsp")
		cvar_set ("sv_gravity", "100");
	else
		cvar_set ("sv_gravity", "800");

// the area based ambient sounds MUST be the first precache_sounds
// player precaches
	W_Precache ();			// get weapon precaches

#ifdef ARENA
	a_precache();
#endif

// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

// setup precaches always needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");			// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");

	precache_sound ("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

	precache_sound ("boss1/sight1.wav"); 
	precache_sound ("boss2/pop2.wav");

// ax sounds
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world
	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming
	precache_sound ("buttons/switch04.wav");		// countdown

// Invulnerability sounds
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");

	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
	precache_model ("progs/s_explod.spr");	// sprite explosion

	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing

	precache_model ("progs/missile.mdl");
	precache_model ("progs/grenade.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");

	precache_model ("progs/backpack.mdl");
	precache_model ("progs/zom_gib.mdl");
	precache_model ("progs/v_light.mdl");

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	// 0 normal
	lightstyle(0, "m");
	
	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	setmodel (first_ent, "progs/eyes.mdl");
	modelindex_eyes = first_ent.modelindex;

	setmodel (first_ent, "progs/player.mdl");
	modelindex_player = first_ent.modelindex;

	setmodel (first_ent, "progs/h_player.mdl");
	modelindex_head = first_ent.modelindex;

	first_ent.modelindex = 0;
	first_ent.model = "";

	if (mapname == "aerowalk" && !game_disable_powerups)
		custom_quad();

	VersionInfo();

	if (!game_not_match && !game_arena) {
		localcmd("serverinfo status Standby\n");
		localcmd("localinfo sv_spectalk 1\n");
		k_standby = 0;
	}

	if (teamplay)
		a_rep = stof(infokey(world, "autoreport"));

	if (world.FrogBotWP != "") {
		if (cvar("sv_frog_only_builtin"))
			dprint("Frogbot: sv_frog_only_builtin, ignoring embedded map waypoints\n");
		else
		{
			has_embedded_wp = TRUE;
			dprint("Frogbot: using map embedded waypoints\n");
		}
	}
	marker_load_state = 1;
};

/*
============
StartFrame

============
*/
void() StartFrame =
{
	local entity timer;

#ifndef QUAKE
	real_frametime = (time - old_time);
	old_time = time;

	if (real_frametime > 0.1)
		real_frametime = 0.1;
#endif

	framecount = framecount + 1;

// s: spawn the timer here.
 
	if (game_not_match && !game_arena)
	{
		timer = find(world, classname, "timer");
		if (framecount == 1 && timer != world)
		{
			remove(timer);
			timer = world;
		}
		if (timer == world && timelimit)
		if (!intermission_running && !intermission_getting_closer)
		{
			real_time = 0;
			timer = spawn();
			timer.nextthink = time + 1;
			timer.think = TimerThink;
			timer.touch = null;
			timer.owner = world;
			timer.classname = "timer";
		}
	}

#ifndef QUAKE
	if (framecount == 1)
	{
		// In QW this needs to happen in frame 1. Also, unlike in
		// Quake, entity spawning may be postponed until frame 1.
		InitParameters();
	}
#endif

	/* Robust loading  -- DrLex
	 * Frogbot init can only start when all entity markers are ready.
	 * Some entities postpone their BecomeMarker until framecount >= 2.
	 * Avoid counting frames altogether; just wait until all markers
	 * are ready for sure. */
	if(marker_load_state > -2)
	{
		if(marker_load_state == 1)
		{
			InitFrogbots1();
			marker_load_state = -1;
		}
		else if(marker_load_state == -1)
		{
			InitFrogbots2();
			marker_load_state = -2;
		}
	}

	time_12 = time + 12;

	if (time >= check_parm_time)
		CheckParameters();

	if (time >= next_marker_time)  // check markers 10 times/s
	{
		next_marker_time = next_marker_time + 0.1;
		if (next_marker_time <= time)
			next_marker_time = time + 0.1;
		marker_time = TRUE;
	}
	else
		marker_time = FALSE;

	if (time >= next_hazard_time)  // check hazards 40 times/s
	{
		next_hazard_time = next_hazard_time + 0.025;
		if (next_hazard_time <= time)
			next_hazard_time = time + 0.025;
		hazard_time = TRUE;
	}
	else
		hazard_time = FALSE;

	if (time >= next_special_moves)  // check special moves 64 times/s
	{
		next_special_moves = next_special_moves + 0.015625;
		if (next_special_moves <= time)
			next_special_moves = time + 0.015625;
		special_moves_clock = TRUE;
	}
	else
		special_moves_clock = FALSE;

#ifndef QUAKE
	frametime = real_frametime;
#endif

	average_frametime = (0.9 * average_frametime) + (0.1 * frametime);
	sv_accelerate_frametime = sv_accelerate * frametime;
	max_accel_forward = sv_accelerate_frametime * sv_maxspeed;
	sv_friction_frametime = sv_friction * frametime;
	inv_sv_friction_frametime = 1 - sv_friction_frametime;
	sv_friction_frametime_100 = sv_friction_frametime * 100;	// sv_stopspeed = 100

#ifdef QUAKE
	inv_sv_friction_frametime_2 = 1 - sv_friction_frametime * 2;
	sv_friction_frametime_200 = sv_friction_frametime * 200;
#endif

	mouse_friction = 5400 * frametime;

	if (prephysics)
	{
		prephysics.nextthink = 0.001;		// ie. this frame
		postphysics.nextthink = 0.001;	// ie. this frame

		if (game_arena)
		{
		#ifdef ARENA
			if (frogbot_loading)
			if (loadbot_time_())
				LoadFrogbot();
		#endif
		}
		else
		{
			if (!game_not_match)
			{ 
				if (!load_delay_time)
					load_delay_time = time + 3;
				if (frogbot_loading)
				if (time >= load_delay_time)
					LoadFrogbot();
			}
			else
			{ 
				if (frogbot_loading)
					LoadFrogbot();
			}
		} 

		FrogbotPrePhysics1();
	}
#ifdef MANUAL
	if (manual_mode)
	{
		self = first_ent;
		MarkerDisplay();
	}
#endif

#ifdef ARENA
	framethink();
#endif
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

#ifdef QUAKE
void() FindClientBodyQue =
{
	while (bodyque_client != dropper)
	{
		if (!(bodyque_client.flags & FL_BODYQUE))
		if (!bodyque_client.player)
		{
			bodyque_entry.aiment = bodyque_client;
			bodyque_client.flags = FL_BODYQUE;
			return;
		}
		bodyque_client = nextent(bodyque_client);
	}
	bodyque_entry.aiment = world;
};

void() AssignClientBodyQue =
{
	score_pos_ = 0;
	bodyque_client = first_ent;
	while (bodyque_client != dropper)
	{
		bodyque_client.score_pos = score_pos_;
		score_pos_ = score_pos_ + 1;
		bodyque_client = nextent(bodyque_client);
	}

	bodyque_entry = first_bodyque;
	bodyque_client = first_ent;

	while (bodyque_entry)
	{
		if (!(bodyque_entry.aiment.flags & FL_BODYQUE))
			FindClientBodyQue();
		bodyque_entry = bodyque_entry.next;
	}
};

void() InitBodyQue =
{
	bodyque_head = first_bodyque = spawn();
	bodyque_head.next = spawn();
	bodyque_head.next.next = spawn();
	bodyque_head.next.next.next = spawn();
};

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void() CopyToBodyQue =
{
	SetViewPlayer();

	if (self.health >= -40)
	{
		if (bodyque_head.aiment)
		{
			bodyque_entry = bodyque_head.aiment;
			bodyque_head.modelindex = 0;
			WriteByte(MSG_ALL, MSG_UPDATECOLORS);
			WriteByte(MSG_ALL, bodyque_entry.score_pos);
			if (self.player)
				WriteByte(MSG_ALL, (self.team - 1) * 17);
			else
				WriteByte(MSG_ALL, self.color_);
			setorigin (bodyque_entry, self.origin);
		}
		else
		{
			bodyque_entry = bodyque_head;
		}

		bodyque_entry.skin = viewport.skin;
		bodyque_entry.modelindex = modelindex_player;
		bodyque_entry.frame = self.frame;
	}
	else
	{
		if (bodyque_head.aiment)
			bodyque_head.aiment.modelindex = 0;
		bodyque_entry = bodyque_head;
		bodyque_entry.skin = 0;
		bodyque_entry.modelindex = modelindex_head;
		bodyque_entry.frame = 0;
	}

	viewport.model = "";
	bodyque_entry.angles = self.angles;
	bodyque_entry.model = "/";
	bodyque_entry.colormap = self.colormap;
	bodyque_head.velocity = self.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, self.origin);
	setsize (bodyque_head, self.mins, self.maxs);
	bodyque_head.movetype = MOVETYPE_TOSS;
	bodyque_head = bodyque_head.next;
	if (!bodyque_head)
		bodyque_head = first_bodyque;
};

#else
void() InitBodyQue =
{
	bodyque_head = spawn();
	bodyque_head.next = spawn();
	bodyque_head.next.next = spawn();
	bodyque_head.next.next.next = spawn();
	bodyque_head.next.next.next.next = bodyque_head;
};

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void() CopyToBodyQue =
{
	if (self.health >= -40)
	{
		bodyque_head.modelindex = modelindex_player;
		bodyque_head.frame = self.frame;
	}
	else
	{
		bodyque_head.modelindex = modelindex_head;
		bodyque_head.frame = 0;
	}
	self.model = "";
	bodyque_head.angles = self.angles;
	bodyque_head.model = "/";
	bodyque_head.colormap = self.colormap;
	bodyque_head.movetype = MOVETYPE_TOSS;
	bodyque_head.velocity = self.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, self.origin);
	setsize (bodyque_head, self.mins, self.maxs);
	bodyque_head = bodyque_head.next;
};
#endif
