/*
	bot/botgoals.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2001 DMSouL
	Copyright (C) 2000-2007 ParboiL
	Universal doors by DrLex 2024/12
*/

#include "../settings.h"

void() AdjustTravelPenalties;

/*
============
ResetGoalEntity

============
*/
void() ResetGoalEntity =
{
	goalentity_ = self.goalentity;
	if (goalentity_)
	{
		goalentity_.teamflag = goalentity_.teamflag - (goalentity_.teamflag & self.teamflag);
		self.goalentity = world;
	}
};

/*
============
UpdateGoalEntity

============
*/
void() UpdateGoalEntity =
{
	test_enemy = first_client;
	while (test_enemy)
	{
		if (test_enemy.goalentity == self)
		{
			goal_refresh_time_ = time + random();
			if (test_enemy.goal_refresh_time > goal_refresh_time_)
				test_enemy.goal_refresh_time = goal_refresh_time_;
		}
		test_enemy = test_enemy.next;
	}
};

/*
============
EvalGoal

============
*/
void() EvalGoal =
{
	if (time < (self.air_finished - 2))
		goal_entity.desire();
	else if (self.items & IT_SLIME_PROOF)
		goal_entity.desire();
	else if ((goal_entity.T & T_LIQUID) || !goal_entity.index)
		goal_entity.desire();
	else  // When about to drown, any marker guaranteed to have air is most desirable
		goal_desire = 600;
	goal_entity.saved_goal_desire = goal_desire;
	if (goal_desire > 0)
	{
		if (mapname == "aerowalk")
		if (pre_game)
		if (!game_disable_powerups)
		if (goal_entity.classname == "dynamic_item")
		{
			goal_entity.saved_goal_desire = 0;
			return;
		}

		if (mapname == "povdmm4")
		if (!door_open)
		if (goal_entity.classname == "item_armor2")
		{
			goal_entity.saved_goal_desire = 0;
			return;
		}

		if (time < goal_entity.touchPlayerTime)
		if (goal_entity.nextthink > 0)
		if (goal_entity.touchPlayer.realteam == realteam_)
		if (goal_entity.touchPlayer != self)
		{
			goal_entity.saved_goal_desire = 0;
			return;
		}

		if(goal_entity.G_ == 1)
			goal_desire = goal_desire * desire_adj_G1;
		else if(goal_entity.G_ == 2)
			goal_desire = goal_desire * desire_adj_G2;

		from_marker = touch_marker_;
		to_marker = goal_entity.touch_marker;
		to_marker.zone_marker();
		to_marker.sub_arrival_time();
		AdjustTravelPenalties();
		goal_time = traveltime;

		if (enemy_repel)
		{
			from_marker = enemy_touch_marker;
			to_marker.zone_marker();
			to_marker.sub_arrival_time();
			AdjustTravelPenalties();
			if (traveltime <= (goal_time - 1.25))
			{
				goal_desire = goal_desire + enemy_repel;
				goal_entity.saved_goal_desire = goal_desire;
				if (goal_desire <= 0)
					return;
			}
		}

		// DrLex: see remarks in botpath.qc.
		if (goalentity_marker.Z_ == door_targetZ)
		{
			local float tZ_behind_door = 0;
			if (touch_marker_.taskClus1 & DM6_DOOR) {
				if ((door_targetZ == 1) && (touch_marker_.Z1_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 2) && (touch_marker_.Z2_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 3) && (touch_marker_.Z3_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 4) && (touch_marker_.Z4_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 5) && (touch_marker_.Z5_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 6) && (touch_marker_.Z6_task & DM6_DOOR)) tZ_behind_door = 1;
			}
			else if (touch_marker_.taskClus2 & DM6_DOOR) {
				if ((door_targetZ == 7) && (touch_marker_.Z7_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 8) && (touch_marker_.Z8_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 9) && (touch_marker_.Z9_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 10) && (touch_marker_.Z10_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 11) && (touch_marker_.Z11_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 12) && (touch_marker_.Z12_task & DM6_DOOR)) tZ_behind_door = 1;
			}
			else if (touch_marker_.taskClus3 & DM6_DOOR) {
				if ((door_targetZ == 13) && (touch_marker_.Z13_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 14) && (touch_marker_.Z14_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 15) && (touch_marker_.Z15_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 16) && (touch_marker_.Z16_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 17) && (touch_marker_.Z17_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 18) && (touch_marker_.Z18_task & DM6_DOOR)) tZ_behind_door = 1;
			}
			else if (touch_marker_.taskClus4 & DM6_DOOR) {
				if ((door_targetZ == 19) && (touch_marker_.Z19_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 20) && (touch_marker_.Z20_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 21) && (touch_marker_.Z21_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 22) && (touch_marker_.Z22_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 23) && (touch_marker_.Z23_task & DM6_DOOR)) tZ_behind_door = 1;
				else if ((door_targetZ == 24) && (touch_marker_.Z24_task & DM6_DOOR)) tZ_behind_door = 1;
			}

			if (tZ_behind_door)
			if (dm6_door.takedamage)
			if (enemy_ == look_object_)
			if (!self.invincible_time)
			if (enemy_.firepower >= 50)
			{
				goal_entity.saved_goal_desire = 0;
				return;
			}
		}

		goal_entity.saved_respawn_time = goal_entity.goal_respawn_time + (goal_time * prediction_error_ * random()) - time;

		if (goal_time < goal_entity.saved_respawn_time)
			goal_time = goal_entity.saved_respawn_time;

		goal_entity.saved_goal_time = goal_time;

		if (self.bot_evade) 
		{
			if (enemy_repel)
			{
				from_marker = enemy_touch_marker;
				to_marker.zone_marker();
				to_marker.sub_arrival_time();
				AdjustTravelPenalties();
				goal_entity.saved_enemy_time_squared = traveltime * traveltime;
			}
			if ((enemy_time_squared + (goal_time * goal_time)) >= goal_entity.saved_enemy_time_squared)
			{
				goal_entity.saved_goal_desire = 0;
				return;
			}
		}

		if (goal_time < lookahead_time_)
		{
			goal_score = goal_desire * (lookahead_time_ - goal_time) / (goal_time + 5);

			if (goal_score > best_score)
			{
				best_score = goal_score;
				best_goal = goal_entity;
			}
		}
	}
};

