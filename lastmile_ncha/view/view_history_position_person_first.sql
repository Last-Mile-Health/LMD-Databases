use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_person_first;

create view lastmile_ncha.view_history_position_person_first as
select
      pr.person_id,
      substring_index( group_concat( pr.position_id_pk order by pr.begin_date asc separator ',' ), ',', 1 ) as position_id_pk,
      min( pr.begin_date )  as begin_date,
      
      if( 
          substring_index( group_concat( coalesce( pr.end_date, 'null' ) order by pr.begin_date asc separator ',' ), ',', 1 ) like 'null', 
          null,  
          substring_index( group_concat( pr.end_date order by pr.begin_date asc separator ',' ), ',', 1 )
      )
      as end_date
    
from lastmile_ncha.position_person as pr
group by pr.person_id
;


