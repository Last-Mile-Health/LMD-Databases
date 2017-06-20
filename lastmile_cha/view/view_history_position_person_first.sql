use lastmile_cha;

drop view if exists view_history_position_person_first;

create view view_history_position_person_first as

select
      trim( pr1.person_id   )     as person_id,
      trim( pr1.position_id )     as position_id,
      pr1.begin_date,
      pr1.end_date
     
from position_person as pr1
    left outer join position_person as pr2 on  (  trim( pr1.person_id )  like  trim(  pr2.person_id ) ) and 
                                               (        pr1.begin_date   <            pr2.begin_date        )
group by  trim( pr1.person_id )
having    count( * ) >= 1
;


