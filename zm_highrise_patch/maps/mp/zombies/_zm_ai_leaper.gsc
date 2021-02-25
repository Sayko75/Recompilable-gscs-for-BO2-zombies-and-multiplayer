//checked includes match cerberus output
#include maps/mp/zm_highrise_elevators;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

precache() //checked matches cerberus output
{
	precache_fx();
}

precache_fx() //checked matches cerberus output
{
	level._effect[ "leaper_death" ] = loadfx( "maps/zombie/fx_zmb_leaper_death" );
	level._effect[ "leaper_spawn" ] = loadfx( "maps/zombie/fx_zmb_leaper_spawn" );
	level._effect[ "leaper_trail" ] = loadfx( "maps/zombie/fx_zmb_leaper_trail" );
	level._effect[ "leaper_walk" ] = loadfx( "maps/zombie/fx_zmb_leaper_walk" );
	level._effect[ "leaper_wall_impact" ] = loadfx( "maps/zombie/fx_zmb_leaper_wall_impact" );
}

init() //checked matches cerberus output
{
	leaper_spawner_init();
	leaper_calc_anim_offsets();
	if ( !isDefined( level.leapers_per_player ) )
	{
		level.leapers_per_player = 2;
	}
	level.no_jump_triggers = getentarray( "leaper_no_jump_trigger", "targetname" );
}

leaper_calc_anim_offsets() //checked matches cerberus output
{
	leaper = spawn_zombie( level.leaper_spawners[ 0 ] );
	if ( isDefined( leaper ) )
	{
		level.leaper_anim = spawnstruct();
		asd = "zm_wall_up";
		anim_id = leaper getanimfromasd( asd, 0 );
		level.leaper_anim.up_mid = getmovedelta( anim_id, 0, 0.488 ) + vectorScale( ( 0, 0, 1 ), 6 );
		level.leaper_anim.up_end = getmovedelta( anim_id, 0, 1 );
		asd = "zm_wall_left";
		anim_id = leaper getanimfromasd( asd, 0 );
		wallhit_time = getnotetracktimes( anim_id, "wallhit" );
		level.leaper_anim.left_mid = getmovedelta( anim_id, 0, wallhit_time[ 0 ] ) + vectorScale( ( 0, 0, 1 ), 48 );
		level.leaper_anim.left_end = getmovedelta( anim_id, 0, 1 );
		asd = "zm_wall_left_large";
		anim_id = leaper getanimfromasd( asd, 0 );
		wallhit_time = getnotetracktimes( anim_id, "wallhit" );
		level.leaper_anim.left_large_mid = getmovedelta( anim_id, 0, wallhit_time[ 0 ] ) + vectorScale( ( 0, 0, 1 ), 48 );
		level.leaper_anim.left_large_end = getmovedelta( anim_id, 0, 1 );
		asd = "zm_wall_right";
		anim_id = leaper getanimfromasd( asd, 0 );
		wallhit_time = getnotetracktimes( anim_id, "wallhit" );
		level.leaper_anim.right_mid = getmovedelta( anim_id, 0, wallhit_time[ 0 ] ) + vectorScale( ( 0, 0, 1 ), 48 );
		level.leaper_anim.right_end = getmovedelta( anim_id, 0, 1 );
		asd = "zm_wall_right_large";
		anim_id = leaper getanimfromasd( asd, 0 );
		wallhit_time = getnotetracktimes( anim_id, "wallhit" );
		level.leaper_anim.right_large_mid = getmovedelta( anim_id, 0, wallhit_time[ 0 ] ) + vectorScale( ( 0, 0, 1 ), 48 );
		level.leaper_anim.right_large_end = getmovedelta( anim_id, 0, 1 );
		leaper delete();
	}
}

leaper_spawner_init() //checked changed to match cerberus output
{
	level.leaper_spawners = getentarray( "leaper_zombie_spawner", "script_noteworthy" );
	if ( level.leaper_spawners.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.leaper_spawners.size; i++ )
	{
		level.leaper_spawners[ i ].is_enabled = 1;
		level.leaper_spawners[ i ].script_forcespawn = 1;
	}
	/*
/#
	assert( level.leaper_spawners.size > 0 );
#/
	*/
	level.leaper_health = 100;
	array_thread( level.leaper_spawners, ::add_spawn_function, ::leaper_init );
	/*
/#
	if ( isDefined( level.leaper_rounds_enabled ) && level.leaper_rounds_enabled )
	{
		level thread leaper_spawner_zone_check();
#/
	}
	*/
}

leaper_spawner_zone_check() //checked changed to match cerberus output
{
	flag_wait( "zones_initialized" );
	str_zone_list = "";
	str_spawn_count_list = "";
	n_zones_missing_spawners = 0;
	a_zones = getarraykeys( level.zones );
	for ( i = 0; i < a_zones.size; i++ )
	{
		if ( level.zones[ a_zones[ i ] ].leaper_locations.size == 0 )
		{
			n_zones_missing_spawners++;
		}
	}
	/*
/#
	assert( n_zones_missing_spawners == 0, "All zones require at least one leaper spawn point." + n_zones_missing_spawners + " zones are missing leaper spawners. They are: " + str_zone_list );
#/
/#
	println( "========== LEAPER SPAWN COUNT PER ZONE ===========" );
	println( str_spawn_count_list );
	println( "==================================================" );
#/
	*/
}

