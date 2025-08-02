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
#include "maps/drlex/map_catalyst.qc"
#include "maps/drlex/map_dark-terror-ffa.qc"
#include "maps/drlex/map_dmz1++.qc"
#include "maps/drlex/map_e1m4.qc"
#include "maps/drlex/map_hohoho2.qc"
#include "maps/drlex/map_nova.qc"
#include "maps/drlex/map_tox.qc"
#include "maps/ktx/map_bravado.qc"
#include "maps/ktx/map_endif.qc"
#include "maps/ktx/map_monsoon.qc"
#include "maps/ktx/map_shifter.qc"
#include "maps/trinca/map_a2.qc"
#include "maps/trinca/map_aggressr.qc"
#include "maps/trinca/map_amphi.qc"
#include "maps/trinca/map_bovine.qc"
#include "maps/trinca/map_bsdm6.qc"
#include "maps/trinca/map_cmt3.qc"
#include "maps/trinca/map_cmt4.qc"
#include "maps/trinca/map_debello.qc"
#include "maps/trinca/map_del1.qc"
#include "maps/trinca/map_dm1.qc"
#include "maps/trinca/map_dm4ish.qc"
#include "maps/trinca/map_dm5.qc"
#include "maps/trinca/map_dranzdm8.qc"
#include "maps/trinca/map_e1m1.qc"
#include "maps/trinca/map_e1m3.qc"
#include "maps/trinca/map_e1m5.qc"
#include "maps/trinca/map_efdm13.qc"
#include "maps/trinca/map_efdm8.qc"
#include "maps/trinca/map_egyptele.qc"
#include "maps/trinca/map_end.qc"
#include "maps/trinca/map_eodm3.qc"
#include "maps/trinca/map_exdm3.qc"
#include "maps/trinca/map_filthy.qc"
#include "maps/trinca/map_four.qc"
#include "maps/trinca/map_genocide.qc"
#include "maps/trinca/map_lilith.qc"
#include "maps/trinca/map_oktest1.qc"
#include "maps/trinca/map_q3dm6qw.qc"
#include "maps/trinca/map_rwild.qc"
#include "maps/trinca/map_schloss.qc"
#include "maps/trinca/map_shady.qc"
#include "maps/trinca/map_shine.qc"
#include "maps/trinca/map_skull.qc"
#include "maps/trinca/map_start.qc"
#include "maps/trinca/map_thf.qc"
#include "maps/trinca/map_trindm1.qc"
#include "maps/trinca/map_trindm2.qc"
#include "maps/trinca/map_trindm3.qc"
#include "maps/trinca/map_ukpak2.qc"
#include "maps/trinca/map_utressor.qc"
#include "maps/trinca/map_ztndm4.qc"
#include "maps/trinca/map_ztndm6.qc"

