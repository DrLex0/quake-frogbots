/*
	player.qc

	player functions/definitions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

#include "settings.h"

void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run_ =
{
	self.nextthink = time + 0.1;
	self.walkframe = self.walkframe + 1;

#ifdef TALK
	teamreport2(self, 0);
#endif

	if (!self.velocity_x)
	{
		if (!self.velocity_y)
		{
			if (self.weapon == IT_AXE)
			{
				if (self.walkframe >= 12)
					self.walkframe = 0;
				self.frame = $axstnd1 + self.walkframe;
			}
			else
			{
				if (self.walkframe >= 5)
					self.walkframe = 0;
				self.frame = $stand1 + self.walkframe;
			}
			return;
		}
	}

	if (self.walkframe >= 6)
		self.walkframe = 0;
	if (self.weapon == IT_AXE)
		self.frame = $axrun1 + self.walkframe;
	else
		self.frame = $rockrun1 + self.walkframe;
};

void() player_run =
{
	self.weaponframe = 0;
	self.walkframe = -1;
	self.think = player_run_;
	player_run_();
};


void() muzzleflash =
{
#ifdef QUAKE
	self.effects = self.aiment.effects = self.effects | EF_MUZZLEFLASH;
#else
	WriteByte (MSG_MULTICAST, SVC_MUZZLEFLASH);
	WriteEntity (MSG_MULTICAST, self);
	multicast (self.origin, MULTICAST_PVS);
#endif
};

void()	player_shot1 =	[$shotatt1, player_shot2	]
{
	self.weaponframe = 1;
	muzzleflash();
};
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.weaponframe=2;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.weaponframe=3;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.weaponframe=4;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.weaponframe=5;};
void()	player_shot6 =	[$shotatt6, player_run	] {self.weaponframe=6;};

void()	player_axe1 =	[$axatt1, player_axe2	] {self.weaponframe=1;};
void()	player_axe2 =	[$axatt2, player_axe3	] {self.weaponframe=2;};
void()	player_axe3 =	[$axatt3, player_axe4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axe4 =	[$axatt4, player_run	] {self.weaponframe=4;};

void()	player_axeb1 =	[$axattb1, player_axeb2	] {self.weaponframe=5;};
void()	player_axeb2 =	[$axattb2, player_axeb3	] {self.weaponframe=6;};
void()	player_axeb3 =	[$axattb3, player_axeb4	] {self.weaponframe=7;W_FireAxe();};
void()	player_axeb4 =	[$axattb4, player_run	] {self.weaponframe=8;};

void()	player_axec1 =	[$axattc1, player_axec2	] {self.weaponframe=1;};
void()	player_axec2 =	[$axattc2, player_axec3	] {self.weaponframe=2;};
void()	player_axec3 =	[$axattc3, player_axec4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axec4 =	[$axattc4, player_run	] {self.weaponframe=4;};

void()	player_axed1 =	[$axattd1, player_axed2	] {self.weaponframe=5;};
void()	player_axed2 =	[$axattd2, player_axed3	] {self.weaponframe=6;};
void()	player_axed3 =	[$axattd3, player_axed4	] {self.weaponframe=7;W_FireAxe();};
void()	player_axed4 =	[$axattd4, player_run	] {self.weaponframe=8;};

//============================================================================

void() player_nail1 =[$nailatt1, player_nail2] 
{
	muzzleflash();
	if (self.button0_)
	{
		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe == 9)
			self.weaponframe = 1;
		SuperDamageSound();
		W_FireSpikes (4);
		self.attack_finished = time + 0.2;
		DelayUpdateWeapons();
	}
	else
	{
		player_run ();
	}
};

void() player_nail2 =[$nailatt2, player_nail1]
{
	muzzleflash();
	if (self.button0_)
	{
		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe == 9)
			self.weaponframe = 1;
		SuperDamageSound();
		W_FireSpikes (-4);
		self.attack_finished = time + 0.2;
		DelayUpdateWeapons();
	}
	else
	{
		player_run ();
	}
};

//============================================================================

void() player_light1 =[$light1, player_light2] 
{
	muzzleflash();
	if (self.button0_)
	{
		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe == 5)
			self.weaponframe = 1;
		SuperDamageSound();
		W_FireLightning();
		self.attack_finished = time + 0.2;
	}
	else
	{
		player_run ();
	}
};

void() player_light2 =[$light2, player_light1]
{
	muzzleflash();
	if (self.button0_)
	{
		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe == 5)
			self.weaponframe = 1;
		SuperDamageSound();
		W_FireLightning();
		self.attack_finished = time + 0.2;
	}
	else
	{
		player_run ();
	}
};

//============================================================================


void() player_rocket1 =[$rockatt1, player_rocket2]
{
	self.weaponframe=1;
	muzzleflash();
};
void() player_rocket2 =[$rockatt2, player_rocket3] {self.weaponframe=2;};
void() player_rocket3 =[$rockatt3, player_rocket4] {self.weaponframe=3;};
void() player_rocket4 =[$rockatt4, player_rocket5] {self.weaponframe=4;};
void() player_rocket5 =[$rockatt5, player_rocket6] {self.weaponframe=5;};
void() player_rocket6 =[$rockatt6, player_run] {self.weaponframe=6;};
void(float num_bubbles) DeathBubbles;

void()	player_pain2 =	[	$pain2,	player_pain3	] {};
void()	player_pain3 =	[	$pain3,	player_pain4	] {};
void()	player_pain4 =	[	$pain4,	player_pain5	] {};
void()	player_pain5 =	[	$pain5,	player_pain6	] {};
void()	player_pain6 =	[	$pain6,	player_run	] {};

void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {};
void()	player_axpain6 =	[	$axpain6,	player_run	] {};

void() PlayerPain =
{
	self.state = self.state & NOT_NOTARGET_ENEMY;
	if (self.weaponframe)
		return;
	if (self.invisible_finished <= time)
	{
		self.weaponframe = 0;
		self.nextthink = time + 0.1;

		msg_entity = self;

		if (attacker.classname == "teledeath")
			sound (CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);

	// water pain sounds
		else if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
		{
			DeathBubbles(1);
			if (random() > 0.5)
				sound (CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
			else
				sound (CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		}

	// slime pain sounds
		else if (self.watertype == CONTENT_SLIME)
		{
	// FIX ME	put in some steam here
			if (random() > 0.5)
				sound (CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
			else
				sound (CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		}

		else if (self.watertype == CONTENT_LAVA)
		{
			if (random() > 0.5)
				sound (CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
			else
				sound (CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		}

		else if (self.pain_finished <= time)
		{
			self.pain_finished = time + 0.5;

		// don't make multiple pain sounds right after each other

		// ax pain sound
			if (axhitme_)
			{
				sound (CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
			}
			else
			{
				rnd = floor(random() * 6);

				if (rnd == 0)
					self.noise = "player/pain1.wav";
				else if (rnd == 1)
					self.noise = "player/pain2.wav";
				else if (rnd == 2)
					self.noise = "player/pain3.wav";
				else if (rnd == 3)
					self.noise = "player/pain4.wav";
				else if (rnd == 4)
					self.noise = "player/pain5.wav";
				else
					self.noise = "player/pain6.wav";

				sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);
			}
		}

		if (self.weapon == IT_AXE)
		{
			self.frame = $axpain1;
			self.think = player_axpain2;
		}
		else
		{
			self.frame = $pain1;
			self.think = player_pain2;
		}
	}
};

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;
void() player_die_ax1;

void() DeathBubblesSpawn =
{
	if (self.owner.waterlevel != 3)
	{
		remove_self();
		return;
	}
	if (total_bubbles > 48)
	{
		remove_self();
		return;
	}
	bubble = spawn();
	total_bubbles = total_bubbles + 1;
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove_self();
};

void(float num_bubbles) DeathBubbles =
{
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.nextthink = 0.001;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
};


void() DeathSound =
{
	// water death sounds
	msg_entity = self;
	if (self.waterlevel == 3)
	{
		if (numberofclients < 9)
			DeathBubbles(20);
		else
			DeathBubbles(8);
		sound (CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
	}
	else
	{
		rnd = floor(random() * 5);

		if (rnd == 0)
			self.noise = "player/death1.wav";
		else if (rnd == 1)
			self.noise = "player/death2.wav";
		else if (rnd == 2)
			self.noise = "player/death3.wav";
		else if (rnd == 3)
			self.noise = "player/death4.wav";
		else
			self.noise = "player/death5.wav";

		sound (CHAN_VOICE, self.noise, 1, ATTN_NONE);
	}
};


void() PlayerDead =
{
	self.nextthink = 0;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
};

vector() VelocityForDamage =
{
	vec__x = 100 * crandom();
	vec__y = 100 * crandom();
	vec__z = 200 + 100 * random();

	if (dm > -50)
		return (vec_ * 0.7);
	else if (dm > -200)
		return (vec_ * 2);
	else
		return (vec_ * 10);
};

void(string gibname, float gibtime) ThrowGib =
{
	local	entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage ();
	new.movetype = MOVETYPE_BOUNCE;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + gibtime + random()*gibtime;
};

void() GibPlayer =
{
// throw head
#ifdef QUAKE
	msg_entity = self;
	if (self.player)
	{
		viewport = self.aiment;
		non_viewport = self;
	}
	else
	{
		viewport = self;
		non_viewport = self.aiment;
	}

	SetViewPortClient();
	viewport.modelindex = modelindex_head;
#else
	self.modelindex = modelindex_head;
#endif

	self.nextthink = time + 1;
	self.think = PlayerDead;
	self.movetype = MOVETYPE_BOUNCE;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	dm = self.health;
	self.velocity = VelocityForDamage ();
	self.origin_z = self.origin_z - 24;
	self.flags = self.flags & FL_NOT_ONGROUND;
	self.avelocity = crandom() * '0 600 0';

	local float maxgibtime = 10;
	// reduce gib persistence in complex maps with many clients, otherwise extreme carnage
	// may cause number of edicts to exceed the rather low maximum of certain engines.
	// (Maybe a toggle like the good old 'ekg' cheat from ROTT could be implemented
	// to allow excessive juicy gibbage on engines that can handle it.)
	if (numberofclients > 8)
	if (num_map_load_edicts > 350)
		maxgibtime = 6;

	ThrowGib ("progs/gib1.mdl", maxgibtime);
	ThrowGib ("progs/gib2.mdl", maxgibtime);
	ThrowGib ("progs/gib3.mdl", maxgibtime);
	if (maxgibtime > 6)
	{
		ThrowGib ("progs/gib3.mdl", 3);
		ThrowGib ("progs/gib3.mdl", 3);
		if (random() > 0.9)
			ThrowGib ("progs/eyes.mdl", 2);
	}

	msg_entity = self;
	if (attacker.classname == "teledeath")
		sound (CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
	else if (random() < 0.5)
		sound (CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDie =
{
	self.dead_time = time + max_dead_time;

	if (!game_arena)
	{
		if (duel_mode)
			ar_time = time + 3;
	}

	if (!pre_game)
	{
	#ifdef ARENA
		selfdie();
		if (!game_arena)
	#endif
		DropBackpack();

	#ifdef ARENA
		if (game_drop)
	#else
		if (game_dropring)
	#endif
		if (self.invisible_finished > time)
			drop_artifact_invisibility();

	#ifdef ARENA
		if (game_drop)
	#else
		if (game_dropquad)
	#endif
		if (self.super_damage_finished > time)
			drop_artifact_super_damage();
	}

	ResetItems();
	ClientObituary();
	
	self.weaponmodel = "";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.takedamage = self.solid = self.touch_distance = 0;
	self.touch_marker = world;
	self.flags = self.flags & FL_NOT_ONGROUND;
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
		GibPlayer ();
	else
	{
		DeathSound();
	
		self.angles_x = 0;
		self.angles_z = 0;

	#ifdef QUAKE
		self.aiment.angles = self.angles;	// this can happen after FrogbotPostPhysics
	#endif
	
		if (self.weapon == IT_AXE)
			player_die_ax1 ();
		else
		{
			rnd = floor(random()*5);

			if (rnd == 0)
				player_diea1();
			else if (rnd == 1)
				player_dieb1();
			else if (rnd == 2)
				player_diec1();
			else if (rnd == 3)
				player_died1();
			else
				player_diee1();
		}
	}

#ifdef QUAKE
	self.aiment.frame = self.frame;	// this can happen after FrogbotPostPhysics
#endif
};

void() set_suicide_frame =
{	// used by kill command and disconnect command
	self.frame = $deatha11;
	self.takedamage = self.solid = self.movetype = self.nextthink = 0;
	self.deadflag = DEAD_DEAD;
};


void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11	] {PlayerDead();};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead();};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead();};

void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead();};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead();};

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {};
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerDead();};
