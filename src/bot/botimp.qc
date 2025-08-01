/*
	bot/botimp.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 1999-2000 Numb
	Copyright (C) 2000-2007 ParboiL
	Fixes and enhancements by DrLex 2024
*/

#include "../settings.h"

void() GameSettings;
void() LoadTemp1;
void() AddBot;
float() AddRandomBot;
void() AddBotError;
void() AddBots;
void() DoCountDown;
void() PlayerReady;

#ifdef MANUAL
void() ToggleManualMode;
void() ManualImpulseCommands;
#endif

/*
============
SetAttribs

============
*/
void() SetAttribs =
{
	// DrLex: apparently the intention was to make smartness configurable, but this never happened
	// and was hard-coded to 10, making bots do annoyingly advanced things even on lowest skill
	// levels. Smartness now varies together with skill up to 10, but can be overridden by setting
	// cvar 'fb_custom_smart' to nonzero. For 'dumbest' possible bots, use negative value. There is
	// still some stuff that should be disabled or toned down at lower smartness levels, for
	// instance a level 0 bot should not do the HURT_SELF thing.
	local float smartness;

	skill_ = self.bot_skill;  // 0 to 20
	self.bot_inaccuracy = 0.05 * (20 - skill_);
	self.bot_inaccuracy = self.bot_inaccuracy * self.bot_inaccuracy;  // 0 to 1

	if (game_show_rules)
	{
		bprint_fb(2, "skill �");
		bprint_g(2, skill_);
		bprint_fb(2, "�\n");
	}
	if (skill_ > 10)
	{
		smartness = 10;
		self.fast_aim = (skill_ - 10) * 0.1;	// 0.1 to 1
		skill_ = 10;
	}
	else
	{
		self.fast_aim = 0;
		smartness = 3 + 0.7 * skill_;
	}
	if (cvar("fb_custom_smart")) {
		smartness = cvar("fb_custom_smart");
		if (smartness < 0) smartness = 0;
		if (smartness > 10) smartness = 10;
	}
	dprint("Frogbot smartness: ", ftos(smartness), "\n");
	self.bot_smartness = smartness;

	self.firing_reflex = 0.5 - (skill_ * 0.04);	// 0.5 to 0.1
	self.accuracy = 45 - (skill_ * 2.25);	// 45 to 22.5

	self.stop_turn_speed = 135 + (smartness * 40.5);	// 135 to 540
	self.dodge_amount = smartness * 0.1;		// 0 to 1
	self.look_anywhere = smartness * 0.1;	// 0 to 1
	self.lookahead_time = 5 + (smartness * 2.5);		// 5 to 30
	self.prediction_error = 1 - (smartness * 0.1);	// 1 to 0
};

void() SetGame =
{
	game_disable_powerups = (!(gamemode & GAME_ENABLE_POWERUPS));
	game_enable_runes = gamemode & GAME_ENABLE_RUNES;
	game_not_rune_rj = (!(gamemode & GAME_RUNE_RJ));
	game_rl_pref = gamemode & GAME_RL_PREF;
	game_lg_pref = gamemode & GAME_LG_PREF;
	game_not_match = (!(gamemode & GAME_MATCH));
	game_lava_cheat = gamemode & GAME_LAVA_CHEAT;
	game_show_rules = (!(gamemode & GAME_HIDE_RULES));
	game_disable_autoreport = (!(gamemode & GAME_ENABLE_AUTOREPORT));
	game_disable_dropweap = (!(gamemode & GAME_ENABLE_DROPWEAP));
	game_disable_autosteams = (!(gamemode & GAME_ENABLE_AUTOSTEAMS));
#ifdef TALK
	game_disable_botchat = (!(gamemode & GAME_ENABLE_BOTCHAT));
#endif
#ifdef QUAKE
	game_qwphysics = gamemode & GAME_QWPHYSICS;
	game_skins = (!(gamemode & GAME_NOSKINS));
	game_qwaim = gamemode & GAME_QWAIM;
#else
	game_qizmo = (stof(infokey(world, "proxy")));
#endif
#ifdef ARENA
	a_gamemode();
#else
	// Avoids the need for some #ifdefs
	game_arena = FALSE;
#endif
};

