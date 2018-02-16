use lastmile_cha;

drop view if exists view_history_position_person_cea_ceo;

create view view_history_position_person_cea_ceo as 

select

      l.person_id,
      concat( trim( r.first_name ), ' ', trim( r.last_name ) )  as full_name,
      trim( l.position_id )                                     as position_id,
      l.begin_date                                              as position_person_begin_date,
      l.end_date                                                as position_person_end_date,
      trim( j.title )                                           as job
      
from view_history_position_person_last as l
    left outer join person as r             on l.person_id    = r.person_id
    left outer join `position` as p         on l.position_id  like trim( p.position_id )
        left outer join job as j            on p.job_id       = j.job_id

where ( trim( j.title ) like 'CEA' ) or ( trim( j.title ) like 'CEO' )
;