/*
	lists.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
	Improvements by DrLex 2026
*/

#include "settings.h"

void() thud_touch;
void() FrogbotPrePhysics2;
void() FrogbotPostPhysics;
void() adjust_view_ofs_z;
void() LoadMap;

/* The .next/.previous doubly linked lists below (first_client, first_takedamage)
 * are deliberately joined into one chain; see UpdateRadiusDamage for the details.
 * A consequence is that the head of first_client normally has a .previous that is
 * NOT a client, and that the two Add/Remove functions here must keep that join
 * point stitched. Do not "clean up" the .previous handling without reading
 * UpdateRadiusDamage first.
 * Anything that is not one of these 2 lists must use its own link field. */

entity(entity first_in_list) AddToList =
{
	// self.previous / first_in_list.previous.next carry the join with the
	// takedamage segment when this is the client list: inserting a new head
	// automatically repoints the takedamage tail at it.
	self.next = first_in_list;
	self.previous = first_in_list.previous;
	if (first_in_list)
	{
		if (first_in_list.previous)
			first_in_list.previous.next = self;
		first_in_list.previous = self;
	}
	return self;
};

entity(entity first_in_list) RemoveFromList =
{
	// Likewise, self.previous.next repoints the takedamage tail when the head of
	// the client list leaves, or terminates the chain when the last client leaves.
	if (first_in_list == self)
		first_in_list = first_in_list.next;
	if (self.previous)
		self.previous.next = self.next;
	if (self.next)
		self.next.previous = self.previous;
	// Clear only after the three fixups above have read them. Leaving stale links
	// behind means a removed entity keeps pointing into a list it is no longer
	// part of, which is how the 'removebot' limbo bug was able to reach a player.
	// Note this does terminate any walk whose cursor sits on the entity being
	// removed; no current caller removes from inside such a walk.
	self.next = self.previous = world;
	return first_in_list;
};

void() Add_takedamage =
{
	self.takedamage = DAMAGE_YES;
	first_takedamage = AddToList(first_takedamage);
	takedamage_exists = TRUE;
};

/*
============
UpdateRadiusDamage

first_takedamage is not a list of its own, it is a concatenation:
    [damageable map entities] ++ [all clients]
walked through .next by T_RadiusDamage and the bot discharge estimator, so that
clients never have to be inserted in a damage list one by one.

This function only has to create the join; AddToList/RemoveFromList keep it
stitched afterwards, because the client list head's .previous is the tail of the
takedamage segment.

Invariants this relies on -- break any of them and radius damage silently stops
hurting some or all clients:
 - Callers must invoke this BEFORE adjusting numberofclients. The test below is
   really "was the client list empty until now", i.e. does the join need to be
   (re)created. Add_client increments after calling us, RemoveFromAllLists
   decrements after calling us.
 - Nothing is ever removed from the takedamage segment. There is no
   Remove_takedamage, and takedamage_exists is never cleared.
 - The takedamage segment always precedes the client segment.
============
*/
void() UpdateRadiusDamage =
{
	if (takedamage_exists)
	{
		if (numberofclients)
			return;
		// Client list just became non-empty: (re)attach it behind the last
		// damageable map entity.
		test_enemy = first_takedamage;
		while (test_enemy.next)
			test_enemy = test_enemy.next;
		test_enemy.next = first_client;
		first_client.previous = test_enemy;
	}
	else
	{
		// No damageable map entities (yet): the chain is just the client list.
		// A later Add_takedamage prepends in front of it, which keeps the
		// segment order intact.
		first_takedamage = first_client;
	}
};

void() CheckTwoTeams =
{
	local entity client;

	first_team = second_team = 0;

	client = first_client;
	first_team = first_client.realteam;
	while (client)
	{
		new_team = client.realteam;
		if (new_team != first_team)
		{
			if (second_team)
			{
				if (new_team != second_team)
				{
					two_teams = FALSE;
					return;
				}
			}
			else
				second_team = new_team;
		}
		client = client.next;
	}

	if (second_team)
		two_teams = TRUE;
	else
		two_teams = FALSE;
};

