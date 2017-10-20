use lastmile_program;

drop view if exists view_train_cha_module;

create view view_train_cha_module as

select
      trim( t.cha_id )    as cha_id,
      trim( t.person_id ) as person_id,
      group_concat( distinct t.module order by cast( trim( t.module ) as unsigned ) asc separator ', ' ) as cha_module_list

from train_cha as t
-- from view_train_moh_cha_id as t
group by trim( t.cha_id ), trim( t.person_id )
;