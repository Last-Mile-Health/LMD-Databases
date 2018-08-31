use lastmile_cha;

drop view if exists view_position_chss_supervisor;

create view view_position_chss_supervisor as

select

      p.position_id,
      p.health_facility_id,
      p.position_begin_date,
      
      ps.begin_date                    as position_supervision_begin_date,
      
      s.position_id                    as position_supervisor_id,
      s.health_facility_id             as position_supervisor_health_facility_id,
      s.position_begin_date            as position_supervisor_begin_date
      
from view_position_chss as p
    left outer join position_supervisor as ps on ( trim( p. position_id ) like trim( ps.position_id ) ) and ( ps.end_date is null )
        left outer join view_position_qao as s on trim( ps.position_supervisor_id ) like trim( s.position_id )
;