void() Add_client =
{
	if (self.client_)
		return;

	self.client_ = TRUE;

	first_client = AddToList(first_client);
	UpdateRadiusDamage();
	numberofclients = numberofclients + 1;

	if (teamplay)
	{
		self.realteam = self.team;
		team_index = self.team - 1;
		self.teamflag = 1;
		while (team_index)
		{
			team_index = team_index - 1;
			self.teamflag = self.teamflag * 2;
		}
	}
	else
	{
		current_team = current_team + 1;
		self.realteam = current_team;
	}

	CheckTwoTeams();

	self.movetarget = world;	// clear shot rocket
	self.goalentity = self.enemy = world;
};

void() RemoveFromAllLists =
{
	if (self.client_)
	{
		self.client_ = FALSE;
		self.frogbot = FALSE;
		first_client = RemoveFromList(first_client);
		UpdateRadiusDamage();
		numberofclients = numberofclients - 1;
		CheckTwoTeams();
	}
};

/*
============
LinkedListAt

Gets the entity at index_ positions away from start_entity in a linked list,
where each item points to the next item through the .next property.
Will return world if index_ exceeds length of the list.
============
*/
entity(entity start_entity, float index_) LinkedListAt =
{
	while (index_ > 0)
	{
		start_entity = start_entity.next;
		if (! start_entity)
			return world;
		index_ = index_ - 1;
	}
	return start_entity;
};

/*
============
FrogbotAt

Gets the frogbot entity at index_ positions from the start of the frogbot list.
Walks .next_frogbot, which is exclusive to this list, so it stays valid no matter
which of these entities are currently in the game as bots.
Returns world if index_ exceeds the length of the list.
============
*/
entity(float index_) FrogbotAt =
{
	local entity bot_at;

	bot_at = first_frogbot;
	while (index_ > 0)
	{
		bot_at = bot_at.next_frogbot;
		if (! bot_at)
			return world;
		index_ = index_ - 1;
	}
	return bot_at;
};

/*
============
EntityAt

Gets the entity at index_ positions away from start_entity in nextent order.

DANGER: only usable for entities that have been created before any entities
were removed. After that, gaps will be created in the entity list that may
be filled with the latest spawned entities, breaking the chronological order.
Use linked lists and LinkedListAt for anything dynamic.
============
*/
entity(entity start_entity, float index_) EntityAt =
{
	while (index_ > 0)
	{
		start_entity = nextent(start_entity);
		index_ = index_ - 1;
	}
	return start_entity;
};

/*
============
InitFrogbots1

Create bot entities and physics think entities.
Now uses linked list for bots, instead of unreliable nextent().
============
*/
void() InitFrogbots1 =
{
	prephysics = spawn();
	prephysics.think = FrogbotPrePhysics2;

	frogbot_spawned = world;
	while (frogbot_number < maxplayers)
	{
		new_bot = spawn();
		new_bot.touch = thud_touch;

		if (!first_frogbot)
			first_frogbot = new_bot;
		// Link through .next_frogbot field; do NOT use .next/.previous here,
		// see info in defs.qc.
		if (frogbot_spawned)
			frogbot_spawned.next_frogbot = new_bot;
		new_bot.index = 1000 + frogbot_number;  // useful for debugging
		new_bot.score_pos = frogbot_number;
		frogbot_number = frogbot_number + 1;
		new_bot.colormap = frogbot_number;
		frogbot_spawned = new_bot;
	}
	frogbot_spawned = world;

	postphysics = spawn();
	postphysics.think = FrogbotPostPhysics;
};

