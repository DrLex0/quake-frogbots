// This file has been generated with generate_maplist.py

#include "maps/map_aerowalk.qc"
#include "maps/map_amphi2.qc"
#include "maps/map_dm3.qc"
#include "maps/map_dm4.qc"
#include "maps/map_dm6.qc"
#include "maps/map_e1m2.qc"
#include "maps/map_frobodm2.qc"
#include "maps/map_pkeg1.qc"
#include "maps/map_povdmm4.qc"
#include "maps/map_spinev2.qc"
#include "maps/map_ultrav.qc"
#include "maps/map_ztndm3.qc"

void() SprintMaps =
{
	sprint_fb(self, 2, "   aerowalk     amphi2        dm3\n");
	sprint_fb(self, 2, "        dm4        dm6       e1m2\n");
	sprint_fb(self, 2, "   frobodm2      pkeg1    povdmm4\n");
	sprint_fb(self, 2, "    spinev2     ultrav     ztndm3\n");
};

void() LoadWaypoints =
{
	if (mapname == "aerowalk")
	{
		map_aerowalk();
		return;
	}
	if (mapname == "amphi2")
	{
		map_amphi2();
		return;
	}
	if (mapname == "dm3")
	{
		map_dm3();
		return;
	}
	if (mapname == "dm4")
	{
		map_dm4();
		return;
	}
	if (mapname == "dm6")
	{
		map_dm6();
		return;
	}
	if (mapname == "e1m2")
	{
		map_e1m2();
		return;
	}
	if (mapname == "frobodm2")
	{
		map_frobodm2();
		return;
	}
	if (mapname == "pkeg1")
	{
		map_pkeg1();
		return;
	}
	if (mapname == "povdmm4")
	{
		map_povdmm4();
		return;
	}
	if (mapname == "spinev2")
	{
		map_spinev2();
		return;
	}
	if (mapname == "ultrav")
	{
		map_ultrav();
		return;
	}
	if (mapname == "ztndm3")
	{
		map_ztndm3();
		return;
	}
};

string(string mname) MapHasWaypoints =
{
	if (mname == "aerowalk")
		return "aerowalk";
	if (mname == "amphi2")
		return "amphi2";
	if (mname == "dm3")
		return "dm3";
	if (mname == "dm4")
		return "dm4";
	if (mname == "dm6")
		return "dm6";
	if (mname == "e1m2")
		return "e1m2";
	if (mname == "frobodm2")
		return "frobodm2";
	if (mname == "pkeg1")
		return "pkeg1";
	if (mname == "povdmm4")
		return "povdmm4";
	if (mname == "spinev2")
		return "spinev2";
	if (mname == "ultrav")
		return "ultrav";
	if (mname == "ztndm3")
		return "ztndm3";
	return "";
};
