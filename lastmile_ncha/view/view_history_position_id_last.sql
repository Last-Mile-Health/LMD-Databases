use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_position_id_last;

create view lastmile_ncha.view_history_position_id_last as
select
      position_id_pk,
      substring_index( trim( group_concat( distinct position_id order by position_id_begin_date desc separator ',' ) ), ',', 1 ) as position_id_last
from lastmile_ncha.view_history_person_position_cha
group by position_id_pk

