use lastmile_ncha;

drop view if exists lastmile_ncha.view_person_position_cha_id_update;

create view lastmile_ncha.view_person_position_cha_id_update as

select
      pr.position_id_pk,
      l.position_id_last,
      pr.position_id,
      pr.person_id,
      pr.person_id_lmh,
      
      if( pr.position_id like pr.person_id_lmh, pr.position_id, pr.person_id_lmh ) as cha_id_historical,
      
      pr.position_begin_date,
      pr.position_end_date,
      
      pr.position_id_begin_date,
      pr.position_id_end_date,
      
      pr.position_person_begin_date,
      pr.position_person_end_date
      
from lastmile_ncha.view_history_person_position_cha as pr
    left outer join lastmile_ncha.view_history_position_id_last as l on pr.position_id_pk like l.position_id_pk
;