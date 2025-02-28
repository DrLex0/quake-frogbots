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
#include "maps/trinca/map_bovine.qc"
#include "maps/trinca/map_cmt4.qc"
#include "maps/trinca/map_dm5.qc"
#include "maps/trinca/map_e1m6.qc"
#include "maps/trinca/map_efdm13.qc"
#include "maps/trinca/map_eodm3.qc"
#include "maps/trinca/map_exdm3.qc"
#include "maps/trinca/map_lilith.qc"
#include "maps/trinca/map_oktest1.qc"
#include "maps/trinca/map_utressor.qc"
#include "maps/trinca/map_ztndm6.qc"

void() SprintMaps =
{
	sprint_fb(self, 2, "   aerowalk     amphi2     bovine\n");
	sprint_fb(self, 2, "       cmt4        dm3        dm4\n");
	sprint_fb(self, 2, "        dm5        dm6       e1m2\n");
	sprint_fb(self, 2, "       e1m6     efdm13      eodm3\n");
	sprint_fb(self, 2, "      exdm3   frobodm2    hohoho2\n");
	sprint_fb(self, 2, "     lilith    oktest1      pkeg1\n");
	sprint_fb(self, 2, "    povdmm4    spinev2        tox\n");
	sprint_fb(self, 2, "     ultrav   utressor     ztndm3\n");
	sprint_fb(self, 2, "     ztndm6\n");
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
	if (mapname == "bovine")
	{
		map_bovine();
		return TRUE;
	}
	if (mapname == "cmt4")
	{
		map_cmt4();
		return TRUE;
	}
	if (mapname == "dm5")
	{
		map_dm5();
		return TRUE;
	}
	if (mapname == "e1m6")
	{
		map_e1m6();
		return TRUE;
	}
	if (mapname == "efdm13")
	{
		map_efdm13();
		return TRUE;
	}
	if (mapname == "eodm3")
	{
		map_eodm3();
		return TRUE;
	}
	if (mapname == "exdm3")
	{
		map_exdm3();
		return TRUE;
	}
	if (mapname == "lilith")
	{
		map_lilith();
		return TRUE;
	}
	if (mapname == "oktest1")
	{
		map_oktest1();
		return TRUE;
	}
	if (mapname == "utressor")
	{
		map_utressor();
		return TRUE;
	}
	if (mapname == "ztndm6")
	{
		map_ztndm6();
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
	if (mname == "bovine")
		return "bovine";
	if (mname == "cmt4")
		return "cmt4";
	if (mname == "dm5")
		return "dm5";
	if (mname == "e1m6")
		return "e1m6";
	if (mname == "efdm13")
		return "efdm13";
	if (mname == "eodm3")
		return "eodm3";
	if (mname == "exdm3")
		return "exdm3";
	if (mname == "lilith")
		return "lilith";
	if (mname == "oktest1")
		return "oktest1";
	if (mname == "utressor")
		return "utressor";
	if (mname == "ztndm6")
		return "ztndm6";
	return "";
};
