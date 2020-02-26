use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_qao_person_info;

create view lastmile_ncha.view_position_qao_person_info as

select
      pr.position_id_pk,
      pr.position_id,
      pr.position_begin_date,

      if( pr.position_person_begin_date is null, 'N', 'Y' )                                         as position_filled,
      if( pr.position_person_begin_date is null, d.end_date_last, pr.position_person_begin_date )   as position_filled_last_date,
      
      pr.position_person_begin_date,
      rf.begin_date                       as hire_date,
      pr.person_id,
      pr.person_id_lmh,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate
      
from lastmile_ncha.view_position_qao_person as pr
    left outer join   lastmile_ncha.view_history_position_last_date           as d    on pr.position_id_pk = d.position_id_pk
    left outer join   lastmile_ncha.view_history_position_person_first        as rf   on pr.person_id    =   rf.person_id 
;