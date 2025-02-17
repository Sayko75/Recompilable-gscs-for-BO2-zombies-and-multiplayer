// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weapon_utils;
#include maps\mp\killstreaks\_helicopter;
#include maps\mp\killstreaks\_airsupport;

init()
{
    precacherumble( "stinger_lock_rumble" );
    game["locking_on_sound"] = "uin_alert_lockon_start";
    game["locked_on_sound"] = "uin_alert_lockon";
    precachestring( &"MP_CANNOT_LOCKON_TO_TARGET" );
    thread onplayerconnect();
    level.fx_flare = loadfx( "vehicle/vexplosion/fx_heli_chaff" );
/#
    setdvar( "scr_freelock", "0" );
#/
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self clearirtarget();
        thread stingertoggleloop();
        self thread stingerfirednotify();
    }
}

clearirtarget()
{
    self notify( "stinger_irt_cleartarget" );
    self notify( "stop_lockon_sound" );
    self notify( "stop_locked_sound" );
    self.stingerlocksound = undefined;
    self stoprumble( "stinger_lock_rumble" );
    self.stingerlockstarttime = 0;
    self.stingerlockstarted = 0;
    self.stingerlockfinalized = 0;

    if ( isdefined( self.stingertarget ) )
    {
        lockingon( self.stingertarget, 0 );
        lockedon( self.stingertarget, 0 );
    }

    self.stingertarget = undefined;
    self weaponlockfree();
    self weaponlocktargettooclose( 0 );
    self weaponlocknoclearance( 0 );
    self stoplocalsound( game["locking_on_sound"] );
    self stoplocalsound( game["locked_on_sound"] );
    self destroylockoncanceledmessage();
}

stingerfirednotify()
{
    self endon( "disconnect" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "missile_fire", missile, weap );

        if ( maps\mp\gametypes\_weapon_utils::isguidedrocketlauncherweapon( weap ) )
        {
            if ( isdefined( self.stingertarget ) && self.stingerlockfinalized )
                self.stingertarget notify( "stinger_fired_at_me", missile, weap, self );

            level notify( "missile_fired", self, missile, self.stingertarget, self.stingerlockfinalized );
            self notify( "stinger_fired", missile, weap );
        }
    }
}

stingertoggleloop()
{
    self endon( "disconnect" );
    self endon( "death" );

    for (;;)
    {
        self waittill( "weapon_change", weapon );

        while ( maps\mp\gametypes\_weapon_utils::isguidedrocketlauncherweapon( weapon ) )
        {
            abort = 0;

            while ( !self playerstingerads() )
            {
                wait 0.05;

                if ( !maps\mp\gametypes\_weapon_utils::isguidedrocketlauncherweapon( self getcurrentweapon() ) )
                {
                    abort = 1;
                    break;
                }
            }

            if ( abort )
                break;

            self thread stingerirtloop();

            while ( self playerstingerads() )
                wait 0.05;

            self notify( "stinger_IRT_off" );
            self clearirtarget();
            weapon = self getcurrentweapon();
        }
    }
}

stingerirtloop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "stinger_IRT_off" );
    locklength = self getlockonspeed();

    for (;;)
    {
        wait 0.05;

        if ( self.stingerlockfinalized )
        {
            passed = softsighttest();

            if ( !passed )
                continue;

            if ( !isstillvalidtarget( self.stingertarget ) )
            {
                self clearirtarget();
                continue;
            }

            if ( !self.stingertarget.locked_on )
                self.stingertarget notify( "missile_lock", self );

            lockingon( self.stingertarget, 0 );
            lockedon( self.stingertarget, 1 );
            thread looplocallocksound( game["locked_on_sound"], 0.75 );
            continue;
        }

        if ( self.stingerlockstarted )
        {
            if ( !isstillvalidtarget( self.stingertarget ) )
            {
                self clearirtarget();
                continue;
            }

            lockingon( self.stingertarget, 1 );
            lockedon( self.stingertarget, 0 );
            passed = softsighttest();

            if ( !passed )
                continue;

            timepassed = gettime() - self.stingerlockstarttime;

            if ( timepassed < locklength )
                continue;
/#
            assert( isdefined( self.stingertarget ) );
#/
            self notify( "stop_lockon_sound" );
            self.stingerlockfinalized = 1;
            self weaponlockfinalize( self.stingertarget );
            continue;
        }

        besttarget = self getbeststingertarget();

        if ( !isdefined( besttarget ) )
        {
            self destroylockoncanceledmessage();
            continue;
        }

        if ( !self locksighttest( besttarget ) )
        {
            self destroylockoncanceledmessage();
            continue;
        }

        if ( self locksighttest( besttarget ) && isdefined( besttarget.lockondelay ) && besttarget.lockondelay )
        {
            self displaylockoncanceledmessage();
            continue;
        }

        self destroylockoncanceledmessage();
        initlockfield( besttarget );
        self.stingertarget = besttarget;
        self.stingerlockstarttime = gettime();
        self.stingerlockstarted = 1;
        self.stingerlostsightlinetime = 0;
        self thread looplocalseeksound( game["locking_on_sound"], 0.6 );
    }
}