/*
============
InitParameters

============
*/
void() InitParameters =
{
	local float ds;

	first_ent = nextent(world);
	test_enemy = first_ent;
	maxplayers = 0;
	while(test_enemy)
	{
		maxplayers = maxplayers + 1;
		test_enemy = nextent(test_enemy);
	}

	dropper = spawn();	// first entity after clients
	setsize (dropper, VEC_HULL_MIN, VEC_HULL_MAX);

	dropper.desire = goal_NULL;
	dropper.virtual_goal = dropper;

	self = dropper;
	NewItems();

	InitBodyQue ();

#ifdef QUAKE
	temp1 = cvar("temp1");
#else
	temp1 = stof(infokey(world, "temp1"));
	deathmatch = cvar("deathmatch");

	if (maxplayers > 24)
		maxplayers = 24;
#endif

	nextmap = mapname;
	pre_game = TRUE;

	gamemode = cvar("samelevel");

	SetGame();

	teamplay = cvar("teamplay");

#ifdef ARENA
	initialize();
#endif

	if (teamplay == 1)
		healthplay = TEAM_TOTAL_HEALTH_PROTECT;
	else if (teamplay == 2)
		healthplay = TEAM_FRAG_PENALTY;
	else if (teamplay == 3)
		healthplay = TEAM_HEALTH_PROTECT;
	else if (teamplay == 4)
	{
		healthplay = TEAM_HEALTH_PROTECT;
		armorplay = TRUE;
	}
	else if (teamplay == 5)
	{
		healthplay = TEAM_TOTAL_HEALTH_PROTECT;
		armorplay = TRUE;
	}
	else
	{
		teamplay = 0;
		cvar_set("teamplay", "0");
	}

	next_teamplay = teamplay;

	if (!temp1)
	{
		ds = cvar("fb_custom_skill");
		if (! ds) ds = stof(infokey(world, "d_skill"));
		if (ds) skill = ds;
		else skill = 10;
		if (skill < 0) skill = 0;
		localcmd("\n");	// flush buffer (early Quake versions)
		localsave(0, 1, 0);
		localsave(1, 1, 1);
	}
	else
		LoadTemp1();

	SetSkill();

	sv_accelerate = cvar("sv_accelerate");
	sv_friction = cvar("sv_friction");

	numberofbots = -1;

	if ((deathmatch != floor(deathmatch)) || (deathmatch < 1) || (deathmatch > MAX_DEATHMATCH))
	{
		deathmatch = 1;
		cvar_set("deathmatch", "1");
	}

	next_deathmatch = deathmatch;

	if (game_not_match)
	{
		GameSettings();
		max_dead_time = 1000000;
	}
	else
		max_dead_time = 5;

	if (deathmatch <= 3)
		available_weapons = IT_AXE_SHOTGUN;
	else
	{
		if (deathmatch == 4)
			available_weapons = IT_ALL_BUT_GRENADE;
		else
			available_weapons = IT_ALL;
	}

	if (deathmatch != 4)
		quad_factor = 4;
	else
		quad_factor = 8;

	leave = (deathmatch != 1);

	sv_maxspeed = cvar("sv_maxspeed");

	if (sv_maxspeed >= 346.666666)
	{
		if (sv_maxspeed > 400)
		{
			cvar_set("sv_maxspeed", "400");
			sv_maxspeed = 400;
		}
		sv_maxstrafespeed = 346.666666;
	}
	else
	{
		if (sv_maxspeed < 320)
		{
			cvar_set("sv_maxspeed", "320");
			sv_maxspeed = 320;
		}
		sv_maxstrafespeed = sv_maxspeed;
	}

	sv_maxwaterspeed = sv_maxspeed * 0.7;
	half_sv_maxspeed = sv_maxspeed * 0.5;
	inv_sv_maxspeed = 1 / sv_maxspeed;

	str_func_avail = 0;
	if (cvar("pr_checkextension"))
	if (checkextension("ZQ_QC_STRINGS") || checkextension("FRIK_FILE"))
		str_func_avail = 1;
};

/*
============
SaveTemp1

============
*/
void() SaveTemp1 =
{
#ifdef QUAKE
	cvar_set_("temp1", skill + 1);
#else
	localcmd("localinfo temp1 ");
	localcmd_ftos(skill + 1);
	localcmd("\n");
#endif
};

/*
============
SetSkill

============
*/
void() SetSkill =
{
#ifdef QUAKE
	cvar_set_("skill", skill);
	old_skill = skill;
#endif
	bprint_fb(2, "\"skill\" changed to \"");
	bprint_ftos(2, skill);
	bprint_fb(2, "\"\n");
	first_ent.bot_skill = skill;
	SaveTemp1();
	if (cvar("fb_custom_skill"))
	{
		if (skill) cvar_set_("fb_custom_skill", skill);
		else cvar_set_("fb_custom_skill", -1);
	}
};

/*
============
LoadTemp1

============
*/
void() LoadTemp1 =
{
	skill = temp1 - 1;
};

/*
============
localsave

============
*/
void(float frogbot_pos, float index_, float value) localsave =
{
	localcmd("localinfo ");
	localcmd_ftos(frogbot_pos * 2 + index_);
	localcmd(" ");
	localcmd_ftos(value);
	localcmd("\n");
};

/*
============
localload

============
*/
void(float frogbot_pos) localload =
{
	str = ftos(frogbot_pos * 2 + frogbot_load_stage);
	registered = stof(infokey(world, str));
};

/*
============
SaveFrogbot

============
*/
void() SaveFrogbot =
{
	localsave(numberofbots, 1, 2 + self.color_+ self.teamcolor * 256 + self.bot_skill * 65536);
	localsave(numberofbots, 2, self.botnumber);
	localsave(numberofbots + 1, 1, 1);
};

/*
============
LoadFrogbot

============
*/
void() LoadFrogbot =
{
	self = postphysics;

	if (frogbot_load_stage)
	{
	#ifdef QUAKE
		registered = cvar("registered");
	#endif

		if (numberofbots == -1)
		{
			first_ent.admin_code = self.admin_code = registered;
			numberofbots = 0;
			if (map_lacks_waypoints)
			{
			#ifdef QUAKE
				cvar_set("registered", "1");
			#endif
				frogbot_loading = FALSE;
				return;
			}
		}
		else
		{
			if (frogbot_load_stage == 1)
			{
				if (registered == 1)
				{
					frogbot_loading = FALSE;
					return;
				}
				registered = registered - 2;
				self.color_ = registered & 255;
				self.teamcolor = floor(registered / 256) & 255;
				self.bot_skill = floor(registered / 65536) & 255;
			}
			else if (frogbot_load_stage == 2)
				self.botnumber = registered;

#ifdef TALK
			self.old_bot = TRUE;
#endif

			if (frogbot_load_stage <= NUMBER_LOAD_STAGE)
			{
				frogbot_load_stage = frogbot_load_stage + 1;
				localload(numberofbots + 1);
				return;
			}
			AddBot();
		}
	}

	frogbot_load_stage = 1;
	localload(numberofbots + 1);
};

