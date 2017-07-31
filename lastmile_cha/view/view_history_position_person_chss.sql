use lastmile_cha;

drop view if exists view_history_position_person_chss;

create view view_history_position_person_chss as 

select

      substring_index( trim( l.person_id ), '|', 1 )            as chss_id,
      concat( trim( r.first_name ), ' ', trim( r.last_name ) )  as chss,
      trim( l.position_id )                                     as position_id,
      l.begin_date                                              as position_person_begin_date,
      l.end_date                                                as position_person_end_date
      
from view_history_position_person_last as l
    left outer join person as r             on l.person_id    = trim( r.person_id )
    left outer join `position` as p         on l.position_id  = trim( p.position_id )
        left outer join job as j            on p.job_id       = j.job_id

where trim( j.title ) like 'CHSS'
;