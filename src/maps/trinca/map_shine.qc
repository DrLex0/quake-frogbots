// Original 25-01-2005 by Trinca
// Minor tweaks by DrLex 2025-04
void() map_shine =
{
// custom markers start at m35
N(724,-522,216);N(593,-509,216);N(423,-505,216);N(255,-503,216);
N(515,-585,216);N(522,-815,216);N(532,-955,216);N(399,-898,216);
N(248,-904,216);N(119,-904,216);N(188,-1018,216);N(-197,-887,216);
N(-341,-894,216);N(-495,-863,216);N(-524,-740,216);N(-511,-560,216);
N(-376,-526,216);N(196,-1142,216);N(185,-1297,216);N(155,-1455,216);
N(-129,-1495,216);N(-200,-1227,216);N(-188,-1088,216);N(-176,-987,216);
N(-253,-509,216);N(-100,-516,216);N(22,-517,216);N(117,-520,216);
N(23,-619,216);N(171,-418,216);N(-184,-415,216);N(-205,-260,200);
N(-169,-124,168);N(-36,-64,136);N(167,-109,104);N(205,-248,72);
N(189,-383,40);N(-1,-387,24);N(-1,-546,24);N(-2,-664,24);
N(141,-684,24);N(280,-702,24);N(-149,-676,24);N(-320,-688,24);
N(130,-566,24);N(-100,-570,24);N(0,-807,24);N(1,-972,24);
N(1,-1117,24);N(4,-1256,24);N(-138,-1239,24);N(-290,-1228,24);
N(-447,-1245,24);N(-578,-1241,24);N(155,-1246,24);N(296,-1247,24);
N(426,-1247,24);N(124,-1097,24);N(-126,-1117,24);N(-712,-1246,24);
N(-712,-1384,24);N(-706,-1104,24);N(-711,-975,24);N(-709,-816,24);
N(-726,-642,24);N(-442,-700,24);N(-597,-703,24);N(-866,-698,16);
N(-594,-582,24);N(-539,-822,24);N(570,-1216,24);N(556,-1099,24);
N(590,-969,24);N(414,-703,24);N(534,-798,24);N(690,-909,24);
N(705,-1097,16);N(815,-881,56);N(938,-860,88);N(1045,-733,120);
N(1024,-590,152);N(822,-519,200);N(961,-529,168);N(739,-701,360);
N(771,-814,360);N(763,-585,360);
LSQ();
Z7(m1);Z7(m2);Z1(m3);Z9(m4);Z4(m5);Z6(m6);Z7(m7);Z6(m8);
Z3(m9);Z1(m10);Z9(m11);Z2(m12);Z6(m13);Z6(m14);Z2(m15);Z1(m16);
Z9(m17);Z4(m18);Z9(m19);Z7(m20);Z3(m21);Z3(m22);Z8(m23);Z11(m24);
Z8(m26);Z8(m27);Z11(m29);Z8(m30);Z2(m31);Z9(m32);Z4(m33);Z8(m34);
Z8(m25);Z11(m28);Z1(m35);Z1(m36);Z1(m37);Z1(m38);Z1(m39);Z1(m40);
Z1(m41);Z1(m42);Z2(m43);Z2(m44);Z3(m45);Z2(m46);Z2(m47);Z2(m48);
Z2(m49);Z2(m50);Z2(m51);Z3(m52);Z3(m53);Z3(m54);Z3(m55);Z3(m56);
Z3(m57);Z3(m58);Z4(m59);Z4(m60);Z4(m61);Z4(m62);Z4(m63);Z4(m64);
Z4(m65);Z5(m66);Z5(m67);Z5(m68);Z5(m69);Z5(m70);Z5(m71);Z6(m72);
Z6(m73);Z6(m74);Z6(m75);Z6(m76);Z6(m77);Z6(m78);Z6(m79);Z6(m80);
Z6(m81);Z7(m82);Z7(m83);Z7(m84);Z7(m85);Z7(m86);Z7(m87);Z7(m88);
Z7(m89);Z7(m90);Z7(m91);Z7(m92);Z7(m93);Z8(m94);Z8(m95);Z8(m96);
Z8(m97);Z8(m98);Z8(m99);Z8(m100);Z8(m101);Z8(m102);Z8(m103);Z8(m104);
Z9(m105);Z9(m106);Z9(m107);Z9(m108);Z9(m109);Z9(m110);Z9(m111);Z10(m112);
Z10(m113);Z10(m114);Z10(m115);Z10(m116);Z10(m117);Z11(m118);Z11(m119);
Z11(m120);
G11(m1);G22(m2);G8(m3);G20(m4);G6(m5);G1(m6);G13(m7);G17(m12);
G14(m13);G10(m15);G9(m16);G7(m17);G21(m18);G23(m19);G12(m20);G3(m21);
G16(m22);G18(m23);G5(m24);G4(m26);G2(m27);G10(m31);G15(m32);
m1.P0=m84;m1.P1=m7;m1.P2=m85;m1.P3=m89;m1.P4=m90;m2.P0=m85;
m2.P1=m86;m3.P0=m37;m3.P1=m36;m3.P2=m39;m4.P0=m17;m4.P1=m105;
m5.P0=m62;m5.P1=m38;m5.P2=m74;m6.P0=m72;m7.P0=m1;m8.P0=m72;
m8.P1=m13;m8.P2=m80;m9.P0=m55;m9.P1=m56;m9.P2=m1;m10.P0=m35;
m10.P1=m36;m10.P2=m116;m11.P0=m105;m11.P1=m91;m11.P2=m17;m12.P0=m50;
m13.P0=m8;m13.P1=m80;m13.P2=m77;m14.P0=m71;m14.P1=m79;m15.P0=m31;
m15.P1=m46;m16.P0=m39;m16.P1=m40;m17.P0=m105;m17.P1=m111;m17.P2=m4;
m18.P0=m60;m18.P1=m59;m19.P0=m107;m19.P1=m109;m20.P0=m90;m20.P1=m89;
m21.P0=m54;m21.P1=m55;m21.P2=m22;m21.P3=m1;m22.P0=m55;m22.P1=m21;
m22.P2=m54;m23.P0=m102;m23.P1=m99;m23.P2=m98;m23.P3=m49;m24.P0=m118;
m24.P1=m119;m24.P2=m120;m24.P3=m114;m26.P0=m94;m27.P0=m102;m29.P0=m25;
m30.P0=m28;m31.P0=m44;m31.P1=m15;m32.P0=m109;m32.P1=m108;m33.P0=m63;
m33.P1=m60;m34.P0=m103;m34.P1=m99;m25.P0=m30;m25.P1=m95;m28.P0=m29;
m28.P1=m118;m35.P0=m36;m35.P1=m116;m36.P0=m3;m36.P1=m39;m36.P2=m35;
m37.P0=m38;m37.P1=m39;m37.P2=m3;m38.P0=m37;m38.P1=m64;m38.P2=m62;
m38.P3=m5;m39.P0=m37;m39.P1=m36;m39.P2=m3;m39.P3=m16;m40.P0=m16;
m40.P1=m41;m40.P2=m42;m41.P0=m40;m41.P1=m42;m41.P2=m105;m41.P3=m112;
m42.P0=m41;m42.P1=m40;m42.P2=m43;m43.P0=m42;m43.P1=m44;m43.P2=m45;
m44.P0=m43;m44.P1=m31;m44.P2=m45;m45.P0=m43;m45.P1=m44;m45.P2=m52;
m46.P0=m15;m46.P1=m47;m46.P2=m58;m47.P0=m46;m47.P1=m48;m48.P0=m47;
m48.P1=m49;m48.P2=m98;m49.P0=m48;m49.P1=m50;m49.P2=m102;m50.P0=m49;
m50.P1=m51;m50.P2=m102;m50.P3=m12;m51.P0=m50;m52.P0=m45;m52.P1=m53;
m52.P2=m1;m53.P0=m52;m53.P1=m54;m53.P2=m1;m54.P0=m53;m54.P1=m21;
m54.P2=m22;m54.P3=m1;m55.P0=m21;m55.P1=m22;m55.P2=m9;m55.P3=m1;
m56.P0=m9;m56.P1=m57;m56.P2=m1;m57.P0=m56;m57.P1=m58;m57.P2=m83;
m58.P0=m57;m58.P1=m46;m59.P0=m65;m59.P1=m60;m59.P2=m18;m60.P0=m59;
m60.P1=m18;m60.P2=m61;m60.P3=m63;m60.P4=m65;m61.P0=m60;m61.P1=m63;
m61.P2=m62;m61.P3=m6;m62.P0=m61;m62.P1=m64;m62.P2=m38;m62.P3=m5;
m62.P4=m63;m63.P0=m61;m63.P1=m62;m63.P2=m60;m63.P3=m74;m64.P0=m62;
m64.P1=m38;m64.P2=m6;m65.P0=m59;m65.P1=m60;m65.P2=m66;m65.P3=m6;
m66.P0=m65;m66.P1=m67;m66.P2=m6;m67.P0=m66;m67.P1=m68;m67.P2=m6;
m68.P0=m67;m68.P1=m69;m68.P2=m6;m69.P0=m68;m69.P1=m70;m69.P2=m6;
m70.P0=m69;m70.P1=m71;m70.P2=m6;m71.P0=m70;m71.P1=m14;m71.P2=m79;
m72.P0=m73;m72.P1=m6;m72.P2=m8;m72.P3=m79;m72.P4=m80;m73.P0=m79;
m73.P1=m72;m73.P2=m74;m73.P3=m80;m74.P0=m77;m74.P1=m81;m74.P2=m75;
m74.P3=m80;m74.P4=m73;m74.P5=m79;m75.P0=m74;m75.P1=m76;m75.P2=m79;
m76.P0=m75;m76.P1=m108;m77.P0=m80;m77.P1=m13;m77.P2=m74;m77.P3=m78;
m78.P0=m100;m78.P1=m77;m79.P0=m14;m79.P1=m73;m79.P2=m75;m79.P3=m71;
m79.P4=m72;m79.P5=m74;m80.P0=m13;m80.P1=m77;m80.P2=m72;m80.P3=m74;
m80.P4=m73;m80.P5=m8;m81.P0=m74;m81.P1=m82;m82.P0=m81;m82.P1=m83;
m83.P0=m82;m83.P1=m84;m83.P2=m92;m83.P3=m93;m83.P4=m85;m84.P0=m83;
m84.P1=m1;m84.P2=m85;m84.P3=m89;m84.P4=m21;m84.P5=m56;m84.P6=m53;
m85.P0=m1;m85.P1=m84;m85.P2=m93;m85.P3=m2;m85.P4=m86;m85.P5=m83;
m86.P0=m2;m86.P1=m87;m86.P2=m85;m87.P0=m86;m87.P1=m88;m88.P0=m87;
m88.P1=m94;m89.P0=m84;m89.P1=m90;m89.P2=m20;m89.P3=m92;m89.P4=m1;
m90.P0=m89;m90.P1=m91;m90.P2=m20;m90.P3=m1;m91.P0=m90;m91.P1=m105;
m92.P0=m89;m92.P1=m83;m93.P0=m83;m93.P1=m85;m94.P0=m95;m94.P1=m26;
m94.P2=m88;m94.P3=m96;m95.P0=m25;m95.P1=m94;m96.P0=m94;m96.P1=m97;
m97.P0=m96;m97.P1=m98;m98.P0=m97;m98.P1=m104;m98.P2=m102;m98.P3=m99;
m98.P4=m101;m98.P5=m23;m99.P0=m101;m99.P1=m102;m99.P2=m98;m99.P3=m103;
m99.P4=m23;m100.P0=m104;m100.P1=m78;m100.P2=m101;m100.P3=m103;m101.P0=m100;
m101.P1=m99;m101.P2=m98;m101.P3=m103;m101.P4=m104;m102.P0=m27;m102.P1=m98;
m102.P2=m99;m102.P3=m23;m103.P0=m100;m103.P2=m101;m103.P3=m99;m104.P0=m98;
m104.P1=m100;m104.P2=m101;m105.P0=m91;m105.P1=m17;m105.P2=m106;m105.P3=m4;
m106.P0=m105;m106.P1=m107;m106.P2=m111;m106.P3=m41;m107.P0=m110;m107.P1=m106;
m107.P2=m19;m107.P3=m109;m107.P4=m111;m108.P0=m109;m108.P1=m76;m108.P2=m32;
m109.P0=m19;m109.P1=m32;m109.P2=m108;m109.P3=m107;m109.P4=m110;m110.P0=m107;
m110.P1=m109;m110.P2=m111;m110.P3=m112;m111.P0=m17;m111.P1=m107;m111.P2=m106;
m111.P3=m110;m112.P0=m110;m112.P1=m113;m113.P0=m112;m113.P1=m114;m114.P0=m113;
m114.P1=m115;m115.P0=m114;m115.P1=m117;m116.P0=m117;m116.P1=m35;m117.P0=m115;
m117.P1=m116;m118.P0=m28;m118.P1=m24;m118.P2=m120;m118.P3=m119;m119.P0=m118;
m119.P1=m24;m119.P2=m111;m119.P3=m41;m120.P0=m118;m120.P1=m24;m120.P2=m36;
m5.D2=1024;m9.D2=1024;m21.D3=1024;m23.D3=512;m24.D3=1024;m41.D2=1024;
m41.D3=1024;m48.D2=1024;m49.D2=1024;m50.D2=1024;m52.D2=1024;m53.D2=1024;
m54.D3=1024;m55.D3=1024;m56.D2=1024;m57.D2=1024;m61.D3=1024;m63.D3=1024;
m64.D2=1024;m65.D3=1024;m66.D2=1024;m67.D2=1024;m68.D2=1024;m69.D2=1024;
m70.D2=1024;m84.D4=512;m84.D5=512;m84.D6=512;m106.D3=512;m119.D2=1024;
m119.D3=1024;m120.D2=1024;
};
/* MarkerInfo
m1 item_artifact_super_damage 0 -1344 24;
m2 item_shells -240 -1344 0;
m3 item_health 496 -400 192;
m4 item_health 720 -1360 -10;
m5 item_armor2 192 -704 192;
m6 weapon_rocketlauncher 0 -256 0;
m7 item_health -16 -1456 0;
m8 info_player_deathmatch -144 -416 24;
m9 info_player_deathmatch -192 -1384 216;
m10 info_player_deathmatch 752 -400 216;
m11 info_player_deathmatch 528 -1344 24;
m12 item_rockets -560 -512 198;
m13 item_rockets -208 -520 0;
m14 item_cells 192 -528 0;
m15 item_health -48 -912 192;
m16 weapon_supershotgun 512 -704 192;
m17 weapon_grenadelauncher 736 -1248 -8;
m18 item_cells -208 -640 192;
m19 item_shells 464 -928 0;
m20 item_rockets 208 -1344 0;
m21 weapon_rocketlauncher 0 -1512 192;
m22 item_rockets -16 -1576 192;
m23 item_health -784 -720 -10;
m24 item_health 880 -720 336;
m26 item_armor2 -800 -1248 0;
m27 weapon_lightning -960 -704 -8;
m29 trigger_teleport 608 -704 404;
m30 trigger_teleport -704 -1528 76;
m31 item_health 16 -912 192;
m32 item_health 560 -688 0;
m33 info_player_deathmatch -96 -736 216;
m34 info_player_deathmatch -704 -432 24;
m25 info_teleport_destination -704 -1496 35;
m28 info_teleport_destination 664 -704 379;
m35 marker 724 -522 216;
m36 marker 593 -509 216;
m37 marker 423 -505 216;
m38 marker 255 -503 216;
m39 marker 515 -585 216;
m40 marker 522 -815 216;
m41 marker 532 -955 216;
m42 marker 399 -898 216;
m43 marker 248 -904 216;
m44 marker 119 -904 216;
m45 marker 188 -1018 216;
m46 marker -197 -887 216;
m47 marker -341 -894 216;
m48 marker -495 -863 216;
m49 marker -524 -740 216;
m50 marker -511 -560 216;
m51 marker -376 -526 216;
m52 marker 196 -1142 216;
m53 marker 185 -1297 216;
m54 marker 155 -1455 216;
m55 marker -129 -1495 216;
m56 marker -200 -1227 216;
m57 marker -188 -1088 216;
m58 marker -176 -987 216;
m59 marker -253 -509 216;
m60 marker -100 -516 216;
m61 marker 22 -517 216;
m62 marker 117 -520 216;
m63 marker 23 -619 216;
m64 marker 171 -418 216;
m65 marker -184 -415 216;
m66 marker -205 -260 200;
m67 marker -169 -124 168;
m68 marker -36 -64 136;
m69 marker 167 -109 104;
m70 marker 205 -248 72;
m71 marker 189 -383 40;
m72 marker -1 -387 24;
m73 marker -1 -546 24;
m74 marker -2 -664 24;
m75 marker 141 -684 24;
m76 marker 280 -702 24;
m77 marker -149 -676 24;
m78 marker -320 -688 24;
m79 marker 130 -566 24;
m80 marker -100 -570 24;
m81 marker 0 -807 24;
m82 marker 1 -972 24;
m83 marker 1 -1117 24;
m84 marker 4 -1256 24;
m85 marker -138 -1239 24;
m86 marker -290 -1228 24;
m87 marker -447 -1245 24;
m88 marker -578 -1241 24;
m89 marker 155 -1246 24;
m90 marker 296 -1247 24;
m91 marker 426 -1247 24;
m92 marker 124 -1097 24;
m93 marker -126 -1117 24;
m94 marker -712 -1246 24;
m95 marker -712 -1384 24;
m96 marker -706 -1104 24;
m97 marker -711 -975 24;
m98 marker -709 -816 24;
m99 marker -726 -642 24;
m100 marker -442 -700 24;
m101 marker -597 -703 24;
m102 marker -866 -698 16;
m103 marker -594 -582 24;
m104 marker -539 -822 24;
m105 marker 570 -1216 24;
m106 marker 556 -1099 24;
m107 marker 590 -969 24;
m108 marker 414 -703 24;
m109 marker 534 -798 24;
m110 marker 690 -909 24;
m111 marker 705 -1097 16;
m112 marker 815 -881 56;
m113 marker 938 -860 88;
m114 marker 1045 -733 120;
m115 marker 1024 -590 152;
m116 marker 822 -519 200;
m117 marker 961 -529 168;
m118 marker 739 -701 360;
m119 marker 771 -814 360;
m120 marker 763 -585 360;
*/