leaper_init() //checked changed out to match cerberus output
{
	self endon( "death" );
	level endon( "intermission" );
	self.animname = "leaper_zombie";
	self.audio_type = "leaper";
	self.has_legs = 1;
	self.ignore_all_poi = 1;
	self.is_leaper = 1;
	self.melee_anim_func = ::melee_anim_func;
	self.meleedamage = 30;
	recalc_zombie_array();
	if ( isDefined( self.spawn_point ) )
	{
		spot = self.spawn_point;
		if ( !isDefined( spot.angles ) )
		{
			spot.angles = ( 0, 0, 0 );
		}
		self forceteleport( spot.origin, spot.angles );
	}
	self playsound( "zmb_vocals_leaper_spawn" );
	self set_zombie_run_cycle( "run" );
	self.state = "init";
	self thread leaper_think();
	self thread leaper_spawn_failsafe();
	self thread leaper_traverse_watcher();
	self.maxhealth = level.leaper_health;
	self.health = level.leaper_health;
	self setphysparams( 15, 0, 24 );
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
	self.allowpain = 0;
	self thread play_ambient_leaper_vocals();
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self maps/mp/zombies/_zm_spawner::zombie_setup_attack_properties();
	self maps/mp/zombies/_zm_spawner::zombie_complete_emerging_into_playable_area();
	self setfreecameralockonallowed( 0 );
	if ( ( self.spawn_point.script_parameters == "emerge_bottom" || self.spawn_point.script_parameters == "emerge_top" ) && isDefined( self.spawn_point.script_parameters ) )
	{
		self thread do_leaper_emerge( self.spawn_point );
	}
	self thread leaper_death();
	self thread leaper_check_zone();
	self thread leaper_check_no_jump();
	self thread leaper_watch_enemy();
	self.combat_animmode = ::leaper_combat_animmode;
	level thread maps/mp/zombies/_zm_spawner::zombie_death_event( self );
	self thread maps/mp/zombies/_zm_spawner::enemy_death_detection();
	self thread leaper_elevator_failsafe();
}

play_ambient_leaper_vocals() //checked changed to match cerberus output
{
	self endon( "death" );
	wait randomintrange( 2, 4 );
	while ( 1 )
	{
		if ( isDefined( self ) )
		{
			if ( isDefined( self.favoriteenemy ) && distance( self.origin, self.favoriteenemy.origin ) <= 150 )
			{
			}
			else
			{
				self playsound( "zmb_vocals_leaper_ambience" );
			}
		}
		wait randomfloatrange( 1, 1.5 );
	}
}

leaper_death() //checked matches cerberus output
{
	self endon( "leaper_cleanup" );
	self waittill( "death" );
	self leaper_stop_trail_fx();
	self playsound( "zmb_vocals_leaper_death" );
	playfx( level._effect[ "leaper_death" ], self.origin );
	if ( get_current_zombie_count() == 0 && level.zombie_total == 0 )
	{
		level.last_leaper_origin = self.origin;
		level notify( "last_leaper_down" );
	}
	if ( isplayer( self.attacker ) )
	{
		event = "death";
		if ( issubstr( self.damageweapon, "knife_ballistic_" ) )
		{
			event = "ballistic_knife_death";
		}
		self.attacker thread do_player_general_vox( "general", "leaper_killed", 20, 20 );
		self.attacker maps/mp/zombies/_zm_score::player_add_points( event, self.damagemod, self.damagelocation, 1 );
	}
}

leaper_think() //checked changed to match cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		switch( self.state )
		{
			case "init":
				leaper_building_jump();
				break;
			case "chasing":
				leaper_check_wall();
				break;
			case "leaping":
				break;
		}
        wait 0.1;
	}
}

