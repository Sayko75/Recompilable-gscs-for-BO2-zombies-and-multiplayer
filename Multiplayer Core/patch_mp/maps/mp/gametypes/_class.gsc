// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.classmap["class_smg"] = "CLASS_SMG";
    level.classmap["class_cqb"] = "CLASS_CQB";
    level.classmap["class_assault"] = "CLASS_ASSAULT";
    level.classmap["class_lmg"] = "CLASS_LMG";
    level.classmap["class_sniper"] = "CLASS_SNIPER";
    level.classmap["custom0"] = "CLASS_CUSTOM1";
    level.classmap["custom1"] = "CLASS_CUSTOM2";
    level.classmap["custom2"] = "CLASS_CUSTOM3";
    level.classmap["custom3"] = "CLASS_CUSTOM4";
    level.classmap["custom4"] = "CLASS_CUSTOM5";
    level.classmap["custom5"] = "CLASS_CUSTOM6";
    level.classmap["custom6"] = "CLASS_CUSTOM7";
    level.classmap["custom7"] = "CLASS_CUSTOM8";
    level.classmap["custom8"] = "CLASS_CUSTOM9";
    level.classmap["custom9"] = "CLASS_CUSTOM10";
    level.maxkillstreaks = 4;
    level.maxspecialties = 6;
    level.maxbonuscards = 3;
    level.maxallocation = getgametypesetting( "maxAllocation" );
    level.loadoutkillstreaksenabled = getgametypesetting( "loadoutKillstreaksEnabled" );
    level.prestigenumber = 5;
    level.defaultclass = "CLASS_ASSAULT";

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "weapon", "allowfrag" ) )
        level.weapons["frag"] = "frag_grenade_mp";
    else
        level.weapons["frag"] = "";

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "weapon", "allowsmoke" ) )
        level.weapons["smoke"] = "smoke_grenade_mp";
    else
        level.weapons["smoke"] = "";

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "weapon", "allowflash" ) )
        level.weapons["flash"] = "flash_grenade_mp";
    else
        level.weapons["flash"] = "";

    level.weapons["concussion"] = "concussion_grenade_mp";

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "weapon", "allowsatchel" ) )
        level.weapons["satchel_charge"] = "satchel_charge_mp";
    else
        level.weapons["satchel_charge"] = "";

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "weapon", "allowbetty" ) )
        level.weapons["betty"] = "mine_bouncing_betty_mp";
    else
        level.weapons["betty"] = "";

    if ( maps\mp\gametypes\_tweakables::gettweakablevalue( "weapon", "allowrpgs" ) )
        level.weapons["rpg"] = "rpg_mp";
    else
        level.weapons["rpg"] = "";

    create_class_exclusion_list();
    cac_init();
    load_default_loadout( "CLASS_SMG", 10 );
    load_default_loadout( "CLASS_CQB", 11 );
    load_default_loadout( "CLASS_ASSAULT", 12 );
    load_default_loadout( "CLASS_LMG", 13 );
    load_default_loadout( "CLASS_SNIPER", 14 );
    level.primary_weapon_array = [];
    level.side_arm_array = [];
    level.grenade_array = [];
    level.inventory_array = [];
    max_weapon_num = 99;

    for ( i = 0; i < max_weapon_num; i++ )
    {
        if ( !isdefined( level.tbl_weaponids[i] ) || level.tbl_weaponids[i]["group"] == "" )
            continue;

        if ( !isdefined( level.tbl_weaponids[i] ) || level.tbl_weaponids[i]["reference"] == "" )
            continue;

        weapon_type = level.tbl_weaponids[i]["group"];
        weapon = level.tbl_weaponids[i]["reference"];
        attachment = level.tbl_weaponids[i]["attachment"];
        weapon_class_register( weapon + "_mp", weapon_type );

        if ( isdefined( attachment ) && attachment != "" )
        {
            attachment_tokens = strtok( attachment, " " );

            if ( isdefined( attachment_tokens ) )
            {
                if ( attachment_tokens.size == 0 )
                {
                    weapon_class_register( weapon + "_" + attachment + "_mp", weapon_type );
                    continue;
                }

                for ( k = 0; k < attachment_tokens.size; k++ )
                    weapon_class_register( weapon + "_" + attachment_tokens[k] + "_mp", weapon_type );
            }
        }
    }

    precacheshader( "waypoint_second_chance" );
    level thread onplayerconnecting();
}

