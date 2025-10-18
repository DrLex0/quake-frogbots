/*
	bot/botwater.qc

	Copyright (C) 1999-2000 Numb
	Redesign by DrLex 2025/02
*/

#include "../settings.h"

void() VelocityForArrow;


float() WaterCombat =
{
	if (self.waterlevel < 2)
		return TRUE;
	return ((pointcontents(enemy_.origin) == CONTENT_WATER) && (enemy_.origin_z < origin__z - 32));
};

float() JumpInWater =
{
	return (pointcontents(self.origin + '0 0 -64') == CONTENT_WATER);
};

/*
============
CheckWaterPathState

Clear path states that make no sense while swimming
============
*/
void() CheckWaterPathState =
{
	if (self.waterlevel < 2)
		return;
	if (self.path_state & WAIT_GROUND)
	{
		if (self.path_state & DELIBERATE_AIR)
			self.path_state = self.path_state - DELIBERATE_AIR_WAIT_GROUND;
		else
			self.path_state = self.path_state - WAIT_GROUND;
	}
}

/*
============
CheckBotStuckInLiquid

Use a different strategy when we can't seem to reach the target marker
in liquids than on land. When this happens, it may be because the bot
briefly touched a marker on a ledge and fell back in liquid, or drifted
away while trying to reach a marker. Try to fix by finding a nearby
accessible marker and resetting path state.
============
*/
void() CheckBotStuckInLiquid = 
{
	if (! self.frogbot) return;

	if (time < self.water_unstuck_retry) return;

	// Use stricter deadline, so we are are ahead of the regular expiry mechanism
	if (time < self.linked_marker_time - 2.5)
	{
		self.water_unstuck_retry = 0;
		return;
	}

	// ignore markers too high up, probably can't reach them anyway
	local entity nearest = LocateMarker(self.origin + '0 0 32', 42);
	if (distance >= 1000)
		return;  // markers behind obstacle or too high up
	self.old_linked_marker = world;
	self.linked_marker = nearest;
	self.path_state = 0;
	self.linked_marker_time = time + 5;
	self.water_unstuck_retry = time + 3;
};

/*
============
BotVerticalSwim

Swim up or down depending on target marker position
============
*/
void() BotVerticalSwim
{
	if (! self.linked_marker) return;
	if ((self.linked_marker.absmin_z + self.linked_marker.view_ofs_z + 1) < self.origin_z) 
		self.swim_arrow = DOWN;
	else if ((self.linked_marker.absmin_z + self.linked_marker.view_ofs_z + 1) >= self.origin_z) 
	{
		self.swim_arrow = UP;
	}
	VelocityForArrow();
}

/*
============
SwimAwayFromWall

Obstruction avoidance: only if obstruction persists, otherwise
risk of oscillating in place and eventually drowning
============
*/
float() SwimAwayFromWall =
{
	if (self.obstruction_normal == '0 0 0')
	{
		self.t_swim_obstruction = 0;
		return FALSE;
	}
	if (! self.t_swim_obstruction)
	{
		self.t_swim_obstruction = time + 0.2;
		return FALSE;
	}
	if (time < self.t_swim_obstruction)
		return FALSE;

#ifdef DEBUG_WATER
	dprint("SwimAwayFromWall\n");
#endif
	if ((self.obstruction_normal * rel_pos) > 0.5)
	{
		dir_move = (-1) * dir_move;
	}

	traceline (self.origin, self.origin + v_right * 20, TRUE, self);
	if (trace_fraction != 1)
	{
		dir_move = normalize(dir_move);
		dir_move = normalize(dir_move + ((-32) * v_right * random()));
	}

	traceline (self.origin, self.origin + v_right * (-20), TRUE, self);
	if (trace_fraction != 1)
	{
		dir_move = normalize(dir_move);
		dir_move = normalize(dir_move + (32 * v_right * random()));
	}

	NewVelocityForArrow();
	self.t_swim_obstruction = 0;
	return TRUE;
};

/*
============
BotGoUpForAir

Try not to drown.
============
*/
float() BotGoUpForAir =
{
	if (self.items & IT_SLIME_PROOF)
		return FALSE;
	if ((self.touch_marker.T | self.linked_marker.T) & T_NO_AIR)
		return FALSE;
	if (time > (self.air_finished - 2))
	{
#ifdef DEBUG_WATER
		dprint("BotGoUpForAir\n");
#endif
		if (self.obstruction_normal != '0 0 0')
		{
			dir_move = -1 * self.obstruction_normal;
			NewVelocityForArrow();
			return TRUE;
		}
		traceline (self.origin, self.origin + '0 0 64', TRUE, self);
		if (trace_fraction == 1)
		{
			self.swim_arrow = FORCE_UP;
			return TRUE;
		}
		new_velocity 	= self.velocity;
		dir_move 	= normalize(dir_move);
		dir_move 	= dir_move + normalize(new_velocity);
		dir_move_z 	= 0;
		NewVelocityForArrow();
	
		if (time > self.air_finished)
		{
#ifdef DEBUG_WATER
			dprint("BotGoUpForAir!\n");
#endif
			// time's up!
			// Origin is 32 units below top, we only have a chance
			// to find air if we can move up at least 1u
			traceline (self.origin, self.origin + '0 0 33', TRUE, self);
			if (trace_fraction == 1)
			{
				self.swim_arrow = FORCE_UP;
				return TRUE;
			}
		}
	}
	return FALSE;
};

