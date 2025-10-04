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
#include "maps/drlex/map_aerowalkfrost.qc"
#include "maps/drlex/map_bravadob5.qc"
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
#include "maps/trinca/map_dakdm1.qc"
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
#include "maps/trinca/map_naked6.qc"
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
#include "maps/trinca/map_ztndm1.qc"
#include "maps/trinca/map_ztndm2.qc"
#include "maps/trinca/map_ztndm4.qc"
#include "maps/trinca/map_ztndm5.qc"
#include "maps/trinca/map_ztndm6.qc"
#include "maps/other/map_dm-cepheus.qc"

void() SprintMaps =
{
	sprint_fb(self, 2, "          a2  aerowalk aerowalkfrost\n");
	sprint_fb(self, 2, "    aggressr       amphi      amphi2\n");
	sprint_fb(self, 2, "      bovine     bravado   bravadob5\n");
	sprint_fb(self, 2, "       bsdm6   burialb10    catalyst\n");
	sprint_fb(self, 2, "        cmt3        cmt4      dakdm1\n");
	sprint_fb(self, 2, " dark-terror-ffa     debello    del1\n");
	sprint_fb(self, 2, "  dm-cepheus         dm1         dm3\n");
	sprint_fb(self, 2, "         dm4      dm4ish         dm5\n");
	sprint_fb(self, 2, "         dm6  dm_cepheus      dmz1++\n");
	sprint_fb(self, 2, "    dranzdm8        e1m1        e1m2\n");
	sprint_fb(self, 2, "        e1m3        e1m4        e1m5\n");
	sprint_fb(self, 2, "      efdm13       efdm8    egyptele\n");
	sprint_fb(self, 2, "         end       endif       eodm3\n");
	sprint_fb(self, 2, "       exdm3      filthy        four\n");
	sprint_fb(self, 2, "    frobodm2    genocide     hohoho2\n");
	sprint_fb(self, 2, "      lilith     monsoon      naked6\n");
	sprint_fb(self, 2, "    naked7b2        nova     oktest1\n");
	sprint_fb(self, 2, "       pkeg1     povdmm4     q3dm6qw\n");
	sprint_fb(self, 2, "       rwild     schloss       shady\n");
	sprint_fb(self, 2, "     shifter       shine       skull\n");
	sprint_fb(self, 2, "     spinev2       start         thf\n");
	sprint_fb(self, 2, "         tox      tridm1      tridm2\n");
	sprint_fb(self, 2, "      tridm3     trindm1     trindm2\n");
	sprint_fb(self, 2, "     trindm3      ukpak2      ultrav\n");
	sprint_fb(self, 2, "    utressor      ztndm1      ztndm2\n");
	sprint_fb(self, 2, "      ztndm3 ztndm3frost      ztndm4\n");
	sprint_fb(self, 2, "      ztndm5      ztndm6\n");
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
	if (mapname == "aerowalkfrost")
	{
		map_aerowalkfrost();
		return TRUE;
	}
	if (mapname == "bravadob5")
	{
		map_bravadob5();
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
	if (mapname == "dakdm1")
	{
		map_dakdm1();
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
	if (mapname == "naked6")
	{
		map_naked6();
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
	if (mapname == "ztndm1")
	{
		map_ztndm1();
		return TRUE;
	}
	if (mapname == "ztndm2")
	{
		map_ztndm2();
		return TRUE;
	}
	if (mapname == "ztndm4")
	{
		map_ztndm4();
		return TRUE;
	}
	if (mapname == "ztndm5")
	{
		map_ztndm5();
		return TRUE;
	}
	if (mapname == "ztndm6")
	{
		map_ztndm6();
		return TRUE;
	}
	if (mapname == "dm-cepheus")
	{
		map_dmDASHcepheus();
		return TRUE;
	}
	if (mapname == "ztndm3frost")
	{
		map_ztndm3();
		return TRUE;
	}
	if (mapname == "naked7b2")
	{
		map_cmt3();
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
	if (mapname == "dm_cepheus")
	{
		map_dmDASHcepheus();
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
	if (mname == "aerowalkfrost")
		return "aerowalkfrost";
	if (mname == "bravadob5")
		return "bravadob5";
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
	if (mname == "dakdm1")
		return "dakdm1";
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
	if (mname == "naked6")
		return "naked6";
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
	if (mname == "ztndm1")
		return "ztndm1";
	if (mname == "ztndm2")
		return "ztndm2";
	if (mname == "ztndm4")
		return "ztndm4";
	if (mname == "ztndm5")
		return "ztndm5";
	if (mname == "ztndm6")
		return "ztndm6";
	if (mname == "dm-cepheus")
		return "dm-cepheus";
	if (mname == "ztndm3frost")
		return "ztndm3frost";
	if (mname == "naked7b2")
		return "naked7b2";
	if (mname == "tridm1")
		return "tridm1";
	if (mname == "tridm2")
		return "tridm2";
	if (mname == "tridm3")
		return "tridm3";
	if (mname == "dm_cepheus")
		return "dm_cepheus";
	return "";
};
