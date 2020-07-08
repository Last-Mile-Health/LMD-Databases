use lastmile_report;

drop view if exists lastmile_report.view_snapshot_position_cha;
/*
 * Former Unicef Grand Gedef CHAs and CHSSs are tagged with the string "UNICEF" in the cohort field in the position table.
 *
 * All other positions have null for cohort.  Grand Gedeh positions with cohort equal to null are under LMH management.
 *
 * The same with Rivercess positions, they are all under LMH management.  However, only Unicef is being treated as a cohort,
 * whaterver the hell that means at any given moment.
 *
*/

create view lastmile_report.view_snapshot_position_cha as
select

      c.position_status, 
      c.snapshot_date, 
            
      case
        when ( ( c.cohort is null ) or ( trim( c.cohort ) like '' ) ) and ( c.county like '%Grand%Gedeh%' ) 
            then trim( concat( c.county, ' ', 'LMH' ) )
            
        when ( c.cohort like '%UNICEF%' ) and ( c.county like '%Grand%Gedeh%' ) 
            then trim( concat( c.county, ' ', c.cohort ) )
            
        else c.county
      end as cohort,
      
      sum( if( c.person_id is null, 0, 1 ) )                          as cha_count,
      count( * )                                                      as position_count,
       
      round( sum( c.position_community_count_proportional ), 0 )      as community_count,
      sum( c.population )                                             as population,
      count( * ) * 235                                                as population_estimate,
      sum( c.household) as household 
     
from lastmile_report.data_mart_snapshot_position_cha as c
group by  c.position_status, 
          c.snapshot_date,
          case
              when ( ( c.cohort is null ) or ( trim( c.cohort ) like '' ) ) and ( c.county like '%Grand%Gedeh%' ) 
                  then trim( concat( c.county, ' ', 'LMH' ) )
            
              when ( c.cohort like '%UNICEF%' ) and ( c.county like '%Grand%Gedeh%' ) 
                  then trim( concat( c.county, ' ', c.cohort ) )
            
              else c.county
          end 
          
order by  c.position_status, 
          c.snapshot_date,      
          case
              when ( ( c.cohort is null ) or ( trim( c.cohort ) like '' ) ) and ( c.county like '%Grand%Gedeh%' ) 
                  then trim( concat( c.county, ' ', 'LMH' ) )
            
              when ( c.cohort like '%UNICEF%' ) and ( c.county like '%Grand%Gedeh%' ) 
                  then trim( concat( c.county, ' ', c.cohort ) )
            
              else c.county
          end
;


-- select
--      position_status, 
--      snapshot_date, 
--      county,
--      count( * )                                                    as cha_count,
--      round( sum( position_community_count_proportional ), 0 )      as community_count,
--      sum( population )                                             as population,
--      sum( household)                                               as household 
-- from data_mart_snapshot_position_cha
-- group by position_status, snapshot_date, county 
-- order by position_status, snapshot_date, county
-- ;

-- select
--      c.position_status, 
--      c.snapshot_date, 
--      trim( concat( c.county, ' ', coalesce( c.cohort, '' ) ) )       as county,
--      count( * )                                                      as cha_count,
--      round( sum( c.position_community_count_proportional ), 0 )      as community_count,
--      sum( c.population )                                             as population,
--      sum( c.household)                                               as household 
-- from data_mart_snapshot_position_cha as c
-- group by c.position_status, c.snapshot_date, trim( concat( c.county, ' ', coalesce( c.cohort, '' ) ) )
-- order by c.position_status, c.snapshot_date, trim( concat( c.county, ' ', coalesce( c.cohort, '' ) ) )
-- ;

-- select
--      c.position_status, 
--      c.snapshot_date, 
--      c.county,
--      c.cohort,
--      count( * )                                                      as cha_count,
--      round( sum( c.position_community_count_proportional ), 0 )      as community_count,
--      sum( c.population )                                             as population,
--      sum( c.household)                                               as household 

-- from data_mart_snapshot_position_cha as c
-- group by c.position_status, c.snapshot_date, c.county, c.cohort
-- order by c.position_status, c.snapshot_date, c.county, c.cohort
-- ;