void() SprintMaps =
{
	sprint_fb(self, 2, "         a2   aerowalk   aggressr\n");
	sprint_fb(self, 2, "      amphi     amphi2     bovine\n");
	sprint_fb(self, 2, "    bravado      bsdm6  burialb10\n");
	sprint_fb(self, 2, "   catalyst       cmt3       cmt4\n");
	sprint_fb(self, 2, " dark-terror-ffa    debello  del1\n");
	sprint_fb(self, 2, "        dm1        dm3        dm4\n");
	sprint_fb(self, 2, "     dm4ish        dm5        dm6\n");
	sprint_fb(self, 2, "     dmz1++   dranzdm8       e1m1\n");
	sprint_fb(self, 2, "       e1m2       e1m3       e1m4\n");
	sprint_fb(self, 2, "       e1m5     efdm13      efdm8\n");
	sprint_fb(self, 2, "   egyptele        end      endif\n");
	sprint_fb(self, 2, "      eodm3      exdm3     filthy\n");
	sprint_fb(self, 2, "       four   frobodm2   genocide\n");
	sprint_fb(self, 2, "    hohoho2     lilith    monsoon\n");
	sprint_fb(self, 2, "       nova    oktest1      pkeg1\n");
	sprint_fb(self, 2, "    povdmm4    q3dm6qw      rwild\n");
	sprint_fb(self, 2, "    schloss      shady    shifter\n");
	sprint_fb(self, 2, "      shine      skull    spinev2\n");
	sprint_fb(self, 2, "      start        thf        tox\n");
	sprint_fb(self, 2, "     tridm1     tridm2     tridm3\n");
	sprint_fb(self, 2, "    trindm1    trindm2    trindm3\n");
	sprint_fb(self, 2, "     ukpak2     ultrav   utressor\n");
	sprint_fb(self, 2, "     ztndm3     ztndm4     ztndm6\n");
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
	if (mapname == "catalyst")
	{
		map_catalyst();
		return TRUE;
	}
	if (mapname == "dark-terror-ffa")
	{
		map_darkDASHterrorDASHffa();
		return TRUE;
	}
	if (mapname == "dmz1++")
	{
		map_dmz1PLUSPLUS();
		return TRUE;
	}
	if (mapname == "e1m4")
	{
		map_e1m4();
		return TRUE;
	}
	if (mapname == "hohoho2")
	{
		map_hohoho2();
		return TRUE;
	}
	if (mapname == "nova")
	{
		map_nova();
		return TRUE;
	}
	if (mapname == "tox")
	{
		map_tox();
		return TRUE;
	}
	if (mapname == "bravado")
	{
		map_bravado();
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
	if (mapname == "bsdm6")
	{
		map_bsdm6();
		return TRUE;
	}
	if (mapname == "cmt3")
	{
		map_cmt3();
		return TRUE;
	}
	if (mapname == "cmt4")
	{
		map_cmt4();
		return TRUE;
	}
	if (mapname == "debello")
	{
		map_debello();
		return TRUE;
	}
	if (mapname == "del1")
	{
		map_del1();
		return TRUE;
	}
	if (mapname == "dm1")
	{
		map_dm1();
		return TRUE;
	}
	if (mapname == "dm4ish")
	{
		map_dm4ish();
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
	if (mapname == "e1m1")
	{
		map_e1m1();
		return TRUE;
	}
	if (mapname == "e1m3")
	{
		map_e1m3();
		return TRUE;
	}
	if (mapname == "e1m5")
	{
		map_e1m5();
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
	if (mapname == "egyptele")
	{
		map_egyptele();
		return TRUE;
	}
	if (mapname == "end")
	{
		map_end();
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
	if (mapname == "filthy")
	{
		map_filthy();
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
	if (mapname == "q3dm6qw")
	{
		map_q3dm6qw();
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
	if (mapname == "shady")
	{
		map_shady();
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
	if (mapname == "trindm1")
	{
		map_trindm1();
		return TRUE;
	}
	if (mapname == "trindm2")
	{
		map_trindm2();
		return TRUE;
	}
	if (mapname == "trindm3")
	{
		map_trindm3();
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
	if (mapname == "ztndm4")
	{
		map_ztndm4();
		return TRUE;
	}
	if (mapname == "ztndm6")
	{
		map_ztndm6();
		return TRUE;
	}
	if (mapname == "tridm1")
	{
		map_trindm1();
		return TRUE;
	}
	if (mapname == "tridm2")
	{
		map_trindm2();
		return TRUE;
	}
	if (mapname == "tridm3")
	{
		map_trindm3();
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
	if (mname == "catalyst")
		return "catalyst";
	if (mname == "dark-terror-ffa")
		return "dark-terror-ffa";
	if (mname == "dmz1++")
		return "dmz1++";
	if (mname == "e1m4")
		return "e1m4";
	if (mname == "hohoho2")
		return "hohoho2";
	if (mname == "nova")
		return "nova";
	if (mname == "tox")
		return "tox";
	if (mname == "bravado")
		return "bravado";
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
	if (mname == "bsdm6")
		return "bsdm6";
	if (mname == "cmt3")
		return "cmt3";
	if (mname == "cmt4")
		return "cmt4";
	if (mname == "debello")
		return "debello";
	if (mname == "del1")
		return "del1";
	if (mname == "dm1")
		return "dm1";
	if (mname == "dm4ish")
		return "dm4ish";
	if (mname == "dm5")
		return "dm5";
	if (mname == "dranzdm8")
		return "dranzdm8";
	if (mname == "e1m1")
		return "e1m1";
	if (mname == "e1m3")
		return "e1m3";
	if (mname == "e1m5")
		return "e1m5";
	if (mname == "efdm13")
		return "efdm13";
	if (mname == "efdm8")
		return "efdm8";
	if (mname == "egyptele")
		return "egyptele";
	if (mname == "end")
		return "end";
	if (mname == "eodm3")
		return "eodm3";
	if (mname == "exdm3")
		return "exdm3";
	if (mname == "filthy")
		return "filthy";
	if (mname == "four")
		return "four";
	if (mname == "genocide")
		return "genocide";
	if (mname == "lilith")
		return "lilith";
	if (mname == "oktest1")
		return "oktest1";
	if (mname == "q3dm6qw")
		return "q3dm6qw";
	if (mname == "rwild")
		return "rwild";
	if (mname == "schloss")
		return "schloss";
	if (mname == "shady")
		return "shady";
	if (mname == "shine")
		return "shine";
	if (mname == "skull")
		return "skull";
	if (mname == "start")
		return "start";
	if (mname == "thf")
		return "thf";
	if (mname == "trindm1")
		return "trindm1";
	if (mname == "trindm2")
		return "trindm2";
	if (mname == "trindm3")
		return "trindm3";
	if (mname == "ukpak2")
		return "ukpak2";
	if (mname == "utressor")
		return "utressor";
	if (mname == "ztndm4")
		return "ztndm4";
	if (mname == "ztndm6")
		return "ztndm6";
	if (mname == "tridm1")
		return "tridm1";
	if (mname == "tridm2")
		return "tridm2";
	if (mname == "tridm3")
		return "tridm3";
	return "";
};
