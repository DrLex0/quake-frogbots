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
#include "maps/drlex/map_burialb10.qc"
#include "maps/drlex/map_hohoho2.qc"
#include "maps/drlex/map_tox.qc"
#include "maps/ktx/map_endif.qc"
#include "maps/ktx/map_monsoon.qc"
#include "maps/ktx/map_shifter.qc"
#include "maps/trinca/map_a2.qc"
#include "maps/trinca/map_aggressr.qc"
#include "maps/trinca/map_amphi.qc"
#include "maps/trinca/map_bovine.qc"
#include "maps/trinca/map_cmt4.qc"
#include "maps/trinca/map_del1.qc"
#include "maps/trinca/map_dm5.qc"
#include "maps/trinca/map_dranzdm8.qc"
#include "maps/trinca/map_efdm13.qc"
#include "maps/trinca/map_efdm8.qc"
#include "maps/trinca/map_eodm3.qc"
#include "maps/trinca/map_exdm3.qc"
#include "maps/trinca/map_four.qc"
#include "maps/trinca/map_genocide.qc"
#include "maps/trinca/map_lilith.qc"
#include "maps/trinca/map_oktest1.qc"
#include "maps/trinca/map_rwild.qc"
#include "maps/trinca/map_schloss.qc"
#include "maps/trinca/map_shine.qc"
#include "maps/trinca/map_skull.qc"
#include "maps/trinca/map_start.qc"
#include "maps/trinca/map_thf.qc"
#include "maps/trinca/map_trindm2.qc"
#include "maps/trinca/map_ukpak2.qc"
#include "maps/trinca/map_utressor.qc"
#include "maps/trinca/map_ztndm6.qc"

void() SprintMaps =
{
	sprint_fb(self, 2, "         a2   aerowalk   aggressr\n");
	sprint_fb(self, 2, "      amphi     amphi2     bovine\n");
	sprint_fb(self, 2, "  burialb10       cmt4       del1\n");
	sprint_fb(self, 2, "        dm3        dm4        dm5\n");
	sprint_fb(self, 2, "        dm6   dranzdm8       e1m2\n");
	sprint_fb(self, 2, "     efdm13      efdm8      endif\n");
	sprint_fb(self, 2, "      eodm3      exdm3       four\n");
	sprint_fb(self, 2, "   frobodm2   genocide    hohoho2\n");
	sprint_fb(self, 2, "     lilith    monsoon    oktest1\n");
	sprint_fb(self, 2, "      pkeg1    povdmm4      rwild\n");
	sprint_fb(self, 2, "    schloss    shifter      shine\n");
	sprint_fb(self, 2, "      skull    spinev2      start\n");
	sprint_fb(self, 2, "        thf        tox     tridm2\n");
	sprint_fb(self, 2, "    trindm2     ukpak2     ultrav\n");
	sprint_fb(self, 2, "   utressor     ztndm3     ztndm6\n");
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
	if (mapname == "burialb10")
	{
		map_burialb10();
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
	if (mapname == "endif")
	{
		map_endif();
		return TRUE;
	}
	if (mapname == "monsoon")
	{
		map_monsoon();
		return TRUE;
	}
	if (mapname == "shifter")
	{
		map_shifter();
		return TRUE;
	}
	if (mapname == "a2")
	{
		map_a2();
		return TRUE;
	}
	if (mapname == "aggressr")
	{
		map_aggressr();
		return TRUE;
	}
	if (mapname == "amphi")
	{
		map_amphi();
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
	if (mapname == "del1")
	{
		map_del1();
		return TRUE;
	}
	if (mapname == "dm5")
	{
		map_dm5();
		return TRUE;
	}
	if (mapname == "dranzdm8")
	{
		map_dranzdm8();
		return TRUE;
	}
	if (mapname == "efdm13")
	{
		map_efdm13();
		return TRUE;
	}
	if (mapname == "efdm8")
	{
		map_efdm8();
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
	if (mapname == "four")
	{
		map_four();
		return TRUE;
	}
	if (mapname == "genocide")
	{
		map_genocide();
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
	if (mapname == "rwild")
	{
		map_rwild();
		return TRUE;
	}
	if (mapname == "schloss")
	{
		map_schloss();
		return TRUE;
	}
	if (mapname == "shine")
	{
		map_shine();
		return TRUE;
	}
	if (mapname == "skull")
	{
		map_skull();
		return TRUE;
	}
	if (mapname == "start")
	{
		map_start();
		return TRUE;
	}
	if (mapname == "thf")
	{
		map_thf();
		return TRUE;
	}
	if (mapname == "trindm2")
	{
		map_trindm2();
		return TRUE;
	}
	if (mapname == "ukpak2")
	{
		map_ukpak2();
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
	if (mapname == "tridm2")
	{
		map_trindm2();
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
	if (mname == "burialb10")
		return "burialb10";
	if (mname == "hohoho2")
		return "hohoho2";
	if (mname == "tox")
		return "tox";
	if (mname == "endif")
		return "endif";
	if (mname == "monsoon")
		return "monsoon";
	if (mname == "shifter")
		return "shifter";
	if (mname == "a2")
		return "a2";
	if (mname == "aggressr")
		return "aggressr";
	if (mname == "amphi")
		return "amphi";
	if (mname == "bovine")
		return "bovine";
	if (mname == "cmt4")
		return "cmt4";
	if (mname == "del1")
		return "del1";
	if (mname == "dm5")
		return "dm5";
	if (mname == "dranzdm8")
		return "dranzdm8";
	if (mname == "efdm13")
		return "efdm13";
	if (mname == "efdm8")
		return "efdm8";
	if (mname == "eodm3")
		return "eodm3";
	if (mname == "exdm3")
		return "exdm3";
	if (mname == "four")
		return "four";
	if (mname == "genocide")
		return "genocide";
	if (mname == "lilith")
		return "lilith";
	if (mname == "oktest1")
		return "oktest1";
	if (mname == "rwild")
		return "rwild";
	if (mname == "schloss")
		return "schloss";
	if (mname == "shine")
		return "shine";
	if (mname == "skull")
		return "skull";
	if (mname == "start")
		return "start";
	if (mname == "thf")
		return "thf";
	if (mname == "trindm2")
		return "trindm2";
	if (mname == "ukpak2")
		return "ukpak2";
	if (mname == "utressor")
		return "utressor";
	if (mname == "ztndm6")
		return "ztndm6";
	if (mname == "tridm2")
		return "tridm2";
	return "";
};
