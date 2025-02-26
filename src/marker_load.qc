/*
	marker_load.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Enhancements by DrLex 2024-2025
*/

#include "settings.h"


string FROG_ID_ERR = "Frogbot ERROR: invalid FrB_ID reference in map, see developer log\n";

/*
============
AddToQue

============
*/
void() AddToQue_apply =
{
// Note: Max 100000 commands in a function call

	if (que_size < 50)
	{
		m1=m2;m2=m3;m3=m4;m4=m5;m5=m6;m6=m7;m7=m8;m8=m9;m9=m10;m10=m11;
		m11=m12;m12=m13;m13=m14;m14=m15;m15=m16;m16=m17;m17=m18;m18=m19;m19=m20;m20=m21;
		m21=m22;m22=m23;m23=m24;m24=m25;m25=m26;m26=m27;m27=m28;m28=m29;m29=m30;m30=m31;
		m31=m32;m32=m33;m33=m34;m34=m35;m35=m36;m36=m37;m37=m38;m38=m39;m39=m40;m40=m41;
		m41=m42;m42=m43;m43=m44;m44=m45;m45=m46;m46=m47;m47=m48;m48=m49;m49=m50;m50=self;
	}
	else if (que_size < 100)
	{
		m51=m52;m52=m53;m53=m54;m54=m55;m55=m56;m56=m57;m57=m58;m58=m59;m59=m60;m60=m61;
		m61=m62;m62=m63;m63=m64;m64=m65;m65=m66;m66=m67;m67=m68;m68=m69;m69=m70;m70=m71;
		m71=m72;m72=m73;m73=m74;m74=m75;m75=m76;m76=m77;m77=m78;m78=m79;m79=m80;m80=m81;
		m81=m82;m82=m83;m83=m84;m84=m85;m85=m86;m86=m87;m87=m88;m88=m89;m89=m90;m90=m91;
		m91=m92;m92=m93;m93=m94;m94=m95;m95=m96;m96=m97;m97=m98;m98=m99;m99=m100;m100=self;
	}
	else if (que_size < 150)
	{
		m101=m102;m102=m103;m103=m104;m104=m105;m105=m106;m106=m107;m107=m108;m108=m109;m109=m110;m110=m111;
		m111=m112;m112=m113;m113=m114;m114=m115;m115=m116;m116=m117;m117=m118;m118=m119;m119=m120;m120=m121;
		m121=m122;m122=m123;m123=m124;m124=m125;m125=m126;m126=m127;m127=m128;m128=m129;m129=m130;m130=m131;
		m131=m132;m132=m133;m133=m134;m134=m135;m135=m136;m136=m137;m137=m138;m138=m139;m139=m140;m140=m141;
		m141=m142;m142=m143;m143=m144;m144=m145;m145=m146;m146=m147;m147=m148;m148=m149;m149=m150;m150=self;
	}
	else if (que_size < 200)
	{
		m151=m152;m152=m153;m153=m154;m154=m155;m155=m156;m156=m157;m157=m158;m158=m159;m159=m160;m160=m161;
		m161=m162;m162=m163;m163=m164;m164=m165;m165=m166;m166=m167;m167=m168;m168=m169;m169=m170;m170=m171;
		m171=m172;m172=m173;m173=m174;m174=m175;m175=m176;m176=m177;m177=m178;m178=m179;m179=m180;m180=m181;
		m181=m182;m182=m183;m183=m184;m184=m185;m185=m186;m186=m187;m187=m188;m188=m189;m189=m190;m190=m191;
		m191=m192;m192=m193;m193=m194;m194=m195;m195=m196;m196=m197;m197=m198;m198=m199;m199=m200;m200=self;
	}
	else if (que_size < 250)
	{
		m201=m202;m202=m203;m203=m204;m204=m205;m205=m206;m206=m207;m207=m208;m208=m209;m209=m210;m210=m211;
		m211=m212;m212=m213;m213=m214;m214=m215;m215=m216;m216=m217;m217=m218;m218=m219;m219=m220;m220=m221;
		m221=m222;m222=m223;m223=m224;m224=m225;m225=m226;m226=m227;m227=m228;m228=m229;m229=m230;m230=m231;
		m231=m232;m232=m233;m233=m234;m234=m235;m235=m236;m236=m237;m237=m238;m238=m239;m239=m240;m240=m241;
		m241=m242;m242=m243;m243=m244;m244=m245;m245=m246;m246=m247;m247=m248;m248=m249;m249=m250;m250=self;
	}
	else if (que_size < 300)
	{
		m251=m252;m252=m253;m253=m254;m254=m255;m255=m256;m256=m257;m257=m258;m258=m259;m259=m260;m260=m261;
		m261=m262;m262=m263;m263=m264;m264=m265;m265=m266;m266=m267;m267=m268;m268=m269;m269=m270;m270=m271;
		m271=m272;m272=m273;m273=m274;m274=m275;m275=m276;m276=m277;m277=m278;m278=m279;m279=m280;m280=m281;
		m281=m282;m282=m283;m283=m284;m284=m285;m285=m286;m286=m287;m287=m288;m288=m289;m289=m290;m290=m291;
		m291=m292;m292=m293;m293=m294;m294=m295;m295=m296;m296=m297;m297=m298;m298=m299;m299=m300;m300=self;
	}
	else if (que_size < 350) // "350"
	{
		m301=m302;m302=m303;m303=m304;m304=m305;m305=m306;m306=m307;m307=m308;m308=m309;m309=m310;m310=m311;
		m311=m312;m312=m313;m313=m314;m314=m315;m315=m316;m316=m317;m317=m318;m318=m319;m319=m320;m320=m321;
		m321=m322;m322=m323;m323=m324;m324=m325;m325=m326;m326=m327;m327=m328;m328=m329;m329=m330;m330=m331;
		m331=m332;m332=m333;m333=m334;m334=m335;m335=m336;m336=m337;m337=m338;m338=m339;m339=m340;m340=m341;
		m341=m342;m342=m343;m343=m344;m344=m345;m345=m346;m346=m347;m347=m348;m348=m349;m349=m350;m350=self;
	}

#ifdef MANUAL
	else
		bprint_("ERROR: Max Que size exceeded\n");
#endif

	que_size = que_size + 1;
};