create_class_exclusion_list()
{
    currentdvar = 0;
    level.itemexclusions = [];

    while ( getdvarint( _hash_32DF55CC + currentdvar ) )
    {
        level.itemexclusions[currentdvar] = getdvarint( _hash_32DF55CC + currentdvar );
        currentdvar++;
    }

    level.attachmentexclusions = [];

    for ( currentdvar = 0; getdvar( _hash_7F6F03E6 + currentdvar ) != ""; currentdvar++ )
        level.attachmentexclusions[currentdvar] = getdvar( _hash_7F6F03E6 + currentdvar );
}

is_item_excluded( itemindex )
{
    if ( !level.onlinegame )
        return false;

    numexclusions = level.itemexclusions.size;

    for ( exclusionindex = 0; exclusionindex < numexclusions; exclusionindex++ )
    {
        if ( itemindex == level.itemexclusions[exclusionindex] )
            return true;
    }

    return false;
}

is_attachment_excluded( attachment )
{
    numexclusions = level.attachmentexclusions.size;

    for ( exclusionindex = 0; exclusionindex < numexclusions; exclusionindex++ )
    {
        if ( attachment == level.attachmentexclusions[exclusionindex] )
            return true;
    }

    return false;
}

set_statstable_id()
{
    if ( !isdefined( level.statstableid ) )
        level.statstableid = tablelookupfindcoreasset( "mp/statsTable.csv" );
}

get_item_count( itemreference )
{
    set_statstable_id();
    itemcount = int( tablelookup( level.statstableid, 4, itemreference, 5 ) );

    if ( itemcount < 1 )
        itemcount = 1;

    return itemcount;
}

getdefaultclassslotwithexclusions( classname, slotname )
{
    itemreference = getdefaultclassslot( classname, slotname );
    set_statstable_id();
    itemindex = int( tablelookup( level.statstableid, 4, itemreference, 0 ) );

    if ( is_item_excluded( itemindex ) )
        itemreference = tablelookup( level.statstableid, 0, 0, 4 );

    return itemreference;
}

load_default_loadout( class, classnum )
{
    level.classtoclassnum[class] = classnum;
}

weapon_class_register( weapon, weapon_type )
{
    if ( issubstr( "weapon_smg weapon_cqb weapon_assault weapon_lmg weapon_sniper weapon_shotgun weapon_launcher weapon_special", weapon_type ) )
        level.primary_weapon_array[weapon] = 1;
    else if ( issubstr( "weapon_pistol", weapon_type ) )
        level.side_arm_array[weapon] = 1;
    else if ( weapon_type == "weapon_grenade" )
        level.grenade_array[weapon] = 1;
    else if ( weapon_type == "weapon_explosive" )
        level.inventory_array[weapon] = 1;
    else if ( weapon_type == "weapon_rifle" )
        level.inventory_array[weapon] = 1;
    else
    {
/#
        assert( 0, "Weapon group info is missing from statsTable for: " + weapon_type );
#/
    }
}

cac_init()
{
    level.tbl_weaponids = [];
    set_statstable_id();

    for ( i = 0; i < 256; i++ )
    {
        itemrow = tablelookuprownum( level.statstableid, 0, i );

        if ( itemrow > -1 )
        {
            group_s = tablelookupcolumnforrow( level.statstableid, itemrow, 2 );

            if ( issubstr( group_s, "weapon_" ) )
            {
                reference_s = tablelookupcolumnforrow( level.statstableid, itemrow, 4 );

                if ( reference_s != "" )
                {
                    level.tbl_weaponids[i]["reference"] = reference_s;
                    level.tbl_weaponids[i]["group"] = group_s;
                    level.tbl_weaponids[i]["count"] = int( tablelookupcolumnforrow( level.statstableid, itemrow, 5 ) );
                    level.tbl_weaponids[i]["attachment"] = tablelookupcolumnforrow( level.statstableid, itemrow, 8 );
                }
            }
        }
    }

    level.perknames = [];

    for ( i = 0; i < 256; i++ )
    {
        itemrow = tablelookuprownum( level.statstableid, 0, i );

        if ( itemrow > -1 )
        {
            group_s = tablelookupcolumnforrow( level.statstableid, itemrow, 2 );

            if ( group_s == "specialty" )
            {
                reference_s = tablelookupcolumnforrow( level.statstableid, itemrow, 4 );

                if ( reference_s != "" )
                {
                    perkicon = tablelookupcolumnforrow( level.statstableid, itemrow, 6 );
                    perkname = tablelookupistring( level.statstableid, 0, i, 3 );
                    precachestring( perkname );
                    precacheshader( perkicon );
                    level.perknames[perkicon] = perkname;
                }
            }
        }
    }

    level.killstreaknames = [];
    level.killstreakicons = [];
    level.killstreakindices = [];

    for ( i = 0; i < 256; i++ )
    {
        itemrow = tablelookuprownum( level.statstableid, 0, i );

        if ( itemrow > -1 )
        {
            group_s = tablelookupcolumnforrow( level.statstableid, itemrow, 2 );

            if ( group_s == "killstreak" )
            {
                reference_s = tablelookupcolumnforrow( level.statstableid, itemrow, 4 );

                if ( reference_s != "" )
                {
                    level.tbl_killstreakdata[i] = reference_s;
                    level.killstreakindices[reference_s] = i;
                    icon = tablelookupcolumnforrow( level.statstableid, itemrow, 6 );
                    name = tablelookupistring( level.statstableid, 0, i, 3 );
                    precachestring( name );
                    level.killstreaknames[reference_s] = name;
                    level.killstreakicons[reference_s] = icon;
                    level.killstreakindices[reference_s] = i;
                    precacheshader( icon );
                    precacheshader( icon + "_drop" );
                }
            }
        }
    }
}

