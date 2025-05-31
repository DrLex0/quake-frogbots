/*
	bot/botpath.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2001 DMSouL
	Copyright (C) 2000-2007 ParboiL
	Improvements by DrLex 2024-2025
*/

#include "../settings.h"

float() able_rj;
void() NewVelocityForArrow;
float(float max_angle) right_direction;

/*
============
AdjustTravelPenalties

Dynamic path cost hocus-pocus. Restore traveltime for paths if:
- path has RJ flag and the bot can rocket-jump,
- path goes through slime and the bot has protection,
- path goes through lava and the bot has pentagram.
Basically this must be invoked after every .sub_arrival_time() call.
See TravelTime() for more information.
============
*/
void() AdjustTravelPenalties =
{
	if (traveltime < 1000) return;
	if (traveltime >= 400000) return;

	// Lava or slime. Allow multiple segments (up to 3 for lava, 7 for slime),
	// although this should be very rare.
	// Only paths going into the danger zone will get a penalty. If there are any
	// 'dry' markers surrounded by slime, they must be given 'slime island' type,
	// to ensure the zone is considered as one big whole and the bot will not get
	// stranded on such island when running out of protection.
	// For lava this is pointless: the bot is better off staying on the island when
	// the pentagram expires, and maybe scoring some kills before getting killed,
	// instead of getting a suicide penalty for jumping into the lava.
	if (traveltime >= 100000)
	{
		// Don't jump into lava, or GTFO when only 5s of protection remain
		if (self.invincible_finished - time > 5)
		{
			if (traveltime >= 200000) traveltime = traveltime - 200000;
			if (traveltime >= 100000) traveltime = traveltime - 100000;
		}
		else return;
	}
	if (traveltime >= 10000)
	{
		// Don't jump into slime, or GTFO when only 5s of protection remain
		if ((self.invincible_finished - time > 5) ||
			(self.radsuit_finished - time > 5))
		{
			if (traveltime >= 40000) traveltime = traveltime - 40000;
			if (traveltime >= 20000) traveltime = traveltime - 20000;
			if (traveltime >= 10000) traveltime = traveltime - 10000;
		}
		else return;
	}

	// RJ. Allow planning for up to 2 RJs, but add small penalty in that case.
	if (traveltime >= 1000)
	if (traveltime < 3000)
	if (able_rj())
	{
		if (traveltime < 2000) traveltime = traveltime - 1000;
		else traveltime = traveltime - 1998;
	}
}

/*
============
AdjustPathTimePenalty

Like AdjustTravelPenalties, but for a single segment's path_time.
============
*/
void() AdjustPathTimePenalty
{
	if (path_time < 1000) return;
	if (path_time >= 200000) return;

	if (path_time >= 100000)
	{
		if (self.invincible_finished - time > 5)
			path_time = path_time - 100000;
	}
	if (path_time >= 10000)
	{
		if ((self.invincible_finished - time > 5) ||
			(self.radsuit_finished - time > 5))
			path_time = path_time - 10000;
		else return;
	}

	if (path_time >= 1000)
	if (path_time < 2000)
	if (able_rj())
		path_time = path_time - 1000;
}

/*
============
DropTravelPenalties

To obtain true path times regardless of bot state.
============
*/
void() DropTravelPenalties =
{
	if (traveltime < 1000) return;
	if (traveltime >= 400000) return;
	if (traveltime >= 200000) traveltime = traveltime - 200000;
	if (traveltime >= 100000) traveltime = traveltime - 100000;
	if (traveltime >= 40000) traveltime = traveltime - 40000;
	if (traveltime >= 20000) traveltime = traveltime - 20000;
	if (traveltime >= 10000) traveltime = traveltime - 10000;
	if (traveltime >= 3000) return;
	if (traveltime < 2000) traveltime = traveltime - 1000;
	else traveltime = traveltime - 2000;
}