leaper_can_use_anim( local_mid, local_end, dir ) //checked matches cerberus output
{
	start = self.origin;
	mid = self localtoworldcoords( local_mid );
	end = self localtoworldcoords( local_end );
	real_mid = mid;
	forward_dist = length( end - start ) * 0.5;
	forward_vec = vectornormalize( end - start );
	temp_org = start + vectorScale( forward_vec, forward_dist );
	forward_org = ( temp_org[ 0 ], temp_org[ 1 ], real_mid[ 2 ] );
	end_top = end + vectorScale( ( 0, 0, 1 ), 24 );
	end_bottom = end + vectorScale( ( 0, 0, -1 ), 60 );
	trace = bullettrace( start, mid, 1, self );
	if ( isDefined( trace[ "entity" ] ) )
	{
		return 0;
	}
	if ( isDefined( trace[ "fraction" ] ) && trace[ "fraction" ] < 1 )
	{
		if ( trace[ "fraction" ] < 0.2 )
		{
			/*
/#
			if ( getDvarInt( #"5B4FE0B3" ) == 1 )
			{
				line( start, mid, ( 0, 0, 1 ), 1, 0, 100 );
#/
			}
			*/
			return 0;
		}
		if ( dir == "up" )
		{
			if ( trace[ "fraction" ] < 0.9 )
			{
				return 0;
			}
		}
		mid = trace[ "position" ];
		/*
/#
		if ( getDvarInt( #"5B4FE0B3" ) >= 1 )
		{
			line( start, mid, ( 0, 0, 1 ), 1, 0, 100 );
#/
		}
		*/
		if ( dir != "up" )
		{
			trace = bullettrace( forward_org, real_mid, 1, self );
			if ( isDefined( trace[ "entity" ] ) )
			{
				return 0;
			}
			if ( isDefined( trace[ "fraction" ] ) && trace[ "fraction" ] < 1 )
			{
				/*
/#
				if ( getDvarInt( #"5B4FE0B3" ) == 1 )
				{
					line( forward_org, real_mid, ( 0, 0, 1 ), 1, 0, 100 );
#/
				}
				*/
			}
			else
			{
				/*
/#
				if ( getDvarInt( #"5B4FE0B3" ) == 1 )
				{
					line( forward_org, real_mid, ( 0, 0, 1 ), 1, 0, 100 );
#/
				}
				*/
				return 0;
			}
		}
	}
	else
	{
		/*
/#
		if ( getDvarInt( #"5B4FE0B3" ) == 1 )
		{
			line( start, mid, ( 0, 0, 1 ), 1, 0, 100 );
#/
		}
		*/
		return 0;
	}
	trace = bullettrace( mid, end, 1, self );
	if ( isDefined( trace[ "fraction" ] ) && trace[ "fraction" ] < 1 )
	{
		/*
/#
		if ( getDvarInt( #"5B4FE0B3" ) == 1 )
		{
			line( mid, end, ( 0, 0, 1 ), 1, 0, 100 );
#/
		}
		*/
		return 0;
	}
	else
	{
		/*
/#
		if ( getDvarInt( #"5B4FE0B3" ) >= 1 )
		{
			line( mid, end, ( 0, 0, 1 ), 1, 0, 100 );
#/
		}
		*/
	}
	trace = bullettrace( end_top, end_bottom, 1, self );
	if ( isDefined( trace[ "fraction" ] ) && trace[ "fraction" ] >= 1 )
	{
		/*
/#
		if ( getDvarInt( #"5B4FE0B3" ) == 1 )
		{
			line( end_top, end_bottom, ( 0, 0, 1 ), 1, 0, 100 );
#/
		}
		*/
		return 0;
	}
	else
	{
		/*
/#
		if ( getDvarInt( #"5B4FE0B3" ) >= 1 )
		{
			line( end_top, end_bottom, ( 0, 0, 1 ), 1, 0, 100 );
#/
		}
		*/
	}
	return 1;
}

leaper_building_jump() //checked matches cerberus output
{
	self endon( "death" );
	if ( isDefined( self.spawn_point.script_string ) && self.spawn_point.script_string != "find_flesh" )
	{
		self animscripted( self.spawn_point.origin, self.spawn_point.angles, "zm_building_leap", self.spawn_point.script_string );
		self maps/mp/animscripts/zm_shared::donotetracks( "building_leap_anim" );
	}
	self thread leaper_playable_area_failsafe();
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	self.state = "chasing";
}

leaper_check_wall() //checked matches cerberus output
{
	self endon( "death" );
	if ( !isDefined( self.next_leap_time ) )
	{
		self.next_leap_time = getTime() + 500;
	}
	if ( is_true( self.sliding_on_goo ) || is_true( self.is_leaping ) )
	{
		return;
	}
	if ( getTime() > self.next_leap_time && !is_true( self.no_jump ) )
	{
		wall_anim = [];
		if ( self leaper_can_use_anim( level.leaper_anim.up_mid, level.leaper_anim.up_end, "up" ) )
		{
			wall_anim[ wall_anim.size ] = "zm_wall_up";
		}
		if ( self leaper_can_use_anim( level.leaper_anim.left_mid, level.leaper_anim.left_end, "left" ) )
		{
			wall_anim[ wall_anim.size ] = "zm_wall_left";
		}
		else
		{
			if ( self leaper_can_use_anim( level.leaper_anim.left_large_mid, level.leaper_anim.left_large_end, "left_large" ) )
			{
				wall_anim[ wall_anim.size ] = "zm_wall_left_large";
			}
		}
		if ( self leaper_can_use_anim( level.leaper_anim.right_mid, level.leaper_anim.right_end, "right" ) )
		{
			wall_anim[ wall_anim.size ] = "zm_wall_right";
		}
		else
		{
			if ( self leaper_can_use_anim( level.leaper_anim.right_large_mid, level.leaper_anim.right_large_end, "right_large" ) )
			{
				wall_anim[ wall_anim.size ] = "zm_wall_right_large";
			}
		}
		if ( !self isinscriptedstate() )
		{
			b_should_play_wall_jump_anim = wall_anim.size > 0;
		}
		if ( b_should_play_wall_jump_anim && isDefined( self.enemy ) && self cansee( self.enemy ) || is_true( self.in_player_zone ) )
		{
			wall_anim = array_randomize( wall_anim );
			self.leap_anim = wall_anim[ 0 ];
			self leaper_start_trail_fx();
			self.ignoreall = 1;
			self.is_leaping = 1;
			self notify( "stop_find_flesh" );
			self notify( "zombie_acquire_enemy" );
			self animcustom( ::leaper_play_anim );
			self waittill( "leap_anim_done" );
			self leaper_stop_trail_fx();
			self.ignoreall = 0;
			self.is_leaping = 0;
			self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
			self.next_leap_time = getTime() + 500;
		}
	}
}

