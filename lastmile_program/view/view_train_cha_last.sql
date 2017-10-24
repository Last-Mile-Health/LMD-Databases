use lastmile_program;

drop view if exists view_train_cha_last;

-- Throw out duplicate records by cha_id, person_id, module.  There will be instances where specific CHAs
-- will be retrain in particular modules.  Only take the latest one.

create view view_train_cha_last as

select
      trim( t1.cha_id    )            as cha_id,
      trim( t1.person_id )            as person_id,
      
      t1.module,
      t1.begin_date,
      t1.end_date,
      
      trim( t1.cha_id_lmh )           as cha_id_lmh,
      
      trim( t1.participant_name )     as participant_name,
      trim( t1.participant_type )     as participant_type,
      
      trim( t1.facilitator_1 )        as facilitator_1,
      trim( t1.facilitator_2 )        as facilitator_2,
      trim( t1.facilitator_3 )        as facilitator_3,
      trim( t1.facilitator_4 )        as facilitator_4,
      
      trim( t1.health_district )      as health_district,
      trim( t1.county )               as county,
      trim( t1.gender )               as gender,
      trim( t1.phone )                as phone,
     
      t1.pre_test,
      t1.practical_skills_check,
      t1.post_test,
      t1.overall_assessment,
      
      trim( t1.note )                 as note,
      trim( t1.data_entry_name )      as data_entry_name
      
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