/*
============
EvalGoal2

============
*/
void() EvalGoal2 =
{
	goal_desire = goal_entity.saved_goal_desire;
	if (goal_desire > 0)
	{
		goal_time2 = goal_entity.saved_goal_time;

		if (goal_time2 <= 5)
		{
			if(goal_entity.G_ == 1)
				goal_desire = goal_desire * desire_adj_G1;
			else if(goal_entity.G_ == 2)
				goal_desire = goal_desire * desire_adj_G2;

			goal_marker2 = goal_entity.touch_marker;

		// first goal_entity, then best_goal

			from_marker = goal_marker2;
			best_goal_marker.zone_marker();
			best_goal_marker.sub_arrival_time();
			AdjustTravelPenalties();
			traveltime2 = goal_time2 + traveltime;
			if (traveltime2 < best_respawn_time)
				traveltime2 = best_respawn_time;
			if (self.bot_evade) 
			if (enemy_repel)
			{
				if ((enemy_time_squared + traveltime2 * traveltime2) >= best_goal.saved_enemy_time_squared)
					traveltime2 = 1000000;
			}
			if (traveltime2 < lookahead_time_)
			{
				goal_score2 = (goal_desire * (lookahead_time_ - goal_time2) / (goal_time2 + 5))
					+ (best_goal_desire * (lookahead_time_ - traveltime2) / (traveltime2 + 5));
				if (goal_score2 > best_score2)
				{
					best_score2 = goal_score2;
					best_goal2 = goal_entity;
				}
			}

		// first best_goal, then goal_entity

			from_marker = best_goal_marker;
			goal_marker2.zone_marker();
			goal_marker2.sub_arrival_time();
			AdjustTravelPenalties();
			traveltime2 = best_goal_time + traveltime;
			if (traveltime2 < goal_entity.saved_respawn_time)
				traveltime2 = goal_entity.saved_respawn_time;
			if (self.bot_evade) 
			if (enemy_repel)
			{
				if ((enemy_time_squared + traveltime2 * traveltime2) >= goal_entity.saved_enemy_time_squared)
					return;
			} 
			if (traveltime2 < lookahead_time_)
			{
				goal_score2 = best_score + (goal_desire * (lookahead_time_ - traveltime2) / (traveltime2 + 5));

				if (goal_score2 > best_score2)
				{
					best_score2 = goal_score2;
					best_goal2 = best_goal;
				}
			}
		}
	}
};

