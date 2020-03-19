use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_supervisor;

create view lastmile_ncha.view_position_supervisor as 
select 
      ps.position_id_pk, 
      pl.position_id_last           as position_id,
      ps.position_supervisor_id_pk, 
      psl.position_id_last          as position_supervisor_id,
      ps.begin_date, 
      ps.end_date,
      ps.meta_insert_date_time
from lastmile_ncha.position_supervisor as ps
    left outer join lastmile_ncha.view_history_position_id_last       as pl   on ps.position_id_pk            = pl.position_id_pk
    left outer join lastmile_ncha.view_history_chss_position_id_last  as psl  on ps.position_supervisor_id_pk = psl.position_id_pk
;