use lastmile_cha;

drop view if exists view_history_position_last_date;

create view view_history_position_last_date as 

select

      trim( pr.position_id )  as position_id,
      max(  pr.begin_date )   as begin_date_last,
      max(  pr.end_date )     as end_date_last
      
from position_person as pr
group by trim( pr.position_id )
;