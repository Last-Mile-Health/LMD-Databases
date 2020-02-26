use lastmile_cha;

drop view if exists view_history_position_person_last;

create view view_history_position_person_last as
select
      pr.person_id,
      substring_index( group_concat( trim( pr.position_id ) order by pr.begin_date desc separator ',' ), ',', 1 ) as position_id,
      max( pr.begin_date )  as begin_date,
      
      if( 
          substring_index( group_concat( coalesce( pr.end_date, 'null' ) order by pr.begin_date desc separator ',' ), ',', 1 ) like 'null', 
          null,  
          substring_index( group_concat( pr.end_date order by pr.begin_date desc separator ',' ), ',', 1 )
      )
      as end_date
      
from position_person as pr
group by pr.person_id
;

/*
select
      pr1.person_id,
      trim( pr1.position_id ) as position_id,
      pr1.begin_date,
      pr1.end_date
     
from position_person as pr1
    left outer join position_person as pr2 on  (  pr1.person_id   = pr2.person_id   ) and 
                                               (  pr1.begin_date  > pr2.begin_date  )
group by  pr1.person_id
having    count( * ) >= 1
;

*/