getclasschoice( response )
{
/#
    assert( isdefined( level.classmap[response] ) );
#/
    return level.classmap[response];
}

getloadoutitemfromddlstats( customclassnum, loadoutslot )
{
    itemindex = self getloadoutitem( customclassnum, loadoutslot );

    if ( is_item_excluded( itemindex ) && !is_warlord_perk( itemindex ) )
        return 0;

    return itemindex;
}

getattachmentstring( weaponnum, attachmentnum )
{
    attachmentstring = getitemattachment( weaponnum, attachmentnum );

    if ( attachmentstring != "none" && !is_attachment_excluded( attachmentstring ) )
        attachmentstring += "_";
    else
        attachmentstring = "";

    return attachmentstring;
}

getattachmentsdisabled()
{
    if ( !isdefined( level.attachmentsdisabled ) )
        return 0;

    return level.attachmentsdisabled;
}

getkillstreakindex( class, killstreaknum )
{
    killstreaknum++;
    killstreakstring = "killstreak" + killstreaknum;

    if ( getdvarint( _hash_826EB3B9 ) == 2 )
        return getdvarint( _hash_E1D3321F + killstreakstring );
    else
        return self getloadoutitem( class, killstreakstring );
}

givekillstreaks( classnum )
{
    self.killstreak = [];

    if ( !level.loadoutkillstreaksenabled )
        return;

    sortedkillstreaks = [];
    currentkillstreak = 0;

    for ( killstreaknum = 0; killstreaknum < level.maxkillstreaks; killstreaknum++ )
    {
        killstreakindex = getkillstreakindex( classnum, killstreaknum );

        if ( isdefined( killstreakindex ) && killstreakindex > 0 )
        {
/#
            assert( isdefined( level.tbl_killstreakdata[killstreakindex] ), "KillStreak #:" + killstreakindex + "'s data is undefined" );
#/

            if ( isdefined( level.tbl_killstreakdata[killstreakindex] ) )
            {
                self.killstreak[currentkillstreak] = level.tbl_killstreakdata[killstreakindex];

                if ( isdefined( level.usingmomentum ) && level.usingmomentum )
                {
                    killstreaktype = maps\mp\killstreaks\_killstreaks::getkillstreakbymenuname( self.killstreak[currentkillstreak] );

                    if ( isdefined( killstreaktype ) )
                    {
                        weapon = maps\mp\killstreaks\_killstreaks::getkillstreakweapon( killstreaktype );
                        self giveweapon( weapon );

                        if ( isdefined( level.usingscorestreaks ) && level.usingscorestreaks )
                        {
                            if ( maps\mp\killstreaks\_killstreak_weapons::isheldkillstreakweapon( weapon ) )
                            {
                                if ( !isdefined( self.pers["held_killstreak_ammo_count"][weapon] ) )
                                    self.pers["held_killstreak_ammo_count"][weapon] = 0;

                                if ( !isdefined( self.pers["held_killstreak_clip_count"][weapon] ) )
                                    self.pers["held_killstreak_clip_count"][weapon] = 0;

                                if ( self.pers["held_killstreak_ammo_count"][weapon] > 0 )
                                {
                                    self setweaponammoclip( weapon, self.pers["held_killstreak_clip_count"][weapon] );
                                    self setweaponammostock( weapon, self.pers["held_killstreak_ammo_count"][weapon] - self.pers["held_killstreak_clip_count"][weapon] );
                                }
                                else
                                    self maps\mp\gametypes\_class::setweaponammooverall( weapon, 0 );
                            }
                            else
                            {
                                quantity = self.pers["killstreak_quantity"][weapon];

                                if ( !isdefined( quantity ) )
                                    quantity = 0;

                                self setweaponammoclip( weapon, quantity );
                            }
                        }

                        sortdata = spawnstruct();
                        sortdata.cost = level.killstreaks[killstreaktype].momentumcost;
                        sortdata.weapon = weapon;
                        sortindex = 0;

                        for ( sortindex = 0; sortindex < sortedkillstreaks.size; sortindex++ )
                        {
                            if ( sortedkillstreaks[sortindex].cost > sortdata.cost )
                                break;
                        }

                        for ( i = sortedkillstreaks.size; i > sortindex; i-- )
                            sortedkillstreaks[i] = sortedkillstreaks[i - 1];

                        sortedkillstreaks[sortindex] = sortdata;
                    }
                }

                currentkillstreak++;
            }
        }
    }

    actionslotorder = [];
    actionslotorder[0] = 4;
    actionslotorder[1] = 2;
    actionslotorder[2] = 1;

    if ( isdefined( level.usingmomentum ) && level.usingmomentum )
    {
        for ( sortindex = 0; sortindex < sortedkillstreaks.size && sortindex < actionslotorder.size; sortindex++ )
            self setactionslot( actionslotorder[sortindex], "weapon", sortedkillstreaks[sortindex].weapon );
    }
}