leaper_check_zone() //checked changed to match cerberus output
{
	self endon( "death" );
	self.in_player_zone = 0;
	while ( 1 )
	{
		self.in_player_zone = 0;
		foreach ( zone in level.zones )
		{
			if ( !isDefined( zone.volumes ) || zone.volumes.size == 0 )
			{
			}
			else
			{
				zone_name = zone.volumes[ 0 ].targetname;
				if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( zone_name ) )
				{
					if ( is_true( zone.is_occupied ) )
					{
						self.in_player_zone = 1;
						break;
					}
				}
			}
		}
		wait 0.2;
	}
}

leaper_check_no_jump() //checked changed to match cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		self.no_jump = 0;
		foreach ( trigger in level.no_jump_triggers )
		{
			if ( self istouching( trigger ) )
			{
				self.no_jump = 1;
				break;
			}
		}
		wait 0.2;
	}
}

melee_anim_func() //checked matches cerberus output
{
	self.next_leap_time = getTime() + 1500;
	self animmode( "gravity" );
}

leaper_start_trail_fx() //checked matches cerberus output
{
	self endon( "death" );
	self leaper_stop_trail_fx();
	self.trail_fx = spawn( "script_model", self.origin );
	self.trail_fx setmodel( "tag_origin" );
	self.trail_fx linkto( self );
	wait 0.1;
	playfxontag( level._effect[ "leaper_trail" ], self.trail_fx, "tag_origin" );
}

leaper_stop_trail_fx() //checked matches cerberus output
{
	if ( isDefined( self.trail_fx ) )
	{
		self.trail_fx delete();
	}
}

leaper_play_anim() //checked matches cerberus output
{
	self endon( "death" );
	self animmode( "nogravity" );
	self setanimstatefromasd( self.leap_anim );
	self thread leaper_handle_fx_notetracks( "wall_anim" );
	maps/mp/animscripts/zm_shared::donotetracks( "wall_anim" );
	self animmode( "normal" );
	self notify( "leap_anim_done" );
}

leaper_handle_fx_notetracks( animname ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "leap_anim_done" );
	if ( isDefined( self.leap_anim ) && self getanimhasnotetrackfromasd( "wallhit" ) )
	{
		self waittillmatch( animname );
		playfx( level._effect[ "leaper_wall_impact" ], self.origin );
	}
}

leaper_notetracks( animname ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "leap_anim_done" );
	self waittillmatch( animname );
	self animmode( "normal" );
}

enable_leaper_rounds() //checked matches cerberus output
{
	level.leaper_rounds_enabled = 1;
	flag_init( "leaper_round" );
	level thread leaper_round_tracker();
}

leaper_round_tracker() //checked changed to match cerberus output
{
	level.leaper_round_count = 1;
	level.next_leaper_round = level.round_number + randomintrange( 4, 7 );
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while ( 1 )
	{
		level waittill( "between_round_over" );
		if ( level.round_number == level.next_leaper_round )
		{
			level.music_round_override = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			leaper_round_start();
			level.round_spawn_func = ::leaper_round_spawning;
			level.round_wait_func = ::leaper_round_wait;
			level.next_leaper_round = level.round_number + randomintrange( 4, 6 );
		}
		else if ( flag( "leaper_round" ) )
		{
			leaper_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.music_round_override = 0;
			level.leaper_round_count += 1;
		}
	}
}

leaper_round_spawning() //checked changed to match cerberus output
{
	level endon( "intermission" );
	level endon( "leaper_round_ending" );
	level.leaper_targets = getplayers();
	for ( i = 0; i < level.leaper_targets.size; i++ )
	{
		level.leaper_targets[ i ].hunted_by = 0;
	}
	/*
/#
	level endon( "kill_round" );
	if ( getDvarInt( "zombie_cheat" ) == 2 || getDvarInt( "zombie_cheat" ) >= 4 )
	{
		return;
#/
	}
	*/
	if ( level.intermission )
	{
		return;
	}
	level.leaper_intermission = 1;
	level thread leaper_round_accuracy_tracking();
	level thread leaper_round_aftermath();
	players = get_players();
	wait 1;
	playsoundatposition( "vox_zmba_event_dogstart_0", ( 0, 0, 0 ) );
	wait 1;
	if ( level.leaper_round_count < 3 )
	{
		max = players.size * level.leapers_per_player;
	}
	else
	{
		max = players.size * level.leapers_per_player;
	}
	level.zombie_total = max;
	leaper_health_increase();
	level.leaper_count = 0;
	while ( 1 )
	{
		b_hold_spawning_when_leapers_are_all_dead = 1;
		/*
/#
		n_test_mode_active = getDvarInt( #"298DD9A4" );
		if ( isDefined( n_test_mode_active ) && n_test_mode_active == 1 )
		{
			level.zombie_total = 9999;
			b_hold_spawning_when_leapers_are_all_dead = 0;
		}
		else
		{
			n_remaining_leapers_this_round = max - level.leaper_count;
			level.zombie_total = clamp( n_remaining_leapers_this_round, 0, max );
#/
		}
		*/
		if ( ( level.leaper_count >= max ) && b_hold_spawning_when_leapers_are_all_dead )
		{
			wait 0.5;
			continue;
		}
		num_player_valid = get_number_of_valid_players();
		per_player = 2;
		/*
/#
		if ( getDvarInt( #"5A273E4B" ) == 2 )
		{
			per_player = 1;
#/
		}
		*/
		while ( get_current_zombie_count() >= ( num_player_valid * per_player ) )
		{
			wait 2;
			num_player_valid = get_number_of_valid_players();
		}
		players = get_players();
		favorite_enemy = get_favorite_enemy();
		spawn_point = leaper_spawn_logic( level.enemy_dog_spawns, favorite_enemy );
		ai = spawn_zombie( level.leaper_spawners[ 0 ] );
		if ( isDefined( ai ) )
		{
			ai.favoriteenemy = favorite_enemy;
			ai.spawn_point = spawn_point;
			spawn_point thread leaper_spawn_fx( ai, spawn_point );
			level.zombie_total--;

			level.leaper_count++;
		}
		waiting_for_next_leaper_spawn( level.leaper_count, max );
	}
}