void() AddToQue =
{
	marker_index = marker_index + 1;
	self.index = marker_index;
	AddToQue_apply();

	self.zone_marker = Z_marker_error;
	self.sub_arrival_time = S_time_error;
	self.sub_path_marker = S_path_marker_error;
	self.path_marker = Z_path_marker_error;
	self.next_zone_marker = Z_next_zone_marker_error;
	self.sight_from_marker = Z_sight_from_marker_error;
	self.higher_sight_from_marker = Z_higher_sight_from_marker_error;
	self.sight_from_time = Z_sight_from_time_error;
};

/*
============
AddToTmpQue

Queue for waypoint-only markers added after entity markers.
To keep behavior consistent between compiled and embedded waypoints,
this list must preserve ordering.
============
*/
void() AddToTmpQue
{
	if (last_tmp_marker)
		last_tmp_marker.next = self;
	else
		first_tmp_marker = self;
	self.next = world;
	last_tmp_marker = self;
}

/*
============
N (New marker)

Load a marker.
Changed by DrLex (2024-12): use 3 float arguments instead of a vector.
This eliminates the endless accumulation of pr_globals. Now we can
in theory add an infinite number of maps, until we hit another limit.
Old waypoint files will need a trivial conversion, use the -t option
in the generate_maplist.py script.
============
*/
void(float vx, float vy, float vz) N =
{
	local vector org;
	org_x = vx;
	org_y = vy;
	org_z = vz;
// put on save que
	spawn_marker(org);
	self = marker_;
	AddToQue();
};

/*
============
LSQ (Left Shift Que)

============
*/
void() LSQ =
{
	self = world;
	while ((floor(que_size * 0.02) * 50) != que_size)
		AddToQue_apply();

	no_change = TRUE;
	m = m_2 = last_marker;
	m_zone = zone_stack_head;
	path_normal = TRUE;

	spawn_load();
	dropper.think = Calc_G_time_1;
	set_load();
};

/*
============
SetFrB_Props

Applies Frogbot entity annotations embedded in BSP
============
*/
void(entity mk) SetFrB_Props =
{
	if (! has_embedded_wp) return;

	local string zone, goal;
	if (mk.FrB_Z != "") {
		zone = mk.FrB_Z;
		if (zone == "1") Z1(mk);
		else if (zone == "2") Z2(mk);
		else if (zone == "3") Z3(mk);
		else if (zone == "4") Z4(mk);
		else if (zone == "5") Z5(mk);
		else if (zone == "6") Z6(mk);
		else if (zone == "7") Z7(mk);
		else if (zone == "8") Z8(mk);
		else if (zone == "9") Z9(mk);
		else if (zone == "10") Z10(mk);
		else if (zone == "11") Z11(mk);
		else if (zone == "12") Z12(mk);
		else if (zone == "13") Z13(mk);
		else if (zone == "14") Z14(mk);
		else if (zone == "15") Z15(mk);
		else if (zone == "16") Z16(mk);
		else if (zone == "17") Z17(mk);
		else if (zone == "18") Z18(mk);
		else if (zone == "19") Z19(mk);
		else if (zone == "20") Z20(mk);
		else if (zone == "21") Z21(mk);
		else if (zone == "22") Z22(mk);
		else if (zone == "23") Z23(mk);
		else if (zone == "24") Z24(mk);
		else
		{
			dprint("Invalid value for FrB_Z: '", mk.FrB_Z, "'\n");
			error(FROG_ID_ERR);
		}
	}
	if (mk.FrB_g != "") {
		goal = mk.FrB_g;
		if (goal == "1") G1(mk);
		else if (goal == "2") G2(mk);
		else if (goal == "3") G3(mk);
		else if (goal == "4") G4(mk);
		else if (goal == "5") G5(mk);
		else if (goal == "6") G6(mk);
		else if (goal == "7") G7(mk);
		else if (goal == "8") G8(mk);
		else if (goal == "9") G9(mk);
		else if (goal == "10") G10(mk);
		else if (goal == "11") G11(mk);
		else if (goal == "12") G12(mk);
		else if (goal == "13") G13(mk);
		else if (goal == "14") G14(mk);
		else if (goal == "15") G15(mk);
		else if (goal == "16") G16(mk);
		else if (goal == "17") G17(mk);
		else if (goal == "18") G18(mk);
		else if (goal == "19") G19(mk);
		else if (goal == "20") G20(mk);
		else if (goal == "21") G21(mk);
		else if (goal == "22") G22(mk);
		else if (goal == "23") G23(mk);
		else if (goal == "24") G24(mk);
		else
		{
			dprint("Invalid value for FrB_g: '", mk.FrB_g, "'\n");
			error(FROG_ID_ERR);
		}
	}
}

