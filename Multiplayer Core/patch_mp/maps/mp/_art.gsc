// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
/#
    if ( getdvar( "scr_art_tweak" ) == "" || getdvar( "scr_art_tweak" ) == "0" )
        setdvar( "scr_art_tweak", 0 );

    if ( getdvar( "scr_dof_enable" ) == "" )
        setdvar( "scr_dof_enable", "1" );

    if ( getdvar( "scr_cinematic_autofocus" ) == "" )
        setdvar( "scr_cinematic_autofocus", "1" );

    if ( getdvar( "scr_art_visionfile" ) == "" && isdefined( level.script ) )
        setdvar( "scr_art_visionfile", level.script );

    if ( getdvar( "debug_reflection" ) == "" )
        setdvar( "debug_reflection", "0" );

    if ( getdvar( "debug_reflection_matte" ) == "" )
        setdvar( "debug_reflection_matte", "0" );

    if ( getdvar( "debug_color_pallete" ) == "" )
        setdvar( "debug_color_pallete", "0" );

    precachemodel( "test_sphere_lambert" );
    precachemodel( "test_macbeth_chart" );
    precachemodel( "test_macbeth_chart_unlit" );
    precachemodel( "test_sphere_silver" );
    level thread debug_reflection();
    level thread debug_reflection_matte();
    level thread debug_color_pallete();
#/
    if ( !isdefined( level.dofdefault ) )
    {
        level.dofdefault["nearStart"] = 0;
        level.dofdefault["nearEnd"] = 1;
        level.dofdefault["farStart"] = 8000;
        level.dofdefault["farEnd"] = 10000;
        level.dofdefault["nearBlur"] = 6;
        level.dofdefault["farBlur"] = 0;
    }

    level.curdof = ( level.dofdefault["farStart"] - level.dofdefault["nearEnd"] ) / 2;
/#
    thread tweakart();
#/
    if ( !isdefined( level.script ) )
        level.script = tolower( getdvar( "mapname" ) );
}

artfxprintln( file, string )
{
/#
    if ( file == -1 )
        return;

    fprintln( file, string );
#/
}

strtok_loc( string, par1 )
{
    stringlist = [];
    indexstring = "";

    for ( i = 0; i < string.size; i++ )
    {
        if ( string[i] == " " )
        {
            stringlist[stringlist.size] = indexstring;
            indexstring = "";
            continue;
        }

        indexstring += string[i];
    }

    if ( indexstring.size )
        stringlist[stringlist.size] = indexstring;

    return stringlist;
}

setfogsliders()
{
    fogall = strtok_loc( getdvar( "g_fogColorReadOnly" ), " " );
    red = fogall[0];
    green = fogall[1];
    blue = fogall[2];
    halfplane = getdvar( "g_fogHalfDistReadOnly" );
    nearplane = getdvar( "g_fogStartDistReadOnly" );

    if ( !isdefined( red ) || !isdefined( green ) || !isdefined( blue ) || !isdefined( halfplane ) )
    {
        red = 1;
        green = 1;
        blue = 1;
        halfplane = 10000001;
        nearplane = 10000000;
    }

    setdvar( "scr_fog_exp_halfplane", halfplane );
    setdvar( "scr_fog_nearplane", nearplane );
    setdvar( "scr_fog_color", red + " " + green + " " + blue );
}