/*
============
UpdateGoal

============
*/
void() UpdateGoal =
{
	self.goal_refresh_time = time + 2 + random();
	prediction_error_ = self.prediction_error;
	best_score = 0;
	best_goal = world;
	enemy_ = self.enemy;
	enemy_touch_marker = enemy_.touch_marker;
	items_ = self.items;
	enemy_desire = enemy_repel = 0;
	self.bot_evade = FALSE;

	if (deathmatch <= 3 && !game_arena)
	{
		if (numberofclients == 2)
		{
			if (random() < 0.08)
			if ((self.origin_z + 18) > (enemy_.absmin_z + enemy_.view_ofs_z))
			if (self.items & IT_ROCKET_LAUNCHER)
			if (self.ammo_rockets > 4)
			if (!self.waterlevel) 
			if ((self.health > 70) && (self.armorvalue > 100) && !enemy_visible)
				self.bot_evade = TRUE;
		}
		else if (numberofclients > 2)
		{
			if (random() < 0.1)
			if ((self.origin_z + 18) > (enemy_.absmin_z + enemy_.view_ofs_z))
			if ((self.items & IT_ROCKET_LAUNCHER) || (self.items & IT_LIGHTNING)) 
			if ((self.ammo_cells >= 20) || (self.ammo_rockets > 3))
			if (!self.waterlevel) 
			if ((self.health > 70) && (self.armorvalue > 90))
			if (!(self.items & (IT_INVULNERABILITY | IT_INVISIBILITY | IT_QUAD)))
				self.bot_evade = TRUE;
		}
	}

	if (enemy_touch_marker)
	{
		virtual_enemy = enemy_;

	//
	// EvalClient
	//

		enemy_.desire();
		if (enemy_desire > 0)
		{
			from_marker = touch_marker_;
			enemy_touch_marker.zone_marker();
			enemy_touch_marker.sub_arrival_time();
			AdjustTravelPenalties();

			enemy_.saved_respawn_time = 0;
			enemy_.saved_goal_time = traveltime;

			if (traveltime < lookahead_time_)
			{
				goal_score = enemy_desire * (lookahead_time_ - traveltime) / (traveltime + 5);

				if (goal_score > best_score)
				{
					best_score = goal_score;
					best_goal = enemy_;
					enemy_.saved_goal_desire = enemy_desire;
				}
			}
		}
		else
		{
			if (enemy_.enemy == self)
				enemy_repel = enemy_desire;
		}
	}
	else
		virtual_enemy = dropper;

	// This seems to be the only place where I see any preference for lower goal
	// numbers, but it is very weak. Only if G1 scores the same in EvalGoal* as
	// for instance G7, and none scores better, then G1 will win from G7  -- DrLex
	goal_entity = touch_marker_.G1_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G2_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G3_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G4_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G5_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G6_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G7_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G8_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G9_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G10_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G11_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G12_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G13_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G14_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G15_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G16_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G17_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G18_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G19_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G20_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G21_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G22_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G23_.virtual_goal;
	EvalGoal();
	goal_entity = touch_marker_.G24_.virtual_goal;
	EvalGoal();

	goal_entity = find(world, classname, "dynamic_item");
	while (goal_entity)
	{
		if (goal_entity.touch_marker)
			EvalGoal();
		goal_entity = find(goal_entity, classname, "dynamic_item");
	}

	if (teamplay && !game_arena)
	{
		search_entity = HelpTeammate();
		if (search_entity != world)
		if (random() < 0.25)
			best_goal = search_entity;
	}

	if (best_goal)
	{
#ifdef DEBUG_GOALS
		dprint("   best_score ", ftos(best_score), " for ", best_goal.classname, "\n");
#endif
		best_goal_desire = best_goal.saved_goal_desire;
		best_goal.saved_goal_desire = 0;	// don't pick twice
		best_goal_time = best_goal.saved_goal_time;
		best_goal_marker = best_goal.touch_marker;
		best_respawn_time = best_goal.saved_respawn_time;

		best_score2 = best_score;
		best_goal2 = best_goal;

		if (enemy_desire > 0)
		{
		//
		// EvalClient2
		//

			goal_time2 = enemy_.saved_goal_time;
			if (goal_time2 <= 5)
			{
				goal_marker2 = enemy_.touch_marker;

			// first enemy_, then best_goal

				from_marker = goal_marker2;
				best_goal_marker.zone_marker();
				best_goal_marker.sub_arrival_time();
				AdjustTravelPenalties();
				traveltime2 = goal_time2 + traveltime;
				if (traveltime2 < best_respawn_time)
					traveltime2 = best_respawn_time;

				if (traveltime2 < lookahead_time_)
				{
					goal_score2 = (enemy_desire * (lookahead_time_ - goal_time2) / (goal_time2 + 5))	+ (best_goal_desire * (lookahead_time_ - traveltime2) / (traveltime2 + 5));

					if (goal_score2 > best_score2)
					{
						best_score2 = goal_score2;
						best_goal2 = enemy_;
					}
				}

			// first best_goal, then enemy_

				from_marker = best_goal_marker;
				goal_marker2.zone_marker();
				goal_marker2.sub_arrival_time();
				AdjustTravelPenalties();
				traveltime2 = best_goal_time + traveltime;
				if (traveltime2 < enemy_.saved_respawn_time)
					traveltime2 = enemy_.saved_respawn_time;

				if (traveltime2 < lookahead_time_)
				{
					goal_score2 = best_score + (enemy_desire * (lookahead_time_ - traveltime2) / (traveltime2 + 5));

					if (goal_score2 > best_score2)
					{
						best_score2 = goal_score2;
						best_goal2 = best_goal;
					}
				}
			}
		}

		goal_entity = touch_marker_.G1_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G2_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G3_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G4_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G5_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G6_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G7_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G8_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G9_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G10_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G11_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G12_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G13_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G14_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G15_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G16_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G17_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G18_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G19_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G20_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G21_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G22_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G23_.virtual_goal;
		EvalGoal2();
		goal_entity = touch_marker_.G24_.virtual_goal;
		EvalGoal2();

		goal_entity = find(world, classname, "dynamic_item");
		while (goal_entity)
		{
			if (goal_entity.touch_marker)
				EvalGoal2();
			goal_entity = find(goal_entity, classname, "dynamic_item");
		}
#ifdef DEBUG_GOALS
		dprint("   best_score2 ", ftos(best_score2), " for ", best_goal2.classname, "\n");
#endif

		goalentity_ = self.goalentity = best_goal2;
		self.goal_respawn_time = time + best_goal2.saved_respawn_time;
	}
	else
		goalentity_ = self.goalentity = world;
};
