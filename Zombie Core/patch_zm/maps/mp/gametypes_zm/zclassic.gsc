#include maps/mp/zombies/_zm_stats;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_stats;

main()
{
	maps/mp/gametypes_zm/_zm_gametype::main();
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level._game_module_custom_spawn_init_func = ::custom_spawn_init_func;
	level._game_module_stat_update_func = ::survival_classic_custom_stat_update;
	maps/mp/gametypes_zm/_zm_gametype::post_gametype_main( "zclassic" );
}

onprecachegametype()
{
	level.playersuicideallowed = 1;
	level.canplayersuicide = ::canplayersuicide;
	level.suicide_weapon = "death_self_zm";
	precacheitem( "death_self_zm" );
	maps/mp/gametypes_zm/_zm_gametype::rungametypeprecache( "zclassic" );
}

onstartgametype()
{
	maps/mp/gametypes_zm/_zm_gametype::rungametypemain( "zclassic", ::zclassic_main );
}