/*
============
CheckParameters

============
*/
void() CheckParameters =
{
	if (!game_not_match || game_arena)
		real_time = check_parm_time - start_time;
#ifndef ARENA
	timelimit = cvar("timelimit") * 60;
#else
	if (!game_not_match)
#endif
	if (start_time)
		DoCountDown();

	if (timelimit)
	{
		if (!game_not_match)
		{
			if (!pre_game)
			if (real_time >= timelimit_user * 60)
				NextLevel();
		}
		else
		{
			if (real_time >= timelimit * 60)
				NextLevel();
		}
	}

	check_parm_time = floor(time) + 1;

	if (sv_accelerate != cvar("sv_accelerate"))
	{
		sv_accelerate = cvar("sv_accelerate");

		if (sv_accelerate < 10)
			sv_accelerate = 10;

		cvar_log("sv_accelerate", sv_accelerate);
	}

	if (next_deathmatch != cvar("deathmatch"))
	{
		next_deathmatch = cvar("deathmatch");
		bprint_fb(2, "deathmatch changed to ");
		bprint_ftos(2, next_deathmatch);
		bprint_fb(2, "\n(enabled after restart)\n");
	}

	if (next_teamplay != cvar("teamplay"))
	{
		next_teamplay = cvar("teamplay");
		bprint_fb(2, "teamplay changed to ");
		bprint_ftos(2, next_teamplay);
		bprint_fb(2, "\n(enabled after restart)\n");
	}


#ifdef QUAKE
	if (cvar("sys_ticrate") > 0.025)
		cvar_set("sys_ticrate", "0.025");

	if (game_qwphysics)
		sv_maxfriction = sv_accelerate;
	else
		sv_maxfriction = sv_accelerate * 0.5;

	if (sv_maxfriction > 10)
		sv_maxfriction = 10;

	if (sv_friction > sv_maxfriction)
		cvar_set_("sv_friction", sv_maxfriction);

	if (sv_friction != cvar("sv_friction"))
	{
		sv_friction = cvar("sv_friction");
		if (sv_friction < 0)
		{
			sv_friction = 0;
			cvar_set_("sv_friction", 0);
		}
	}

	skill = cvar("skill");
	skill = floor(skill);
	if (skill < 0)
		skill = 0;
	if (skill > MAX_SKILL)
		skill = MAX_SKILL;

	if (skill != old_skill)
		SetSkill();

	if (host_framerate != cvar("host_framerate"))
	{
		host_framerate = cvar("host_framerate");
	#ifndef ARENA
		bprint_fb(2, "host_framerate changed to ");
		bprint_ftos(2, host_framerate * 1000000);
		bprint_fb(2, "/1000000\n");
	#else
		bprint_fb(2, "\"host_framerate\" changed to \"");
		bprint_ftos(2, host_framerate);
		bprint_fb(2, "\"\n");
	#endif
	}
#else
	if (sv_accelerate > 10)
		sv_maxfriction = 10;
	else
		sv_maxfriction = sv_accelerate;

	if (sv_friction > sv_maxfriction)
		cvar_set_("sv_friction", sv_maxfriction);

	if (sv_friction != cvar("sv_friction"))
	{
		sv_friction = cvar("sv_friction");
		if (sv_friction < 0)
			sv_friction = 0;
		cvar_log("sv_friction", sv_friction);
	}
#endif

	fraglimit = cvar("fraglimit");

	if ((cvar("sv_gravity") != 800) && (mapname != "e1m8"))
		cvar_set("sv_gravity", "800");

	if ((cvar("sv_gravity") != 100) && (mapname == "e1m8"))
		cvar_set("sv_gravity", "100");

	if (cvar("sv_mintic") != 0)
		cvar_set("sv_mintic", "0");

	if (sv_maxspeed != cvar("sv_maxspeed"))
		NextLevel();
};

/*
============
BotExists

============
*/
float() BotExists =
{
	bot = frogbot_spawned;
	while (bot != postphysics)
	{
		if (bot != self)
		{
		if (bot.botnumber == self.botnumber)
				return TRUE;
		}
		bot = nextent(bot);
	}
	return FALSE;
};

/*
============
HCFrogbot

============
*/
void(float color, float numb) HCFrogbot =
{
	self.color_ = color;
	self.botnumber = numb;
};

