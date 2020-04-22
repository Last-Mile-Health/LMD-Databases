use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_id_distinct;

create view lastmile_ncha.view_position_id_distinct as

select 
      pid.position_id, 
      p.job_id, 
      j.title as job
from lastmile_ncha.position_id as pid
    left outer join lastmile_ncha.`position` as p on pid.position_id_pk = p.position_id_pk
        left outer join lastmile_ncha.job as j on p.job_id = j.job_id
group by pid.position_id, p.job_id, j.title
;