tweakart()
{
/#
    if ( !isdefined( level.tweakfile ) )
        level.tweakfile = 0;

    if ( getdvar( "scr_fog_baseheight" ) == "" )
    {
        setdvar( "scr_fog_exp_halfplane", "500" );
        setdvar( "scr_fog_exp_halfheight", "500" );
        setdvar( "scr_fog_nearplane", "0" );
        setdvar( "scr_fog_baseheight", "0" );
    }

    setdvar( "scr_fog_fraction", "1.0" );
    setdvar( "scr_art_dump", "0" );
    setdvar( "scr_art_sun_fog_dir_set", "0" );
    setdvar( "scr_dof_nearStart", level.dofdefault["nearStart"] );
    setdvar( "scr_dof_nearEnd", level.dofdefault["nearEnd"] );
    setdvar( "scr_dof_farStart", level.dofdefault["farStart"] );
    setdvar( "scr_dof_farEnd", level.dofdefault["farEnd"] );
    setdvar( "scr_dof_nearBlur", level.dofdefault["nearBlur"] );
    setdvar( "scr_dof_farBlur", level.dofdefault["farBlur"] );
    file = undefined;
    filename = undefined;
    tweak_toggle = 1;

    for (;;)
    {
        while ( getdvarint( "scr_art_tweak" ) == 0 )
        {
            tweak_toggle = 1;
            wait 0.05;
        }

        if ( tweak_toggle )
        {
            tweak_toggle = 0;
            fogsettings = getfogsettings();
            setdvar( "scr_fog_nearplane", fogsettings[0] );
            setdvar( "scr_fog_exp_halfplane", fogsettings[1] );
            setdvar( "scr_fog_exp_halfheight", fogsettings[3] );
            setdvar( "scr_fog_baseheight", fogsettings[2] );
            setdvar( "scr_fog_color", fogsettings[4] + " " + fogsettings[5] + " " + fogsettings[6] );
            setdvar( "scr_fog_color_scale", fogsettings[7] );
            setdvar( "scr_sun_fog_color", fogsettings[8] + " " + fogsettings[9] + " " + fogsettings[10] );
            level.fogsundir = [];
            level.fogsundir[0] = fogsettings[11];
            level.fogsundir[1] = fogsettings[12];
            level.fogsundir[2] = fogsettings[13];
            setdvar( "scr_sun_fog_start_angle", fogsettings[14] );
            setdvar( "scr_sun_fog_end_angle", fogsettings[15] );
            setdvar( "scr_fog_max_opacity", fogsettings[16] );
        }

        level.fogexphalfplane = getdvarfloat( "scr_fog_exp_halfplane" );
        level.fogexphalfheight = getdvarfloat( "scr_fog_exp_halfheight" );
        level.fognearplane = getdvarfloat( "scr_fog_nearplane" );
        level.fogbaseheight = getdvarfloat( "scr_fog_baseheight" );
        level.fogcolorred = getdvarcolorred( "scr_fog_color" );
        level.fogcolorgreen = getdvarcolorgreen( "scr_fog_color" );
        level.fogcolorblue = getdvarcolorblue( "scr_fog_color" );
        level.fogcolorscale = getdvarfloat( "scr_fog_color_scale" );
        level.sunfogcolorred = getdvarcolorred( "scr_sun_fog_color" );
        level.sunfogcolorgreen = getdvarcolorgreen( "scr_sun_fog_color" );
        level.sunfogcolorblue = getdvarcolorblue( "scr_sun_fog_color" );
        level.sunstartangle = getdvarfloat( "scr_sun_fog_start_angle" );
        level.sunendangle = getdvarfloat( "scr_sun_fog_end_angle" );
        level.fogmaxopacity = getdvarfloat( "scr_fog_max_opacity" );

        if ( getdvarint( "scr_art_sun_fog_dir_set" ) )
        {
            setdvar( "scr_art_sun_fog_dir_set", "0" );
            println( "Setting sun fog direction to facing of player" );
            players = get_players();
            dir = vectornormalize( anglestoforward( players[0] getplayerangles() ) );
            level.fogsundir = [];
            level.fogsundir[0] = dir[0];
            level.fogsundir[1] = dir[1];
            level.fogsundir[2] = dir[2];
        }

        fovslidercheck();
        dumpsettings();

        if ( !getdvarint( _hash_DBBD8F3B ) )
        {
            if ( !isdefined( level.fogsundir ) )
            {
                level.fogsundir = [];
                level.fogsundir[0] = 1;
                level.fogsundir[1] = 0;
                level.fogsundir[2] = 0;
            }

            setvolfog( level.fognearplane, level.fogexphalfplane, level.fogexphalfheight, level.fogbaseheight, level.fogcolorred, level.fogcolorgreen, level.fogcolorblue, level.fogcolorscale, level.sunfogcolorred, level.sunfogcolorgreen, level.sunfogcolorblue, level.fogsundir[0], level.fogsundir[1], level.fogsundir[2], level.sunstartangle, level.sunendangle, 0, level.fogmaxopacity );
        }
        else
            setexpfog( 100000000, 100000001, 0, 0, 0, 0 );

        wait 0.1;
    }
#/
}