/*
============
InitFrogbots2

Finalize entities and invoke waypoint loading
============
*/
void() InitFrogbots2 =
{
	// DrLex says: no idea why this is being done here; my best guess is
	// to free up entity slots, as it seems to remove "not needed" corners
	// (other part of this logic is in func_train_find)
	test_enemy = find(world, classname, "path_corner");
	while (test_enemy)
	{
		if (!test_enemy.admin_code)
			remove(test_enemy);
		test_enemy = find(test_enemy, classname, "path_corner");
	}

	total_entity_count = 1;
	self = world;
	while ((self = nextent(self)))
		total_entity_count = total_entity_count + 1;

	self = first_item;
	while (self)
	{
		self.movetype = MOVETYPE_NONE;
		self.origin_z = self.origin_z + 6;
		droptofloor();
		setsize(self, self.mins + '-49 -49 0', self.maxs + '49 49 0');
		adjust_view_ofs_z();
		self.virtual_mins = self.absmin + '32 32 -33';
		self.virtual_maxs = self.virtual_mins + '96 96 114';
		self = self.next;
	}

	SpawnRunes();

	LoadMap();	// dropper.think changed, no reference to absmin/view_ofs
};

/*
============
UpdateFrags

============
*/
void(entity e) UpdateFrags =
{
	if (fraglimit)
		if (e.frags >= fraglimit)
			NextLevel ();

	if (e.player)
		return;

	WriteByte(MSG_ALL, MSG_UPDATEFRAGS);
	WriteByte(MSG_ALL, e.score_pos);
	WriteShort(MSG_ALL, e.frags);
};

/*
============
ClearName

============
*/
void(float to, entity client) ClearName =
{
#ifdef QUAKE
	WriteByte(to, MSG_UPDATENAME);
	WriteByte(to, client.score_pos);
	WriteByte(to, 0);
#else
	WriteByte(to, SVC_UPDATEUSERINFO);		// update userinfo
	WriteByte(to, client.score_pos);		// client number
	WriteLong(to, 0);					// client userid
	WriteByte(to, 92); // \
	WriteByte(to, _n);
	WriteByte(to, _a);
	WriteByte(to, _m);
	WriteByte(to, _e);
	WriteByte(to, 92); // \
	WriteByte(to, 0);
#endif
};

/*
============
SetColorName QW // ParboiL

============
*/
#ifdef QUAKE
void(float to, entity client) SetColorName =
{
	WriteByte(to, MSG_UPDATECOLORS);
	WriteByte(to, client.score_pos);
	WriteByte(to, client.color_);
	WriteByte(to, MSG_UPDATENAME);
	WriteByte(to, client.score_pos);
	if (client.netname != "")
		WriteString(to, client.netname);
	else
		WriteString(to, "[no name]");
};
#else
void(float to, entity client) SetColorName =
{
	local string s1;

	WriteByte(to, SVC_UPDATEPING);		// update ping
	WriteByte(to, client.score_pos);		// client number
	WriteShort(to, 999);				// client ping

	WriteByte(to, SVC_UPDATEPACKETLOSS);	// update pl
	WriteByte(to, client.score_pos);		// client number
	WriteByte(to, (30 + (random() * 20)));	// client pl

	WriteByte(to, SVC_UPDATETIME);		// update time
	WriteByte(to, client.score_pos);		// client number
	WriteLong(to, time);				// client enter time

	clientshirt = floor(client.color_ / 16);
	clientpants = client.color_ - (clientshirt * 16);
	WriteByte(to, SVC_UPDATEUSERINFO);		// update userinfo
	WriteByte(to, client.score_pos);		// client number
	WriteLong(to, 0);					// client userid

	WriteByte(to, 92); // \
	WriteByte(to, _b);
	WriteByte(to, _o);
	WriteByte(to, _t);
	WriteByte(to, _t);
	WriteByte(to, _o);
	WriteByte(to, _m);
	WriteByte(to, _c);
	WriteByte(to, _o);
	WriteByte(to, _l);
	WriteByte(to, _o);
	WriteByte(to, _r);
	WriteByte(to, 92); // \

	if (clientpants > 9)
	{
		WriteByte(to, 49);
		WriteByte(to, 38 + clientpants);
	}
	else
		WriteByte(to, 48 + clientpants);

	WriteByte(to, 92); // \
	WriteByte(to, _t);
	WriteByte(to, _o);
	WriteByte(to, _p);
	WriteByte(to, _c);
	WriteByte(to, _o);
	WriteByte(to, _l);
	WriteByte(to, _o);
	WriteByte(to, _r);
	WriteByte(to, 92); // \

	if (clientshirt > 9)
	{
		WriteByte(to, 49);
		WriteByte(to, 38 + clientshirt);
	}
	else
		WriteByte(to, 48 + clientshirt);

	WriteByte(to, 92); // \
	WriteByte(to, _n);
	WriteByte(to, _a);
	WriteByte(to, _m);
	WriteByte(to, _e);
	WriteByte(to, 92); // \
	WriteString(to, client.netname);

	if (teamplay)
	{
		WriteByte(to, SVC_SETINFO);
		WriteByte(to, client.score_pos);
		WriteString(to, "team");
		s1 = GetTeamName(client.team);
		WriteString(to, s1); 
	}
};
#endif

