use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_position_id_nchap_first;

create view lastmile_ncha.view_history_position_position_id_nchap_first as
select 
      position_id_pk, 
      substring_index( group_concat( distinct trim( position_id ) order by position_id_begin_date asc separator ',' ), ',', 1 ) as position_id_nchap     
from lastmile_ncha.view_history_position_position_id
where position_id like '%-%' and job_id like '1'
group by position_id_pk
;