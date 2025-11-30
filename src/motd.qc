/*
	motd.qc

	Copyright (C) 2000-2007 ParboiL
	Changes by DrLex 2024-2025
*/

#include "settings.h"

#ifndef MANUAL
void() PrintMOTD =
{
	local string s1, s2;
	s1 = infokey(world, "k_motd1");
	s2 = infokey(world, "k_motd2");
	if (s1 == "") s1 = string_null;
	if (s2 == "") s2 = string_null;
	if (self.attack_finished < time || k_shutdown) {
		remove(self);
		k_shutdown = 0;
		return;
	}
	if (self.attack_finished > time + 6) centerprint5(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n");
	else centerprint5(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n\nRunning Ζςοηβοτ φ”β“ by ΔςΜεψ\n\nwith Ζβγα “®’“λτ final by ΠαςboiL\nbased on Λονβατ Τεανσ ”®”“\n");
	// Running Frogbot v2b1 by DrLex\n\nwith Fbca 1.01kt final by ParboiL\nbased on Kombat Teams 2.21
	self.nextthink = time + 0.7;
};
#else
void() PrintMOTD =
{
	if (self.attack_finished < time) {
		remove(self);
		return;
	}
	centerprint(self.owner, "Frogbot Waypoint Tool φ”β“\nEnable ναξυαμ νοδε to start editing\n\n\n");
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

void() CheckBadEnts =
{
	if (bad_ent_detected)
	{
		dprint ("\nΕÒÒΟÒΊ a custom .ent file appears to be loaded. Trying to spawn a Frogbot, will almost certainly crash the game. Remove the .ent file and reload the map again before trying to add a bot.\n");
		sprint_fb(self, 2, "\nΕÒÒΟÒΊ a custom .ent file appears to be loaded. Trying to spawn a Frogbot, will almost certainly crash the game. Remove the .ent file and reload the map again before trying to add a bot.\n");
	}
}

#ifdef ARENA
void() AliasesTime =
{
	self.alias1time = time + 1;
	self.alias2time = time + 2;
	self.alias3time = time + 3;
};

void() StuffAliases =
{
	if (self.alias1time)
	if (time >= self.alias1time)
	{
		self.alias1time = 0;
		aliases1();
	}
	if (self.alias2time)
	if (time >= self.alias2time)
	{
		self.alias2time = 0;
		aliases2();
	}
	if (self.alias3time)
	if (time >= self.alias3time)
	{
		self.alias3time = 0;
		self.k_stuff = 1;
		aliases3();
		sprint_fb(self, 2, "Commands downloaded\n");
		CheckBadEnts();
	}
};
#endif