entity (entity start_ent, string val) FindFrB_ID =
{
	local entity found = find(start_ent, FrB_ID, val);
	if (found) return found;
	dprint("ERROR: no FrB_ID='", val, "' found\n");
	error(FROG_ID_ERR);
	return world;  // make compiler shut up
}

/*
============
ApplyFrB_props

Applies Frogbot embedded world annotations and path fields.
Basically the equivalent of hard-coded map_mapname() functions.
Must happen after all markers have spawned.
============
*/
void() ApplyFrB_props =
{
	if (! has_embedded_wp) return;

	// DO NOT just test stof("42") or you'll lose half an hour of your life
	// and start questioning your sanity due to fteqcc optimizing this.
	local string test_it = "42";
	if (stof(test_it) != 42)
		error("ERROR: build and Quake engine must support stof() to load embedded waypoints\n");

	local entity mk, found, m_prev;

	// Append the temporary 'Que' to the regular one
	item_marker_index = marker_index;
	mk = first_tmp_marker;
	while(mk)
	{
		self = mk;
		AddToQue();
		BecomeMarker(mk);
		m_prev = mk;
		mk = mk.next;
		m_prev.next = world;  // clear tmp field just to be sure
	}
	LSQ();

	// Maybe this should split up with think to avoid a DoS on the engine?
	mk = last_marker;
	while(mk)
	{
		if (mk.FrB_P0 != "") { found = FindFrB_ID(world, mk.FrB_P0); if(found) mk.P0 = found; }
		if (mk.FrB_P1 != "") { found = FindFrB_ID(world, mk.FrB_P1); if(found) mk.P1 = found; }
		if (mk.FrB_P2 != "") { found = FindFrB_ID(world, mk.FrB_P2); if(found) mk.P2 = found; }
		if (mk.FrB_P3 != "") { found = FindFrB_ID(world, mk.FrB_P3); if(found) mk.P3 = found; }
		if (mk.FrB_P4 != "") { found = FindFrB_ID(world, mk.FrB_P4); if(found) mk.P4 = found; }
		if (mk.FrB_P5 != "") { found = FindFrB_ID(world, mk.FrB_P5); if(found) mk.P5 = found; }
		if (mk.FrB_P6 != "") { found = FindFrB_ID(world, mk.FrB_P6); if(found) mk.P6 = found; }
		if (mk.FrB_P7 != "") { found = FindFrB_ID(world, mk.FrB_P7); if(found) mk.P7 = found; }
		if (mk.FrB_D0 != "") mk.D0 = stof(mk.FrB_D0);
		if (mk.FrB_D1 != "") mk.D1 = stof(mk.FrB_D1);
		if (mk.FrB_D2 != "") mk.D2 = stof(mk.FrB_D2);
		if (mk.FrB_D3 != "") mk.D3 = stof(mk.FrB_D3);
		if (mk.FrB_D4 != "") mk.D4 = stof(mk.FrB_D4);
		if (mk.FrB_D5 != "") mk.D5 = stof(mk.FrB_D5);
		if (mk.FrB_D6 != "") mk.D6 = stof(mk.FrB_D6);
		if (mk.FrB_D7 != "") mk.D7 = stof(mk.FrB_D7);
		if (mk.FrB_oZ != "") mk.view_ofs_z = stof(mk.FrB_oZ);
		if (mk.FrB_T != "") mk.T = stof(mk.FrB_T);
		mk = mk.marker_linkrev;
	}

	if (world.FrB_door != "" ) {
		found = FindFrB_ID(world, world.FrB_door);
		if(found) dm6_door = found;
	}
	if (world.FrB_doorD != "")
		door_open_dist = stof(world.FrB_doorD);
	if (world.FrB_doorZ != "")
		door_targetZ = stof(world.FrB_doorZ);
}