/*
============
OffsetProbeMarker

Traces a line towards linked_marker from self.origin plus
X, Z offsets in plane defined by v_right and v_up unit vectors.
Returns 1 if no obstacle encountered, 0 otherwise
============
*/
float(float x_ofs, float z_ofs) OffsetProbeMarker =
{
	local vector spot1, spot2;

	spot1 = self.origin + (x_ofs * v_right) + (z_ofs * v_up);
	spot2 = self.linked_marker.absmin + self.linked_marker.view_ofs;
	traceline (spot1, spot2, TRUE, self);
	// marker for switch, platform, etc may be inside its brush
	if (trace_ent == self.linked_marker) return 1;
	if (trace_fraction == 1) return 1;
	return 0;
};

/*
============
ForwardProbeMarker

Check if bot can move across f_dist * v_forward
and will then be able to see linked_marker
============
*/
float(float f_dist) ForwardProbeMarker =
{
	local vector spot1, spot2;

	spot1 = self.origin + '0 0 4';  // centre of player model
	spot2 = spot1 + (v_forward * f_dist);
	traceline(spot1, spot2, TRUE, self);
	if (trace_fraction < 1) return FALSE;

	spot1 = self.linked_marker.absmin + self.linked_marker.view_ofs;
	traceline(spot2, spot1, TRUE, self);
	if (trace_ent == self.linked_marker) return TRUE;
	return (trace_fraction == 1);
}

/*
============
BotSubmarineLogic

This implements movement logic similar to a submarine with 4 sonars arranged in a rectangle.
If A = topLeft, B = topRight, C = bottomLeft, D = bottomRight, and 0 means obstruction,
and we treat ABCD as a binary number, then we get as lookup table for desired movement:
0	0000  cannot see marker from any corner
1	0001  RIGHT DOWN
2	0010  LEFT DOWN
3	0011  DOWN
4	0100  RIGHT UP
5	0101  RIGHT
6	0110  either LEFT UP or RIGHT DOWN
7	0111  RIGHT DOWN
8	1000  LEFT UP
9	1001  either RIGHT UP or LEFT DOWN
10	1010  LEFT
11	1011  LEFT DOWN
12	1100  UP
13	1101  RIGHT UP
14	1110  LEFT UP
15	1111  all corners OK
Return value:
  0 if bot is good to go
  1 if movement keys have been set
  2 if marker not visible at all
============
*/
float(float lookup) BotSubmarineLogic =
{
	// Test most likely cases first
	if (lookup == 15)  // all OK: go for it
		return 0;

	if (lookup > 8)
	{
		if (lookup == 12)  // obstruction bottom
		{
			self.swim_arrow = UP;
			return 1;
		}
		if (lookup == 10)  // obstruction right
		{
			self.arrow = LEFT;
			return 1;
		}
		if (lookup == 7)  // obstruction top left
		{
			self.arrow = RIGHT;
			self.swim_arrow = DOWN;
			return 1;
		}
		if (lookup == 11)  // obstruction top right
		{
			self.arrow = LEFT;
			self.swim_arrow = DOWN;
			return 1;
		}
		if (lookup == 13)  // obstruction bottom left
		{
			self.arrow = RIGHT;
			self.swim_arrow = UP;
			return 1;
		}
		// 14: obstruction bottom right, 8: visible top left, 9: obstruction diagonal /
		// For case 9, could do random LU or RD, but would require extra to stick to choice;
		// should be very rare anyway, prefer upward move and hope for the best.
		self.arrow = LEFT;
		self.swim_arrow = UP;
		return 1;
	}
	// lookup < 9
	if (lookup == 0)  // not visible from any corner
	{
		return 2;
	}
	if (lookup == 3)  // obstruction top
	{
		self.swim_arrow = DOWN;
		return 1;
	}
	if (lookup == 5)  // obstruction left
	{
		self.arrow = RIGHT;
		return 1;
	}
	if (lookup == 1)  // visible bottom right
	{
		self.arrow = RIGHT;
		self.swim_arrow = DOWN;
		return 1;
	}
	if (lookup == 2)  // visible bottom left
	{
		self.arrow = LEFT;
		self.swim_arrow = DOWN;
		return 1;
	}
	// 4: visible top right; 6: obstruction diagonal \ (same remark as above)
	self.arrow = RIGHT;
	self.swim_arrow = UP;
	return 1;
};

