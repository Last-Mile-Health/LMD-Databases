use lastmile_program;

drop view if exists view_train_cha_module;

create view view_train_cha_module as

select
      trim( ID ) as cha_id,
      group_concat( distinct module order by module asc separator ', ' ) as cha_module_list
from view_train_cha
group by trim( ID )
;