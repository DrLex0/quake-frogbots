// Original 05-08-2005 by Trinca
// Improvements 2025-04 by DrLex
// - guess what... teleports again
// - split up zones
// - give everything goals
// - edit 2025-05: added WSJ near quad
void() map_del1 =
{
// custom markers start at m43
N(7,-452,40);N(0,-561,40);N(151,-483,40);N(148,-642,40);
N(293,-497,40);N(362,-363,40);N(520,-366,40);N(538,-490,40);
N(431,-642,40);N(426,-195,40);N(415,-7,40);N(255,57,40);
N(262,-58,40);N(103,1,66);N(-81,-5,97);N(-258,-12,104);
N(-420,55,104);N(-301,200,104);N(-157,156,104);N(136,-720,248);
N(306,-720,248);N(482,-720,248);N(610,-670,248);N(317,-650,88);
N(475,-659,168);N(546,-515,248);N(448,-364,248);N(426,2,280);
N(299,98,280);N(-90,85,312);N(-244,-140,312);N(-510,-144,360);
N(-372,-146,360);N(-575,-22,360);N(-591,132,360);N(-572,306,360);
N(-465,439,360);N(-542,-542,360);N(-694,-602,360);N(-854,-635,360);
N(-963,-519,360);N(-880,-349,144);N(-441,303,272);N(-304,303,272);
N(-139,303,312);
LSQ();
Z4(m1);Z1(m3);Z1(m4);Z2(m5);Z5(m6);Z1(m7);Z6(m8);Z5(m9);
Z5(m10);Z6(m11);Z1(m12);Z2(m13);Z3(m14);Z3(m15);Z1(m16);Z6(m17);
Z4(m18);Z3(m19);Z6(m20);Z1(m21);Z3(m22);Z5(m23);Z6(m24);Z2(m25);
Z2(m29);Z4(m30);Z4(m31);Z4(m32);Z6(m33);Z1(m34);Z3(m35);Z2(m36);
Z5(m37);Z1(m38);Z4(m39);Z3(m40);Z3(m41);Z3(m42);Z2(m2);Z4(m26);
Z4(m27);Z2(m28);Z1(m43);Z1(m44);Z1(m45);Z1(m46);Z1(m47);Z1(m48);
Z1(m49);Z1(m50);Z1(m51);Z1(m52);Z1(m53);Z2(m54);Z2(m55);Z2(m56);
Z2(m57);Z2(m58);Z2(m59);Z2(m60);Z2(m61);Z3(m62);Z3(m63);Z3(m64);
Z3(m65);Z1(m66);Z3(m67);Z3(m68);Z3(m69);Z3(m70);Z3(m71);Z4(m72);
Z4(m73);Z4(m74);Z4(m75);Z4(m76);Z4(m77);Z4(m78);Z4(m79);Z5(m80);
Z5(m81);Z5(m82);Z5(m83);Z6(m84);Z4(m85);Z4(m86);Z4(m87);
G6(m1);G4(m4);G22(m5);G20(m6);G14(m7);G23(m10);G9(m11);G12(m13);
G13(m16);G18(m17);G7(m18);G2(m19);G10(m20);G1(m21);G5(m22);G8(m23);
G3(m25);G15(m31);G21(m32);G18(m33);G13(m34);G12(m36);G23(m37);G14(m38);
G11(m39);G17(m41);G16(m42);
m3.view_ofs_z=33;m24.view_ofs_z=35;m29.view_ofs_z=39;m30.view_ofs_z=37;
m85.T=16;m86.T=4;m87.T=16;
m1.P0=m72;m1.P1=m39;m1.P2=m87;m3.P0=m2;m4.P0=m54;m4.P1=m53;
m5.P0=m25;m5.P1=m57;m5.P2=m58;m6.P0=m83;m6.P1=m82;m7.P0=m47;
m7.P1=m48;m7.P2=m38;m7.P3=m45;m8.P0=m33;m8.P1=m84;m8.P2=m20;
m9.P0=m80;m9.P1=m81;m10.P0=m74;m10.P1=m37;m11.P0=m20;m11.P1=m24;
m11.P2=m84;m12.P0=m53;m12.P1=m21;m13.P0=m61;m13.P1=m36;m13.P2=m60;
m14.P0=m69;m14.P1=m15;m15.P0=m14;m15.P1=m35;m16.P0=m50;m16.P1=m34;
m17.P0=m20;m17.P1=m33;m18.P0=m72;m18.P1=m73;m19.P0=m68;m19.P1=m69;
m19.P2=m45;m19.P3=m63;m19.P4=m62;m20.P0=m17;m20.P1=m33;m20.P2=m84;
m20.P3=m11;m21.P0=m53;m21.P1=m52;m21.P2=m12;m22.P0=m62;m22.P1=m43;
m23.P0=m83;m23.P1=m20;m24.P0=m26;m25.P0=m5;m25.P1=m58;m25.P2=m59;
m29.P0=m27;m30.P0=m28;m31.P0=m30;m31.P1=m32;m32.P0=m79;m32.P1=m78;
m32.P2=m31;m33.P0=m20;m33.P1=m8;m33.P2=m17;m33.P3=m84;m34.P0=m16;
m34.P1=m51;m35.P0=m15;m35.P1=m68;m35.P2=m69;m36.P0=m13;m36.P1=m61;
m37.P0=m10;m37.P1=m80;m38.P0=m7;m38.P1=m43;m38.P2=m45;m39.P0=m13;
m39.P1=m59;m39.P2=m85;m40.P0=m71;m40.P1=m70;m41.P0=m69;m41.P1=m70;
m42.P0=m71;m42.P1=m72;m2.P0=m29;m2.P1=m59;m26.P0=m39;m27.P0=m30;
m27.P1=m79;m27.P2=m31;m28.P0=m29;m28.P1=m59;m43.P0=m38;m43.P1=m44;
m43.P2=m45;m43.P3=m3;m43.P4=m59;m44.P0=m43;m44.P1=m46;m44.P2=m45;
m44.P3=m3;m45.P0=m46;m45.P1=m38;m45.P2=m7;m45.P3=m47;m45.P4=m43;
m45.P5=m44;m45.P6=m48;m46.P0=m44;m46.P1=m45;m46.P2=m66;m47.P0=m50;
m47.P1=m48;m47.P2=m7;m47.P3=m45;m48.P0=m49;m48.P1=m47;m48.P2=m50;
m48.P3=m7;m48.P4=m52;m48.P5=m45;m49.P0=m52;m49.P1=m48;m49.P2=m50;
m50.P0=m49;m50.P1=m16;m50.P2=m51;m50.P3=m47;m50.P4=m48;m51.P0=m34;
m51.P1=m50;m52.P0=m53;m52.P1=m55;m52.P2=m21;m52.P3=m49;m52.P4=m48;
m53.P0=m55;m53.P1=m54;m53.P2=m4;m53.P3=m12;m53.P4=m21;m53.P5=m52;
m54.P0=m56;m54.P1=m55;m54.P2=m53;m54.P3=m4;m55.P0=m54;m55.P1=m56;
m55.P2=m53;m55.P3=m52;m56.P0=m57;m56.P1=m54;m56.P2=m55;m57.P0=m58;
m57.P1=m5;m57.P2=m61;m57.P3=m56;m58.P0=m59;m58.P1=m60;m58.P2=m61;
m58.P3=m57;m58.P4=m25;m58.P5=m5;m59.P0=m60;m59.P1=m29;m59.P2=m58;
m59.P3=m25;m60.P0=m59;m60.P1=m58;m60.P2=m61;m60.P3=m13;m61.P0=m60;
m61.P1=m13;m61.P2=m36;m61.P3=m58;m61.P4=m57;m62.P0=m63;m62.P1=m22;
m62.P2=m45;m63.P0=m62;m64.P0=m63;m65.P0=m64;m66.P0=m46;m66.P1=m67;
m67.P0=m66;m67.P1=m68;m68.P0=m67;m68.P1=m19;m68.P2=m69;m68.P3=m35;
m68.P4=m65;m69.P0=m68;m69.P1=m19;m69.P2=m14;m69.P3=m38;m69.P4=m35;
m69.P5=m41;m70.P0=m41;m70.P1=m71;m70.P2=m40;m71.P0=m70;m71.P1=m40;
m71.P2=m42;m72.P0=m42;m72.P1=m1;m72.P2=m18;m72.P3=m58;m73.P0=m18;
m73.P1=m75;m74.P0=m75;m74.P1=m76;m74.P2=m39;m74.P3=m10;m75.P0=m73;
m75.P1=m74;m75.P2=m59;m76.P0=m74;m76.P1=m77;m77.P0=m76;m77.P1=m78;
m78.P0=m77;m78.P1=m79;m78.P2=m32;m78.P3=m39;m79.P0=m78;m79.P1=m32;
m79.P2=m31;m79.P3=m30;m80.P0=m37;m80.P1=m9;m80.P2=m81;m81.P0=m80;
m81.P1=m9;m81.P2=m82;m82.P0=m81;m82.P1=m83;m82.P2=m6;m83.P0=m82;
m83.P1=m6;m83.P2=m23;m83.P3=m20;m84.P0=m8;m84.P1=m20;m84.P2=m11;
m84.P3=m33;m85.P0=m86;m85.P1=m39;m86.P0=m87;m87.P0=m1;m87.P1=m60;
m1.D1=1024;m19.D3=1024;m19.D4=1024;m23.D0=1024;m57.D1=1024;m68.D4=1024;
m74.D2=1024;m78.D3=2048;m83.D2=1024;m85.D0=8;
};
/* MarkerInfo
m1 weapon_grenadelauncher -96 240 288;
m3 trigger_teleport -168 -488 80;
m4 item_armor1 416 160 16;
m5 item_cells -88 -184 80;
m6 item_rockets -1088 -592 336;
m7 item_health 152 -328 16;
m8 info_player_deathmatch -896 -168 144;
m9 info_player_deathmatch -480 -624 360;
m10 item_shells -528 -360 336;
m11 weapon_supershotgun -976 -560 120;
m12 info_player_deathmatch 536 120 40;
m13 item_health -112 264 80;
m14 info_player_deathmatch 584 -344 248;
m15 item_cells 592 -400 224;
m16 item_rockets 584 -664 16;
m17 item_health -1048 -192 120;
m18 item_armor1 -96 -144 288;
m19 weapon_rocketlauncher 384 -480 224;
m20 item_armorInv -1008 -368 120;
m21 item_health 560 -16 16;
m22 item_armor2 -32 -704 224;
m23 weapon_rocketlauncher -784 -304 336;
m24 trigger_teleport -976 -648 184;
m25 weapon_lightning -288 -144 80;
m29 trigger_teleport -616 80 144;
m30 trigger_teleport -216 480 400;
m31 item_health -520 560 336;
m32 item_cells -624 456 336;
m33 item_health -1000 -192 120;
m34 item_rockets 536 -712 16;
m35 item_cells 592 -448 224;
m36 item_health -72 224 80;
m37 item_shells -528 -408 336;
m38 item_health 104 -328 16;
m39 item_artifact_super_damage -448 272 272;
m40 info_player_deathmatch 456 136 280;
m41 item_health 400 -160 246;
m42 item_rockets 112 80 278;
m2 info_teleport_destination -536 80 131;
m26 info_teleport_destination -472 296 299;
m27 info_teleport_destination -256 480 387;
m28 info_teleport_destination -576 80 131;
m43 marker 7 -452 40;
m44 marker 0 -561 40;
m45 marker 151 -483 40;
m46 marker 148 -642 40;
m47 marker 293 -497 40;
m48 marker 362 -363 40;
m49 marker 520 -366 40;
m50 marker 538 -490 40;
m51 marker 431 -642 40;
m52 marker 426 -195 40;
m53 marker 415 -7 40;
m54 marker 255 57 40;
m55 marker 262 -58 40;
m56 marker 103 1 66;
m57 marker -81 -5 97;
m58 marker -258 -12 104;
m59 marker -420 55 104;
m60 marker -301 200 104;
m61 marker -157 156 104;
m62 marker 136 -720 248;
m63 marker 306 -720 248;
m64 marker 482 -720 248;
m65 marker 610 -670 248;
m66 marker 317 -650 88;
m67 marker 475 -659 168;
m68 marker 546 -515 248;
m69 marker 448 -364 248;
m70 marker 426 2 280;
m71 marker 299 98 280;
m72 marker -90 85 312;
m73 marker -244 -140 312;
m74 marker -510 -144 360;
m75 marker -372 -146 360;
m76 marker -575 -22 360;
m77 marker -591 132 360;
m78 marker -572 306 360;
m79 marker -465 439 360;
m80 marker -542 -542 360;
m81 marker -694 -602 360;
m82 marker -854 -635 360;
m83 marker -963 -519 360;
m84 marker -880 -349 144;
m85 marker -441 303 272;
m86 marker -304 303 272;
m87 marker -139 303 312;
*/