leaper_round_accuracy_tracking() //checked changed to match cerberus output
{
	players = getplayers();
	level.leaper_round_accurate_players = 0;
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ].total_shots_start_leaper_round = players[ i ] maps/mp/gametypes_zm/_globallogic_score::getpersstat( "total_shots" );
		players[ i ].total_hits_start_leaper_round = players[ i ] maps/mp/gametypes_zm/_globallogic_score::getpersstat( "hits" );
	}
	level waittill( "last_leaper_down" );
	players = getplayers();

	for ( i = 0; i < players.size; i++ )
	{
		total_shots_end_leaper_round = players[ i ] maps/mp/gametypes_zm/_globallogic_score::getpersstat( "total_shots" ) - players[ i ].total_shots_start_leaper_round;
		total_hits_end_leaper_round = players[ i ] maps/mp/gametypes_zm/_globallogic_score::getpersstat( "hits" ) - players[ i ].total_hits_start_leaper_round;
		if ( total_shots_end_leaper_round == total_hits_end_leaper_round )
		{
			level.leaper_round_accurate_players++;
		}
	}
	if ( level.leaper_round_accurate_players == players.size )
	{
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] maps/mp/zombies/_zm_score::add_to_player_score( 2000 );
		}
		if ( isDefined( level.last_leaper_origin ) )
		{
			trace = groundtrace( level.last_leaper_origin + vectorScale( ( 0, 0, 1 ), 10 ), level.last_leaper_origin + vectorScale( ( 0, 0, -1 ), 150 ), 0, undefined, 1 );
			power_up_origin = trace[ "position" ];
			level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "free_perk", power_up_origin + vectorScale( ( 1, 1, 0 ), 30 ) );
		}
	}
}

leaper_round_wait() //checked matches cerberus output
{
	level endon( "restart_round" );
	/*
/#
	if ( getDvarInt( "zombie_cheat" ) == 2 || getDvarInt( "zombie_cheat" ) >= 4 )
	{
		level waittill( "forever" );
#/
	}
	*/
	wait 1;
	if ( flag( "leaper_round" ) )
	{
		wait 7;
		while ( level.leaper_intermission )
		{
			wait 0.5;
		}
	}
}

leaper_health_increase() //checked changed to match cerberus output
{
	players = getplayers();
	if ( level.leaper_round_count == 1 )
	{
		level.leaper_health = 400;
	}
	else if ( level.leaper_round_count == 2 )
	{
		level.leaper_health = 900;
	}
	else if ( level.leaper_round_count == 3 )
	{
		level.leaper_health = 1300;
	}
	else if ( level.leaper_round_count == 4 )
	{
		level.leaper_health = 1600;
	}
	if ( level.leaper_health > 1600 )
	{
		level.leaper_health = 1600;
	}
}

get_favorite_enemy() //checked partially changed to match cerberus output see compiler_limitations.md No.2
{
	leaper_targets = getplayers();
	least_hunted = leaper_targets[ 0 ];
	i = 0;
	while ( i < leaper_targets.size )
	{
		if ( !isDefined( leaper_targets[ i ].hunted_by ) )
		{
			leaper_targets[ i ].hunted_by = 0;
		}
		if ( !is_player_valid( leaper_targets[ i ] ) )
		{
			i++;
			continue;
		}
		if ( !is_player_valid( least_hunted ) )
		{
			least_hunted = leaper_targets[ i ];
		}
		if ( leaper_targets[ i ].hunted_by < least_hunted.hunted_by )
		{
			least_hunted = leaper_targets[ i ];
		}
		i++;
	}
	least_hunted.hunted_by += 1;
	return least_hunted;
}

leaper_watch_enemy() //checked matches cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		if ( !is_player_valid( self.favoriteenemy ) )
		{
			self.favoriteenemy = get_favorite_enemy();
		}
		wait 0.2;
	}
}

leaper_combat_animmode() //checked matches cerberus output
{
	self animmode( "gravity", 0 );
}

leaper_spawn_logic_old( leaper_array, favorite_enemy ) //checked partially changed to match cerberus output see compiler_limitations.md No. 2
{
	all_locs = getstructarray( "leaper_location", "script_noteworthy" );
	leaper_locs = array_randomize( all_locs );
	i = 0;
	while ( i < leaper_locs.size )
	{
		if ( leaper_locs.size > 1 )
		{
			if ( isDefined( level.old_leaper_spawn ) && level.old_leaper_spawn == leaper_locs[ i ] )
			{
				i++;
				continue;
			}
		}
        dist_squared = distancesquared( leaper_locs[ i ].origin, favorite_enemy.origin );
        if ( dist_squared > 160000 && dist_squared < 1000000 )
        {
            level.old_leaper_spawn = leaper_locs[ i ];
            return leaper_locs[ i ];
        }
		i++;
	}
	return leaper_locs[ 0 ];
}