destroylockoncanceledmessage()
{
    if ( isdefined( self.lockoncanceledmessage ) )
        self.lockoncanceledmessage destroy();
}

displaylockoncanceledmessage()
{
    if ( isdefined( self.lockoncanceledmessage ) )
        return;

    self.lockoncanceledmessage = newclienthudelem( self );
    self.lockoncanceledmessage.fontscale = 1.25;
    self.lockoncanceledmessage.x = 0;
    self.lockoncanceledmessage.y = 50;
    self.lockoncanceledmessage.alignx = "center";
    self.lockoncanceledmessage.aligny = "top";
    self.lockoncanceledmessage.horzalign = "center";
    self.lockoncanceledmessage.vertalign = "top";
    self.lockoncanceledmessage.foreground = 1;
    self.lockoncanceledmessage.hidewhendead = 0;
    self.lockoncanceledmessage.hidewheninmenu = 1;
    self.lockoncanceledmessage.archived = 0;
    self.lockoncanceledmessage.alpha = 1.0;
    self.lockoncanceledmessage settext( &"MP_CANNOT_LOCKON_TO_TARGET" );
}

getbeststingertarget()
{
    targetsall = target_getarray();
    targetsvalid = [];

    for ( idx = 0; idx < targetsall.size; idx++ )
    {
/#
        if ( getdvar( "scr_freelock" ) == "1" )
        {
            if ( self insidestingerreticlenolock( targetsall[idx] ) )
                targetsvalid[targetsvalid.size] = targetsall[idx];

            continue;
        }
#/
        if ( level.teambased )
        {
            if ( isdefined( targetsall[idx].team ) && targetsall[idx].team != self.team )
            {
                if ( self insidestingerreticlenolock( targetsall[idx] ) )
                    targetsvalid[targetsvalid.size] = targetsall[idx];
            }

            continue;
        }

        if ( self insidestingerreticlenolock( targetsall[idx] ) )
        {
            if ( isdefined( targetsall[idx].owner ) && self != targetsall[idx].owner )
                targetsvalid[targetsvalid.size] = targetsall[idx];
        }
    }

    if ( targetsvalid.size == 0 )
        return undefined;

    chosenent = targetsvalid[0];

    if ( targetsvalid.size > 1 )
    {

    }

    return chosenent;
}

insidestingerreticlenolock( target )
{
    radius = self getlockonradius();
    return target_isincircle( target, self, 65, radius );
}

insidestingerreticlelocked( target )
{
    radius = self getlockonradius();
    return target_isincircle( target, self, 65, radius );
}

isstillvalidtarget( ent )
{
    if ( !isdefined( ent ) )
        return false;

    if ( !target_istarget( ent ) )
        return false;

    if ( !insidestingerreticlelocked( ent ) )
        return false;

    return true;
}

playerstingerads()
{
    return self playerads() == 1.0;
}

looplocalseeksound( alias, interval )
{
    self endon( "stop_lockon_sound" );
    self endon( "disconnect" );
    self endon( "death" );

    for (;;)
    {
        self playlocalsound( alias );
        self playrumbleonentity( "stinger_lock_rumble" );
        wait( interval / 2 );
    }
}

