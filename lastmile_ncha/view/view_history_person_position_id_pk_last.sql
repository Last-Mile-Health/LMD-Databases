use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_person_position_id_pk_last;

create view lastmile_ncha.view_history_person_position_id_pk_last  as
select
      r.person_id,
      cast( substring_index( group_concat( distinct pr.position_id_pk order by pr.begin_date desc separator ',' ), ',', 1 ) as unsigned ) as position_id_pk,
      
      max( pr.begin_date )  as begin_date,
      
      if( 
          substring_index( group_concat( coalesce( pr.end_date, 'null' ) order by pr.begin_date desc separator ',' ), ',', 1 ) like 'null', 
          null,  
          substring_index( group_concat( pr.end_date order by pr.begin_date desc separator ',' ), ',', 1 )
      )
      as end_date
      
from lastmile_ncha.person as r
    left outer join lastmile_ncha.position_person as pr on r.person_id = pr.person_id
group by r.person_id
;

