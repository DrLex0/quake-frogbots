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

	// Only start doing RJ with custom angles from skill 5 on,
	// because it is slightly hacky
	if (description & ROCKET_JUMP)
	if (touch_marker_.rj_angles)
	if (self.bot_skill < 5)
		return;

	if (!path_normal)
	{
		if (!(description & REVERSIBLE))
			return;
	}
	marker_pos = test_marker.absmin + test_marker.view_ofs;

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

Forces bot to stick to current touch_marker_ and not stray away too far from it.
Parameter is timeout for the marker.
============
*/
void(float lm_time) WaitAtTouchMarker =
{
	linked_marker_ = touch_marker_;
	self.linked_marker = touch_marker_;
	self.path_from_marker = touch_marker_;
	SetExclusive();
	self.path_state = 0;
	self.linked_marker_time = time + lm_time;
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
				WaitAtTouchMarker(5);
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
					WaitAtTouchMarker(5);
					return TRUE;
				}
				btn_target = find (btn_target, targetname, linked_marker_.target);
			}
		}
	}

	/* Comment from ancient times: "FIXME: should this include doors?"
	 * DrLex says: probably not, but map makers do use func_door as lifts, which raises
	 * the question what is a "door". So far I have not seen obvious problems caused
	 * by considering classname "door" here. Walking across a true closed horizontal door
	 * like in dm6 may be OK because it will be in STATE_TOP. However, in general it
	 * is best to just set T_NOTOUCH on doors that should not be part of a true path. */
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
		WaitAtTouchMarker(5);
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
WaitAndShootAtTrigger

Logic for shootable triggers -- it's complicated.
Originally this was only implemented for the dm6 door (yes, only that specific door).
Then it was sort of extended to 1 similar door in any map, but it remained kludgy and limited.
Now it is generalised to anything that needs to be shot in order to traverse the chosen path.
Rules:
- The thing to be shot is set in .shoot_me (from SHOOT_AT pseudo-path).
  This is _mandatory_ if the path has NEED_SHOOT mode. It may also be set on markers
  having a path towards another marker that has a NEED_SHOOT path, to allow the bot
  to already prepare for the shot while approaching the actual NEED_SHOOT spot.
- The thing to be opened may be set in .linked_door. This is set either from the
  LINKED_DOOR pseudo-path, or else from SHOOT_AT if it points to a door. 
  Hence for the typical dm6-like door, .shoot_me == .linked_door.
Return value indicates whether the bot must wait at touch_marker_ or not.
============
*/
float() WaitAndShootAtTrigger =
{
	local entity shoot_tgt = touch_marker_.shoot_me;
	local float path_requires_shot = FALSE;
	// Clear this state, it will be set when needed
	self.state = self.state - (self.state & NEED_SHOOT_AIM);
	if (new_path_state & NEED_SHOOT)
		path_requires_shot = TRUE;
	else if (shoot_tgt)
	{
		// We're not on a NEED_SHOOT path. Check whether we should anticipate:
		// does next marker have NEED_SHOOT towards zone of our goal entity?
		// This is only a heuristic, ideally we should test whether the
		// NEED_SHOOT path is in between here and goal, but too complicated
		// to implement; the heuristic will usually do the trick.
		if (! linked_marker_.shoot_targetZ)
			return FALSE;
		if (linked_marker_.shoot_targetZ != goalentity_marker.Z_)
			return FALSE;
	}
	else return FALSE;

	local entity link_door = touch_marker_.link_door_ent;
	// If door is open enough, just continue
	if (link_door)
	if (vlen(link_door.origin - link_door.pos2) <= link_door.d_door_open)
		return FALSE;

	// Rely on the regular (crude) look system by default. The think logic
	// will override this with more accurate aiming if NEED_SHOOT_AIM is set.
	if (self.look_object != self.enemy)
	{
		look_object_ = shoot_tgt;
		self.look_object = look_object_;
	}
	else if(! self.look_object)  // not expected to happen in real games, but better be safe
	{
		look_object_ = shoot_tgt;
		self.look_object = look_object_;
	}

	// If door needs to be shot but is currently unresponsive,
	// wait unless we're not yet on the NEED_SHOOT path
	if (shoot_tgt == link_door)
	if (!link_door.takedamage)
		return path_requires_shot;

	// Should we execute this more often somewhere else? Seems to work well enough as-is.
	if (shoot_tgt.takedamage)
	{
		// Check whether bot is aiming at the target
		// This does require careful marker placement for small targets. Aim for the crotch!
		src = origin_ + '0 0 16';
		makevectors(self.v_angle);
		traceline(src, src + v_forward*2048, FALSE, self);
		if (trace_ent == shoot_tgt)
		{
			self.shoot_at_thing = TRUE;
			self.state = self.state | NOTARGET_ENEMY;
			// door won't be open immediately, hence wait if path requires it
			if (link_door)
				return path_requires_shot;
			// Fire and forget, continue unconditionally
			return FALSE;
		}
	}
	return path_requires_shot;
}

/*
============
CheckAccurateRunUp

When entering a PRECISE_JUMP path, check whether conditions
are good for the jump. If not, start the run-up procedure.
Do not run-up for a slow PJ or the RJ+PJ combo!
============
*/
void() CheckAccurateRunUp =
{
	if (self.running_up)
		return;
	if (! (new_path_state & PRECISE_JUMP))
		return;
	if (new_path_state & SLOW_DOWN)
		return;
	if (new_path_state & ROCKET_JUMP)
		return;
	if(right_direction(20 + 30 * self.bot_inaccuracy)) // direction already OK, no run-up needed
		return;
	if (touch_marker_.jump_direction)
		dir_move = touch_marker_.absmin + touch_marker_.view_ofs -
			(touch_marker_.jump_direction.absmin + touch_marker_.jump_direction.view_ofs);
	else
		dir_move = touch_marker_.absmin + touch_marker_.view_ofs -
			(linked_marker_.absmin + linked_marker_.view_ofs);
	dir_move_z = 0;
	self.run_up_point = touch_marker_.absmin + touch_marker_.view_ofs + 90 * normalize(dir_move);
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
	// Don't keep pitch even when the path is sloped, it degrades max speed
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
	// When the bot deliberately got airborne, ignore markers until landed, unless T_AIR_TOUCH.
	// A sticky touch must not be ignored, bots may have jumped to activate a switch.
	if (self.path_state & WAIT_GROUND)
	if (!(self.flags & FL_ONGROUND))
	if (!(touch_marker_.T & T_AIR_TOUCH))
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

	if (WaitAndShootAtTrigger())
	{
		self.state = self.state | NEED_SHOOT_AIM;
		WaitAtTouchMarker(0.3);
		return;
	}
	if (WaitOnLift())
		return;

	// NOTE: is currently not set anywhere
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

	self.linked_marker = linked_marker_;
	self.path_from_marker = touch_marker_;
	self.path_state = new_path_state;
	CheckAccurateRunUp();
	CheckWallStrafe();
	SetExclusive();

	if (touch_marker_ == linked_marker_)
		self.linked_marker_time = time + 0.3;
	else
		self.linked_marker_time = time + 5;

	self.old_linked_marker = touch_marker_;

//
// CheckTasks
//

	self.state = self.state & NOT_NOTARGET_ENEMY;
	if (self.flags & FL_ONGROUND)
	if (self.wasinwater)
	{
		self.wasinwater = FALSE;
		self.state = self.state & NOT_NOTARGET_ENEMY;	
	}
	if (look_object_.client_)
		return;

//
//	BestLook
//

	if (look_object_)
	if (look_object_ == touch_marker_.shoot_me)
		return;
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