/*
============
SetScoreboard

Exact purpose of this is unclear, does some score init for bots only.
- self is player that just joined
- other is print_entity for that player
============
*/
void() SetScoreboard =
{
	msg_entity = self;
	msg_level = PRINT_HIGH;
	score_count = 0;

	test_enemy = other.enemy;  // should be first_frogbot. Why passed through a var? Dunno.
	if(! test_enemy)
		return;

	while (score_count < SPAWN_SIZE)
	{
		if (test_enemy.frogbot)
		{
		#ifndef QUAKE
			WriteByte(MSG_ONE, SVC_UPDATEPING);			// update ping
			WriteByte(MSG_ONE, test_enemy.score_pos);		// client number
			WriteShort(MSG_ONE, (300 + (random() * 40)));	// client ping
			WriteByte(MSG_ONE, SVC_UPDATEPACKETLOSS);		// update pl
			WriteByte(MSG_ONE, test_enemy.score_pos);		// client number
			WriteByte(MSG_ONE, (30 + (random() * 20)));	// client pl
			WriteByte(MSG_ONE, SVC_UPDATETIME);			// update time
			WriteByte(MSG_ONE, test_enemy.score_pos);		// client number
			WriteLong(MSG_ONE, time);				// client enter time
		#endif
			WriteByte(MSG_ONE, MSG_UPDATEFRAGS);
			WriteByte(MSG_ONE, test_enemy.score_pos);
			WriteShort(MSG_ONE, test_enemy.frags);
			SetColorName(MSG_ONE, test_enemy);
		}
		test_enemy = test_enemy.next_frogbot;
		if(! test_enemy)
			return;
		score_count = score_count + 1;
	}
	other.enemy = test_enemy;
};

#ifndef QUAKE
void() SetPlayerInfo =
{
	WriteByte(MSG_BROADCAST, SVC_PLAYERINFO);
	WriteByte(MSG_BROADCAST, self.score_pos);
	if (self.modelindex == modelindex_player)
	{
		if (self.effects)
			WriteShort(MSG_BROADCAST, 4254);		// mask = 4254 = 158 + 4096
		else
			WriteShort(MSG_BROADCAST, 4126);		// mask = 4126 = 30 + 4096
	}
	else
	{
		if (self.effects)
			WriteShort(MSG_BROADCAST, 4286);		// mask = 4286 = 190 + 4096
		else
			WriteShort(MSG_BROADCAST, 4158);		// mask = 4158 = 62 + 4096
	}
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	WriteByte(MSG_BROADCAST, self.frame);

	WriteByte(MSG_BROADCAST, 129);		// mask2 = 129
	WriteShort(MSG_BROADCAST, self.v_angle_x * 182.0444444);	// 182.0444444 = 65536 / 360
	WriteShort(MSG_BROADCAST, self.v_angle_y * 182.0444444);	// 182.0444444 = 65536 / 360

	WriteByte(MSG_BROADCAST, real_frametime);

	WriteShort(MSG_BROADCAST, self.velocity_x);
	WriteShort(MSG_BROADCAST, self.velocity_y);
	WriteShort(MSG_BROADCAST, self.velocity_z);

	if (self.modelindex != modelindex_player)
		WriteByte(MSG_BROADCAST, self.modelindex);

	if (self.effects)
		WriteByte(MSG_BROADCAST, self.effects);
};
#endif
