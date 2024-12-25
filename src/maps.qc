/*
	maps.qc

	Copyright (C) 2000-2003 rxr
	Copyright (C) 2000-2007 ParboiL
	DrLex 2024-12: ported impulse-less voting system from Trinca's sources.
	Voting on a map M may now be done with 'cmd M'.
*/

#include "settings.h"

.string k_votemap;

string(string mapname) MapHasWaypoints;  //generated inside map_load_gen.qc


float(string val) map_was_voted =
{
	local entity p;
	p = find(world, classname, "player");
	while(p)
	{
		if (p != self)
		{
			if (p.k_votemap == val)
			{
				return TRUE;
			}
		}
		p = find(p, classname, "player");
	}
	return FALSE;
};

float(string val) count_map_votes =
{
	local entity p;
	local float n_v;
	p = find(world, classname, "player");
	while(p) {
		if (p.k_votemap == val) n_v = n_v + 1;
		p = find(p, classname, "player");
	}
	return n_v;
};

void(string pmapname) SelectMapCore =
{
	local float num_v, majority;
	if (match_in_progress || counting_down || intermission_running) return;
	if (k_vbreak || (numberofplayers < 2))
	{
		if ((self.k_votemap == pmapname) && numberofplayers > 1)
		{
			sprint_fb(self, 2, "žžžžŸ your vote is still good žžžžŸ\n");
		}
		else
		{
			self.k_votemap = pmapname;
			num_v = count_map_votes(pmapname);
			majority = (floor(numberofplayers / 2)) + 1;
			if (map_was_voted(pmapname))
			{
				bprint_fb(3, self.netname);
				bprint_fb(3, " agrees to map ");
			}
			else
			{
				bprint_fb(3, self.netname);
				bprint_fb(3, " would rather play on ");
			}
			bprint_fb(2, pmapname);
			bprint_fb(2, "\n");
			if (num_v >= majority)
			{
				if (numberofplayers > 1)
				{
					bprint(2, "Majority votes for mapchange\n");
				} 
				localcmd("map ");
				localcmd(pmapname);
				localcmd("\n");
				return;
			}
		}
	}
	else
	{
		bprint_fb(3, self.netname);
		bprint_fb(3, " suggests map ");
		bprint_fb(2, pmapname);
		bprint_fb(2, "\n");
		self.k_votemap = pmapname;
	}
	k_vbreak = TRUE;
};

void(entity e, string s) clientcommand = #440;
float(string s) tokenize = #441;
string(float n) argv = #442;

void(string str) mvdtokenize= #84;
string(float n) mvdargv = #86;

//qsg's krimzon_sv_parseclientcommand (fte, fuhquake, decent engines)
void(string s) SV_ParseClientCommand =
{
	local string arg0, map;
	tokenize(s);
	arg0 = argv(0);
	map = MapHasWaypoints(arg0);
	if (map!="")
	{
		SelectMapCore(map);
	}
	else
		clientcommand(self, s);
};

//mvdsv (mvdsv, mvdsv, lame standards ignorant engines)
float(string s) UserCmd =
{
	local string arg0, map;

	mvdtokenize(s);
	arg0 = mvdargv(0);
	map = MapHasWaypoints(arg0);
	if (map!="")
	{
		SelectMapCore(arg0);
		return TRUE;
	}
	return FALSE;
}

// random map que for ffa;
string() rndffamap =
{
	local float x, y, closed;
	local string cmap, pmap;
	cmap = infokey(world, mapname);
	pmap = cmap;
	while ((cmap != "") && (cmap != mapname)) {
		cmap = infokey(world, cmap);
		if (cmap == mapname) closed = TRUE;
		else pmap = cmap;
		x = x + 1;
	}
	if (!x || !closed) return mapname;
	else if (x == 1) return pmap;
	else {
		x = rndm(1, x);
		cmap = mapname;
		while (y < x) {
			cmap = infokey(world, cmap);
			y = y + 1;
		}
		return cmap;
	}
};