looplocallocksound( alias, interval )
{
    self endon( "stop_locked_sound" );
    self endon( "disconnect" );
    self endon( "death" );

    if ( isdefined( self.stingerlocksound ) )
        return;

    self.stingerlocksound = 1;

    for (;;)
    {
        self playlocalsound( alias );
        self playrumbleonentity( "stinger_lock_rumble" );
        wait( interval / 6 );
        self playlocalsound( alias );
        self playrumbleonentity( "stinger_lock_rumble" );
        wait( interval / 6 );
        self playlocalsound( alias );
        self playrumbleonentity( "stinger_lock_rumble" );
        wait( interval / 6 );
        self stoprumble( "stinger_lock_rumble" );
    }

    self.stingerlocksound = undefined;
}

locksighttest( target )
{
    eyepos = self geteye();

    if ( !isdefined( target ) )
        return false;

    passed = bullettracepassed( eyepos, target.origin, 0, target );

    if ( passed )
        return true;

    front = target getpointinbounds( 1, 0, 0 );
    passed = bullettracepassed( eyepos, front, 0, target );

    if ( passed )
        return true;

    back = target getpointinbounds( -1, 0, 0 );
    passed = bullettracepassed( eyepos, back, 0, target );

    if ( passed )
        return true;

    return false;
}

softsighttest()
{
    lost_sight_limit = 500;

    if ( self locksighttest( self.stingertarget ) )
    {
        self.stingerlostsightlinetime = 0;
        return true;
    }

    if ( self.stingerlostsightlinetime == 0 )
        self.stingerlostsightlinetime = gettime();

    timepassed = gettime() - self.stingerlostsightlinetime;

    if ( timepassed >= lost_sight_limit )
    {
        self clearirtarget();
        return false;
    }

    return true;
}

initlockfield( target )
{
    if ( isdefined( target.locking_on ) )
        return;

    target.locking_on = 0;
    target.locked_on = 0;
}

lockingon( target, lock )
{
/#
    assert( isdefined( target.locking_on ) );
#/
    clientnum = self getentitynumber();

    if ( lock )
    {
        target notify( "locking on" );
        target.locking_on |= 1 << clientnum;
        self thread watchclearlockingon( target, clientnum );
    }
    else
    {
        self notify( "locking_on_cleared" );
        target.locking_on &= ~( 1 << clientnum );
    }
}

watchclearlockingon( target, clientnum )
{
    target endon( "death" );
    self endon( "locking_on_cleared" );
    self waittill_any( "death", "disconnect" );
    target.locking_on &= ~( 1 << clientnum );
}

lockedon( target, lock )
{
/#
    assert( isdefined( target.locked_on ) );
#/
    clientnum = self getentitynumber();

    if ( lock )
    {
        target.locked_on |= 1 << clientnum;
        self thread watchclearlockedon( target, clientnum );
    }
    else
    {
        self notify( "locked_on_cleared" );
        target.locked_on &= ~( 1 << clientnum );
    }
}

watchclearlockedon( target, clientnum )
{
    self endon( "locked_on_cleared" );
    self waittill_any( "death", "disconnect" );

    if ( isdefined( target ) )
        target.locked_on &= ~( 1 << clientnum );
}

missiletarget_lockonmonitor( player, endon1, endon2 )
{
    self endon( "death" );

    if ( isdefined( endon1 ) )
        self endon( endon1 );

    if ( isdefined( endon2 ) )
        self endon( endon2 );

    for (;;)
    {
        if ( target_istarget( self ) )
        {

        }

        wait 0.1;
    }
}

_incomingmissile( missile )
{
    if ( !isdefined( self.incoming_missile ) )
        self.incoming_missile = 0;

    self.incoming_missile++;
    self thread _incomingmissiletracker( missile );
}

_incomingmissiletracker( missile )
{
    self endon( "death" );

    missile waittill( "death" );

    self.incoming_missile--;
/#
    assert( self.incoming_missile >= 0 );
#/
}

missiletarget_ismissileincoming()
{
    if ( !isdefined( self.incoming_missile ) )
        return false;

    if ( self.incoming_missile )
        return true;

    return false;
}

