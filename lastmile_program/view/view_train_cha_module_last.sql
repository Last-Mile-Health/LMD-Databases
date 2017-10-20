use lastmile_program;

drop view if exists view_train_cha_module_last;

-- Throw out duplicate records by cha_id, person_id, module.  There will be instances where specific CHAs
-- will be retrain in particular modules.  Only take the latest one.

create view view_train_cha_module_last as

select
      trim( t1.cha_id    ) as cha_id,
      trim( t1.person_id ) as person_id,
      t1.module
 
from train_cha as t1
    left outer join train_cha as t2 on  ( trim( t1.cha_id     ) like  trim( t2.cha_id    ) )  and
                                        ( trim( t1.person_id  ) like  trim( t2.person_id ) )  and
                                        ( t1.module     = t2.module     )                     and
                                        ( t1.begin_date > t2.begin_date )
                                       
group by  trim( t1.cha_id    ), 
          trim( t1.person_id ),
          t1.module
having    count( * ) >= 1
;