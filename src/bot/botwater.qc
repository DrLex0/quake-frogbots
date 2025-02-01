/*
	bot/botwater.qc

	Copyright (C) 1999-2000 Numb
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
Seek way out when in liquid for too long.
This logic is dodgy and has risk of the bot getting forever stuck if
the only way out requires diving. I guess this only exists because we
cannot trust waypoint makers to provide enough paths out from liquids.
Added some extra checks to reduce risk, but it still exists. -- DrLex
*/
void() BotWaterJumpFix = 
{
	if (! self.frogbot) return;
	if (self.watertype > CONTENT_LAVA)
	if (self.items & IT_SLIME_PROOF) // no point in trying to get out
		return;

	// FIXME: nobody should rely on counting to measure time in the 21st century
	self.tread_water_count = self.tread_water_count + 1;
	if (self.tread_water_count > 75)
	{
		self.tread_water_count = 0;
		local entity nearest = LocateMarker(self.origin + '0 0 32');
		if (distance < 1000)  // Do not consider markers behind obstacles
		if (nearest.absmin_z + nearest.view_ofs_z - self.origin_z < 128)  // or too high up
		{
			self.old_linked_marker = world;
			self.linked_marker = nearest;
			self.path_state = 0;
			self.linked_marker_time = time + 5;
		}
	}
};

// This is way too simplistic. If the bot's origin is just 1u behind a corner, this fails.
// FIXME: make a unified thing that sends traces from each corner of the player model,
// and sets arrow keys depending on which trace(s) succeed and which don't.
float() BotCanReachMarker = 
{
	local vector spot1, spot2;
	
	// Note: NEVER use marker.origin unless it is certain to be a point entity.
	// Teleport triggers have '0 0 0' as origin, causing this calculation to return junk.
	spot2 = self.linked_marker.absmin + self.linked_marker.view_ofs;
	spot1 = self.origin + self.view_ofs;

	traceline (spot1,spot2,TRUE,self);
	return (trace_fraction == 1); 
};

float() BotSwimDown =
{
	return ((self.linked_marker.absmin_z + self.linked_marker.view_ofs_z + 1) < self.origin_z);
};

float() BotSwimUp =
{
	return ((self.linked_marker.absmin_z + self.linked_marker.view_ofs_z + 1) >= self.origin_z);
};

float() BotGoUpForAir =
{
	if (self.items & IT_SLIME_PROOF)
		return FALSE;
	if (time > (self.air_finished - 2))
	{
		traceline (self.origin, self.origin + '0 0 64', TRUE, self);
		if (trace_fraction == 1)
			return (self.swim_arrow = UP);	
		else
		{
			new_velocity 	= self.velocity;
			dir_move 	= normalize(dir_move);
			dir_move 	= dir_move + normalize(new_velocity);
			dir_move_z 	= 0;
			NewVelocityForArrow();
		}	
	
		if (time > self.air_finished)
		{	
			// time's up!
			// Origin is 32 units below top, hence we only have a chance
			// to find air if at least 33 units of room.
			traceline (self.origin, self.origin + '0 0 33', TRUE, self);
			if (trace_fraction != 1)
				return (self.swim_arrow = UP);
		}
	}
	return FALSE;	
};

void() SwimAwayFromWall =
{
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
	
};
	
void() FrogWaterMove = 
{
	if (self.frogbot)
	if (self.waterlevel > 2)
	{
		if (time < self.frogwatermove_time)
			return;
		self.frogwatermove_time = self.frogbot_nextthink + 0.1;

		if (self.obstruction_normal != '0 0 0')
			SwimAwayFromWall();

		if (BotGoUpForAir())
		{
			VelocityForArrow();
			return;
		}

		if (touch_marker_)
		if (touch_marker_.classname == "trigger_teleport")
		if (self.linked_marker.classname == "info_teleport_destination")
		{
			VelocityForArrow();
			return;
		}

		if (BotCanReachMarker())
		{
			if (BotSwimDown()) 
			{
				self.swim_arrow = DOWN;
			}
			else if (BotSwimUp()) 
			{
				self.swim_arrow = UP;
			}
		}
		else
		{
			traceline (self.origin,self.origin + '0 0 32', TRUE, self); 
			if (trace_fraction == 1) 
			{
				self.swim_arrow = UP;
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
		}
		VelocityForArrow();
	}
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