leaper_spawn_logic( leaper_array, favorite_enemy ) //checked changed to match cerberus output
{
	a_zones_active = level.active_zone_names;
	a_zones_occupied = [];
	foreach ( zone in a_zones_active )
	{
		if ( level.zones[ zone ].is_occupied )
		{
			a_zones_occupied[ a_zones_occupied.size ] = zone;
		}
	}
	a_leaper_spawn_points = [];
	foreach ( zone in a_zones_occupied )
	{
		a_leaper_spawn_points = arraycombine( a_leaper_spawn_points, level.zones[ zone ].leaper_locations, 0, 0 );
	}
	if ( a_leaper_spawn_points.size == 0 )
	{
		foreach ( zone in a_zones_active )
		{
			a_leaper_spawn_points = arraycombine( a_leaper_spawn_points, level.zones[ zone ].leaper_locations, 0, 0 );
		}
	}
	if ( a_leaper_spawn_points.size == 0 )
	{
		str_zone_list_occupied = "";
		a_keys_error = getarraykeys( a_zones_occupied );
		foreach ( key in a_zones_occupied )
		{
			str_zone_list_occupied = ( str_zone_list_occupied + "  " ) + key;
		}
		str_zone_list_active = "";
		a_keys_error = getarraykeys( a_zones_active );
		foreach ( key in a_zones_active )
		{
			str_zone_list_active = ( str_zone_list_active + "  " ) + key;
		}
		/*
/#
		assertmsg( "No leaper spawn locations were found in any of the occupied or active zones. Occupied zones: " + str_zone_list_occupied + ". Active zones: " + str_zone_list_active );
#/
		*/
	}
	/*
/#
	if ( getDvarInt( #"A8C231AA" ) )
	{
		player = get_players()[ 0 ];
		a_spawn_points_in_view = [];
		i = 0;
		while ( i < a_leaper_spawn_points.size )
		{
			player_vec = vectornormalize( anglesToForward( player.angles ) );
			player_spawn = vectornormalize( a_leaper_spawn_points[ i ].origin - player.origin );
			dot = vectordot( player_vec, player_spawn );
			if ( dot > 0,707 )
			{
				a_spawn_points_in_view[ a_spawn_points_in_view.size ] = a_leaper_spawn_points[ i ];
				debugstar( a_leaper_spawn_points[ i ].origin, 1000, ( 0, 0, 1 ) );
			}
			i++;
		}
		if ( a_spawn_points_in_view.size <= 0 )
		{
			a_spawn_points_in_view[ a_spawn_points_in_view.size ] = a_leaper_spawn_points[ 0 ];
			iprintln( "no spawner in view" );
		}
		a_leaper_spawn_points = a_spawn_points_in_view;
	}
#/
	*/
	s_leaper_spawn_point = select_leaper_spawn_point( a_leaper_spawn_points );
	return s_leaper_spawn_point;
}

select_leaper_spawn_point( a_spawn_points ) //checked changed to match cerberus output
{
	a_valid_nodes = get_valid_spawner_array( a_spawn_points );
	if ( a_valid_nodes.size == 0 )
	{
		/*
/#
		iprintln( "All leaper spawns used...resetting" );
#/
		*/
		for ( i = 0; i < a_spawn_points.size; i++ )
		{
			a_spawn_points[ i ].has_spawned_leaper_this_round = 0;
		}
		a_valid_nodes = get_valid_spawner_array( a_spawn_points );
	}
	if ( a_valid_nodes.size > 0 )
	{
		s_spawn_point = random( a_valid_nodes );
		s_spawn_point.has_spawned_leaper_this_round = 1;
	}
	else
	{
		/*
/#
		iprintln( "DEBUG: no valid leaper spawns available" );
#/
		*/
		s_spawn_point = a_spawn_points[ 0 ];
	}
	return s_spawn_point;
}

get_valid_spawner_array( a_spawn_points ) //checked partially changed to match cerberus output see compiler_limitations.md No.2 used is_true instead
{
	a_valid_nodes = [];
	i = 0;
	while ( i < a_spawn_points.size )
	{
		if ( is_true( a_spawn_points[ i ].is_blocked ) || !is_true( a_spawn_points[ i ].is_enabled ) || is_true( a_spawn_points[ i ].is_spawning ) )
		{
			i++;
			continue;
		}
		if ( !isDefined( a_spawn_points[ i ].has_spawned_leaper_this_round ) )
		{
			a_spawn_points[ i ].has_spawned_leaper_this_round = 0;
		}
		if ( !a_spawn_points[ i ].has_spawned_leaper_this_round )
		{
			a_valid_nodes[ a_valid_nodes.size ] = a_spawn_points[ i ];
		}
		i++;
	}
	return a_valid_nodes;
}

leaper_spawn_fx( ai, ent ) //checked matches cerberus output
{
	ai setfreecameralockonallowed( 0 );
	ai show();
	ai setfreecameralockonallowed( 1 );
	v_fx_origin = ai.spawn_point.origin;
	if ( isDefined( ai.spawn_point.script_string ) && ai.spawn_point.script_string != "find_flesh" )
	{
		wait 0.1;
		v_fx_origin = ai gettagorigin( "J_SpineLower" );
	}
	playfx( level._effect[ "leaper_spawn" ], v_fx_origin );
	playsoundatposition( "zmb_leaper_spawn_fx", v_fx_origin );
}

