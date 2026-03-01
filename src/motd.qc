/*
	motd.qc

	Copyright (C) 2000-2007 ParboiL
	Changes by DrLex 2024-2026
*/

#include "settings.h"

#ifndef MANUAL
void() PrintMOTD =
{
	local string s1, s2;
	if (self.attack_finished < time || k_shutdown) {
		self.owner.k_motd_seen = TRUE;
		remove(self);
		k_shutdown = 0;
		return;
	}
#ifdef QUAKE
	s1 = "Quake Frogbot Server";
	s2 = "Type /addbot to add a bot";
#else
	s1 = infokey(world, "k_motd1");
	s2 = infokey(world, "k_motd2");
	if (s1 == "") s1 = string_null;
	if (s2 == "") s2 = string_null;
#endif
	if (self.attack_finished > time + 6)
		centerprint5(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n\(\=\=\=\=\=\)\n");
	else
		centerprint(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n\(\=\=\=\=\=\)\n\nRunning \sFrogbot v", FROGBOT_VERSION_FANCY, " by \sDrLex\s\n\nbased on \sFbca \1.\0\1kt\s final by \sPar\sboiL\nbased on \sKombat Teams \2.\2\1\n");
	self.nextthink = time + 0.7;
};
#else
void() PrintMOTD =
{
	if (self.attack_finished < time) {
		remove(self);
		return;
	}
	centerprint(self.owner, "Frogbot Waypoint Tool \sv", FROGBOT_VERSION_FANCY, "\nEnable \smanual mode\s to start editing\n\n\n");
	self.nextthink = time + 0.7;
};
#endif

void() MakeMOTD =
{
	local entity motd;
	motd = spawn();
	motd.classname = "motd";
	motd.owner = self;
	motd.think = PrintMOTD;
	motd.nextthink = time + 0.5;
	if (self.k_motd_seen)
		motd.attack_finished = time + 2;
	else
		motd.attack_finished = time + 7;
};
