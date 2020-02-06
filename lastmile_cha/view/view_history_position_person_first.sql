use lastmile_cha;

drop view if exists view_history_position_person_first;

create view view_history_position_person_first as
select
      person_id,
      min( begin_date ) as begin_date
from lastmile_cha.position_person
group by person_id
;


