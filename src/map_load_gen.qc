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
#include "maps/drlex/map_hohoho2.qc"
#include "maps/drlex/map_tox.qc"
#include "maps/trinca/map_cmt4.qc"
#include "maps/trinca/map_e1m6.qc"
#include "maps/trinca/map_eodm3.qc"
#include "maps/trinca/map_oktest1.qc"

void() SprintMaps =
{
	sprint_fb(self, 2, "   aerowalk     amphi2        dm3\n");
	sprint_fb(self, 2, "        dm4        dm6       e1m2\n");
	sprint_fb(self, 2, "   frobodm2      pkeg1    povdmm4\n");
	sprint_fb(self, 2, "    spinev2     ultrav     ztndm3\n");
	sprint_fb(self, 2, "    hohoho2        tox       cmt4\n");
	sprint_fb(self, 2, "       e1m6      eodm3    oktest1\n");
};

float() LoadWaypoints =
{
	if (mapname == "aerowalk")
	{
		map_aerowalk();
		return TRUE;
	}
	if (mapname == "amphi2")
	{
		map_amphi2();
		return TRUE;
	}
	if (mapname == "dm3")
	{
		map_dm3();
		return TRUE;
	}
	if (mapname == "dm4")
	{
		map_dm4();
		return TRUE;
	}
	if (mapname == "dm6")
	{
		map_dm6();
		return TRUE;
	}
	if (mapname == "e1m2")
	{
		map_e1m2();
		return TRUE;
	}
	if (mapname == "frobodm2")
	{
		map_frobodm2();
		return TRUE;
	}
	if (mapname == "pkeg1")
	{
		map_pkeg1();
		return TRUE;
	}
	if (mapname == "povdmm4")
	{
		map_povdmm4();
		return TRUE;
	}
	if (mapname == "spinev2")
	{
		map_spinev2();
		return TRUE;
	}
	if (mapname == "ultrav")
	{
		map_ultrav();
		return TRUE;
	}
	if (mapname == "ztndm3")
	{
		map_ztndm3();
		return TRUE;
	}
	if (mapname == "hohoho2")
	{
		map_hohoho2();
		return TRUE;
	}
	if (mapname == "tox")
	{
		map_tox();
		return TRUE;
	}
	if (mapname == "cmt4")
	{
		map_cmt4();
		return TRUE;
	}
	if (mapname == "e1m6")
	{
		map_e1m6();
		return TRUE;
	}
	if (mapname == "eodm3")
	{
		map_eodm3();
		return TRUE;
	}
	if (mapname == "oktest1")
	{
		map_oktest1();
		return TRUE;
	}
	return FALSE;
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
	if (mname == "hohoho2")
		return "hohoho2";
	if (mname == "tox")
		return "tox";
	if (mname == "cmt4")
		return "cmt4";
	if (mname == "e1m6")
		return "e1m6";
	if (mname == "eodm3")
		return "eodm3";
	if (mname == "oktest1")
		return "oktest1";
	return "";
};