/*
============
BeenSpawned

============
*/
float(entity client, float value) BeenSpawned =
{
	if (value < 48)
	{
		spawnbit0_ = 1;
		spawnbit1_ = 0;

		while (value > 0)
		{
			spawnbit0_ = spawnbit0_ * 2;
			value = value - 1;
		}

		if (spawnbit0_ >= 16777216)
		{
			spawnbit1_ = spawnbit0_ / 16777216;
			spawnbit0_ = 0;
		}

		if (client.spawnbit0 & spawnbit0_)
			return TRUE;
		if (client.spawnbit1 & spawnbit1_)
			return TRUE;
		client.spawnbit0 = client.spawnbit0 | spawnbit0_;
		client.spawnbit1 = client.spawnbit1 | spawnbit1_;
		client.number_spawnbits = client.number_spawnbits + 1;
	}
	return FALSE;
};

/*
============
SpawnHardBot

============
*/
void() SpawnHardBot =
{
	do
	{
		rnd = random();
		rnd = floor(rnd * NUMBERHARDBOTS);
	} while (BeenSpawned(other, rnd + other.number_bots));

	if (rnd == 0) HCFrogbot(45, 1);
	else if (rnd == 1) HCFrogbot(59, 2);
	else if (rnd == 2) HCFrogbot(19, 3);
	else if (rnd == 3) HCFrogbot(196, 4);
	else if (rnd == 4) HCFrogbot(33, 5);
	else if (rnd == 5) HCFrogbot(203, 6);
	else if (rnd == 6) HCFrogbot(43, 7);
	else if (rnd == 7) HCFrogbot(205, 8);
	else if (rnd == 8) HCFrogbot(60, 9);
	else if (rnd == 9) HCFrogbot(160, 10);
	else if (rnd == 10) HCFrogbot(168, 11);
	else if (rnd == 11) HCFrogbot(212, 12);
	else if (rnd == 12) HCFrogbot(70, 13);
	else if (rnd == 13) HCFrogbot(4, 14);
	else if (rnd == 14) HCFrogbot(75, 15);
	else HCFrogbot(13, 16);
};

/*
============
PersistInfoString

Ensures a string obtained from infokey will not
randomly change as its buffer is being recycled.
============
*/
string(string key, string s_global, string s_default) PersistInfoString =
{
	if (! str_func_avail)
		return s_default;
	local string s;
	s = infokey(world, key);
	if (s == "")
		return s_default;
	if (s_global != "")
		strunzone(s_global);
	s_global = strzone(s);
	return s_global;
}

string() SetNetName =
{
	if (self.botnumber == 1)
		return PersistInfoString ("frobo_name1", frobo_name1, "�a�");
	else if (self.botnumber == 2)
		return PersistInfoString ("frobo_name2", frobo_name2, "Bro");
	else if (self.botnumber == 3)
		return PersistInfoString ("frobo_name3", frobo_name3, "f�Aǅg�d");
	else if (self.botnumber == 4)
		return PersistInfoString ("frobo_name4", frobo_name4, "�����");
	else if (self.botnumber == 5)
		return PersistInfoString ("frobo_name5", frobo_name5, "�hres�");
	else if (self.botnumber == 6)
		return PersistInfoString ("frobo_name6", frobo_name6, "������boy");
	else if (self.botnumber == 7)
		return PersistInfoString ("frobo_name7", frobo_name7, "���tile");
	else if (self.botnumber == 8)
		return PersistInfoString ("frobo_name8", frobo_name8, "������̅f�lU�e");
	else if (self.botnumber == 9)
		return PersistInfoString ("frobo_name9", frobo_name9, "����");
	else if (self.botnumber == 10)
		return PersistInfoString ("frobo_name10", frobo_name10, "dude");
	else if (self.botnumber == 11)
		return PersistInfoString ("frobo_name11", frobo_name11, "di��y");
	else if (self.botnumber == 12)
		return PersistInfoString ("frobo_name12", frobo_name12, "S�������");
	else if (self.botnumber == 13)
		return PersistInfoString ("frobo_name13", frobo_name13, "girlie");
	else if (self.botnumber == 14)
		return PersistInfoString ("frobo_name14", frobo_name14, "�C�P�ŅG�N�");
	else if (self.botnumber == 15)
		return PersistInfoString ("frobo_name15", frobo_name15, "������ǅ�������");
	else return PersistInfoString ("frobo_name16", frobo_name16, "a�d�c�e������");
};

/*
============
SpawnBot

============
*/
float() SpawnBot =
{
	do
	{
		if (self.number_spawnbits >= self.number_bots)
			return FALSE;
		rnd = random();
		rnd = floor(rnd * self.number_bots);
	} while (BeenSpawned(self, rnd));

	msg_entity = self;
	stuffcmd("bot");
	stuffcmd_ftos(rnd + 1);
	stuffcmd("\n");

	return TRUE;
};

/*
============
AddRandomBot

============
*/
float() AddRandomBot =
{
	if (self.number_bots < 0)
	{
		if (self.number_bots == -1)
			self.number_bots = 0 - time;
		else if (self.number_bots != (0 - time))
			self.number_bots = 0;
		if (self.number_bots)
		{
			msg_entity = self;
			stuffcmd("wait;addbot\n");
			return TRUE;
		}
	}
	return (SpawnBot());
};

