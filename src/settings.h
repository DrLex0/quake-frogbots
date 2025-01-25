#ifndef SETTINGS_H

#define SETTINGS_H

#ifndef WAYPOINT_BUILD
	// The regular Frogbot runtime build for QuakeWorld.
	#define TALK
	#define ARENA // Asdf
	//#define NOCLIP // not supposed to be used for production

	// A classic Quake build is actually possible, but some things need fixing
	#ifdef QUAKE
	#pragma PROGS_DAT ../progs.dat
	#endif

#else
	// The waypoint editor, run in regular Quake engine
	#define MANUAL
	#define NOCLIP
	#define QUAKE
#endif

#endif
