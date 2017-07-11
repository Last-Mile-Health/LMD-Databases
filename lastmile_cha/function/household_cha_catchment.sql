use lastmile_cha;
 
drop function if exists household_cha_catchment;

create function household_cha_catchment(  total_household         integer, 
                                          community_count         integer,
                                          household_map_count     integer,
                                          cha_count               integer ) returns integer

begin


if ( not total_household is null ) and ( total_household > 0 ) then

    return total_household;
    
elseif ( not  community_count is null ) and ( not household_map_count is null ) and ( not cha_count is null ) and
       (      community_count > 0     ) and (     household_map_count > 0     ) and (     cha_count > 0     ) then
    

    return household_map_count / cha_count;
    
else

    return null;

end if;

end;