waiting_for_next_leaper_spawn( count, max ) //checked matches cerberus output
{
	default_wait = 1.5;
	if ( level.leaper_round_count == 1 )
	{
		default_wait = 3;
	}
	else if ( level.leaper_round_count == 2 )
	{
		default_wait = 2.5;
	}
	else if ( level.leaper_round_count == 3 )
	{
		default_wait = 2;
	}
	else
	{
		default_wait = 1.5;
	}
	default_wait -= count / max;
	default_wait = clamp( default_wait, 0, 3 );
	wait default_wait;
}

leaper_round_aftermath() //checked changed to match cerberus output
{
	level waittill( "last_leaper_down" );
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "dog_end" );
	power_up_origin = undefined;
	if ( isDefined( level.last_leaper_origin ) )
	{
		trace = groundtrace( level.last_leaper_origin + vectorScale( ( 0, 0, 1 ), 10 ), level.last_leaper_origin + vectorScale( ( 0, 0, -1 ), 150 ), 0, undefined, 1 );
		power_up_origin = trace[ "position" ];
	}
	if ( isDefined( power_up_origin ) )
	{
		level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "full_ammo", power_up_origin );
	}
	wait 2;
	clientnotify( "leaper_stop" );
	wait 6;
	level.leaper_intermission = 0;
}

leaper_round_start() //checked matches cerberus output
{
	flag_set( "leaper_round" );
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "dog_start" );
	level thread leaper_round_start_audio();
	level notify( "leaper_round_starting" );
	clientnotify( "leaper_start" );
}

leaper_round_stop() //checked matches cerberus output
{
	flag_clear( "leaper_round" );
	level notify( "leaper_round_ending" );
	clientnotify( "leaper_stop" );
}

leaper_traverse_watcher() //checked matches cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		if ( is_true( self.is_traversing ) )
		{
			self.elevator_parent = undefined;
			if ( is_true( self maps/mp/zm_highrise_elevators::object_is_on_elevator() ) )
			{
				if ( isDefined( self.elevator_parent ) )
				{
					if ( is_true( self.elevator_parent.is_moving ) )
					{
						playfx( level._effect[ "zomb_gib" ], self.origin );
						self leaper_cleanup();
						self delete();
						return;
					}
				}
			}
		}
		wait 0.2;
	}
}

leaper_playable_area_failsafe() //checked partially changed to match cerberus output see compiler_limitations.md No. 6
{
	self endon( "death" );
	self.leaper_failsafe_start_time = getTime();
	playable_area = getentarray( "player_volume", "script_noteworthy" );
	b_outside_playable_space_this_frame = 0;
	self.leaper_outside_playable_space_time = -2;
	while ( 1 )
	{
		b_outside_playable_last_check = b_outside_playable_space_this_frame;
		b_outside_playable_space_this_frame = is_leaper_outside_playable_space( playable_area );
		n_current_time = getTime();
		if ( b_outside_playable_space_this_frame && !b_outside_playable_last_check )
		{
			self.leaper_outside_playable_space_time = n_current_time;
		}
		else if ( !b_outside_playable_space_this_frame )
		{
			self.leaper_outside_playable_space = -1;
		}
		b_leaper_has_been_alive_long_enough = ( n_current_time - self.leaper_failsafe_start_time ) > 3000;
		b_leaper_is_in_scripted_state = self isinscriptedstate();
		if ( b_outside_playable_space_this_frame )
		{
			if ( ( ( n_current_time - self.leaper_outside_playable_space_time ) > 2000 ) )
			{
				b_leaper_has_been_out_of_playable_space_long_enough_to_delete = true;
			}
			else
			{
				b_leaper_has_been_out_of_playable_space_long_enough_to_delete = false;
			}
		}
		if ( b_leaper_has_been_alive_long_enough && !b_leaper_is_in_scripted_state && b_leaper_has_been_out_of_playable_space_long_enough_to_delete )
		{
			b_can_delete = true;
		}
		else 
		{
			b_can_delete = false;
		}
		if ( b_can_delete )
		{
			playsoundatposition( "zmb_vocals_leaper_fall", self.origin );
			self leaper_cleanup();
			/*
/#
			str_traversal_data = "";
			if ( isDefined( self.traversestartnode ) )
			{
				str_traversal_data = " Last traversal used = " + self.traversestartnode.animscript + " at " + self.traversestartnode.origin;
			}
			iprintln( "leaper at " + self.origin + " with spawn point " + self.spawn_point.origin + " out of play space. DELETING!" + str_traversal_data );
#/
			*/
			self delete();
			return;
		}
		wait 1;
	}
}

is_leaper_outside_playable_space( playable_area ) //checked changed to match cerberus output
{
	b_outside_play_space = 1;
	foreach ( area in playable_area )
	{
		if ( self istouching( area ) )
		{
			b_outside_play_space = 0;
		}
	}
	return b_outside_play_space;
}

leaper_cleanup() //checked matches cerberus output
{
	self leaper_stop_trail_fx();
	self notify( "leaper_cleanup" );
	wait 0.05;
	level.leaper_count--;
	level.zombie_total++;
}

