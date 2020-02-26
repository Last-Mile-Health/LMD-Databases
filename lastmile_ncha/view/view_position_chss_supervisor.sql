use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_chss_supervisor;

create view lastmile_ncha.view_position_chss_supervisor as

select
      p.position_id_pk,
      p.position_id,
      p.health_facility_id,
      p.position_begin_date,
      
      ps.begin_date                    as position_supervision_begin_date,
      
      s.position_id_pk                 as position_supervisor_id_pk,
      s.position_id                    as position_supervisor_id,
      s.health_facility_id             as position_supervisor_health_facility_id,
      s.position_begin_date            as position_supervisor_begin_date
      
from lastmile_ncha.view_position_chss as p
    left outer join lastmile_ncha.position_supervisor as ps on ( p.position_id_pk = ps.position_id_pk ) and ( ps.end_date is null )
        left outer join lastmile_ncha.view_position_qao as s on ps.position_supervisor_id_pk = s.position_id_pk
;