is_warlord_perk( itemindex )
{
    if ( itemindex == 168 || itemindex == 169 )
        return true;
    else
        return false;
}

isperkgroup( perkname )
{
    return isdefined( perkname ) && isstring( perkname );
}

logclasschoice( class, primaryweapon, specialtype, perks )
{
    if ( class == self.lastclass )
        return;

    self logstring( "choseclass: " + class + " weapon: " + primaryweapon + " special: " + specialtype );

    for ( i = 0; i < perks.size; i++ )
        self logstring( "perk" + i + ": " + perks[i] );

    self.lastclass = class;
}

reset_specialty_slots( class_num )
{
    self.specialty = [];
}

initstaticweaponstime()
{
    self.staticweaponsstarttime = gettime();
}

initweaponattachments( weaponname )
{
    self.currentweaponstarttime = gettime();
    self.currentweapon = weaponname;
}

isequipmentallowed( equipment )
{
    if ( equipment == "camera_spike_mp" && self issplitscreen() )
        return false;

    if ( equipment == level.tacticalinsertionweapon && level.disabletacinsert )
        return false;

    return true;
}

isleagueitemrestricted( item )
{
    if ( level.leaguematch )
        return isitemrestricted( item );

    return 0;
}

giveloadoutlevelspecific( team, class )
{
    pixbeginevent( "giveLoadoutLevelSpecific" );

    if ( isdefined( level.givecustomcharacters ) )
        self [[ level.givecustomcharacters ]]();

    if ( isdefined( level.givecustomloadout ) )
        self [[ level.givecustomloadout ]]();

    pixendevent();
}

removeduplicateattachments( weapon )
{
    if ( !isdefined( weapon ) )
        return undefined;

    attachments = strtok( weapon, "+" );

    for ( attachmentindex = 1; attachmentindex < attachments.size; attachmentindex++ )
    {
        for ( attachmentindex2 = attachmentindex + 1; attachmentindex2 < attachments.size; attachmentindex2++ )
        {
            if ( attachments[attachmentindex] == attachments[attachmentindex2] )
                attachments[attachmentindex2] = "none";
        }
    }

    uniqueattachmentsweapon = attachments[0];

    for ( attachmentindex = 1; attachmentindex < attachments.size; attachmentindex++ )
    {
        if ( attachments[attachmentindex] != "none" )
            uniqueattachmentsweapon = uniqueattachmentsweapon + "+" + attachments[attachmentindex];
    }

    return uniqueattachmentsweapon;
}

