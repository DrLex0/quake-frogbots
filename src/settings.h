#ifndef SETTINGS_H
#define SETTINGS_H

// From Trinca's source, obsolete?
//#ifdef FTEQCC
//#pragma warning disable Q201
//#define varkeyword var
//#else
//#define varkeyword
//#endif

#ifndef WAYPOINT_BUILD
	// The regular runtime build, QuakeWorld.
	// A Quake runtime might be possible, but untested
	#define TALK
	#define NOCLIP // not supposed to be used for production
	#define ARENA // Asdf
#else
	// The waypoint editor, run in regular Quake engine
	#define MANUAL
	#define NOCLIP
	#define QUAKE
	#define ARENA  // unclear, we shouldn't need this
#endif


#ifdef QUAKE
#pragma PROGS_DAT ../progs.dat
#endif

#endif
