// Original author unknown. Fixes by DrLex 2025/01-03
// (I suspect changes have been made to the map since original waypoints were made.)
// - Add rocket jumps and fix access to hidden megahealth
// - Add paths through slime, relying on new slime/biosuit awareness
// - Fix overly connected teleporters causing telefrag-fest
// - Improved paths. Don't deliberately jump into slime FFS.
// - Tweaked goals
// This map also deserves a honourable mention for the sheer amount of bugs
// it has exposed in the existing FrogBot implementation.
void() map_efdm13 =
{
// custom markers start at m73
N(911,-392,184);N(914,-252,184);N(1158,69,184);N(1019,374,24);
N(929,262,24);N(826,397,24);N(926,72,-136);N(745,70,-136);
N(600,-137,-136);N(442,-144,-136);N(859,224,-152);N(853,347,-168);
N(713,234,-136);N(726,406,-152);N(599,413,-136);N(257,-159,-136);
N(360,-409,-136);N(345,-258,-136);N(126,-161,-136);N(-19,-148,-136);
N(-210,-141,-136);N(-314,-159,-136);N(-457,-21,-136);N(-454,167,-136);
N(-633,158,-136);N(-618,159,184);N(-440,312,-136);N(-429,450,-136);
N(-569,391,-136);N(-702,385,-136);N(-292,461,-120);N(-850,421,-136);
N(-980,414,-136);N(-1169,344,-136);N(-1019,253,-120);N(-1034,150,-72);
N(-1047,52,-56);N(-844,-62,-40);N(-699,-58,24);N(-584,-70,24);
N(-443,-90,24);N(-302,-9,24);N(-215,104,24);N(-399,-235,24);
N(-388,-372,24);N(-90,-391,24);N(32,-303,24);N(30,-153,24);
N(201,98,24);N(83,142,24);N(60,328,8);N(66,440,8);
N(-44,451,8);N(-168,455,-56);N(203,445,-8);N(345,451,-88);
N(474,439,-136);N(1163,200,184);N(771,-322,184);N(618,-330,184);
N(492,-321,184);N(350,-503,184);N(358,-416,184);N(358,-258,184);
N(240,-315,184);N(347,59,184);N(204,145,184);N(63,124,184);
N(94,292,184);N(-68,447,184);N(-225,453,184);N(-295,284,184);
N(-463,163,184);N(-249,168,184);N(-358,-57,184);N(-326,-259,184);
N(-173,-449,184);N(-56,-452,184);N(1,-449,331);N(109,-450,344);
N(321,-338,344);N(348,-156,344);N(358,-3,344);N(437,71,344);
N(300,126,344);N(97,164,344);N(692,414,24);N(355,23,-200);
N(-80,-194,184);N(-80,-71,184);N(429,77,-119);N(332,-61,-136);
N(126,448,378);N(28,447,184);N(704,384,184);N(264,117,-200);
N(229,10,-200);N(1389,23,-70);N(1376,410,-56);N(-935,-138,-40);
N(1279,0,210);N(-928,-254,-95);N(1392,0,-186);N(1395,-205,24);
N(1379,159,-72);N(1373,160,24);N(-88,-114,248);N(1388,-82,-65);
N(40,-274,344);
LSQ();
Z6(m1);Z1(m2);Z7(m4);Z3(m5);Z1(m6);Z6(m7);Z6(m8);Z6(m9);
Z10(m11);Z2(m13);Z2(m14);Z7(m15);Z12(m17);Z4(m18);Z9(m20);Z4(m22);
Z4(m23);Z4(m24);Z8(m25);Z8(m26);Z9(m27);Z12(m28);Z12(m29);Z5(m30);
Z5(m31);Z5(m32);Z7(m33);Z7(m34);Z7(m35);Z9(m36);Z13(m37);Z13(m38);
Z7(m40);Z13(m41);Z6(m42);Z6(m43);Z5(m44);Z3(m45);Z15(m46);Z10(m47);
Z1(m48);Z5(m49);Z4(m50);Z6(m51);Z6(m52);Z2(m53);Z4(m54);Z2(m55);
Z3(m56);Z1(m57);Z7(m58);Z2(m59);Z2(m60);Z1(m61);Z8(m62);Z11(m63);
Z11(m66);Z11(m67);Z9(m68);Z11(m69);Z14(m70);Z1(m3);Z10(m10);Z6(m12);
Z7(m16);Z4(m19);Z9(m21);Z11(m64);Z11(m65);Z7(m73);Z7(m74);Z7(m75);
Z12(m76);Z12(m77);Z12(m78);Z1(m79);Z1(m80);Z1(m81);Z1(m82);Z1(m83);
Z1(m84);Z1(m85);Z1(m86);Z1(m87);Z2(m88);Z2(m89);Z2(m90);Z2(m91);
Z2(m92);Z2(m93);Z2(m94);Z3(m95);Z3(m96);Z3(m97);Z9(m98);Z3(m99);
Z3(m100);Z3(m101);Z4(m102);Z3(m103);Z4(m104);Z4(m105);Z4(m106);Z4(m107);
Z4(m108);Z5(m109);Z5(m110);Z5(m111);Z5(m112);Z5(m113);Z5(m114);Z5(m115);
Z5(m116);Z6(m117);Z6(m118);Z6(m119);Z6(m120);Z6(m121);Z6(m122);Z6(m123);
Z6(m124);Z6(m125);Z6(m126);Z6(m127);Z6(m128);Z1(m129);Z7(m130);Z7(m131);
Z7(m132);Z7(m133);Z8(m134);Z8(m135);Z8(m136);Z8(m137);Z8(m138);Z8(m139);
Z8(m140);Z8(m141);Z9(m142);Z9(m143);Z9(m144);Z9(m145);Z9(m146);Z9(m147);
Z9(m148);Z9(m149);Z9(m150);Z10(m151);Z10(m152);Z10(m153);Z10(m154);Z10(m155);
Z10(m156);Z10(m157);Z10(m158);Z12(m159);Z2(m160);Z15(m161);Z15(m162);Z2(m163);
Z2(m164);Z13(m165);Z9(m166);Z13(m167);Z2(m168);Z2(m169);Z11(m170);Z11(m171);
Z5(m172);Z7(m173);Z11(m174);Z11(m175);Z11(m176);Z11(m177);Z11(m178);Z15(m179);
Z11(m180);Z10(m181);
G5(m17);G12(m22);G12(m23);G12(m24);G14(m25);G14(m26);G17(m27);G16(m28);
G16(m29);G18(m32);G15(m33);G10(m36);G23(m40);G6(m41);G22(m42);G22(m43);
G2(m44);G3(m45);G11(m46);G4(m47);G2(m48);G9(m50);G13(m51);G13(m52);
G8(m53);G17(m54);G13(m56);G22(m57);G17(m61);G7(m62);G1(m63);G16(m69);
m5.view_ofs_z=41;m67.view_ofs_z=25;
m14.T=32;m63.T=8;m66.T=2;m67.T=2;m69.T=10;m64.T=2;m65.T=2;m160.T=1;
m161.T=1;m162.T=1;m168.T=1;m169.T=1;m176.T=2;m178.T=2;
m1.P1=m10;m2.P1=m16;m4.P0=m58;m4.P1=m17;m5.P1=m98;m6.P0=m82;
m6.P1=m81;m7.P0=m8;m7.P1=m124;m8.P0=m124;m8.P1=m7;m9.P0=m118;
m9.P1=m119;m11.P1=m12;m13.P0=m89;m13.P1=m134;m14.P0=m13;m15.P1=m3;
m17.P0=m76;m18.P1=m21;m20.P1=m19;m22.P0=m106;m22.P1=m24;m22.P2=m23;
m22.P3=m105;m23.P0=m24;m23.P1=m18;m23.P2=m105;m23.P3=m22;m24.P0=m22;
m24.P1=m23;m25.P0=m138;m25.P1=m26;m26.P0=m25;m26.P1=m139;m26.P2=m138;
m27.P0=m142;m27.P1=m141;m28.P0=m29;m28.P1=m76;m29.P0=m78;m29.P1=m28;
m29.P2=m76;m30.P0=m115;m30.P1=m32;m30.P2=m31;m31.P0=m30;m31.P1=m32;
m31.P2=m96;m32.P0=m30;m32.P1=m31;m33.P0=m40;m33.P1=m74;m33.P2=m79;
m34.P0=m35;m34.P1=m16;m35.P0=m34;m35.P1=m73;m35.P2=m16;m36.P0=m147;
m36.P1=m146;m36.P2=m145;m36.P3=m144;m40.P0=m75;m40.P1=m33;m40.P2=m74;
m40.P3=m79;m40.P4=m173;m41.P0=m167;m42.P0=m43;m42.P1=m1;m42.P2=m120;
m43.P0=m122;m43.P1=m42;m43.P2=m1;m43.P3=m121;m43.P4=m179;m44.P0=m110;
m44.P1=m109;m44.P2=m172;m45.P0=m97;m45.P1=m5;m46.P1=m179;m47.P0=m152;
m47.P1=m153;m47.P2=m181;m48.P0=m84;m48.P1=m86;m49.P0=m44;m49.P1=m110;
m50.P0=m104;m50.P1=m105;m51.P0=m118;m51.P1=m52;m52.P0=m51;m52.P1=m117;
m52.P2=m116;m53.P1=m163;m54.P0=m106;m55.P0=m90;m55.P1=m88;m55.P2=m91;
m55.P3=m89;m56.P0=m94;m56.P1=m95;m57.P0=m80;m57.P1=m81;m58.P1=m17;
m59.P0=m92;m59.P1=m93;m60.P0=m59;m60.P1=m92;m60.P2=m93;m61.P0=m87;
m61.P1=m85;m61.P2=m129;m62.P0=m136;m62.P1=m138;m62.P2=m120;m63.P0=m177;
m66.P1=m64;m67.P0=m65;m68.P0=m149;m68.P1=m148;m69.P0=m176;m3.P0=m79;
m3.P1=m2;m10.P0=m156;m10.P1=m11;m12.P0=m43;m12.P1=m42;m12.P2=m1;
m16.P0=m73;m16.P1=m15;m16.P2=m35;m16.P3=m34;m19.P0=m18;m19.P1=m105;
m19.P2=m104;m19.P3=m23;m21.P0=m143;m21.P1=m20;m64.P0=m171;m65.P0=m174;
m65.P1=m66;m73.P0=m74;m73.P1=m131;m73.P2=m16;m73.P3=m35;m74.P0=m33;
m74.P1=m73;m74.P2=m131;m74.P3=m40;m75.P0=m130;m75.P1=m40;m75.P2=m79;
m75.P3=m173;m76.P0=m17;m76.P1=m77;m76.P2=m28;m76.P3=m78;m76.P4=m29;
m77.P0=m76;m77.P1=m78;m77.P2=m79;m78.P0=m77;m78.P1=m159;m78.P2=m29;
m78.P3=m76;m79.P0=m83;m79.P1=m80;m79.P2=m2;m80.P0=m79;m80.P1=m85;
m80.P2=m83;m80.P3=m57;m80.P4=m81;m81.P0=m57;m81.P1=m82;m81.P2=m80;
m82.P0=m81;m82.P1=m88;m82.P2=m90;m83.P0=m84;m83.P1=m85;m83.P2=m79;
m83.P3=m80;m84.P0=m86;m84.P1=m48;m84.P2=m83;m84.P3=m85;m85.P0=m61;
m85.P1=m86;m85.P2=m87;m85.P3=m83;m85.P4=m84;m85.P5=m80;m86.P0=m87;
m86.P1=m85;m86.P2=m84;m86.P3=m48;m87.P0=m86;m87.P1=m61;m87.P2=m85;
m87.P3=m129;m88.P0=m82;m88.P1=m91;m88.P2=m90;m88.P3=m55;m88.P4=m164;
m89.P0=m90;m89.P1=m14;m89.P2=m55;m90.P0=m88;m90.P1=m55;m90.P2=m89;
m90.P3=m82;m91.P0=m88;m91.P1=m92;m91.P2=m55;m92.P0=m91;m92.P1=m93;
m92.P2=m59;m93.P0=m92;m93.P1=m59;m93.P2=m94;m94.P0=m93;m94.P1=m56;
m94.P2=m95;m95.P0=m96;m95.P1=m56;m95.P2=m94;m96.P0=m99;m96.P1=m97;
m96.P2=m95;m97.P0=m96;m97.P1=m45;m98.P0=m145;m99.P0=m101;m99.P1=m100;
m99.P2=m103;m99.P3=m96;m100.P0=m103;m100.P1=m101;m100.P2=m99;m101.P0=m100;
m101.P1=m102;m101.P2=m99;m102.P0=m101;m102.P1=m104;m103.P0=m100;m103.P1=m99;
m103.P2=m126;m104.P0=m105;m104.P1=m18;m104.P2=m102;m104.P3=m50;m105.P0=m18;
m105.P1=m104;m105.P2=m107;m105.P3=m106;m105.P4=m23;m105.P5=m22;m105.P6=m50;
m106.P0=m105;m106.P1=m22;m107.P0=m105;m107.P1=m108;m108.P0=m107;m108.P1=m109;
m109.P0=m44;m109.P1=m108;m109.P2=m54;m110.P0=m111;m110.P1=m44;m110.P2=m172;
m111.P0=m112;m111.P1=m110;m112.P0=m113;m112.P1=m111;m113.P0=m116;m113.P1=m114;
m113.P2=m112;m113.P3=m96;m114.P0=m113;m114.P1=m115;m114.P2=m96;m115.P0=m114;
m115.P1=m30;m115.P2=m96;m116.P0=m113;m116.P1=m117;m116.P2=m52;m117.P0=m52;
m117.P1=m116;m118.P0=m119;m118.P1=m51;m119.P0=m120;m119.P1=m118;m120.P0=m42;
m120.P1=m119;m121.P0=m122;m121.P1=m53;m121.P2=m43;m122.P0=m123;m122.P1=m121;
m122.P2=m43;m123.P0=m124;m123.P1=m122;m124.P0=m127;m124.P1=m8;m124.P2=m125;
m124.P3=m123;m125.P0=m124;m125.P1=m126;m126.P0=m125;m126.P1=m103;m127.P0=m128;
m127.P1=m124;m128.P0=m129;m128.P1=m127;m129.P0=m87;m129.P1=m61;m129.P2=m128;
m130.P0=m17;m130.P1=m75;m131.P0=m73;m131.P1=m74;m131.P2=m132;m132.P0=m131;
m132.P1=m133;m133.P0=m132;m133.P1=m136;m133.P2=m135;m134.P0=m13;m134.P1=m135;
m135.P0=m136;m135.P1=m133;m135.P2=m137;m135.P3=m13;m136.P0=m133;m136.P1=m135;
m136.P2=m137;m136.P3=m62;m136.P4=m120;m137.P0=m136;m137.P1=m135;m138.P0=m62;
m138.P1=m25;m138.P2=m139;m138.P3=m26;m139.P0=m26;m139.P1=m138;m139.P2=m140;
m139.P3=m141;m139.P4=m120;m140.P0=m139;m140.P1=m141;m140.P2=m120;m141.P0=m140;
m141.P1=m139;m141.P2=m27;m142.P0=m143;m142.P1=m166;m143.P0=m144;m143.P1=m20;
m143.P2=m142;m143.P3=m101;m144.P0=m36;m144.P1=m146;m144.P2=m143;m144.P3=m100;
m145.P0=m36;m145.P1=m98;m145.P2=m113;m146.P0=m36;m146.P1=m144;m146.P2=m147;
m146.P3=m115;m147.P0=m148;m147.P1=m36;m147.P2=m146;m147.P3=m112;m148.P0=m68;
m148.P1=m147;m149.P0=m150;m149.P1=m68;m150.P0=m149;m150.P1=m151;m151.P0=m152;
m151.P1=m149;m152.P0=m151;m152.P1=m47;m153.P0=m47;m153.P1=m154;m153.P2=m133;
m154.P0=m153;m154.P1=m155;m154.P2=m120;m155.P0=m154;m155.P1=m156;m155.P2=m157;
m155.P3=m88;m156.P0=m155;m156.P1=m11;m156.P2=m157;m157.P0=m156;m157.P1=m155;
m157.P2=m158;m157.P3=m26;m158.P0=m157;m158.P1=m141;m159.P0=m78;m159.P1=m87;
m160.P0=m169;m161.P0=m162;m161.P1=m120;m162.P0=m161;m162.P1=m120;m163.P0=m164;
m163.P1=m53;m164.P0=m163;m164.P1=m88;m164.P2=m82;m165.P0=m41;m166.P0=m142;
m166.P1=m27;m166.P2=m165;m166.P3=m141;m167.P0=m78;m167.P1=m29;m167.P2=m77;
m168.P0=m169;m169.P0=m88;m170.P0=m177;m170.P1=m175;m170.P2=m180;m171.P0=m63;
m172.P0=m174;m172.P1=m44;m172.P2=m110;m173.P0=m170;m173.P1=m75;m173.P2=m40;
m174.P1=m172;m174.P2=m66;m175.P0=m67;m175.P1=m170;m176.P0=m69;m176.P1=m170;
m177.P0=m170;m177.P1=m63;m178.P0=m170;m178.P1=m63;m179.P0=m120;m179.P1=m46;
m180.P0=m170;m180.P1=m176;m181.P0=m47;m181.P1=m46;
m4.D1=1024;m6.D0=1024;m6.D1=1024;m31.D2=1024;m33.D2=1024;m40.D3=1024;
m40.D4=1024;m43.D4=512;m46.D1=1;m49.D0=1024;m49.D1=1024;m50.D0=1024;
m50.D1=1024;m54.D0=1024;m58.D1=1024;m62.D2=1024;m75.D2=1024;m77.D2=1024;
m88.D4=2;m104.D3=512;m105.D6=512;m113.D3=1024;m114.D2=1024;m115.D2=1024;
m121.D1=1024;m130.D0=1024;m135.D3=1024;m136.D4=1024;m139.D4=1024;m140.D2=1024;
m143.D3=1024;m144.D3=1024;m145.D2=1024;m146.D3=1024;m147.D3=1024;m151.D1=1024;
m153.D2=1024;m154.D2=1024;m155.D3=1024;m157.D3=1024;m158.D1=1024;m159.D1=1024;
m161.D1=1024;m162.D1=1024;m163.D0=1024;m164.D0=130;m165.D0=1024;m166.D2=512;
m167.D0=1024;m167.D1=1024;m167.D2=1024;m172.D0=1;m173.D0=1024;m179.D0=2049;
m181.D1=1;
};
/* MarkerInfo
m1 trigger_teleport -120 0 64;
m2 trigger_teleport 1096 64 -96;
m4 info_player_deathmatch 1152 528 200;
m5 trigger_push -880 160 -148;
m6 info_player_deathmatch 576 -160 8;
m7 info_player_deathmatch 64 592 40;
m8 weapon_supershotgun 64 576 0;
m9 info_player_deathmatch 32 -464 68;
m11 trigger_teleport 584 64 384;
m13 door 352 -512 -8;
m14 func_button 352 -572 -112;
m15 trigger_teleport 896 -584 224;
m17 item_armor2 1152 384 0;
m18 trigger_teleport -960 584 -96;
m20 trigger_teleport -256 648 224;
m22 item_health -1200 464 -160;
m23 item_health -1136 528 -160;
m24 item_health -1200 528 -160;
m25 item_health 368 208 160;
m26 item_health 304 208 160;
m27 item_rockets 88 472 160;
m28 item_health 976 464 0;
m29 item_health 912 464 0;
m30 item_cells -208 208 0;
m31 item_cells -272 272 0;
m32 item_rockets -200 280 0;
m33 weapon_grenadelauncher 928 -128 160;
m34 item_cells 976 -560 160;
m35 item_cells 976 -496 160;
m36 weapon_grenadelauncher -352 160 160;
m37 door 676 416 224;
m38 door 676 352 224;
m40 item_rockets 1080 -48 160;
m41 item_health 400 464 160;
m42 item_rockets 16 -16 0;
m43 item_rockets 16 0 0;
m44 weapon_rocketlauncher -992 -32 -80;
m45 item_armor2 -800 160 -160;
m46 item_armorInv -128 -128 224;
m47 weapon_lightning 160 -352 320;
m48 weapon_rocketlauncher 832 512 -192;
m49 info_player_deathmatch -928 -288 72;
m50 item_artifact_invisibility -960 608 56;
m51 item_health -240 -432 0;
m52 item_health -304 -432 0;
m53 item_artifact_super_damage 480 64 -116;
m54 item_armor1 -1184 160 -96;
m55 item_shells 208 -368 -160;
m56 item_health -448 -240 -160;
m57 item_rockets 792 -168 -160;
m58 weapon_supershotgun 1152 512 160;
m59 weapon_supershotgun -96 -32 -160;
m60 info_player_deathmatch -96 -28 -120;
m61 item_armor1 544 224 -160;
m62 item_artifact_envirosuit 352 -96 184;
m63 item_artifact_invulnerability 1376 288 -72;
m66 trigger_teleport -928 -508 -80;
m67 trigger_teleport 1392 0 -209;
m68 item_cells -352 -480 160;
m69 item_health 1408 -352 -16;
m70 func_button 1256 424 292;
m3 info_teleport_destination 1064 64 -109;
m10 info_teleport_destination 552 64 371;
m12 info_teleport_destination -88 0 51;
m16 info_teleport_destination 896 -552 211;
m19 info_teleport_destination -960 552 -109;
m21 info_teleport_destination -256 616 211;
m64 info_teleport_destination 1376 608 -1;
m65 info_teleport_destination -928 -480 -65;
m73 marker 911 -392 184;
m74 marker 914 -252 184;
m75 marker 1158 69 184;
m76 marker 1019 374 24;
m77 marker 929 262 24;
m78 marker 826 397 24;
m79 marker 926 72 -136;
m80 marker 745 70 -136;
m81 marker 600 -137 -136;
m82 marker 442 -144 -136;
m83 marker 859 224 -152;
m84 marker 853 347 -168;
m85 marker 713 234 -136;
m86 marker 726 406 -152;
m87 marker 599 413 -136;
m88 marker 257 -159 -136;
m89 marker 360 -409 -136;
m90 marker 345 -258 -136;
m91 marker 126 -161 -136;
m92 marker -19 -148 -136;
m93 marker -210 -141 -136;
m94 marker -314 -159 -136;
m95 marker -457 -21 -136;
m96 marker -454 167 -136;
m97 marker -633 158 -136;
m98 marker -618 159 184;
m99 marker -440 312 -136;
m100 marker -429 450 -136;
m101 marker -569 391 -136;
m102 marker -702 385 -136;
m103 marker -292 461 -120;
m104 marker -850 421 -136;
m105 marker -980 414 -136;
m106 marker -1169 344 -136;
m107 marker -1019 253 -120;
m108 marker -1034 150 -72;
m109 marker -1047 52 -56;
m110 marker -844 -62 -40;
m111 marker -699 -58 24;
m112 marker -584 -70 24;
m113 marker -443 -90 24;
m114 marker -302 -9 24;
m115 marker -215 104 24;
m116 marker -399 -235 24;
m117 marker -388 -372 24;
m118 marker -90 -391 24;
m119 marker 32 -303 24;
m120 marker 30 -153 24;
m121 marker 201 98 24;
m122 marker 83 142 24;
m123 marker 60 328 8;
m124 marker 66 440 8;
m125 marker -44 451 8;
m126 marker -168 455 -56;
m127 marker 203 445 -8;
m128 marker 345 451 -88;
m129 marker 474 439 -136;
m130 marker 1163 200 184;
m131 marker 771 -322 184;
m132 marker 618 -330 184;
m133 marker 492 -321 184;
m134 marker 350 -503 184;
m135 marker 358 -416 184;
m136 marker 358 -258 184;
m137 marker 240 -315 184;
m138 marker 347 59 184;
m139 marker 204 145 184;
m140 marker 63 124 184;
m141 marker 94 292 184;
m142 marker -68 447 184;
m143 marker -225 453 184;
m144 marker -295 284 184;
m145 marker -463 163 184;
m146 marker -249 168 184;
m147 marker -358 -57 184;
m148 marker -326 -259 184;
m149 marker -173 -449 184;
m150 marker -56 -452 184;
m151 marker 1 -449 331;
m152 marker 109 -450 344;
m153 marker 321 -338 344;
m154 marker 348 -156 344;
m155 marker 358 -3 344;
m156 marker 437 71 344;
m157 marker 300 126 344;
m158 marker 97 164 344;
m159 marker 692 414 24;
m160 marker 355 23 -200;
m161 marker -80 -194 184;
m162 marker -80 -71 184;
m163 marker 429 77 -119;
m164 marker 332 -61 -136;
m165 marker 126 448 378;
m166 marker 28 447 184;
m167 marker 704 384 184;
m168 marker 264 117 -200;
m169 marker 229 10 -200;
m170 marker 1389 23 -70;
m171 marker 1376 410 -56;
m172 marker -935 -138 -40;
m173 marker 1279 0 210;
m174 marker -928 -254 -95;
m175 marker 1392 0 -186;
m176 marker 1395 -205 24;
m177 marker 1379 159 -72;
m178 marker 1373 160 24;
m179 marker -88 -114 248;
m180 marker 1388 -82 -65;
m181 marker 40 -274 344;
*/