/*
============
EvalPath

============
*/
void() EvalPath =
{
	// Default for 'lifts' not in down position: do not consider them at all.
	// If 'wait lift' is set on them, do consider them and wait if best path.
	// Also do not ignore when coming from a T_WAITLIFT button, platform may
	// already be moving.
	// If path has Just GO mode, ignore any danger or uselessness.
	if (test_marker.classname == "door")
	if (test_marker.state != STATE_BOTTOM)
	if (! (touch_marker_.T & T_WAITLIFT))
	if (! (test_marker.T & T_WAITLIFT))
	if (! (description & JUST_GO))
		return;

	if (!path_normal)
	{
		if (!(description & REVERSIBLE))
			return;
	}
 	if (test_marker == dm6_door)
	{
		if (!dm6_door.takedamage)
			return;	// door open
	}
	marker_pos = test_marker.absmin + test_marker.view_ofs;

	if (description & DM6_DOOR)
	{
		if (vlen(dm6_door.origin) < door_open_dist)
			return;	// door not open enough
	}

	same_dir = self_dir * normalize(marker_pos - origin_);
	path_score = same_dir + random();

	avoid = FALSE;
	if (time < test_marker.arrow_time)
	if (self != test_marker.arrow_client)
	{
		// Avoid teleport triggers recently approached by _other_ clients
		avoid = TRUE;
	}

	if (! avoid)
	if (rocket_alert)
	{
		if (vlen(marker_pos - rocket_endpos) < 200)
		{
			traceline(rocket_endpos, marker_pos, TRUE, self);
			if (trace_fraction == 1)
				avoid = TRUE;
		}
	}

	if (beQuiet)
	{
	// try not to make noise.
	// items and respawn/teleport destinations
		if (test_marker.pickup)
		if (!test_marker.nextthink)	// item sitting there
		if (test_marker != goalentity_marker)
		if (test_marker.pickup())
			path_score = path_score - 2.5;
	}

	AdjustPathTimePenalty();
	if (avoid)
	{
		path_score = path_score - 2.5;
	}
	else
	{
		if (goalentity_marker)
		{
			from_marker = test_marker;
			path_normal = self.path_normal_;
			goalentity_marker.zone_marker();
			goalentity_marker.sub_arrival_time();
			AdjustTravelPenalties();
			total_goal_time = path_time + traveltime;
			if (total_goal_time > goal_late_time)
			{
				if (traveltime < current_goal_time)	// improve position
					path_score = path_score + lookahead_time_ - total_goal_time;
				else if (total_goal_time > current_goal_time_125) // don't go way off track
					path_score = path_score - total_goal_time;
			}
		}
	}

	if (path_score <= best_score)
		return;
	// Do not pick path going into slime without protection, but OK if we're already in slime
	if (path_time >= 10000)
	if (! (touch_marker_.T & T_BIOHZD))
		return;

	best_score = path_score;
	linked_marker_ = test_marker;
	new_path_state = description;
};

/*
============
EvalLook

============
*/
void() EvalLook =
{
	look_score = (dir_look * normalize((from_marker.absmin + from_marker.view_ofs) - linked_marker_origin));
	look_score = look_score + random();

	if (look_score > best_score)
	{
		best_score = look_score;
		look_object_ = from_marker;
	}
};

/*
============
EvalCloseRunAway

============
*/
void() EvalCloseRunAway =
{
	from_marker = enemy_touch_marker;
	to_marker.zone_marker();
	to_marker.sub_arrival_time();
	AdjustTravelPenalties();
	traveltime2 = traveltime;

	from_marker = touch_marker_;
	to_marker.zone_marker();
	to_marker.sub_arrival_time();
	AdjustTravelPenalties();

	if (look_traveltime)
		test_away_score = random() * RA_time * ((traveltime2 * traveltime2) - (look_traveltime_squared + (traveltime * traveltime))) / (look_traveltime * traveltime);
	else
		test_away_score = random() * RA_time * (traveltime2 - traveltime);

	if (test_away_score > best_away_score)
	{
		best_away_marker = to_marker;
		best_away_score = test_away_score;
	}
};

