use lastmile_report;
 
drop function if exists cha_catchment_household;

create function cha_catchment_household(  total_household         integer, 
                                          community_count         integer,
                                          household_map_count     integer,
                                          position_count          integer ) returns integer

begin


if ( not total_household is null ) and ( total_household > 0 ) then

    return total_household;
    
elseif ( not  community_count is null ) and ( not household_map_count is null ) and ( not position_count is null ) and
       (      community_count > 0     ) and (     household_map_count > 0     ) and (     position_count > 0     ) then
    

    return household_map_count / position_count;
    
else

    return null;

end if;

end;