giveloadout( team, class )
{
    pixbeginevent( "giveLoadout" );
    self takeallweapons();
    primaryindex = 0;
    self.specialty = [];
    self.killstreak = [];
    primaryweapon = undefined;
    self notify( "give_map" );
    class_num_for_killstreaks = 0;
    primaryweaponoptions = 0;
    secondaryweaponoptions = 0;
    playerrenderoptions = 0;
    primarygrenadecount = 0;
    iscustomclass = 0;

    if ( issubstr( class, "CLASS_CUSTOM" ) )
    {
        pixbeginevent( "custom class" );
        class_num = int( class[class.size - 1] ) - 1;

        if ( -1 == class_num )
            class_num = 9;

        self.class_num = class_num;
        self reset_specialty_slots( class_num );
        playerrenderoptions = self calcplayeroptions( class_num );
        class_num_for_killstreaks = class_num;
        iscustomclass = 1;
        pixendevent();
    }
    else
    {
        pixbeginevent( "default class" );
/#
        assert( isdefined( self.pers["class"] ), "Player during spawn and loadout got no class!" );
#/
        class_num = level.classtoclassnum[class];
        self.class_num = class_num;
        pixendevent();
    }

    knifeweaponoptions = self calcweaponoptions( class_num, 2 );
    self giveweapon( "knife_mp", 0, knifeweaponoptions );
    self.specialty = self getloadoutperks( class_num );

    if ( level.leaguematch )
    {
        for ( i = 0; i < self.specialty.size; i++ )
        {
            if ( isleagueitemrestricted( self.specialty[i] ) )
            {
                arrayremoveindex( self.specialty, i );
                i--;
            }
        }
    }

    self register_perks();
    self setactionslot( 3, "altMode" );
    self setactionslot( 4, "" );
    givekillstreaks( class_num_for_killstreaks );
    spawnweapon = "";
    initialweaponcount = 0;

    if ( isdefined( self.pers["weapon"] ) && self.pers["weapon"] != "none" && !maps\mp\killstreaks\_killstreaks::iskillstreakweapon( self.pers["weapon"] ) )
        weapon = self.pers["weapon"];
    else
    {
        weapon = self getloadoutweapon( class_num, "primary" );
        weapon = removeduplicateattachments( weapon );

        if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( weapon ) )
            weapon = "weapon_null_mp";
    }

    sidearm = self getloadoutweapon( class_num, "secondary" );
    sidearm = removeduplicateattachments( sidearm );

    if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( sidearm ) )
        sidearm = "weapon_null_mp";

    self.primaryweaponkill = 0;
    self.secondaryweaponkill = 0;

    if ( self isbonuscardactive( 2, self.class_num ) )
    {
        self.primaryloadoutweapon = weapon;
        self.primaryloadoutaltweapon = weaponaltweaponname( weapon );
        self.secondaryloadoutweapon = sidearm;
        self.secondaryloadoutaltweapon = weaponaltweaponname( sidearm );
    }
    else
    {
        if ( self isbonuscardactive( 0, self.class_num ) )
            self.primaryloadoutweapon = weapon;

        if ( self isbonuscardactive( 1, self.class_num ) )
            self.secondaryloadoutweapon = sidearm;
    }

    if ( sidearm != "weapon_null_mp" )
        secondaryweaponoptions = self calcweaponoptions( class_num, 1 );

    primaryweapon = weapon;

    if ( primaryweapon != "weapon_null_mp" )
        primaryweaponoptions = self calcweaponoptions( class_num, 0 );

    if ( sidearm != "" && sidearm != "weapon_null_mp" && sidearm != "weapon_null" )
    {
        self giveweapon( sidearm, 0, secondaryweaponoptions );

        if ( self hasperk( "specialty_extraammo" ) )
            self givemaxammo( sidearm );

        spawnweapon = sidearm;
        initialweaponcount++;
    }

    primaryweapon = weapon;
    primarytokens = strtok( primaryweapon, "_" );
    self.pers["primaryWeapon"] = primarytokens[0];
/#
    println( "^5GiveWeapon( " + weapon + " ) -- weapon" );
#/

    if ( primaryweapon != "" && primaryweapon != "weapon_null_mp" && primaryweapon != "weapon_null" )
    {
        if ( self hasperk( "specialty_extraammo" ) )
            self givemaxammo( primaryweapon );

        self giveweapon( primaryweapon, 0, primaryweaponoptions );
        spawnweapon = primaryweapon;
        initialweaponcount++;
    }

    if ( initialweaponcount < 2 )
    {
        self giveweapon( "knife_held_mp", 0, knifeweaponoptions );

        if ( initialweaponcount == 0 )
            spawnweapon = "knife_held_mp";
    }

    if ( !isdefined( self.spawnweapon ) && isdefined( self.pers["spawnWeapon"] ) )
        self.spawnweapon = self.pers["spawnWeapon"];

    if ( isdefined( self.spawnweapon ) && doesweaponreplacespawnweapon( self.spawnweapon, spawnweapon ) && !self.pers["changed_class"] )
        spawnweapon = self.spawnweapon;

    self.pers["changed_class"] = 0;
/#
    assert( spawnweapon != "" );