/*
============
SetExclusive

Initiates normal exclusive path mode if linked_marker_ is exclusive node,
or else, extends it for a short while if touch_marker was exclusive.
The latter is to give priority to the last exclusive marker's chosen path,
instead of letting some other nearby marker steal its touch.
============
*/
void() SetExclusive =
{
	if (linked_marker_.T & T_EXCLUSIVE)
	{
		self.exclusive_deadline = time + 3;
		self.path_state = (self.path_state | EXCLUSIVE_PATH);
	}
	else if (touch_marker_.T & T_EXCLUSIVE)  // Leaving exclusive path
	{
		self.exclusive_deadline = time + 0.33;
		// Prevent yo-yoing on exclusive door paths while door is still open
		self.exclu_door_cooldown = time + 4;
		self.path_state = (self.path_state | EXCLUSIVE_PATH);
	}
};

/*
============
LiftNeedsButton

Returns TRUE if the touched marker is a "door" (typically a lift)
that still needs a button to be pushed, and the bot is currently
heading for this button.
============
*/
float() LiftNeedsButton =
{
	if (touch_marker_.classname != "door")
		return FALSE;
	if (touch_marker_.state != STATE_BOTTOM)
		return FALSE;  // already activated
	if (linked_marker_.classname != "func_button")
		return FALSE;
	if (linked_marker_.target == touch_marker_.targetname)
		return TRUE;
	return FALSE;
};

/*
============
WaitAtTouchMarker

Forces bot to stick to current touch_marker_ and not stray away too far from it
============
*/
void() WaitAtTouchMarker =
{
	linked_marker_ = self.linked_marker = touch_marker_;
	self.path_from_marker = touch_marker_;
	SetExclusive();
	self.path_state = 0;
	self.linked_marker_time = time + 5;
	self.old_linked_marker = world;
	dir_move = touch_marker_.absmin + touch_marker_.view_ofs - self.origin;
	dir_move_z = 0;
	if(vlen(dir_move) > 48)
	{
		dir_move = normalize(dir_move);
		NewVelocityForArrow();
	}
}

/*
============
WaitOnLift

Elevator logic with deliberate ambiguous function name. Handles:
1. waiting for lifts to come down if linked marker has T_WAITLIFT type
   and is either a "door", or button controlling a "door";
2. standing still on lifts while waiting for them to reach destination.
For lifts activated with buttons, 1-way paths must be coming from outside
towards the button, and then from button to platform. Platform touch
will be ignored when the bot is heading for the switch while the lift
is not yet activated.
Return value indicates whether the bot will be waiting or not.
============
*/
float() WaitOnLift =
{
	local entity btn_target;
	if (linked_marker_.T & T_WAITLIFT)
	{
		if (self.path_state & JUST_GO)
			return FALSE;  // allow override for specific paths
		if (linked_marker_.classname == "door")
		{
			if (linked_marker_.state == STATE_BOTTOM)
				return FALSE;
			else
			{
				WaitAtTouchMarker();
				return TRUE;
			}
		}
		if (linked_marker_.target != "")
		{
			// A button could control multiple lifts, take the worst case
			btn_target = find (world, targetname, linked_marker_.target);
			while (btn_target)
			{
				if (btn_target.state != STATE_BOTTOM)
				{
					WaitAtTouchMarker();
					return TRUE;
				}
				btn_target = find (btn_target, targetname, linked_marker_.target);
			}
		}
	}

	/* Comment from ancient times: "FIXME: should this include doors?"
	 * DrLex says: probably not, but map makers do use func_door as lifts, which raises
	 * the question what is a "door". So far I have not seen obvious problems caused
	 * by considering classname "door" here. Walking across a true closed door like in
	 * dm6 is OK because it will be in STATE_TOP. If problems do arise with shootable
	 * doors, an extra test and maybe an extra marker type/path mode will be needed. */
	if (touch_marker_.classname != "door")
		return FALSE;
	if (deathtype == "squish")
		return FALSE;  // don't wait to be squished

	if (touch_marker_.state == STATE_TOP)
		return FALSE;
	if (linked_marker_.absmin_z + linked_marker_.view_ofs_z <= self.origin_z + 18)
		return FALSE;  // can walk to destination

	if (teamplay)
	{
		if (self.state & HELP_TEAMMATE)
			self.state = self.state - HELP_TEAMMATE;
	}

	// check if fully on lift - if not then continue moving to its center
	if (self.absmin_x >= touch_marker_.absmin_x)
	if (self.absmax_x <= touch_marker_.absmax_x)
	if (self.absmin_y >= touch_marker_.absmin_y)
	if (self.absmax_y <= touch_marker_.absmax_y)
	{
		WaitAtTouchMarker();
		return TRUE;
	}
	dir_move = 0.5 * (touch_marker_.absmin + touch_marker_.absmax) - self.origin;
	dir_move_z = 0;
	if(vlen(dir_move) > 4)
	{
		dir_move = normalize(dir_move);
		NewVelocityForArrow();
	}
	return TRUE;
};