void() FrogWaterMove =
{
	if (! self.frogbot)
		return;
	if (self.flags & FL_WATERJUMP)
		return;

	if (self.waterlevel < 3)
	{
		if (self.waterlevel == 2)
			BotVerticalSwim();
		return;
	}
	if (time < self.frogwatermove_time)
		return;
	self.frogwatermove_time = self.frogbot_nextthink + 0.1;

	if (BotGoUpForAir())
	{
		VelocityForArrow();
		return;
	}
	if (SwimAwayFromWall())
		return;

	if (touch_marker_)
	if (touch_marker_.classname == "trigger_teleport")
	if (self.linked_marker.classname == "info_teleport_destination")
	{
		VelocityForArrow();
		return;
	}

	// Turn the bot into a sonar-equipped submarine.
	// And of course implement this as if it still needs to run on a Pentium II.
	// Maybe some random errors should be added on lower skill levels, this may
	// work a little too well to realistically mimic a human player.
	local float tl, tr, bl, br, go_state;
	local vector facing = '0 0 0';
	facing_y = self.v_angle_y;
	// v_right, v_up, v_forward will be used by OffsetProbeMarker & ForwardProbeMarker
	makevectors(facing);
	// Don't take exact corners, avoid risk of starting traces inside solids
	tl = OffsetProbeMarker(-15.9, 31.9);
	tr = OffsetProbeMarker(15.9, 31.9);
	bl = OffsetProbeMarker(-15.9, -23.9);
	br = OffsetProbeMarker(15.9, -23.9);
	go_state = BotSubmarineLogic((8 * tl) + (4 * tr) + (2 * bl) + br);

	if (go_state == 0)  // keep moving, adjust vertical position
	{
		BotVerticalSwim();
		return;
	}

	if (go_state == 1)  // keys set, execute them
	{
		VelocityForArrow();
		return;
	}

	if (go_state == 2)  // marker invisible, try a forward probe
	if (ForwardProbeMarker(64))
	{
		// marker is just behind a corner: force move forward
		self.velocity = v_forward * sv_maxwaterspeed;
		self.velocity_override = self.velocity;
		self.t_velocity_override = time + (64 / sv_maxwaterspeed);
#ifdef DEBUG_WATER
		dprint("Water fwd probe override ", ftos(64 / sv_maxwaterspeed), "s\n");
#endif
		VelocityForArrow();
		return;
	}

	// Don't know what to do, try random stuff
#ifdef DEBUG_WATER
	dprint("Water random up/down; Lm", ftos(self.linked_marker.index), "\n");
#endif
	if (random() > 0.5)
	{
		traceline (self.origin,self.origin + '0 0 33', TRUE, self);
		if (trace_fraction == 1) 
		{
			self.swim_arrow = UP;
		}
		else
		{
			self.swim_arrow = DOWN;
		}
	}
	else 
	{
		traceline (self.origin,self.origin + '0 0 -32', TRUE, self); 
		if (trace_fraction == 1) 
		{
			self.swim_arrow = DOWN;
		}
		else
		{
			self.swim_arrow = UP;
		}
	}
	VelocityForArrow();
};

float () BotShouldDischarge =
{
	local float n;
	local entity p;

	if (self.waterlevel != 3)
		return FALSE;

	if (!(self.items & IT_LIGHTNING))
		return FALSE;

	if (self.ammo_cells < 25)
		return FALSE;

	if (self.enemy_dist > 600)
		return FALSE;

	if (look_object_ != enemy_)
		return FALSE;

	// discharge!
	if (self.invincible_time > time)
	if (pointcontents(enemy_.origin) == CONTENT_WATER)
		return TRUE;

	// don't discharge...
	if ((self.items & IT_ROCKET_LIGHTNING) && (self.ammo_rockets > 25) && (self.ammo_cells > 25))
		return FALSE;

	if ((self.items & IT_NAILGUN_ROCKET) && (self.ammo_rockets > 25) && (self.ammo_nails > 25))
		return FALSE;

	n = 0;
	p = findradius(self.origin, 1000);
	while (p != world)
	{
		if (pointcontents(p.origin) == CONTENT_WATER)
		{
			if (p.client_)
			{
				if (p.takedamage)
				{
					if (IsVisible(p))
					{
						if (p.realteam != self.realteam)
						{
							n = n + 1;
						}
						else
						{
							n = n - 1;
						}
					}
				}
			}
		}
		p = p.chain;
	}
	
	if (n >= 2)
	{
		// discharge! we'll kill 2 or more 
		if (random() < 0.003)
		{	
			return TRUE;
		}
	}

	return FALSE;
};