/*
============
AddBot

Note: color = (shirt_color * 16) + pants_color
	team = pants_color + 1
	colors: 0 to 13
============
*/
void() AddBot =
{
	local float t1, t2, color;
	if (self.player)
	{
		if (frogbot_loading)
			return;
		if (map_lacks_waypoints)
		{
			InvalidMap();
			impulse_ = 0;
			return;
		}
	}
	if (paths_computed)
	{
#ifdef QUAKE
		local float cv_maxplay;
		cv_maxplay = cvar("maxplayers");
		if (cv_maxplay < 2)	//user forgot to put it up
			cv_maxplay = 16;
		if ((numberofclients >= cv_maxplay) || (numberofbots >= 12))
#else
		if ((numberofclients >= stof(infokey(world, "maxclients"))) || (numberofbots == 16))
#endif
		{
			sprint_fb(self, 2, "Server is full.\n");
		}
		else
		{
			if (!self.botnumber)
			{
				if (AddRandomBot())
					return;
			}
			else if (BotExists())
			{
				CopyBot(self, world);	// NULL
				if (AddRandomBot())
					return;
			}
			other = self;
			numberofbots = numberofbots + 1;
			localcmd("localinfo scratch2 ");
			localcmd_ftos(numberofbots);
			localcmd("\n");
			self = frogbot_spawned = EntityAt(first_frogbot, maxplayers - numberofbots);
			self.flags = 0;
			self.frogbot = TRUE;
			self.classname = "frogbot";
			self.stringname = "gamer";
		#ifdef QUAKE
			self_aiment = self.aiment = EntityAt(world, self.colormap);
			self_aiment.colormap = self.colormap;
			self_aiment.flags = 0;
			self_aiment.player = TRUE;
			self_aiment.movetype = 0;
			if (game_skins)
				self_aiment.skin = other.spawn_skin;
			else
				self_aiment.skin = 0;
		#endif
			self.waterlevel = 0;
			self.watertype = 0;
			self.frags = 0;
			self.deadflag = 0;
			self.arrow = 0;
			self.button0_ = 0;
			self.jump_flag = 0;
			self.effects = 0;
			self.color_ = other.color_;
			self.teamcolor = other.teamcolor;
		#ifdef ARENA
			if (game_arena)
				other.teamcolor = 0;
			self.bot_skill = skill;
		#else
			self.bot_skill = other.bot_skill;
		#endif
			CopyBot(self, other);
			CopyBot(other, world);	// NULL
			scoreboardsize = scoreboardsize + 1;
			if (!self.botnumber)
			{
				do
				{
					SpawnHardBot();
				} while (BotExists());
			}
			if (other.player)
				SaveFrogbot();
			if (teamplay && !game_disable_autosteams)
			{
				t1 = 0;
				t2 = 0;
				search_entity = first_client;
				while(search_entity)
				{
					if (search_entity != self)
					{
						if (search_entity.realteam == TEAM_COLOR1)
							t1 = t1 + 1;
						else if (search_entity.realteam == TEAM_COLOR2)
							t2 = t2 + 1;
					}
					search_entity = search_entity.next;
				}
				if ((t1 < t2) || ((t1 == t2) && (random() < 0.5)))
					color = TEAM_COLOR1;
				else
					color = TEAM_COLOR2;
				self.teamcolor = (color - 1) * 17;
				self.color_ = self.teamcolor;
				self.team = color;
			}
			else
			{
				if (teamplay)
					self.color_ = self.teamcolor;
				self.team = (self.color_ & 15) + 1;
			}
			UpdateFrags(self);
			self.netname = SetNetName();
			SetColorName(MSG_ALL, self);
			ClientConnect_apply();
			SetAttribs();
			PutClientInServer();
#ifdef TALK
			self.old_bot = other.old_bot;
			if (!game_disable_botchat && !self.old_bot)
				say_hello(self);
#endif
			self.oldorigin = self.origin;
			if (!game_not_match && !game_arena)
			{
				self.ready = 0;
				PlayerReady();
			}
			self = other;
		}
	}
};

/*
============
AddBots

============
*/
void() AddBots =
{
	min_second = maxplayers - scoreboardsize + 1;
	if (impulse_ > min_second)
		impulse_ = min_second;

	while (impulse_ > 0)
	{
		impulse_ = impulse_ - 1;
		AddBot();
	}
};

/*
============
ClearSpawnBits

============
*/
void() ClearSpawnBits =
{
	test_enemy = find(world, classname, "player");
	while (test_enemy)
	{
		test_enemy.spawnbit0 = test_enemy.spawnbit1 = test_enemy.number_spawnbits = 0;
		test_enemy = find(test_enemy, classname, "player");
	}
};

/*
============
RemoveBot

============
*/
float(float remove_name) RemoveBot =
{
	if (numberofbots)
	{
		if (frogbot_loading)
			return 0;
		if (time >= frogbot_removetime)
		{
			frogbot_removetime = time + 0.1;

			ClearSpawnBits();

			removebot_self = self;
			self = frogbot_spawned;

			scoreboardsize = scoreboardsize - 1;

			if (self.client_)
				ClientDisconnect();
			self.nextthink = 0;

			self.netname = "";

			if (remove_name)
				ClearName(MSG_ALL, self);

			localsave(numberofbots, 1, 1);
			numberofbots = numberofbots - 1;
			localcmd("localinfo scratch2 ");
			localcmd_ftos(numberofbots);
			localcmd("\n");
			frogbot_spawned = nextent(frogbot_spawned);

			self = removebot_self;
		}
	}
	return numberofbots;
};

void() AutoRemoveBot =
{
	if (RemoveBot(TRUE))
		self.nextthink = time + 0.1;
	else
		remove_self();
};