fovslidercheck()
{
    if ( level.dofdefault["nearStart"] >= level.dofdefault["nearEnd"] )
    {
        level.dofdefault["nearStart"] = level.dofdefault["nearEnd"] - 1;
        setdvar( "scr_dof_nearStart", level.dofdefault["nearStart"] );
    }

    if ( level.dofdefault["nearEnd"] <= level.dofdefault["nearStart"] )
    {
        level.dofdefault["nearEnd"] = level.dofdefault["nearStart"] + 1;
        setdvar( "scr_dof_nearEnd", level.dofdefault["nearEnd"] );
    }

    if ( level.dofdefault["farStart"] >= level.dofdefault["farEnd"] )
    {
        level.dofdefault["farStart"] = level.dofdefault["farEnd"] - 1;
        setdvar( "scr_dof_farStart", level.dofdefault["farStart"] );
    }

    if ( level.dofdefault["farEnd"] <= level.dofdefault["farStart"] )
    {
        level.dofdefault["farEnd"] = level.dofdefault["farStart"] + 1;
        setdvar( "scr_dof_farEnd", level.dofdefault["farEnd"] );
    }

    if ( level.dofdefault["farBlur"] >= level.dofdefault["nearBlur"] )
    {
        level.dofdefault["farBlur"] = level.dofdefault["nearBlur"] - 0.1;
        setdvar( "scr_dof_farBlur", level.dofdefault["farBlur"] );
    }

    if ( level.dofdefault["farStart"] <= level.dofdefault["nearEnd"] )
    {
        level.dofdefault["farStart"] = level.dofdefault["nearEnd"] + 1;
        setdvar( "scr_dof_farStart", level.dofdefault["farStart"] );
    }
}

dumpsettings()
{
/#
    if ( getdvar( "scr_art_dump" ) != "0" )
    {
        println( "\tstart_dist = " + level.fognearplane + ";" );
        println( "\thalf_dist = " + level.fogexphalfplane + ";" );
        println( "\thalf_height = " + level.fogexphalfheight + ";" );
        println( "\tbase_height = " + level.fogbaseheight + ";" );
        println( "\tfog_r = " + level.fogcolorred + ";" );
        println( "\tfog_g = " + level.fogcolorgreen + ";" );
        println( "\tfog_b = " + level.fogcolorblue + ";" );
        println( "\tfog_scale = " + level.fogcolorscale + ";" );
        println( "\tsun_col_r = " + level.sunfogcolorred + ";" );
        println( "\tsun_col_g = " + level.sunfogcolorgreen + ";" );
        println( "\tsun_col_b = " + level.sunfogcolorblue + ";" );
        println( "\tsun_dir_x = " + level.fogsundir[0] + ";" );
        println( "\tsun_dir_y = " + level.fogsundir[1] + ";" );
        println( "\tsun_dir_z = " + level.fogsundir[2] + ";" );
        println( "\tsun_start_ang = " + level.sunstartangle + ";" );
        println( "\tsun_stop_ang = " + level.sunendangle + ";" );
        println( "\ttime = 0;" );
        println( "\tmax_fog_opacity = " + level.fogmaxopacity + ";" );
        println( "" );
        println( "\tsetVolFog(start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale," );
        println( "\t\tsun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, " );
        println( "\t\tsun_stop_ang, time, max_fog_opacity);" );
        setdvar( "scr_art_dump", "0" );
    }
#/
}

debug_reflection()
{
/#
    for ( level.debug_reflection = 0; 1; level.debug_reflection = 0 )
    {
        wait 0.1;
        asm_cond( getdvar( "debug_reflection" ) == "2" && level.debug_reflection != 2 || getdvar( "debug_reflection" ) == "3" && level.debug_reflection != 3, loc_1498 );
        remove_reflection_objects();
        asm_cond( getdvar( "debug_reflection" ) == "2", loc_147C );
        create_reflection_objects();
        level.debug_reflection = 2;
        asm_jump( loc_1495 );
        create_reflection_objects();
        create_reflection_object();
        level.debug_reflection = 3;
        asm_jump( loc_1517 );
        asm_cond( getdvar( "debug_reflection" ) == "1" && level.debug_reflection != 1, loc_14EC );
        setdvar( "debug_reflection_matte", "0" );
        setdvar( "debug_color_pallete", "0" );
        remove_reflection_objects();
        create_reflection_object();
        level.debug_reflection = 1;
        asm_jump( loc_1517 );
        asm_cond( getdvar( "debug_reflection" ) == "0" && level.debug_reflection != 0, loc_1517 );
        remove_reflection_objects();
    }
#/
}

remove_reflection_objects()
{
/#
    if ( ( level.debug_reflection == 2 || level.debug_reflection == 3 ) && isdefined( level.debug_reflection_objects ) )
    {
        for ( i = 0; i < level.debug_reflection_objects.size; i++ )
            level.debug_reflection_objects[i] delete();

        level.debug_reflection_objects = undefined;
    }

    if ( level.debug_reflection == 1 || level.debug_reflection == 3 || level.debug_reflection_matte == 1 || level.debug_color_pallete == 1 || level.debug_color_pallete == 2 )
    {
        if ( isdefined( level.debug_reflectionobject ) )
            level.debug_reflectionobject delete();
    }
#/
}

