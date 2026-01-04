// Test map for embedded waypoints, map and waypoints by DrLex.
// The first edition of these waypoints from 2024-12 was entirely hand-crafted, with the help of
// a sketch on a post-it note, because I wasn't able to rebuild the waypoint tool at that time.
// Updated edition 2025-12-16
void() map_gibpantry =
{
// custom markers start at m13
N(99,111,24);N(-323,52,24);N(-45,167,24);N(-293,-87,24);
N(-368,91,24);N(-368,13,24);N(162,19,24);
LSQ();
Z1(m1);Z1(m2);Z2(m3);Z2(m4);Z3(m5);Z3(m6);Z1(m7);Z2(m8);
Z2(m9);Z1(m10);Z3(m11);Z1(m12);Z1(m13);Z2(m14);Z1(m15);Z2(m16);
Z2(m17);Z2(m18);Z1(m19);
G5(m1);G8(m2);G1(m3);G6(m4);G4(m5);G3(m10);G2(m11);G7(m12);
m1.P0=m13;m1.P1=m19;m1.P2=m15;m2.P0=m13;m2.P1=m12;m3.P0=m14;
m3.P1=m16;m3.P2=m10;m3.P3=m12;m4.P0=m14;m4.P1=m11;m4.P2=m16;
m5.P0=m11;m5.P1=m6;m6.P0=m19;m6.P1=m5;m7.P0=m10;m7.P1=m1;
m7.P2=m15;m8.P0=m10;m8.P1=m14;m8.P2=m12;m9.P0=m11;m9.P1=m16;
m10.P0=m12;m10.P1=m14;m10.P2=m15;m11.P0=m4;m11.P1=m5;m11.P2=m16;
m12.P0=m2;m12.P1=m10;m12.P2=m14;m13.P0=m19;m13.P1=m1;m13.P2=m2;
m14.P0=m3;m14.P1=m10;m14.P2=m4;m14.P3=m16;m14.P4=m12;m15.P0=m1;
m15.P1=m10;m16.P0=m4;m16.P1=m11;m16.P2=m14;m17.P0=m3;m17.P1=m10;
m17.P2=m12;m18.P0=m3;m18.P1=m16;m18.P2=m4;m19.P0=m13;m19.P1=m6;
m19.P2=m1;
m3.D1=1024;m3.D2=1024;m3.D3=1024;m14.D0=2176;m17.D0=2176;m18.D0=2176;
};
/* MarkerInfo
m1 weapon_nailgun 160 224 0 "NG1";
m2 item_spikes -58 80 48 "nail1";
m3 weapon_lightning -364 52 40 "LG1";
m4 item_cells -228 -50 0 "cell1";
m5 item_health 0 -128 0 "heal1";
m6 info_player_deathmatch 166 -136 24 "dm1";
m7 info_player_deathmatch -16 234 24 "dm2";
m8 info_player_deathmatch -348 224 24 "dm3";
m9 info_player_deathmatch -348 -120 24 "dm4";
m10 item_armor2 -212 236 0 "army1";
m11 weapon_rocketlauncher -160 -128 0 "RL1";
m12 item_rockets -184 92 0 "rock1";
m13 marker 99 111 24 "mark1";
m14 marker -323 52 24 "mark2";
m15 marker -45 167 24 "mark3";
m16 marker -293 -87 24 "mark4";
m17 marker -368 91 24 "mark5";
m18 marker -368 13 24 "mark6";
m19 marker 162 19 24 "mark7";
*/