#/
    self.spawnweapon = spawnweapon;
    self.pers["spawnWeapon"] = self.spawnweapon;
    self setspawnweapon( spawnweapon );
    grenadetypeprimary = self getloadoutitemref( class_num, "primarygrenade" );

    if ( isleagueitemrestricted( grenadetypeprimary ) )
        grenadetypeprimary = "";

    if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( grenadetypeprimary + "_mp" ) )
        grenadetypeprimary = "";

    grenadetypesecondary = self getloadoutitemref( class_num, "specialgrenade" );

    if ( isleagueitemrestricted( grenadetypesecondary ) )
        grenadetypesecondary = "";

    if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( grenadetypesecondary + "_mp" ) )
        grenadetypesecondary = "";

    if ( grenadetypeprimary != "" && grenadetypeprimary != "weapon_null_mp" && isequipmentallowed( grenadetypeprimary ) )
    {
        grenadetypeprimary += "_mp";
        primarygrenadecount = self getloadoutitem( class_num, "primarygrenadecount" );
    }

    if ( grenadetypesecondary != "" && grenadetypesecondary != "weapon_null_mp" && isequipmentallowed( grenadetypesecondary ) )
    {
        grenadetypesecondary += "_mp";
        grenadesecondarycount = self getloadoutitem( class_num, "specialgrenadecount" );
    }

    if ( !( grenadetypeprimary != "" && grenadetypeprimary != "weapon_null_mp" && isequipmentallowed( grenadetypeprimary ) ) )
    {
        if ( grenadetypesecondary != level.weapons["frag"] )
            grenadetypeprimary = level.weapons["frag"];
        else
            grenadetypeprimary = level.weapons["flash"];
    }

/#
    println( "^5GiveWeapon( " + grenadetypeprimary + " ) -- grenadeTypePrimary" );
#/
    self giveweapon( grenadetypeprimary );
    self setweaponammoclip( grenadetypeprimary, primarygrenadecount );
    self switchtooffhand( grenadetypeprimary );
    self.grenadetypeprimary = grenadetypeprimary;
    self.grenadetypeprimarycount = primarygrenadecount;

    if ( self.grenadetypeprimarycount > 1 )
        self dualgrenadesactive();

    if ( grenadetypesecondary != "" && grenadetypesecondary != "weapon_null_mp" && isequipmentallowed( grenadetypesecondary ) )
    {
        self setoffhandsecondaryclass( grenadetypesecondary );
/#
        println( "^5GiveWeapon( " + grenadetypesecondary + " ) -- grenadeTypeSecondary" );
#/
        self giveweapon( grenadetypesecondary );
        self setweaponammoclip( grenadetypesecondary, grenadesecondarycount );
        self.grenadetypesecondary = grenadetypesecondary;
        self.grenadetypesecondarycount = grenadesecondarycount;
    }

    self bbclasschoice( class_num, primaryweapon, sidearm );

    if ( !sessionmodeiszombiesgame() )
    {
        for ( i = 0; i < 3; i++ )
        {
            if ( level.loadoutkillstreaksenabled && isdefined( self.killstreak[i] ) && isdefined( level.killstreakindices[self.killstreak[i]] ) )
            {
                killstreaks[i] = level.killstreakindices[self.killstreak[i]];
                continue;
            }

            killstreaks[i] = 0;
        }

        self recordloadoutperksandkillstreaks( primaryweapon, sidearm, grenadetypeprimary, grenadetypesecondary, killstreaks[0], killstreaks[1], killstreaks[2] );
    }

    self maps\mp\teams\_teams::set_player_model( team, weapon );
    self initstaticweaponstime();
    self thread initweaponattachments( spawnweapon );
    self setplayerrenderoptions( playerrenderoptions );

    if ( isdefined( self.movementspeedmodifier ) )
        self setmovespeedscale( self.movementspeedmodifier * self getmovespeedscale() );

    if ( isdefined( level.givecustomloadout ) )
    {
        spawnweapon = self [[ level.givecustomloadout ]]();

        if ( isdefined( spawnweapon ) )
            self thread initweaponattachments( spawnweapon );
    }

    self cac_selector();

    if ( !isdefined( self.firstspawn ) )
    {
        if ( isdefined( spawnweapon ) )
            self initialweaponraise( spawnweapon );
        else
            self initialweaponraise( weapon );
    }
    else
        self seteverhadweaponall( 1 );

    self.firstspawn = 0;
    pixendevent();
}

setweaponammooverall( weaponname, amount )
{
    if ( isweaponcliponly( weaponname ) )
        self setweaponammoclip( weaponname, amount );
    else
    {
        self setweaponammoclip( weaponname, amount );
        diff = amount - self getweaponammoclip( weaponname );
/#
        assert( diff >= 0 );
#/
        self setweaponammostock( weaponname, diff );
    }
}

onplayerconnecting()
{
    for (;;)
    {
        level waittill( "connecting", player );

        if ( !level.oldschool )
        {
            if ( !isdefined( player.pers["class"] ) )
                player.pers["class"] = "";

            player.class = player.pers["class"];
            player.lastclass = "";
        }

        player.detectexplosives = 0;
        player.bombsquadicons = [];
        player.bombsquadids = [];
        player.reviveicons = [];
        player.reviveids = [];
    }
}

