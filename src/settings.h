#ifndef SETTINGS_H

#define SETTINGS_H

#ifndef WAYPOINT_BUILD
	// Frogbot runtime build for QuakeWorld.
	#define TALK
	#define ARENA // Asdf
	//#define NOCLIP // not supposed to be used for production

	// NetQuake build
	#ifdef QUAKE
	// Should not be needed; uncomment otherwise
	//#pragma PROGS_DAT ../Release/quake/progs.dat
    #define YOU_FRAGGED
	#endif

#else
	// The waypoint editor, run in regular Quake engine
	#define MANUAL
	#define NOCLIP
	#define QUAKE
#endif

#endif
