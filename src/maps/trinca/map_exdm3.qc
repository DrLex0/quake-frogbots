// Original 13-09-2004 by Trinca
// Fixed by DrLex 2025-02. Looks like Trinca gave up on this and left it in half-finished state
// when noticing the door did not really work. Now it works by means of exclusive paths.
// To avoid that the bot will get sucked back in when exiting the corridor with the LG,
// the path in that direction goes from exclusive to normal, causing exclusive door activation
// to be suppressed for 4 seconds.
// Also revised goals and split up Z2.
// 2025-07: tweaks and increase desire to get the LG.
void() map_exdm3 =
{
// custom markers start at m54
N(639,-425,24);N(519,-446,24);N(341,-578,8);N(211,-638,8);
N(359,-724,8);N(477,-881,40);N(335,-860,8);N(302,-922,8);
N(239,-778,8);N(490,-990,88);N(391,-1071,136);N(275,-1122,152);
N(584,-1042,152);N(597,-842,152);N(136,-1100,184);N(75,-964,248);
N(221,-612,280);N(477,-1210,152);N(40,-586,280);N(-125,-471,296);
N(-115,-334,312);N(-90,-191,344);N(189,-97,344);N(43,37,344);
N(284,-430,248);N(466,-435,168);N(639,-441,168);N(839,-437,168);
N(641,106,136);N(512,182,72);N(62,-646,8);N(100,-457,24);
N(173,-271,24);N(236,-85,24);N(303,-256,24);N(457,-185,24);
N(605,-108,24);N(492,-31,24);N(762,-102,24);N(897,-115,24);
N(809,-307,24);N(820,-477,24);N(979,-558,72);N(1136,-570,152);
N(86,200,24);N(95,-18,24);N(366,-106,-8);N(1031,-27,168);
N(1013,-444,168);N(1326,-570,168);N(1409,-722,152);N(1210,-1047,152);
N(802,-703,152);N(1079,-945,152);N(121,-1676,52);N(116,-1345,-16);
N(107,-1164,-14);N(139,-935,0);N(111,-1024,0);N(287,-825,8);
N(215,-904,8);N(1215,-1131,160);N(355,-12,-56);N(123,-1851,56);
N(385,-769,8);N(-91,-592,296);N(307,264,216);N(1205,-461,168);
N(881,-648,24);N(586,-194,168);N(296,-709,8);N(744,-425,24);
LSQ();
Z2(m1);Z7(m2);Z3(m3);Z3(m4);Z1(m6);Z4(m7);Z1(m9);Z7(m10);
Z3(m11);Z3(m12);Z4(m13);Z4(m14);Z4(m15);Z4(m16);Z4(m17);Z4(m18);
Z1(m19);Z1(m20);Z2(m21);Z2(m22);Z3(m23);Z7(m24);Z2(m25);Z5(m26);
Z1(m27);Z1(m28);Z5(m29);Z2(m31);Z2(m32);Z2(m33);Z5(m36);Z3(m37);
Z6(m39);Z6(m40);Z4(m41);Z4(m42);Z2(m43);Z2(m44);Z1(m45);Z1(m46);
Z1(m47);Z1(m48);Z3(m49);Z4(m50);Z4(m51);Z4(m52);Z4(m53);Z3(m8);
Z5(m34);Z2(m35);Z4(m38);Z1(m54);Z1(m55);Z1(m56);Z1(m57);Z1(m58);
Z1(m59);Z1(m60);Z1(m61);Z1(m62);Z1(m63);Z1(m64);Z1(m65);Z1(m66);
Z1(m67);Z1(m68);Z1(m69);Z1(m70);Z1(m71);Z2(m72);Z2(m73);Z2(m74);
Z2(m75);Z2(m76);Z2(m77);Z2(m78);Z7(m79);Z7(m80);Z7(m81);Z7(m82);
Z7(m83);Z3(m84);Z3(m85);Z3(m86);Z3(m87);Z3(m88);Z3(m89);Z3(m90);
Z3(m91);Z3(m92);Z3(m93);Z3(m94);Z3(m95);Z3(m96);Z4(m97);Z7(m98);
Z3(m99);Z3(m100);Z4(m101);Z4(m102);Z4(m103);Z4(m104);Z4(m105);Z4(m106);
Z4(m107);Z5(m108);Z5(m109);Z5(m110);Z5(m111);Z5(m112);Z5(m113);Z5(m114);
Z4(m115);Z3(m116);Z5(m117);Z5(m118);Z2(m119);Z6(m120);Z4(m121);Z3(m122);
Z7(m123);Z5(m124);Z3(m125);
G2(m1);G13(m2);G21(m4);G7(m6);G10(m9);G6(m10);G8(m11);G8(m12);
G5(m13);G14(m14);G14(m15);G23(m17);G18(m18);G20(m19);G20(m20);G10(m21);
G10(m22);G16(m24);G15(m25);G1(m26);G9(m27);G9(m28);G11(m31);G11(m32);
G3(m39);G12(m40);G22(m41);G22(m42);G15(m47);G17(m52);G4(m53);
m37.view_ofs_z=36;
m111.T=4;m113.T=4;m114.T=4;m118.T=4;
m1.P0=m25;m1.P1=m76;m1.P2=m75;m1.P3=m77;m2.P0=m80;m2.P1=m24;
m2.P3=m123;m3.P0=m4;m3.P1=m90;m4.P0=m90;m4.P1=m3;m4.P2=m89;
m6.P0=m71;m6.P1=m66;m7.P0=m8;m9.P0=m55;m9.P1=m28;m9.P2=m45;
m9.P3=m58;m9.P4=m56;m9.P5=m59;m9.P6=m67;m10.P0=m83;m10.P1=m98;
m10.P2=m120;m11.P0=m94;m11.P1=m12;m11.P2=m95;m11.P3=m125;m12.P0=m94;
m12.P1=m11;m12.P2=m93;m13.P0=m15;m13.P1=m14;m13.P2=m92;m13.P3=m93;
m14.P0=m15;m14.P1=m101;m14.P2=m13;m15.P0=m14;m15.P1=m13;m15.P2=m101;
m16.P0=m17;m16.P1=m105;m16.P2=m115;m17.P0=m53;m17.P1=m16;m17.P2=m105;
m18.P1=m105;m18.P2=m107;m18.P3=m42;m19.P0=m69;m19.P1=m20;m20.P0=m19;
m20.P1=m70;m20.P2=m72;m21.P0=m73;m21.P1=m22;m21.P2=m74;m21.P4=m23;
m22.P0=m21;m22.P1=m78;m22.P2=m86;m22.P3=m23;m23.P0=m99;m23.P1=m86;
m24.P0=m2;m24.P1=m82;m24.P2=m91;m24.P4=m123;m25.P1=m1;m25.P2=m75;
m26.P0=m109;m26.P1=m108;m27.P0=m45;m27.P1=m28;m28.P0=m55;m28.P1=m9;
m28.P2=m27;m31.P0=m33;m31.P1=m32;m31.P2=m108;m32.P0=m77;m32.P1=m31;
m33.P0=m34;m36.P0=m35;m37.P0=m38;m39.P0=m40;m39.P1=m120;m40.P0=m39;
m40.P1=m120;m41.P0=m42;m41.P1=m106;m41.P2=m67;m42.P0=m18;m42.P1=m41;
m42.P2=m122;m43.P0=m75;m43.P1=m25;m44.P0=m119;m45.P0=m9;m45.P1=m27;
m45.P2=m59;m46.P0=m65;m46.P1=m47;m47.P1=m64;m47.P2=m65;m48.P0=m6;
m48.P1=m66;m49.P0=m122;m50.P0=m121;m51.P0=m101;m51.P1=m102;m52.P0=m105;
m52.P1=m115;m52.P2=m107;m53.P0=m104;m53.P1=m17;m8.P0=m116;m8.P1=m100;
m34.P0=m36;m34.P1=m117;m35.P0=m77;m35.P1=m33;m38.P0=m115;m38.P1=m7;
m38.P2=m105;m54.P0=m55;m54.P1=m125;m55.P0=m54;m55.P1=m28;m55.P2=m9;
m55.P3=m56;m56.P0=m55;m56.P1=m9;m56.P2=m58;m56.P3=m57;m57.P0=m56;
m57.P1=m84;m58.P0=m9;m58.P1=m59;m58.P2=m62;m58.P3=m56;m58.P4=m60;
m59.P0=m9;m59.P1=m45;m59.P2=m58;m59.P3=m63;m59.P4=m60;m60.P0=m58;
m60.P1=m61;m60.P2=m62;m60.P3=m59;m61.P0=m60;m61.P2=m62;m62.P0=m58;
m62.P1=m60;m62.P2=m61;m63.P0=m59;m63.P1=m64;m64.P0=m63;m64.P1=m65;
m64.P2=m47;m64.P3=m71;m64.P4=m61;m64.P5=m60;m65.P0=m64;m65.P2=m68;
m65.P3=m47;m66.P0=m67;m66.P1=m6;m66.P3=m63;m67.P0=m66;m67.P1=m45;
m67.P2=m9;m67.P3=m27;m67.P4=m28;m67.P5=m59;m67.P6=m41;m68.P0=m65;
m68.P1=m69;m69.P0=m68;m69.P1=m19;m70.P0=m20;m70.P1=m72;m70.P2=m9;
m70.P3=m58;m71.P0=m64;m71.P1=m6;m72.P0=m70;m72.P1=m20;m72.P2=m119;
m73.P0=m119;m73.P1=m21;m73.P2=m74;m74.P0=m75;m74.P1=m73;m74.P2=m21;
m75.P0=m74;m75.P2=m1;m75.P3=m25;m76.P0=m1;m76.P1=m77;m76.P2=m88;
m76.P3=m89;m76.P4=m86;m77.P0=m32;m77.P1=m76;m77.P2=m1;m78.P0=m22;
m78.P1=m79;m78.P2=m88;m78.P3=m89;m79.P0=m78;m79.P1=m80;m80.P0=m79;
m80.P1=m81;m80.P2=m2;m81.P0=m80;m81.P1=m102;m81.P2=m94;m81.P3=m12;
m82.P0=m24;m82.P1=m83;m83.P0=m82;m83.P1=m10;m84.P0=m85;m84.P1=m57;
m85.P0=m84;m85.P1=m86;m86.P0=m87;m86.P1=m23;m86.P2=m85;m86.P3=m88;
m87.P0=m99;m87.P1=m86;m87.P2=m116;m88.P0=m86;m88.P1=m100;m88.P2=m89;
m89.P0=m88;m89.P1=m91;m89.P2=m90;m89.P3=m4;m89.P4=m123;m89.P5=m100;
m90.P0=m89;m90.P1=m92;m90.P2=m4;m90.P3=m3;m90.P4=m91;m91.P0=m116;
m91.P1=m89;m91.P2=m90;m92.P0=m90;m92.P1=m93;m93.P0=m92;m93.P1=m12;
m93.P2=m94;m94.P0=m12;m94.P1=m11;m94.P2=m125;m94.P3=m93;m94.P4=m95;
m95.P0=m125;m95.P1=m122;m95.P2=m96;m95.P3=m11;m95.P4=m94;m96.P0=m122;
m96.P1=m97;m96.P2=m95;m97.P0=m96;m97.P2=m121;m97.P3=m103;m98.P0=m10;
m98.P1=m99;m99.P0=m98;m99.P1=m23;m99.P2=m87;m100.P0=m88;m100.P1=m116;
m101.P0=m15;m101.P1=m14;m101.P2=m51;m102.P0=m51;m102.P1=m81;m102.P2=m97;
m102.P3=m121;m103.P0=m97;m103.P1=m121;m103.P2=m104;m104.P0=m103;m104.P1=m53;
m105.P0=m17;m105.P1=m16;m105.P2=m115;m105.P3=m52;m105.P4=m18;m105.P5=m107;
m106.P0=m41;m106.P1=m95;m106.P2=m122;m107.P0=m52;m107.P1=m18;m107.P2=m105;
m108.P1=m26;m108.P3=m117;m109.P0=m26;m109.P1=m110;m110.P0=m109;m110.P1=m112;
m111.P0=m112;m111.P1=m61;m112.P0=m111;m112.P1=m110;m113.P0=m114;m113.P1=m29;
m114.P0=m29;m114.P1=m111;m115.P0=m105;m115.P1=m7;m115.P2=m52;m115.P3=m16;
m116.P0=m100;m116.P1=m37;m117.P0=m108;m117.P1=m36;m118.P0=m113;m118.P1=m29;
m119.P0=m73;m119.P1=m72;m120.P0=m39;m120.P1=m40;m120.P2=m10;m121.P0=m102;
m121.P1=m97;m121.P2=m103;m122.P0=m96;m122.P1=m95;m123.P0=m2;m123.P1=m24;
m123.P2=m89;m124.P0=m113;m124.P1=m29;m125.P0=m54;m125.P1=m95;m125.P2=m94;
m125.P3=m11;
m9.D6=512;m10.D2=2560;m13.D2=1024;m13.D3=1024;m21.D4=1024;m22.D2=1024;
m22.D3=1024;m24.D2=1024;m42.D2=1024;m64.D4=1024;m64.D5=1024;m67.D1=1024;
m67.D2=1024;m67.D3=1024;m67.D4=1024;m67.D5=1024;m70.D2=1024;m70.D3=1024;
m76.D2=1024;m76.D3=1024;m76.D4=1024;m78.D2=1024;m78.D3=1024;m81.D2=1024;
m81.D3=1024;m89.D4=512;m106.D1=1024;m106.D2=1024;m113.D1=4;m114.D0=4;
m118.D1=4;m120.D2=1024;m123.D2=1024;m124.D1=4;
desire_adj_G1=  1.4;
};
/* MarkerInfo
m1 weapon_rocketlauncher 16 -88 320;
m2 weapon_supershotgun 656 -264 144;
m3 item_cells 664 -288 0;
m4 item_rockets 608 -288 0;
m6 weapon_supernailgun 624 -1176 128;
m7 trigger_teleport 1216 -1240 208;
m9 item_armorInv 480 -644 -16;
m10 item_armor1 280 192 0;
m11 item_health 896 -356 6;
m12 item_health 896 -304 6;
m13 weapon_grenadelauncher 816 16 144;
m14 item_rockets 876 44 144;
m15 item_rockets 876 -4 144;
m16 item_spikes 1360 -1088 128;
m17 item_shells 1360 -1040 128;
m18 item_health 1116 -816 128;
m19 item_health 40 -816 256;
m20 item_health 40 -772 256;
m21 item_rockets 28 -440 272;
m22 item_cells 100 -440 272;
m23 item_shells 32 -176 0;
m24 item_health 656 -48 144;
m25 item_health -128 -12 320;
m26 weapon_lightning 128 -1520 -40;
m27 item_cells 592 -720 -16;
m28 item_cells 592 -672 -16;
m29 door 188 -904 44;
m30 trigger_multiple 0 0 0;
m31 item_cells 32 200 320;
m32 item_cells 32 144 320;
m33 trigger_teleport 32 268 432;
m36 trigger_teleport 120 -1948 144;
m37 trigger_teleport 352 80 -20;
m39 item_health 264 344 192;
m40 item_rockets 344 344 192;
m41 item_spikes 816 -832 128;
m42 item_spikes 900 -832 128;
m43 info_player_deathmatch -132 -4 348;
m44 info_player_deathmatch -128 -620 304;
m45 info_player_deathmatch 588 -708 12;
m46 info_player_deathmatch 276 -1244 156;
m47 item_health 320 -1248 128;
m48 info_player_deathmatch 688 -1172 220;
m49 info_player_deathmatch 888 -700 28;
m50 info_player_deathmatch 1260 -436 168;
m51 item_spikes 1020 -216 144;
m52 item_cells 1064 -1112 128;
m53 item_armor2 1352 -864 128;
m8 info_teleport_destination 352 12 15;
m34 info_teleport_destination 120 -1880 115;
m35 info_teleport_destination 32 216 403;
m38 info_teleport_destination 1216 -1160 203;
m54 marker 639 -425 24;
m55 marker 519 -446 24;
m56 marker 341 -578 8;
m57 marker 211 -638 8;
m58 marker 359 -724 8;
m59 marker 477 -881 40;
m60 marker 335 -860 8;
m61 marker 302 -922 8;
m62 marker 239 -778 8;
m63 marker 490 -990 88;
m64 marker 391 -1071 136;
m65 marker 275 -1122 152;
m66 marker 584 -1042 152;
m67 marker 597 -842 152;
m68 marker 136 -1100 184;
m69 marker 75 -964 248;
m70 marker 221 -612 280;
m71 marker 477 -1210 152;
m72 marker 40 -586 280;
m73 marker -125 -471 296;
m74 marker -115 -334 312;
m75 marker -90 -191 344;
m76 marker 189 -97 344;
m77 marker 43 37 344;
m78 marker 284 -430 248;
m79 marker 466 -435 168;
m80 marker 639 -441 168;
m81 marker 839 -437 168;
m82 marker 641 106 136;
m83 marker 512 182 72;
m84 marker 62 -646 8;
m85 marker 100 -457 24;
m86 marker 173 -271 24;
m87 marker 236 -85 24;
m88 marker 303 -256 24;
m89 marker 457 -185 24;
m90 marker 605 -108 24;
m91 marker 492 -31 24;
m92 marker 762 -102 24;
m93 marker 897 -115 24;
m94 marker 809 -307 24;
m95 marker 820 -477 24;
m96 marker 979 -558 72;
m97 marker 1136 -570 152;
m98 marker 86 200 24;
m99 marker 95 -18 24;
m100 marker 366 -106 -8;
m101 marker 1031 -27 168;
m102 marker 1013 -444 168;
m103 marker 1326 -570 168;
m104 marker 1409 -722 152;
m105 marker 1210 -1047 152;
m106 marker 802 -703 152;
m107 marker 1079 -945 152;
m108 marker 121 -1676 52;
m109 marker 116 -1345 -16;
m110 marker 107 -1164 -14;
m111 marker 139 -935 0;
m112 marker 111 -1024 0;
m113 marker 287 -825 8;
m114 marker 215 -904 8;
m115 marker 1215 -1131 160;
m116 marker 355 -12 -56;
m117 marker 123 -1851 56;
m118 marker 385 -769 8;
m119 marker -91 -592 296;
m120 marker 307 264 216;
m121 marker 1205 -461 168;
m122 marker 881 -648 24;
m123 marker 586 -194 168;
m124 marker 296 -709 8;
m125 marker 744 -425 24;
*/