fadeaway( waitdelay, fadedelay )
{
    wait( waitdelay );
    self fadeovertime( fadedelay );
    self.alpha = 0;
}

setclass( newclass )
{
    self.curclass = newclass;
}

initperkdvars()
{
    level.cac_armorpiercing_data = cac_get_dvar_int( "perk_armorpiercing", "40" ) / 100;
    level.cac_bulletdamage_data = cac_get_dvar_int( "perk_bulletDamage", "35" );
    level.cac_fireproof_data = cac_get_dvar_int( "perk_fireproof", "95" );
    level.cac_armorvest_data = cac_get_dvar_int( "perk_armorVest", "80" );
    level.cac_explosivedamage_data = cac_get_dvar_int( "perk_explosiveDamage", "25" );
    level.cac_flakjacket_data = cac_get_dvar_int( "perk_flakJacket", "35" );
    level.cac_flakjacket_hardcore_data = cac_get_dvar_int( "perk_flakJacket_hardcore", "9" );
}

cac_selector()
{
    perks = self.specialty;
    self.detectexplosives = 0;

    for ( i = 0; i < perks.size; i++ )
    {
        perk = perks[i];

        if ( perk == "specialty_detectexplosive" )
            self.detectexplosives = 1;
    }
}

register_perks()
{
    perks = self.specialty;
    self clearperks();

    for ( i = 0; i < perks.size; i++ )
    {
        perk = perks[i];

        if ( perk == "specialty_null" || issubstr( perk, "specialty_weapon_" ) || perk == "weapon_null" )
            continue;

        if ( !level.perksenabled )
            continue;

        self setperk( perk );
    }

/#
    maps\mp\gametypes\_dev::giveextraperks();
#/
}

cac_get_dvar_int( dvar, def )
{
    return int( cac_get_dvar( dvar, def ) );
}

cac_get_dvar( dvar, def )
{
    if ( getdvar( dvar ) != "" )
        return getdvarfloat( dvar );
    else
    {
        setdvar( dvar, def );
        return def;
    }
}

cac_modified_vehicle_damage( victim, attacker, damage, meansofdeath, weapon, inflictor )
{
    if ( !isdefined( victim ) || !isdefined( attacker ) || !isplayer( attacker ) )
        return damage;

    if ( !isdefined( damage ) || !isdefined( meansofdeath ) || !isdefined( weapon ) )
        return damage;

    old_damage = damage;
    final_damage = damage;

    if ( attacker hasperk( "specialty_bulletdamage" ) && isprimarydamage( meansofdeath ) )
    {
        final_damage = damage * ( 100 + level.cac_bulletdamage_data ) / 100;
/#
        if ( getdvarint( _hash_5ABA6445 ) )
            println( "Perk/> " + attacker.name + "'s bullet damage did extra damage to vehicle" );
#/
    }
    else if ( attacker hasperk( "specialty_explosivedamage" ) && isplayerexplosiveweapon( weapon, meansofdeath ) )
    {
        final_damage = damage * ( 100 + level.cac_explosivedamage_data ) / 100;
/#
        if ( getdvarint( _hash_5ABA6445 ) )
            println( "Perk/> " + attacker.name + "'s explosive damage did extra damage to vehicle" );
#/
    }
    else
        final_damage = old_damage;

/#
    if ( getdvarint( _hash_5ABA6445 ) )
        println( "Perk/> Damage Factor: " + final_damage / old_damage + " - Pre Damage: " + old_damage + " - Post Damage: " + final_damage );
#/
    return int( final_damage );
}

