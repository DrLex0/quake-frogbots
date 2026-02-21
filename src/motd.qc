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
	if (self.attack_finished > time + 6) centerprint5(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n");
	// Running Frogbot vVERS by DrLex\n\nbased on Fbca 1.01kt final by ParboiL\nbased on Kombat Teams 2.21
	else centerprint(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n\nRunning Ζςοηβοτ φ", FROGBOT_VERSION_FANCY, " by ΔςΜεψ\n\nbased on Ζβγα “®’“λτ final by ΠαςboiL\nbased on Λονβατ Τεανσ ”®”“\n");
	self.nextthink = time + 0.7;
};
#else
void() PrintMOTD =
{
	if (self.attack_finished < time) {
		remove(self);
		return;
	}
	// Frogbot Waypoint Tool vVERS\nEnable manual mode to start editing
	centerprint(self.owner, "Frogbot Waypoint Tool φ", FROGBOT_VERSION_FANCY, "\nEnable ναξυαμ νοδε to start editing\n\n\n");
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
	motd.attack_finished = time + 7;
};
