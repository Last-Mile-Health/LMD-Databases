use lastmile_program;

drop view if exists view_train_cha;

create view view_train_cha as

select * from lastmile_temp.cha_training_module_1
union all
select * from lastmile_temp.cha_training_module_2
;