cac_modified_damage( victim, attacker, damage, mod, weapon, inflictor, hitloc )
{
/#
    assert( isdefined( victim ) );
#/
/#
    assert( isdefined( attacker ) );
#/
/#
    assert( isplayer( victim ) );
#/

    if ( victim == attacker )
        return damage;

    if ( !isplayer( attacker ) )
        return damage;

    if ( damage <= 0 )
        return damage;

/#
    debug = 0;

    if ( getdvarint( _hash_5ABA6445 ) )
        debug = 1;
#/
    final_damage = damage;

    if ( attacker hasperk( "specialty_bulletdamage" ) && isprimarydamage( mod ) )
    {
        if ( victim hasperk( "specialty_armorvest" ) && !isheaddamage( hitloc ) )
        {
/#
            if ( debug )
                println( "Perk/> " + victim.name + "'s armor countered " + attacker.name + "'s increased bullet damage" );
#/
        }
        else
        {
            final_damage = damage * ( 100 + level.cac_bulletdamage_data ) / 100;
/#
            if ( debug )
                println( "Perk/> " + attacker.name + "'s bullet damage did extra damage to " + victim.name );
#/
        }
    }
    else if ( victim hasperk( "specialty_armorvest" ) && isprimarydamage( mod ) && !isheaddamage( hitloc ) )
    {
        final_damage = damage * ( level.cac_armorvest_data * 0.01 );
/#
        if ( debug )
            println( "Perk/> " + attacker.name + "'s bullet damage did less damage to " + victim.name );
#/
    }
    else if ( victim hasperk( "specialty_fireproof" ) && isfiredamage( weapon, mod ) )
    {
        final_damage = damage * ( 100 - level.cac_fireproof_data ) / 100;
/#
        if ( debug )
            println( "Perk/> " + attacker.name + "'s flames did less damage to " + victim.name );
#/
    }
    else if ( attacker hasperk( "specialty_explosivedamage" ) && isplayerexplosiveweapon( weapon, mod ) )
    {
        final_damage = damage * ( 100 + level.cac_explosivedamage_data ) / 100;
/#
        if ( debug )
            println( "Perk/> " + attacker.name + "'s explosive damage did extra damage to " + victim.name );
#/
    }
    else if ( victim hasperk( "specialty_flakjacket" ) && isexplosivedamage( weapon, mod ) && !victim grenadestuck( inflictor ) )
    {
        cac_data = level.hardcoremode ? level.cac_flakjacket_hardcore_data : level.cac_flakjacket_data;

        if ( level.teambased && attacker.team != victim.team )
            victim thread maps\mp\_challenges::flakjacketprotected( weapon, attacker );
        else if ( attacker != victim )
            victim thread maps\mp\_challenges::flakjacketprotected( weapon, attacker );

        final_damage = int( damage * cac_data / 100 );
/#
        if ( debug )
            println( "Perk/> " + victim.name + "'s flak jacket decreased " + attacker.name + "'s grenade damage" );
#/
    }

/#
    victim.cac_debug_damage_type = tolower( mod );
    victim.cac_debug_original_damage = damage;
    victim.cac_debug_final_damage = final_damage;
    victim.cac_debug_location = tolower( hitloc );
    victim.cac_debug_weapon = tolower( weapon );
    victim.cac_debug_range = int( distance( attacker.origin, victim.origin ) );

    if ( debug )
        println( "Perk/> Damage Factor: " + final_damage / damage + " - Pre Damage: " + damage + " - Post Damage: " + final_damage );
#/
    final_damage = int( final_damage );

    if ( final_damage < 1 )
        final_damage = 1;

    return final_damage;
}

isexplosivedamage( weapon, meansofdeath )
{
    if ( isdefined( weapon ) )
    {
        switch ( weapon )
        {
            case "willy_pete_mp":
            case "tabun_gas_mp":
            case "proximity_grenade_mp":
            case "flash_grenade_mp":
            case "emp_grenade_mp":
            case "concussion_grenade_mp":
            case "briefcase_bomb_mp":
                return false;
        }
    }

    switch ( meansofdeath )
    {
        case "MOD_PROJECTILE_SPLASH":
        case "MOD_GRENADE_SPLASH":
        case "MOD_GRENADE":
        case "MOD_EXPLOSIVE":
            return true;
    }

    return false;
}

hastacticalmask( player )
{
    return player hasperk( "specialty_stunprotection" ) || player hasperk( "specialty_flashprotection" ) || player hasperk( "specialty_proximityprotection" );
}

isprimarydamage( meansofdeath )
{
    return meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET";
}

isfiredamage( weapon, meansofdeath )
{
    if ( ( issubstr( weapon, "flame" ) || issubstr( weapon, "napalmblob_" ) || issubstr( weapon, "napalm_" ) ) && ( meansofdeath == "MOD_BURNED" || meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH" ) )
        return true;

    if ( getsubstr( weapon, 0, 3 ) == "ft_" )
        return true;

    return false;
}

isplayerexplosiveweapon( weapon, meansofdeath )
{
    if ( !isexplosivedamage( weapon, meansofdeath ) )
        return false;

    switch ( weapon )
    {
        case "napalm_mp":
        case "mortar_mp":
        case "hind_ffar_mp":
        case "cobra_ffar_mp":
        case "artillery_mp":
        case "airstrike_mp":
            return true;
    }

    return true;
}

isheaddamage( hitloc )
{
    return hitloc == "helmet" || hitloc == "head" || hitloc == "neck";
}

grenadestuck( inflictor )
{
    return isdefined( inflictor ) && isdefined( inflictor.stucktoplayer ) && inflictor.stucktoplayer == self;
}