void() RemoveAllBots =
{
	test_enemy = spawn();
	test_enemy.think = AutoRemoveBot;
	test_enemy.nextthink = 0.001;
};

#ifdef QUAKE
/*
============
BecomeBot

============
*/
void() BecomeBot =
{
	if (map_lacks_waypoints)
	{
		InvalidMap();
	}
	else
	{
		if (paths_computed)
		{
			if (game_show_rules)
			{
				bprint_fb(2, self.netname);
				bprint_fb(2, " has become a frogbot\n");
			}
			else
			{
				if (!self.client_)
				{
					bprint_fb(2, self.netname);
					bprint_fb(2, " is playing\n");
				}
			}

			if (!self.client_)
				PrepareToClient();

			self.frogbot = TRUE;

			SetAttribs();

			if (self.deadflag == DEAD_NO)
			{
				if (self.v_angle_x < 0)
					self.angles_x = self.v_angle_x - 2.8125;	// crosshair
				else
					self.angles_x = self.v_angle_x;
				self.angles_z = 0;

				self.real_pitch = self.angles_x;
				self.real_yaw = self.angles_y;

				self.state = 0;
			}
			#ifdef ARENA
				self.oldangles = self.angles;
			#endif
		}
	}
};

/*
============
BecomePlayer

============
*/
void() BecomePlayer =
{
	if (self.netname != "")
	{
		if ((game_show_rules) || (!self.client_))
		{
			bprint_fb(2, self.netname);
			bprint_fb(2, " is playing\n");
		}

		if (self.client_)
			self.frogbot = FALSE;
		else
			PrepareToClient();

		self.lookahead_time = 30;
		self.prediction_error = 0;

		self.arrow = 0;
		ClearLookObject(self);
		self.linked_marker = self.old_linked_marker = world;
		self.path_from_marker = world;
	}
};

/*
============
ToggleFrogbot

============
*/
void() ToggleFrogbot =
{
	if (self.frogbot)
		BecomePlayer();
	else
		BecomeBot();
};
#endif

/*
============
ToggleFlash

============
*/
void() ToggleFlash =
{
	if (self.preferences & PREF_FLASH)
	{
		sprint_fb(self, 2, "flashs off\n");
		self.preferences = self.preferences - PREF_FLASH;
	}
	else
	{
		sprint_fb(self, 2, "flashs on\n");
		self.preferences = self.preferences | PREF_FLASH;
	}
};

/*
============
ToggleFramerate

============
*/
void() ToggleFramerate =
{
	if (self.print_framerate)
		self.print_framerate = FALSE;
	else
		self.print_framerate = TRUE;
};

/*
============
ToggleGameMode

============
*/
void(float value, string s) ToggleGameMode =
{
	new_gamemode = cvar("samelevel");

	if (new_gamemode & value)
	{
		new_gamemode = new_gamemode - value;
		bprint_fb(2, s);
		bprint_fb(2, " disabled after restart\n");
	}
	else
	{
		new_gamemode = new_gamemode | value;
		bprint_fb(2, s);
		bprint_fb(2, " enabled after restart\n");
	}

	cvar_set_("samelevel", new_gamemode);
};

/*
============
ToggleGameModeNow

============
*/
void(float value, string s) ToggleGameModeNow =
{
	new_gamemode = cvar("samelevel");

	if (gamemode & value)
	{
		gamemode = gamemode - value;
		new_gamemode = new_gamemode - (new_gamemode & value);
		bprint_fb(2, s);
		bprint_fb(2, " disabled\n");
	}
	else
	{
		gamemode = gamemode | value;
		new_gamemode = new_gamemode | value;
		bprint_fb(2, s);
		bprint_fb(2, " enabled\n");
	}

	cvar_set_("samelevel", new_gamemode);
	SetGame();
};

/*
============
print_boolean

============
*/
void(float value, string s) print_boolean =
{
	sprint_fb(self, 2, s);
	if (gamemode & value)
		sprint_fb(self, 2, "enabled\n");
	else
		sprint_fb(self, 2, "disabled\n");
};

/*
============
PrintRules

============
*/

