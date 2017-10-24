use lastmile_program;

drop view if exists view_train_cha_module;

create view view_train_cha_module as

select
      t.cha_id    as cha_id,
      t.person_id as person_id,
      group_concat( distinct t.module order by cast( t.module as unsigned ) asc separator ', ' ) as cha_module_list

from view_train_cha_last as t
-- from view_train_moh_cha_id as t
group by t.cha_id, t.person_id
;