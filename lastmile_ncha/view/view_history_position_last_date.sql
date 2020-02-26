use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_last_date;

create view lastmile_ncha.view_history_position_last_date as 

select

      pr.position_id_pk,
      max(  pr.begin_date )   as begin_date_last,
      max(  pr.end_date )     as end_date_last
      
from lastmile_ncha.position_person as pr
group by pr.position_id_pk
;