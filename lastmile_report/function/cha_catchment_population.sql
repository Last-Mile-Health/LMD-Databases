use lastmile_report;
 
drop function if exists cha_catchment_population;

create function cha_catchment_population( total_household_member  integer, 
                                          total_household         integer, 
                                          community_count         integer,
                                          household_map_count     integer,
                                          cha_count               integer ) returns integer

begin


if ( not total_household_member is null ) and ( total_household_member > 0 ) then

    return total_household_member;

elseif ( not total_household is null ) and ( total_household > 0 ) then

    return total_household * 6;
    
elseif ( not  community_count is null ) and ( not household_map_count is null ) and ( not cha_count is null ) and
       (      community_count > 0     ) and (     household_map_count > 0     ) and (     cha_count > 0     ) then
    

    return household_map_count * 6 / cha_count;
    
else

    return null;

end if;

end;