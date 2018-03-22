use lastmile_program;

drop view if exists view_train_cha_module;

create view view_train_cha_module as

select
      -- t.position_id,
      t.person_id,
      group_concat( distinct t.module order by cast( t.module as unsigned ) asc separator ', ' ) as cha_module_list
      
from view_train_cha_last as t
-- group by t.position_id, t.person_id
    group by t.person_id
;