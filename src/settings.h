#ifndef SETTINGS_H

#define SETTINGS_H

#ifndef WAYPOINT_BUILD
	// The regular Frogbot runtime build for QuakeWorld.
	// A Quake runtime might be possible, but will require some fixes.
	#define TALK
	#define ARENA // Asdf
	//#define NOCLIP // not supposed to be used for production
#else
	// The waypoint editor, run in regular Quake engine
	#define MANUAL
	#define NOCLIP
	#define QUAKE
#endif


#ifdef QUAKE
#pragma PROGS_DAT ../progs.dat
#endif

#endif