/*
============
CheckAccurateRunUp

When entering a non-slow PRECISE_JUMP path, check whether conditions
are good for the jump. If not, start the run-up procedure.
============
*/
void() CheckAccurateRunUp =
{
	if (self.running_up)
		return;
	if (! (new_path_state & PRECISE_JUMP))
	{
		self.running_up = 0;
		return;
	}
	if (new_path_state & SLOW_DOWN)
		return;
	if(right_direction(20 + 30 * self.bot_inaccuracy)) // direction already OK, no run-up needed
		return;
	dir_move = touch_marker_.absmin + touch_marker_.view_ofs -
		(linked_marker_.absmin + linked_marker_.view_ofs);
	dir_move_z = 0;
	self.run_up_point = touch_marker_.absmin + touch_marker_.view_ofs + 100 * normalize(dir_move);
	self.running_up = self.linked_marker_time = time + 2.5;
}

/*
============
CheckWallStrafe

When entering a WALL_STRAFE path, set up parameters to make the
bot strafe run against the nearest wall at optimal angle for
maximal speed boost.
============
*/
void() CheckWallStrafe =
{
	if (! (new_path_state & WALL_STRAFE))
		return;
	if (self.wallstrafe_key)
		return;
	local vector angles, probe_pt;
	// Assume the path vector is parallel to the wall
	self.run_up_point = linked_marker_.absmin + linked_marker_.view_ofs;
	probe_pt = touch_marker_.absmin + touch_marker_.view_ofs;
	dir_move = self.run_up_point - probe_pt;
	angles = vectoangles(dir_move);
	makevectors(angles);
	// Check whether nearest wall is to the left or right. This could be
	// precomputed, but only has to happen very sporadically anyway.
	traceline(probe_pt, probe_pt + (64 * v_right), TRUE, self);
	local float frac_right = trace_fraction;
	traceline(probe_pt, probe_pt - (64 * v_right), TRUE, self);

	// Some weirdness is going on: for real players, optimal angle is about
	// 8 degrees and will provide 150% speed boost up to 480u/s. For bots it
	// is different and also differs between Quake and QW.  Quake bots can
	// achieve 150%, but requires 11.5 degree angle.  In QW, the best we can
	// get is 140% at 15deg angle, but tends to vary more.  To keep things
	// more or less consistent between engines, use 15 degrees at all times.
	if (frac_right + trace_fraction >= 2)
	{
		self.wallstrafe_key = FORWARD;
	}
	else if (trace_fraction < frac_right)
	{
		self.wallstrafe_key = FORWARD_LEFT;
		angles_y = angles_y + 15;
	}
	else
	{
		self.wallstrafe_key = FORWARD_RIGHT;
		angles_y = angles_y - 15;
	}
	angles_x = angles_z = 0;
	makevectors(angles);
	self.wallstrafe_vec = v_forward;
	self.wallstrafe_deadline = time + 3;
	// Apply the new key immediately. Otherwise it could take several more
	// frames before BestArrowForDirection first sets it, and this can cause
	// problems in borderline cases.
	self.arrow = self.wallstrafe_key;
}