create_reflection_objects()
{
/#
    reflection_locs = getreflectionlocs();

    for ( i = 0; i < reflection_locs.size; i++ )
    {
        level.debug_reflection_objects[i] = spawn( "script_model", reflection_locs[i] );
        level.debug_reflection_objects[i] setmodel( "test_sphere_silver" );
    }
#/
}

create_reflection_object( model )
{
    if ( !isdefined( model ) )
        model = "test_sphere_silver";
/#
    if ( isdefined( level.debug_reflectionobject ) )
        level.debug_reflectionobject delete();

    players = get_players();
    player = players[0];
    level.debug_reflectionobject = spawn( "script_model", player geteye() + vectorscale( anglestoforward( player.angles ), 100 ) );
    level.debug_reflectionobject setmodel( model );
    level.debug_reflectionobject.origin = player geteye() + vectorscale( anglestoforward( player getplayerangles() ), 100 );
    level.debug_reflectionobject linkto( player );
    thread debug_reflection_buttons();
#/
}

debug_reflection_buttons()
{
/#
    level notify( "new_reflection_button_running" );
    level endon( "new_reflection_button_running" );
    level.debug_reflectionobject endon( "death" );
    offset = 100;
    lastoffset = offset;

    while ( getdvar( "debug_reflection" ) == "1" || getdvar( "debug_reflection" ) == "3" || getdvar( "debug_reflection_matte" ) == "1" || getdvar( "debug_color_pallete" ) == "1" || getdvar( "debug_color_pallete" ) == "2" )
    {
        players = get_players();

        if ( players[0] buttonpressed( "BUTTON_X" ) )
            offset += 50;

        if ( players[0] buttonpressed( "BUTTON_Y" ) )
            offset -= 50;

        if ( offset > 1000 )
            offset = 1000;

        if ( offset < 64 )
            offset = 64;

        level.debug_reflectionobject unlink();
        level.debug_reflectionobject.origin = players[0] geteye() + vectorscale( anglestoforward( players[0] getplayerangles() ), offset );
        temp_angles = vectortoangles( players[0].origin - level.debug_reflectionobject.origin );
        level.debug_reflectionobject.angles = ( 0, temp_angles[1], 0 );
        lastoffset = offset;
        line( level.debug_reflectionobject.origin, getreflectionorigin( level.debug_reflectionobject.origin ), ( 1, 0, 0 ), 1, 1 );
        wait 0.05;

        if ( isdefined( level.debug_reflectionobject ) )
            level.debug_reflectionobject linkto( players[0] );
    }
#/
}

debug_reflection_matte()
{
/#
    for ( level.debug_reflection_matte = 0; 1; level.debug_reflection_matte = 0 )
    {
        wait 0.1;
        asm_cond( getdvar( "debug_reflection_matte" ) == "1" && level.debug_reflection_matte != 1, loc_18DC );
        setdvar( "debug_reflection", "0" );
        setdvar( "debug_color_pallete", "0" );
        remove_reflection_objects();
        create_reflection_object( "test_sphere_lambert" );
        level.debug_reflection_matte = 1;
        asm_jump( loc_1907 );
        asm_cond( getdvar( "debug_reflection_matte" ) == "0" && level.debug_reflection_matte != 0, loc_1907 );
        remove_reflection_objects();
    }
#/
}

debug_color_pallete()
{
/#
    for ( level.debug_color_pallete = 0; 1; level.debug_color_pallete = 0 )
    {
        wait 0.1;
        asm_cond( getdvar( "debug_color_pallete" ) == "1" && level.debug_color_pallete != 1, loc_1980 );
        setdvar( "debug_reflection", "0" );
        setdvar( "debug_reflection_matte", "0" );
        remove_reflection_objects();
        create_reflection_object( "test_macbeth_chart" );
        level.debug_color_pallete = 1;
        asm_jump( loc_19E7 );
        asm_cond( getdvar( "debug_color_pallete" ) == "2" && level.debug_color_pallete != 2, loc_19BC );
        remove_reflection_objects();
        create_reflection_object( "test_macbeth_chart_unlit" );
        level.debug_color_pallete = 2;
        asm_jump( loc_19E7 );
        asm_cond( getdvar( "debug_color_pallete" ) == "0" && level.debug_color_pallete != 0, loc_19E7 );
        remove_reflection_objects();
    }
#/
}