leaper_spawn_failsafe() //checked changed to match cerberus output
{
	self endon( "death" );
	while ( 1 )
	{
		prevorigin = self.origin;
		dist_sq = 0;
		for ( i = 0; i < 3; i++ )
		{
			if ( is_true( self.sliding_on_goo ) )
			{
				dist_sq += 576;
			}
			wait 1;
			dist_sq += distancesquared( self.origin, prevorigin );
			prevorigin = self.origin;
		}
		if ( dist_sq < 576 )
		{
			if ( !is_true( self.melee_attack ) )
			{
				self leaper_cleanup();
				/*
/#
				str_traversal_data = "";
				if ( isDefined( self.traversestartnode ) )
				{
					str_traversal_data = " Last traversal used = " + self.traversestartnode.animscript + " at " + self.traversestartnode.origin;
				}
				iprintln( "leaper_spawn_failsafe() killing leaper at " + self.origin + " with spawn point " + self.spawn_point.origin + "!\n" + str_traversal_data );
#/
				*/
				self dodamage( self.health + 100, ( 0, 0, 1 ) );
				return;
			}
			else 
			{
				/*
				/#
				if ( getDvarInt( #"5A273E4B" ) == 1 )
				{
					iprintln( "leaper tried melee" );
	#/
				}
				self.melee_attack = 0;
				*/
			}
		}
	}
}

do_leaper_emerge( spot ) //checked matches cerberus output
{
	self endon( "death" );
	self.deathfunction = ::leaper_death_ragdoll;
	self.no_powerups = 1;
	self.in_the_ceiling = 1;
	spot.is_spawning = 1;
	anim_org = spot.origin;
	anim_ang = spot.angles;
	self ghost();
	self thread maps/mp/zombies/_zm_spawner::hide_pop();
	self thread leaper_death_wait( "spawn_anim" );
	if ( isDefined( level.custom_faller_entrance_logic ) )
	{
		self thread [[ level.custom_faller_entrance_logic ]]();
	}
	self leaper_emerge();
	wait 0.1;
	self notify( "spawn_anim_finished" );
	spot.is_spawning = 0;
}

leaper_death_ragdoll() //checked changed to match cerberus output
{
	self startragdoll();
	self launchragdoll( ( 0, 0, -1 ) );
	return self maps/mp/zombies/_zm_spawner::zombie_death_animscript();
}

leaper_death_wait( endon_notify ) //checked matches cerberus output
{
	self endon( "spawn_anim_finished" );
	self waittill( "death" );
	self.spawn_point.is_spawning = 0;
}

leaper_emerge() //checked matches cerberus output
{
	self endon( "death" );
	if ( self.spawn_point.script_parameters == "emerge_bottom" )
	{
		self animscripted( self.spawn_point.origin, self.spawn_point.angles, "zm_spawn_elevator_from_floor" );
	}
	else
	{
		self animscripted( self.spawn_point.origin, self.spawn_point.angles, "zm_spawn_elevator_from_ceiling" );
	}
	self maps/mp/animscripts/zm_shared::donotetracks( "spawn_anim" );
	self.deathfunction = maps/mp/zombies/_zm_spawner::zombie_death_animscript;
	self.in_the_ceiling = 0;
}

leaper_round_start_audio() //checked matches cerberus output
{
	wait 2.5;
	players = get_players();
	num = randomintrange( 0, players.size );
	players[ num ] maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "leaper_round" );
	array_thread( players, ::wait_for_player_to_see_leaper );
	array_thread( players, ::wait_for_leaper_attack );
}

wait_for_player_to_see_leaper() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	level endon( "leaper_round_ending" );
	while ( 1 )
	{
		leapers = getaiarray( level.zombie_team );
		foreach ( leaper in leapers )
		{
			player_vec = vectornormalize( anglesToForward( self.angles ) );
			player_leaper = vectornormalize( leaper.origin - self.origin );
			dot = vectordot( player_vec, player_leaper );
			if ( dot > 0.707 )
			{
				if ( sighttracepassed( self.origin + vectorScale( ( 0, 0, 1 ), 40 ), leaper.origin + vectorScale( ( 0, 0, 1 ), 10 ), 0, self ) )
				{
					self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "leaper_seen" );
					return;
				}
			}
		}
		wait 0.25;
	}
}

wait_for_leaper_attack() //checked matches cerberus output used is_true instead
{
	self endon( "disconnect" );
	level endon( "leaper_round_ending" );
	while ( 1 )
	{
		self waittill( "melee_swipe", enemy );
		if ( is_true( enemy.is_leaper ) )
		{
			self thread do_player_general_vox( "general", "leaper_attack", 10, 5 );
			wait 5;
		}
	}
}

leaper_elevator_failsafe() //imported from cerberus output
{
	self endon("death");
	free_pos = ( 3780, 1750, 1887 );
	while ( 1 )
	{
		if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( "zone_orange_elevator_shaft_bottom" ) )
		{
			if ( self check_traverse_height() )
			{
				wait 3;
				if ( self check_traverse_height() )
				{
					self forceteleport( free_pos );
					wait 3;
				}
			}
		}
		wait 0.2;
	}
}

check_traverse_height() //imported from cerberus output
{
	if ( isdefined( self.traversestartnode ) )
	{
		traverse_height = self.traversestartnode.origin[ 2 ] - self.origin[ 2 ];
		if ( traverse_height > 300 )
		{
			return 1;
		}
	}
	return 0;
}