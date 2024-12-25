/*
	names.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

#include "settings.h"

void() SetSkill;
void(float frogbot_pos, float index_, float value) localsave;

/*
============
CopyBot

============
*/
void(entity e, entity f) CopyBot =
{
	e.botnumber = f.botnumber;
};

/*
===============
ScratchCommands

===============
*/
void() ScratchCommands =
{
	spawnflags_ = self.spawnflags;

	if (impulse_ == 255)
		impulse_ = 0;

	if (spawnflags_ == START_ADMIN1)
	{
		self.admin_code = impulse_;
		self.spawnflags = START_ADMIN2;
	}
	else if (spawnflags_ == START_ADMIN2)
	{
		self.admin_code = self.admin_code + impulse_ * 256;
		self.spawnflags = START_ADMIN3;
	}
	else
	{
		self.spawnflags = 0;

		if (spawnflags_ == START_ADMIN3)
		{
			self.admin_code = self.admin_code + impulse_ * 65536;
			if (self == first_ent)
			{
				localsave(0, 0, self.admin_code);
				dropper.admin_code = self.admin_code;
				if (self.admin_code)
					bprint_fb(2, "admin set by ");
				else
					bprint_fb(2, "admin cleared by ");
				bprint_fb(2, self.netname);
				bprint_fb(2, "\n");
			}
		}
		else if (spawnflags_ == START_TEAMPLAY)
		{
			if (impulse_ <= MAX_TEAMPLAY)
				cvar_set_("teamplay", impulse_);
		}
		else if (spawnflags_ == START_DEATHMATCH)
		{
			if (impulse_ && impulse_ <= MAX_DEATHMATCH)
			{
				cvar_set_("deathmatch", impulse_);
			#ifndef ARENA
				bprint_fb(2, "\"deathmatch\" changed to \"");
				bprint_ftos(2, impulse_);
				bprint_fb(2, "\" next level\n");
			#endif
			}
		}
		else if (spawnflags_ == START_TIMELIMIT)
			cvar_set_("timelimit", impulse_);
		else if (spawnflags_ == START_FRAGLIMIT)
			cvar_set_("fraglimit", impulse_);
		else if (spawnflags_ == START_SKILL)
		{
		#ifdef ARENA
			if (impulse_ <= MAX_SKILL * 10)
			{
				a_skillfix();
				self.bot_skill = impulse_;
				skill = impulse_;
				SetSkill();
			}
		#else
			if (impulse_ <= MAX_SKILL)
			{
				self.bot_skill = impulse_;
				if (self == first_ent)
					skill = impulse_;
				SetSkill();
			}
		#endif
		}
	#ifdef QUAKE
		else if (spawnflags_ == START_SKIN)
			self.spawn_skin = impulse_;
	#endif
		else if (spawnflags_ == START_BOTS)
			self.number_bots = impulse_;
		else if (spawnflags_ == START_LINES)
			self.lines = impulse_;
		else if (spawnflags_ == START_MSG)
		{
		#ifdef QUAKE
			self.msg_level_ = impulse_;
		#else
			msg_entity = self;
			stuffcmd("msg ");
			stuffcmd_ftos(impulse_);
			stuffcmd("\n");
		#endif
		}
		else
		{
			if (impulse_ == 14)
			{
				impulse_ = random();
				impulse_ = floor(impulse_ * 14);
			}
			if (impulse_ <= 13)
			{
				if (spawnflags_ == START_SHIRT)
					self.color_ = impulse_ * 16 + (self.color_ & 15);
				else if (spawnflags_ == START_PANTS)
					self.color_ = (self.color_ & 240) + impulse_;
				else if (spawnflags_ == START_TEAMSHIRT)
					self.teamcolor = impulse_ * 16 + (self.teamcolor & 15);
				else if (spawnflags_ == START_TEAMPANTS)
					self.teamcolor = (self.teamcolor & 240) + impulse_;
			}
		}
	}
};