/*
============
frogbot_marker_touch

The ginormous bot decision logic when touching a new marker.
============
*/
void() frogbot_marker_touch =
{
	// When the bot deliberately got airborne, ignore markers until landed.
	// Perhaps we'll want to allow overriding this in certain cases with a marker type flag?
	// At any rate, a sticky touch must not be ignored, bots may have jumped to activate a switch.
	if (self.path_state & WAIT_GROUND)
	if (!(self.flags & FL_ONGROUND))
	if (!self.sticky_touch)
		return;

#ifdef DEBUG_TOUCH
	dprint("FBMT m", ftos(touch_marker_.index), "; Lm", ftos(linked_marker_.index), "\n");
#endif
	if (LiftNeedsButton())
		return;

	goalentity_marker = goalentity_.touch_marker;

	if (self.state & RUNAWAY)	// FIXME: consider goals
		goalentity_marker = world;

	if (self.path_state & EXCLUSIVE_PATH)
		self.path_state = self.path_state - EXCLUSIVE_PATH;
	self.sticky_touch = FALSE;

	if (linked_marker_ == touch_marker_)
	{
		if (goalentity_ == touch_marker_)
		{
			if (!touch_marker_.nextthink)
			// item hasn't been touched yet
				return;
		}
		else if (goalentity_marker == touch_marker_)
		{
			if (goalentity_.classname == "dynamic_item")
			{
				if (IsVisible(goalentity_))
				{ 
					linked_marker_ = self.linked_marker = goalentity_;
					self.path_from_marker = touch_marker_;
					SetExclusive();
					self.linked_marker_time = time + 5;
					self.old_linked_marker = touch_marker_;
					return;
				}
			}
		}
	}
	else
	{
		from_marker = self.old_linked_marker;
		to_marker = touch_marker_;
		if (ExistsPath())
		{
			from_marker = touch_marker_;
			to_marker = linked_marker_;
			if (ExistsPath())
			{
				self.path_state = new_path_state;
				self.path_from_marker = touch_marker_;
				return;	// intermediate marker
			}
		}

		self.state = self.state & NOT_HURT_SELF;
	}

//
// best path
//

	self.path_normal_ = TRUE;	// FIXME: AI set this

	if (self.state & RUNAWAY)
	{
		enemy_touch_marker = enemy_.touch_marker;

		if (enemy_touch_marker)
		{
			best_away_marker = world;
			best_away_score = 0;

			to_marker = touch_marker_;
			enemy_touch_marker.sight_from_time();
			look_traveltime_squared = look_traveltime * look_traveltime;

			path_normal = TRUE;

			to_marker = touch_marker_.RA0;
			if (to_marker)
			{
				RA_time = touch_marker_.RA0_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA1;
			if (to_marker)
			{
				RA_time = touch_marker_.RA1_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA2;
			if (to_marker)
			{
				RA_time = touch_marker_.RA2_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA3;
			if (to_marker)
			{
				RA_time = touch_marker_.RA3_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA4;
			if (to_marker)
			{
				RA_time = touch_marker_.RA4_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA5;
			if (to_marker)
			{
				RA_time = touch_marker_.RA5_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA6;
			if (to_marker)
			{
				RA_time = touch_marker_.RA6_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA7;
			if (to_marker)
			{
				RA_time = touch_marker_.RA7_time;
				EvalCloseRunAway();
			}

			if (!best_away_marker)
				best_away_marker = touch_marker_;

			self.goal_respawn_time = 0;
			goalentity_marker = best_away_marker;

			self.path_normal_ = TRUE;
		}
	}

	if (random () < 0.5)
	if (self.items & IT_ROCKET_LAUNCHER)
	if (self.ammo_rockets)
	if ((self.firepower < enemy_.firepower) && (self.armorvalue < enemy_.armorvalue))
	if (!avoid)
	{
		to_marker = enemy_.touch_marker;
		if (to_marker)
		{
			from_marker = touch_marker_;
			from_marker.higher_sight_from_marker();
			if (!look_marker)
			{
				self._highermarker = 0;
				HigherSightMarker();
			}
			if (look_marker)
			{
				goalentity_marker = look_marker;
				self._highermarker = 1;
			}
		}
	}

	if (duel_mode)
	if (enemy_.weapon == IT_GRENADE_LAUNCHER)
	if (enemy_.ammo_rockets > 6)
	if ((self.origin_z + 18) < (enemy_.absmin_z + enemy_.view_ofs_z))
	if (vlen(self.origin - enemy_.origin) < 200)
	if (enemy_.button0)
	{
		to_marker = enemy_.touch_marker;
		if (to_marker)
		{
			from_marker = touch_marker_;
			from_marker.higher_sight_from_marker();
			if (!look_marker)
			{
				self._highermarker = 0;
				HigherSightMarker();
			}
			if (look_marker)
			{
				goalentity_marker = look_marker;
				self._highermarker = 1;
			}
		}
	}

	best_score = -1000000;
	self_dir = normalize(self.velocity);

	rocket_alert = FALSE;

	if (enemy_.items & IT_ROCKET_LAUNCHER && !(self.items & IT_INVULNERABILITY))
	{
		if (enemy_.attack_finished <= time + 0.2)
		{
			if (enemy_.ammo_rockets)
			{
				if (random() < 0.5)
				{
					src = enemy_.origin + '0 0 16';
					traceline(src, origin_, TRUE, self);
					if (trace_fraction != 1)
					{
						rocket_alert = TRUE;
						makevectors(enemy_.v_angle);
						traceline(src, src + (v_forward * 500), TRUE, self);
						rocket_endpos = trace_endpos;
					}
				}
			}
		}
	}

	if (look_object_ == enemy_)
		beQuiet = FALSE;

	else
	{
		if (enemy_)
			beQuiet = !self.allowedMakeNoise;
		else
			beQuiet = FALSE;
	}

	if (goalentity_marker)
	{
		from_marker = touch_marker_;

		path_normal = self.path_normal_;
		goalentity_marker.zone_marker();
		goalentity_marker.sub_arrival_time();
		AdjustTravelPenalties();
		current_goal_time = traveltime;
		current_goal_time_125 = current_goal_time + 1.25;
		if (current_goal_time < 2.5)
			goal_late_time = (self.goal_respawn_time - (random() * 5)) - time;
		else
			goal_late_time = (self.goal_respawn_time - (random() * 10))- time;

		// The idea here seems to also evaluate just staying in place as an option.
		test_marker = touch_marker_;
		if (test_marker)
		if (self.watertype != CONTENT_LAVA)  // not a good idea
		{
			description = 0;
			path_time = 0;
			EvalPath();
		}
	}

	test_marker = touch_marker_.P0;
	if (test_marker)
	{
		description = touch_marker_.D0;
		path_time = touch_marker_.P0_time;
		EvalPath();
	}

	test_marker = touch_marker_.P1;
	if (test_marker)
	{
		description = touch_marker_.D1;
		path_time = touch_marker_.P1_time;
		EvalPath();
	}

	test_marker = touch_marker_.P2;
	if (test_marker)
	{
		description = touch_marker_.D2;
		path_time = touch_marker_.P2_time;
		EvalPath();
	}

	test_marker = touch_marker_.P3;
	if (test_marker)
	{
		description = touch_marker_.D3;
		path_time = touch_marker_.P3_time;
		EvalPath();
	}

	test_marker = touch_marker_.P4;
	if (test_marker)
	{
		description = touch_marker_.D4;
		path_time = touch_marker_.P4_time;
		EvalPath();
	}

	test_marker = touch_marker_.P5;
	if (test_marker)
	{
		description = touch_marker_.D5;
		path_time = touch_marker_.P5_time;
		EvalPath();
	}

	test_marker = touch_marker_.P6;
	if (test_marker)
	{
		description = touch_marker_.D6;
		path_time = touch_marker_.P6_time;
		EvalPath();
	}

	test_marker = touch_marker_.P7;
	if (test_marker)
	{
		description = touch_marker_.D7;
		path_time = touch_marker_.P7_time;
		EvalPath();
	}

	if (WaitOnLift())
		return;

	if (self.state & WAIT)
	{
		if (!look_object_.client_)
		{
			traceline(linked_marker_.absmin + linked_marker_.view_ofs + '0 0 32', look_object_.absmin + look_object_.view_ofs + '0 0 32', TRUE, self);
			if (trace_fraction != 1)
			{	
				linked_marker_ = touch_marker_;
				new_path_state = 0;
			}
		}
		else
			self.state = self.state - (self.state & WAIT); 
	}

	if (mapname == "dm3")
	{
		if (numberofclients > 1)
		if (teamplay && deathmatch <= 3)
		if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING) && !self.bot_evade)
		if ((self.health > 60) && (self.armorvalue > 80))
		if ((self.ammo_cells > 15) || (self.ammo_rockets > 3))
		{
			search_entity = find(world, classname, "item_artifact_super_damage");
			if (search_entity != world)
			if (random() < 0.5)
			{
				if (search_entity.origin_z <= self.origin_z + 18)
				if (vlen(search_entity.origin - self.origin) < 200)
				{
					if (random() < 0.9)
					{
						self.camp_state = self.camp_state | CAMPBOT;
						linked_marker_ = touch_marker_;
					}
				}
				else 
					self.camp_state = self.camp_state - (self.camp_state & CAMPBOT);
			}
		}
	}
	else if (mapname == "dm4")
	{
		if (duel_mode)
		if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING) && !self.bot_evade)
		if ((self.health > 50) && (self.armorvalue > 30))
		if ((self.ammo_cells > 15) || (self.ammo_rockets > 3))
		{
			if (random() < 0.985) 
			{
				if ((enemy_.origin_x < 700) && (vlen('448 -176 60' - self.origin) < 200))
				{
					self.camp_state = self.camp_state | CAMPBOT;
					linked_marker_ = touch_marker_;
				}
				else if ((enemy_.origin_x >= 700) && (vlen('280 -330 60' - self.origin) < 200))
				{
					self.camp_state = self.camp_state | CAMPBOT;
					linked_marker_ = touch_marker_;
				}
				else
					self.camp_state = self.camp_state - (self.camp_state & CAMPBOT);
			}
		}
	}
	else if (mapname == "dm6")
	{
		if (numberofclients > 1)
		if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING) && !self.bot_evade)
		if ((self.health > 80) && (self.armorvalue > 100))
		if ((self.ammo_cells > 15) || (self.ammo_rockets > 3))
		{
			search_entity = find(world, classname, "item_armorInv");
			if (search_entity != world)
			{
				if (search_entity.origin_z <= self.origin_z + 18)
				if (vlen(search_entity.origin - self.origin) < 200)
				{
					if (random() < 0.9)
					{
						self.camp_state = self.camp_state | CAMPBOT;
						linked_marker_ = touch_marker_;
					}
				}
				else
					self.camp_state = self.camp_state - (self.camp_state & CAMPBOT);
			}
		}
	}

	CheckAccurateRunUp();
	CheckWallStrafe();

	self.linked_marker = linked_marker_;
	self.path_from_marker = touch_marker_;
	self.path_state = new_path_state;
	SetExclusive();

	if (touch_marker_ == linked_marker_)
		self.linked_marker_time = time + 0.3;
	else
		self.linked_marker_time = time + 5;

	self.old_linked_marker = touch_marker_;

//
// CheckTasks
//

	// DrLex: generalize dm6_door.
	// As far as I understand it, the Z1_task property collects all path mode
	// bits encountered until goalentity_marker if it is in Z1. I extended it to
	// all zones, clustered so we don't need to test all 24 in the worst case.
	// Using zone 1 for the things behind the door is the most efficient.
	if (goalentity_marker.Z_ == door_targetZ)
	{
		// This makes one wish that QuakeC would short-circuit && and || operators...
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
		{
			direction = normalize(dm6_door.absmin + dm6_door.view_ofs - origin_ - '0 0 40');
			src = origin_ + '0 0 16';

			traceline (src, src + direction*2048, FALSE, self);
			if (trace_ent == dm6_door)
				self.path_state = self.path_state | DM6_DOOR;
		}
		else
		{
			self.path_state = self.path_state - (self.path_state & DM6_DOOR);
		}
	}

	self.state = self.state & NOT_NOTARGET_ENEMY;
	if (self.flags & FL_ONGROUND)
	if (self.wasinwater)
	{
		self.wasinwater = FALSE;
		self.state = self.state & NOT_NOTARGET_ENEMY;	
	}
	if (self.path_state & DM6_DOOR)
	{
		self.state = self.state | NOTARGET_ENEMY;
		look_object_ = dm6_door;
		self.look_object = look_object_;
		return;
	}
	if (look_object_.client_)
		return;

//
//	BestLook
//

	if ((self.waterlevel == 2) || (self.waterlevel == 1)) // SOUL
	{
		self.look_object = self.linked_marker;
		return;
	}
	if (self.path_state & FOCUS_PATH)
	{
		self.look_object = look_object_ = self.linked_marker;
		return;
	}

	if (random() < self.look_anywhere)
	{
		// FIXME: if no enemy then replace with goalentity

		from_marker = enemy_.touch_marker;
		if (!from_marker)
			from_marker = goalentity_marker;

		if (from_marker)
		{
			to_marker = linked_marker_;
			from_marker.sight_from_marker();

			if (look_marker)
			{
				path_normal = TRUE;
				look_marker.zone_marker();
				look_marker.sub_arrival_time();
				AdjustTravelPenalties();
				look_traveltime = traveltime;
			}
			else
				SightMarker();

			if (look_marker)
			{
				to_marker = from_marker;
				from_marker = linked_marker_;

				path_normal = TRUE;
				to_marker.zone_marker();
				to_marker.sub_arrival_time();
				AdjustTravelPenalties();

				if (look_traveltime < traveltime)
				{
					self.look_object = look_object_ = look_marker;
					self.predict_shoot = TRUE;
					return;
				}
			}
		}
	}

	if (touch_marker_ == linked_marker_)
		dir_look = '0 0 0';
	else
	{
		linked_marker_origin = linked_marker_.absmin + linked_marker_.view_ofs;
		dir_look = normalize(linked_marker_origin - origin_);
	}
	makevectors(self.v_angle);
	dir_look = normalize((self.velocity * inv_sv_maxspeed) + v_forward + dir_look);
	linked_marker_origin = linked_marker_.absmin + linked_marker_.view_ofs;

	best_score = -1000000;

	from_marker = linked_marker_.P0;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P1;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P2;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P3;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P4;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P5;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P6;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P7;
	if (from_marker)
		EvalLook();

	self.look_object = look_object_;
	self.predict_shoot = FALSE;
};