void() PrintRules =
{
	sprint_fb(self, 2, "�����....... ");
	sprint_ftos(self, 2, skill);
	sprint_fb(self, 2, "\n����������.. ");
	sprint_ftos(self, 2, deathmatch);
	sprint_fb(self, 2, "\n��������.... ");
	sprint_ftos(self, 2, teamplay);
	sprint_fb(self, 2, "\n");
#ifdef ARENA
	a_rulesfix();
#endif
	print_boolean(GAME_ENABLE_POWERUPS, "��������.... ");
	print_boolean(GAME_ENABLE_RUNES, "����........ ");
	print_boolean(GAME_RUNE_RJ, "�������..... ");
	print_boolean(GAME_MATCH, "�����....... ");
	print_boolean(GAME_LAVA_CHEAT, "���������... ");
	print_boolean(GAME_RL_PREF, "�������..... ");
	print_boolean(GAME_LG_PREF, "�������..... ");
	print_boolean(GAME_HIDE_RULES, "����........ ");
	print_boolean(GAME_ENABLE_AUTOREPORT, "����������.. ");
	print_boolean(GAME_ENABLE_DROPWEAP, "��������.... ");
	print_boolean(GAME_ENABLE_AUTOSTEAMS, "����������.. ");
	print_boolean(GAME_ENABLE_BOTCHAT, "�������..... ");
#ifdef ARENA
	a_boolean();
#endif
#ifdef QUAKE
	print_boolean(GAME_NOSKINS, "�������..... ");
	print_boolean(GAME_QWPHYSICS, "���������... ");
	print_boolean(GAME_QWAIM, "�����....... ");
#endif
	sprint_fb(self, 2, "\n");

	if (sv_accelerate != 10)
	{
		sprint_fb(self, 2, "sv_accelerate is ");
		sprint_ftos(self, 2, sv_accelerate);
		sprint_fb(self, 2, "\n");
	}
	if (sv_friction != 4)
	{
		sprint_fb(self, 2, "sv_friction is ");
		sprint_ftos(self, 2, sv_friction);
		sprint_fb(self, 2, "\n");
	}
#ifdef QUAKE
	if (host_framerate)
	{
	#ifdef ARENA
		sprint_fb(self, 2, "\"host_framerate\" is \"");
		sprint_ftos(self, 2, host_framerate);
		sprint_fb(self, 2, "\"\n");
	#else
		sprint_fb(self, 2, "host_framerate is ");
		sprint_ftos(self, 2, host_framerate * 1000000);
		sprint_fb(self, 2, "/1000000\n");
	#endif
	}
#endif
};

/*
============
PrintFramerate

============
*/
void() PrintFramerate =
{
	sprint_ftos(self, 2, 1/frametime);
	sprint_fb(self, 2, " ");
	sprint_ftos(self, 2, 1/average_frametime);
	sprint_fb(self, 2, " ");
	sprint_ftos(self, 2, (framecount - framecount_start) / (time - time_start));
	sprint_fb(self, 2, "\n");
};

/*
============
PrintTime

============
*/
void() PrintTime =
{
	if (pre_game) return;
	time_to_print = time - start_time;
	sprint_fb(self, 2, "����: ");
	minutes = floor (time_to_print / 60);
	if (minutes < 10)
		sprint_fb(self, 2, " ");	// add extra space in minutes
	sprint_g(self, 2, minutes); // minutes
	sprint_fb(self, 2, "�");
	seconds = floor (time_to_print - (minutes * 60));
	if (seconds < 10)
		sprint_fb(self, 2, "�");	// add extra 0 in seconds
	sprint_g(self, 2, seconds); // seconds
	sprint_fb(self, 2, "\n");
};

/*
============
SetSkin

============
*/
#ifdef QUAKE
void() SetSkin =
{
	if (game_skins)
		self.skin = self.spawn_skin;
};
#endif

/*
============
AddBotError

============
*/
void() AddBotError =
{
	sprint_fb(self, 2, "There is no support of external bots!\n");
	self.spawnflags = self.impulse = self.lines = 0;
	self.input_time = time + 2;
	self.spawnbit0 = self.spawnbit1 = self.number_spawnbits = 0;
	CopyBot(self, world);	// NULL
};

/*
============
NoAdmin

============
*/
void() NoAdmin =
{
	sprint_fb(self, 2, "You don't have admin privileges\n");
};

#ifdef NOCLIP
// toggle noclip mode for editing; should not be in production builds
void() togglenoclip =
{
	msg_entity = self;
	if (self.movetype == MOVETYPE_NOCLIP)
	{
		self.movetype = MOVETYPE_WALK;
		sprint_fb(self, 2, "Noclip OFF\n");
	}
	else
	{
		self.movetype = MOVETYPE_NOCLIP;
		sprint_fb(self, 2, "Noclip ON\n");
	}
};
#endif

