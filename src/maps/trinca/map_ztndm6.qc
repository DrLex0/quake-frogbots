// Original author unknown
// Updated by DrLex 2025-02 for v2 Frogbot
// - added extra markers and made extra connections
// - fixed broken paths with untouchable teleport destination markers
// - use exclusive path & PJ to make bots get the Quad & use the trick teleports
// - 2025-07: added unreachable markers, tweak jump to Quad
void() map_ztndm6 =
{
// custom markers start at m61
N(701,755,24);N(702,463,24);N(853,614,-152);N(697,1033,24);
N(716,167,24);N(581,1112,24);N(385,861,56);N(373,740,88);
N(10,648,88);N(-72,295,88);N(-266,515,24);N(-661,407,24);
N(-588,39,24);N(-407,-36,24);N(-432,84,-136);N(-189,135,24);
N(4,113,24);N(593,80,24);N(206,-120,24);N(270,-190,-40);
N(421,-23,-136);N(364,108,-168);N(410,288,-168);N(257,413,-168);
N(119,656,-168);N(5,743,-136);N(-191,893,-136);N(261,1072,24);
N(-657,-125,24);N(-674,374,-616);N(416,-160,-88);N(-623,576,24);
N(-341,658,24);N(210,30,24);N(459,124,24);N(-215,416,-136);
N(-183,587,-136);N(45,1083,-168);N(-4,433,88);N(-640,182,24);
N(-635,-55,24);N(384,1069,24);N(-219,227,-136);N(-202,713,-136);
N(121,1086,24);N(280,1085,24);N(-319,737,24);N(-320,576,24);
N(385,996,24);N(234,1116,-144);N(234,1060,-144);N(-495,-46,-200);
N(-366,-48,-200);
LSQ();
Z1(m1);Z1(m2);Z1(m3);Z5(m4);Z5(m5);Z7(m6);Z4(m8);Z5(m10);
Z5(m11);Z5(m12);Z5(m13);Z1(m16);Z2(m17);Z4(m18);Z4(m19);Z4(m20);
Z2(m21);Z7(m22);Z1(m23);Z7(m24);Z7(m25);Z4(m26);Z4(m27);Z4(m28);
Z2(m29);Z6(m30);Z2(m31);Z7(m32);Z3(m33);Z3(m34);Z3(m35);Z7(m36);
Z6(m37);Z5(m38);Z2(m39);Z2(m41);Z3(m42);Z3(m43);Z8(m44);Z3(m45);
Z6(m46);Z2(m47);Z2(m48);Z5(m49);Z9(m50);Z9(m52);Z9(m53);Z9(m54);
Z9(m55);Z9(m56);Z7(m57);Z1(m60);Z7(m7);Z4(m9);Z3(m40);Z9(m51);
Z2(m58);Z5(m59);Z1(m61);Z1(m62);Z1(m63);Z1(m64);Z6(m65);Z2(m66);
Z2(m67);Z2(m68);Z2(m69);Z7(m70);Z7(m71);Z7(m72);Z5(m73);Z5(m74);
Z5(m75);Z6(m76);Z6(m77);Z6(m78);Z6(m79);Z6(m80);Z6(m81);Z6(m82);
Z4(m83);Z4(m84);Z4(m85);Z3(m86);Z3(m87);Z3(m88);Z5(m89);Z9(m90);
Z6(m91);Z7(m92);Z7(m93);Z6(m94);Z6(m95);Z3(m96);Z3(m97);Z3(m98);
Z2(m99);Z5(m100);Z5(m101);Z2(m102);Z5(m103);Z3(m104);Z3(m105);Z3(m106);
Z7(m107);Z7(m108);Z2(m109);Z3(m110);Z3(m111);Z5(m112);Z5(m113);
G1(m1);G2(m2);G3(m10);G14(m16);G4(m17);G5(m18);G6(m21);G7(m22);
G14(m23);G8(m24);G8(m25);G9(m26);G9(m27);G10(m28);G11(m29);G12(m30);
G4(m31);G13(m32);G4(m41);G15(m44);G16(m46);G17(m52);G17(m53);G17(m54);
G17(m55);G17(m56);
m57.view_ofs_z=2;m60.view_ofs_z=-9;
m42.T=32;m57.T=4;m105.T=4;m106.T=4;m107.T=4;m108.T=4;m110.T=4;m111.T=4;
m112.T=1;m113.T=1;
m1.P0=m63;m1.P1=m23;m1.P2=m16;m2.P0=m62;m2.P1=m1;m2.P2=m61;
m3.P0=m40;m4.P1=m89;m5.P0=m12;m5.P1=m4;m6.P0=m9;m8.P0=m7;
m10.P0=m73;m10.P1=m74;m10.P2=m75;m11.P0=m75;m11.P1=m13;m12.P0=m13;
m12.P1=m5;m13.P0=m11;m13.P1=m12;m16.P0=m1;m16.P1=m23;m17.P0=m41;
m17.P1=m31;m17.P2=m69;m18.P0=m20;m18.P1=m19;m18.P2=m28;m19.P0=m20;
m19.P1=m18;m19.P2=m83;m19.P3=m84;m20.P0=m82;m20.P1=m19;m20.P2=m18;
m21.P0=m68;m21.P1=m29;m21.P2=m41;m22.P0=m71;m22.P1=m25;m22.P2=m24;
m22.P3=m93;m22.P4=m92;m22.P5=m108;m23.P0=m1;m23.P1=m16;m24.P0=m25;
m24.P1=m22;m24.P2=m92;m24.P3=m72;m25.P0=m71;m25.P1=m22;m25.P2=m24;
m26.P0=m28;m26.P1=m27;m27.P0=m28;m27.P1=m26;m28.P0=m18;m28.P1=m84;
m28.P2=m85;m28.P3=m27;m28.P4=m26;m29.P0=m21;m29.P1=m68;m29.P2=m84;
m30.P0=m77;m30.P1=m46;m30.P2=m94;m31.P0=m17;m31.P2=m69;m32.P0=m70;
m32.P1=m71;m33.P0=m98;m33.P1=m35;m33.P2=m34;m34.P0=m35;m34.P1=m98;
m34.P2=m33;m35.P0=m87;m35.P1=m34;m35.P2=m33;m36.P2=m92;m37.P0=m46;
m37.P1=m95;m38.P0=m75;m38.P1=m103;m39.P0=m31;m39.P1=m47;m39.P2=m69;
m41.P0=m17;m41.P1=m21;m41.P2=m68;m42.P0=m45;m43.P0=m34;m43.P1=m33;
m43.P3=m98;m44.P0=m98;m45.P0=m98;m45.P1=m88;m46.P0=m30;m46.P1=m77;
m46.P2=m84;m46.P3=m94;m46.P4=m95;m47.P1=m48;m47.P2=m69;m48.P0=m47;
m48.P1=m69;m48.P2=m99;m49.P0=m74;m49.P1=m76;m50.P0=m58;m52.P0=m90;
m52.P1=m55;m52.P2=m54;m53.P0=m90;m53.P1=m55;m54.P0=m90;m54.P1=m52;
m54.P2=m56;m55.P0=m90;m55.P1=m53;m55.P2=m52;m56.P0=m90;m56.P1=m54;
m57.P0=m51;m60.P0=m59;m7.P0=m93;m7.P2=m6;m9.P0=m83;m9.P1=m8;
m40.P0=m86;m40.P1=m87;m40.P2=m97;m51.P0=m90;m51.P1=m50;m58.P0=m66;
m58.P1=m102;m58.P2=m88;m58.P3=m109;m59.P0=m38;m59.P1=m96;m61.P0=m1;
m61.P1=m2;m61.P2=m62;m61.P3=m64;m62.P0=m65;m62.P1=m2;m62.P2=m1;
m62.P3=m61;m63.P0=m1;m63.P1=m3;m63.P2=m60;m64.P0=m61;m64.P1=m66;
m65.P0=m62;m65.P1=m78;m66.P0=m64;m66.P1=m102;m67.P0=m109;m67.P1=m68;
m68.P0=m67;m68.P1=m21;m68.P2=m29;m68.P3=m41;m69.P0=m17;m69.P1=m31;
m69.P3=m47;m69.P4=m48;m69.P6=m99;m70.P1=m99;m70.P2=m32;m71.P0=m32;
m71.P1=m25;m71.P2=m22;m71.P3=m93;m71.P4=m108;m72.P0=m92;m72.P1=m24;
m72.P2=m100;m73.P0=m74;m73.P1=m100;m73.P2=m10;m73.P4=m75;m73.P5=m101;
m74.P0=m73;m74.P1=m10;m74.P2=m49;m74.P4=m101;m75.P0=m11;m75.P1=m38;
m76.P0=m49;m76.P1=m77;m77.P0=m76;m77.P1=m30;m77.P2=m46;m78.P0=m65;
m78.P2=m95;m79.P0=m94;m79.P2=m80;m80.P0=m79;m80.P1=m91;m81.P0=m91;
m81.P1=m82;m82.P0=m81;m82.P1=m20;m82.P2=m83;m83.P0=m82;m83.P1=m19;
m83.P2=m8;m83.P4=m84;m84.P0=m19;m84.P1=m83;m84.P2=m28;m84.P3=m85;
m85.P0=m28;m85.P1=m84;m85.P2=m86;m86.P0=m85;m86.P1=m104;m87.P0=m104;
m87.P1=m35;m88.P1=m102;m88.P2=m98;m89.P3=m101;m90.P0=m52;m90.P1=m54;
m90.P2=m53;m90.P3=m55;m90.P4=m56;m90.P5=m51;m91.P0=m81;m91.P1=m80;
m92.P0=m72;m92.P1=m24;m92.P2=m22;m93.P0=m6;m93.P1=m108;m93.P2=m22;
m93.P3=m71;m94.P0=m30;m94.P1=m79;m94.P2=m46;m95.P0=m46;m95.P1=m78;
m96.P0=m97;m96.P1=m103;m96.P2=m26;m97.P0=m104;m97.P1=m96;m98.P0=m42;
m98.P1=m33;m98.P3=m34;m99.P0=m69;m99.P1=m70;m99.P2=m48;m99.P3=m84;
m100.P0=m73;m100.P1=m72;m101.P0=m73;m101.P1=m74;m101.P2=m5;m102.P0=m109;
m102.P1=m88;m102.P2=m66;m102.P3=m106;m103.P0=m38;m103.P1=m96;m104.P0=m86;
m104.P1=m87;m104.P2=m97;m105.P1=m44;m106.P0=m105;m107.P0=m57;m108.P0=m107;
m109.P0=m67;m109.P1=m102;m110.P0=m45;m110.P1=m98;m111.P0=m98;m111.P1=m45;
m112.P0=m113;m113.P0=m112;
m2.D0=1024;m2.D1=1;m2.D2=1024;m10.D0=1024;m10.D1=1024;m10.D2=1024;
m29.D2=1;m44.D0=1;m46.D2=1;m61.D0=1024;m61.D1=1024;m61.D2=1024;
m62.D1=1024;m62.D2=1024;m62.D3=1024;m63.D2=129;m73.D2=1024;m73.D4=1024;
m74.D1=1024;m99.D3=1;m101.D2=2049;m105.D1=129;m106.D0=1;m107.D0=128;
m110.D0=4;m111.D1=4;
};
/* MarkerInfo
m1 weapon_rocketlauncher 704 608 -160;
m2 item_armorInv 848 608 0;
m3 trigger_teleport 1008 608 -176;
m4 func_button -640 -172 -112;
m5 door -640 -128 -88;
m6 trigger_teleport -320 848 48;
m8 trigger_teleport 560 320 -144;
m10 item_health -400 208 0;
m11 weapon_supershotgun -640 96 -160;
m12 item_shells -672 -32 -160;
m13 item_shells -672 0 -160;
m16 item_health 608 576 -160;
m17 item_health 96 736 64;
m18 weapon_lightning 128 192 -160;
m19 item_cells 192 192 -160;
m20 item_cells 192 160 -160;
m21 weapon_grenadelauncher 352 576 64;
m22 weapon_rocketlauncher -416 576 0;
m23 item_health 608 608 -160;
m24 item_rockets -448 496 0;
m25 item_rockets -416 496 0;
m26 item_health -96 448 -224;
m27 item_health -96 480 -224;
m28 item_armor2 32 480 -224;
m29 item_rockets 400 544 64;
m30 item_health 64 32 0;
m31 item_health 64 736 64;
m32 item_armor1 -256 320 64;
m33 weapon_supernailgun -64 1088 -192;
m34 item_spikes -64 912 -192;
m35 item_spikes -96 912 -192;
m36 info_player_deathmatch -672 640 32;
m37 info_player_deathmatch 432 48 32;
m38 info_player_deathmatch -192 64 -128;
m39 info_player_deathmatch -64 736 96;
m41 item_health 128 736 64;
m42 func_button 252 1088 -112;
m43 info_player_deathmatch 32 960 -160;
m44 item_artifact_super_damage -96 1088 24;
m45 door 208 1088 -248;
m46 item_armor1 288 128 0;
m47 item_spikes -96 576 64;
m48 item_cells -96 544 64;
m49 info_player_deathmatch -160 -96 32;
m50 trigger_teleport -656 528 -592;
m52 item_health -672 176 -640;
m53 item_cells -752 176 -640;
m54 item_rockets -624 176 -640;
m55 item_shells -720 176 -640;
m56 item_spikes -592 176 -640;
m57 trigger_teleport -320 828 80;
m60 trigger_teleport 988 608 -100;
m7 info_teleport_destination -312 800 51;
m9 info_teleport_destination 512 320 -141;
m40 info_teleport_destination -224 704 -101;
m51 info_teleport_destination -656 480 -581;
m58 info_teleport_destination 384 1088 59;
m59 info_teleport_destination -224 256 -101;
m61 marker 701 755 24;
m62 marker 702 463 24;
m63 marker 853 614 -152;
m64 marker 697 1033 24;
m65 marker 716 167 24;
m66 marker 581 1112 24;
m67 marker 385 861 56;
m68 marker 373 740 88;
m69 marker 10 648 88;
m70 marker -72 295 88;
m71 marker -266 515 24;
m72 marker -661 407 24;
m73 marker -588 39 24;
m74 marker -407 -36 24;
m75 marker -432 84 -136;
m76 marker -189 135 24;
m77 marker 4 113 24;
m78 marker 593 80 24;
m79 marker 206 -120 24;
m80 marker 270 -190 -40;
m81 marker 421 -23 -136;
m82 marker 364 108 -168;
m83 marker 410 288 -168;
m84 marker 257 413 -168;
m85 marker 119 656 -168;
m86 marker 5 743 -136;
m87 marker -191 893 -136;
m88 marker 261 1072 24;
m89 marker -657 -125 24;
m90 marker -674 374 -616;
m91 marker 416 -160 -88;
m92 marker -623 576 24;
m93 marker -341 658 24;
m94 marker 210 30 24;
m95 marker 459 124 24;
m96 marker -215 416 -136;
m97 marker -183 587 -136;
m98 marker 45 1083 -168;
m99 marker -4 433 88;
m100 marker -640 182 24;
m101 marker -635 -55 24;
m102 marker 384 1069 24;
m103 marker -219 227 -136;
m104 marker -202 713 -136;
m105 marker 121 1086 24;
m106 marker 280 1085 24;
m107 marker -319 737 24;
m108 marker -320 576 24;
m109 marker 385 996 24;
m110 marker 234 1116 -144;
m111 marker 234 1060 -144;
m112 marker -495 -46 -200;
m113 marker -366 -48 -200;
*/