missiletarget_handleincomingmissile( responsefunc, endon1, endon2 )
{
    level endon( "game_ended" );
    self endon( "death" );

    if ( isdefined( endon1 ) )
        self endon( endon1 );

    if ( isdefined( endon2 ) )
        self endon( endon2 );

    for (;;)
    {
        self waittill( "stinger_fired_at_me", missile, weap, attacker );

        _incomingmissile( missile );

        if ( isdefined( responsefunc ) )
            [[ responsefunc ]]( missile, attacker, weap, endon1, endon2 );
    }
}

missiletarget_proximitydetonateincomingmissile( endon1, endon2 )
{
    missiletarget_handleincomingmissile( ::missiletarget_proximitydetonate, endon1, endon2 );
}

_missiledetonate( attacker, weapon )
{
    self endon( "death" );
    radiusdamage( self.origin, 500, 600, 600, attacker, undefined, weapon );
    wait 0.05;
    self detonate();
    wait 0.05;
    self delete();
}

missiletarget_proximitydetonate( missile, attacker, weapon, endon1, endon2 )
{
    level endon( "game_ended" );
    missile endon( "death" );

    if ( isdefined( endon1 ) )
        self endon( endon1 );

    if ( isdefined( endon2 ) )
        self endon( endon2 );

    mindist = distance( missile.origin, self.origin );
    lastcenter = self.origin;
    missile missile_settarget( self );

    for (;;)
    {
        if ( !isdefined( self ) )
            center = lastcenter;
        else
            center = self.origin;

        lastcenter = center;
        curdist = distance( missile.origin, center );

        if ( curdist < 3500 && isdefined( self.numflares ) && self.numflares > 0 )
        {
            self.numflares--;
            self thread missiletarget_playflarefx();
            self maps\mp\killstreaks\_helicopter::trackassists( attacker, 0, 1 );
            newtarget = self missiletarget_deployflares( missile.origin, missile.angles );
            missile missile_settarget( newtarget );
            missiletarget = newtarget;
            return;
        }

        if ( curdist < mindist )
            mindist = curdist;

        if ( curdist > mindist )
        {
            if ( curdist > 500 )
                return;

            missile thread _missiledetonate( attacker, weapon );
        }

        wait 0.05;
    }
}

missiletarget_playflarefx()
{
    if ( !isdefined( self ) )
        return;

    flare_fx = level.fx_flare;

    if ( isdefined( self.fx_flare ) )
        flare_fx = self.fx_flare;

    if ( isdefined( self.flare_ent ) )
        playfxontag( flare_fx, self.flare_ent, "tag_origin" );
    else
        playfxontag( flare_fx, self, "tag_origin" );

    if ( isdefined( self.owner ) )
        self playsoundtoplayer( "veh_huey_chaff_drop_plr", self.owner );

    self playsound( "veh_huey_chaff_explo_npc" );
}

missiletarget_deployflares( origin, angles )
{
    vec_toforward = anglestoforward( self.angles );
    vec_toright = anglestoright( self.angles );
    vec_tomissileforward = anglestoforward( angles );
    delta = self.origin - origin;
    dot = vectordot( vec_tomissileforward, vec_toright );
    sign = 1;

    if ( dot > 0 )
        sign = -1;

    flare_dir = vectornormalize( vectorscale( vec_toforward, -0.5 ) + vectorscale( vec_toright, sign ) );
    velocity = vectorscale( flare_dir, randomintrange( 200, 400 ) );
    velocity = ( velocity[0], velocity[1], velocity[2] - randomintrange( 10, 100 ) );
    flareorigin = self.origin;
    flareorigin += vectorscale( flare_dir, randomintrange( 500, 700 ) );
    flareorigin += vectorscale( ( 0, 0, 1 ), 500.0 );

    if ( isdefined( self.flareoffset ) )
        flareorigin += self.flareoffset;

    flareobject = spawn( "script_origin", flareorigin );
    flareobject.angles = self.angles;
    flareobject setmodel( "tag_origin" );
    flareobject movegravity( velocity, 5.0 );
    flareobject thread deleteaftertime( 5.0 );
    self thread debug_tracker( flareobject );
    return flareobject;
}

debug_tracker( target )
{
    target endon( "death" );

    while ( true )
    {
        maps\mp\killstreaks\_airsupport::debug_sphere( target.origin, 10, ( 1, 0, 0 ), 1, 1 );
        wait 0.05;
    }
}