void(string s, float val) alias =
{
	stuffcmd("alias ");
	stuffcmd(s);
	stuffcmd(" impulse ");
	stuffcmd_ftos(val);
	stuffcmd("\n");
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (! self.impulse)	return;

	if (intermission_running || k_standby) return;

	if (time < self.input_time)
	{
		self.impulse = 0;
		self.input_time = time + 2;
		return;
	}

	impulse_ = self.impulse;

#ifndef QUAKE
	if (impulse_ == IMP_JOIN)
		join();
	else if (impulse_ == IMP_OBSERVE)
		observe();
#endif

	if (!self.client_ && numberofplayers > 0) return;

	if (self.lines)
	{
		self.lines = self.lines - 1;
		if (self.lines < 2)
		{
			AddBotError();
			return;
		}
	}

	if (self.spawnflags)
	{
		self.impulse = 0;
		ScratchCommands();
	}
	else if (impulse_ < IMP_START1)
	{
		if (self.lines)
			AddBotError();
	}
	else
	{
		self.impulse = 0;

		if (impulse_ > IMP_END4)
		{
			if (self.lines)
				AddBotError();

			if (impulse_ == 140)
				f_jump();
			else if (impulse_ == 141)
				r_jump();
		#ifdef MANUAL
			else if (impulse_ == 131)
				ToggleManualMode();
			else if (manual_mode)
				ManualImpulseCommands();
		#endif
		}
		else if (impulse_ <= IMP_END2)
		{
			if (impulse_ <= IMP_END1)
				self.spawnflags = impulse_ - IMP_START1 + START_SKILL;
			else
			{
				if (self.lines)
				{
					if (self.lines != 2)
					{
						AddBotError();
						return;
					}
					self.lines = 0;
				}
				if (impulse_ == IMP_LINES)
					self.spawnflags = START_LINES;
				else if (self.admin_code != dropper.admin_code)
					NoAdmin();
				else if (impulse_ <= IMP_ADD4BOTS)
				{
					impulse_ = impulse_ - IMP_ADDBOT + 1;
					AddBots();
				}
				else
				{
					self.teamcolor = (impulse_ - IMP_ADDBOT0) * 17;
					AddBot();
				}
			}
		}
		else if (self.lines)
			AddBotError();
	#ifdef NOCLIP
		else if (impulse_ == IMP_NOCLIP)
			togglenoclip();
	#endif
		else if (impulse_ == IMP_MSG)
			self.spawnflags = START_MSG;
		else if (impulse_ == IMP_BOTS)
			self.spawnflags = START_BOTS;
		else if (impulse_ == IMP_ADMIN)
			self.spawnflags = START_ADMIN1;
		else if (impulse_ == IMP_TIME)
			PrintTime();
		else if (impulse_ == IMP_RULES)
			PrintRules();
		else if (impulse_ == IMP_FLASH)
			ToggleFlash();
		else if (self.admin_code != dropper.admin_code)
			NoAdmin();
		else if (impulse_ == IMP_HIDE)
			ToggleGameModeNow(GAME_HIDE_RULES, "hide");
		else if (impulse_ == IMP_REMOVEBOT)
			RemoveBot(TRUE);
		else if (impulse_ == IMP_REMOVEALLBOTS)
			RemoveAllBots();
		else if (impulse_ == IMP_LAVACHEAT)
			ToggleGameModeNow(GAME_LAVA_CHEAT, "lavacheat");
		else if (impulse_ == IMP_FRAMERATE)
			ToggleFramerate();
		else if (impulse_ == IMP_POWERUP)
			ToggleGameMode(GAME_ENABLE_POWERUPS, "powerups");
		else if (impulse_ == IMP_AUTOREPORT)
			ToggleGameModeNow(GAME_ENABLE_AUTOREPORT, "autoreport");
		else if (impulse_ == IMP_DROPWEAP)
			ToggleGameModeNow(GAME_ENABLE_DROPWEAP, "dropweap");
		else if (impulse_ == IMP_AUTOSTEAMS)
			ToggleGameModeNow(GAME_ENABLE_AUTOSTEAMS, "autosteams");
		else if (impulse_ == IMP_RUNE)
			ToggleGameMode(GAME_ENABLE_RUNES, "rune");
		else if (impulse_ == IMP_READY)
			PlayerReady();
		else if (impulse_ == IMP_WHO)
			PlayerStatus();
		else if (impulse_ == IMP_SKILLDOWN)
			SkillDown();
		else if (impulse_ == IMP_SKILLUP)
			SkillUp();
	#ifdef QUAKE
		else if (impulse_ == IMP_TOGGLEFROG)
			ToggleFrogbot();
	#endif
	// TODO: move all impulses not specific to ARENA outside this ifdef, and make aliases work
	#ifdef ARENA
		else if (impulse_ == IMP_ABOUT)
			SprintVersion();
		else if (impulse_ == IMP_SCORES)
			PrintScores();
		else if (impulse_ == IMP_BREAK)
			PlayerBreak();
		else if (impulse_ == IMP_TIMEDOWN)
			TimeDown();
		else if (impulse_ == IMP_TIMEUP)
			TimeUp();
		else if (impulse_ == IMP_FRAGSDOWN)
			FragsDown();
		else if (impulse_ == IMP_FRAGSUP)
			FragsUp();
		else if (impulse_ == IMP_CHDM)
			ChangeDM();
		else if (impulse_ == IMP_NO_LG)
			ToggleLighting();
		else if (impulse_ == IMP_SH_SPEED)
			toggle_sh_speed();
		else if (impulse_ == IMP_WS_ON)
			start_print_wp_stats();
		else if (impulse_ == IMP_WS_OFF)
			end_print_wp_stats();
		else if (impulse_ == IMP_WS_RES)
			reset_wp_stats();
		else if (impulse_ == IMP_CHTP)
			ChangeTP();
		else if (impulse_ == IMP_LOCK)
			ChangeLock();
		else if (impulse_ == IMP_SILENCE)
			ToggleSpecTalk();
		else if (impulse_ == IMP_MATCH)
			ToggleGameMode(GAME_MATCH, "match");
		else if (impulse_ == IMP_OVERTIME)
			ChangeOvertime();
#ifdef TALK
		else if (impulse_ == IMP_BOTCHAT)
			ToggleGameModeNow(GAME_ENABLE_BOTCHAT, "botchat");
#endif
		else if (impulse_ == IMP_RL_PREF)
		{
			if (game_lg_pref)
				ToggleGameModeNow(GAME_LG_PREF, "lg_pref");
			ToggleGameModeNow(GAME_RL_PREF, "rl_pref");
		}
		else if (impulse_ == IMP_LG_PREF)
		{
			if (game_rl_pref)
				ToggleGameModeNow(GAME_RL_PREF, "rl_pref");
			ToggleGameModeNow(GAME_LG_PREF, "lg_pref");
		}
		else if (impulse_ == IMP_RUNE_RJ)
			ToggleGameModeNow(GAME_RUNE_RJ, "rune_rj");
		a_impulses();
	#endif
	}
};
