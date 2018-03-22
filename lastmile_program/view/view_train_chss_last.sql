use lastmile_program;

drop view if exists view_train_chss_last;

-- Throw out duplicate records by chss_id and person_id .  There will be instances where CHSSs
-- will be retrain in particular modules.  Only take the latest one.

create view view_train_chss_last as

select
      -- trim( t1.chss_id )                      as position_id,
      trim( t1.person_id )                    as person_id,
         
      t1.begin_date,
      t1.end_date,
      
      trim( t1.chss_id_inserted )             as position_id_inserted,
      
      trim( t1.participant_name )             as participant_name,
      trim( t1.participant_type )             as participant_type,
  
      trim( t1.facilitator_1 )                as facilitator_1,
      trim( t1.facilitator_2 )                as facilitator_2,
      trim( t1.facilitator_3 )                as facilitator_3,
      trim( t1.facilitator_4 )                as facilitator_4,
      
      trim( t1.county )                       as county,
      trim( t1.health_district_training )     as health_district_training,
      trim( t1.gender )                       as gender,
      trim( t1.phone )                        as phone,
  
      trim( t1.m1_pre_test )                  as m1_pre_test, 
      trim( t1.m1_practical_skills_check )    as m1_practical_skills_check, 
      trim( t1.m1_post_test )                 as m1_post_test,   
      trim( t1.m1_overall_assessment )        as m1_overall_assessment,
      
      trim( t1.m2_pre_test )                  as m2_pre_test, 
      trim( t1.m2_practical_skills_check )    as m2_practical_skills_check, 
      trim( t1.m2_post_test )                 as m2_post_test,   
      trim( t1.m2_overall_assessment )        as m2_overall_assessment,
      
      trim( t1.m3_pre_test )                  as m3_pre_test, 
      trim( t1.m3_practical_skills_check )    as m3_practical_skills_check, 
      trim( t1.m3_post_test )                 as m3_post_test,
      trim( t1.m3_overall_assessment )        as m3_overall_assessment,
      
      trim( t1.m4_pre_test )                  as m4_pre_test, 
      trim( t1.m4_practical_skills_check )    as m4_practical_skills_check,
      trim( t1.m4_post_test )                 as m4_post_test,
      trim( t1.m4_overall_assessment )        as m4_overall_assessment,
  
      trim( t1.certificate_given )            as certificate_given,
      trim( t1.note )                         as note,
      trim( t1.data_entry_name )              as data_entry_name
      
 
from train_chss as t1
    left outer join train_chss as t2 on -- ( trim( t1.chss_id )  like  trim( t2.chss_id  ) ) and
                                        ( t1.person_id        =     t2.person_id      )   and                                     
                                        ( t1.begin_date       >     t2.begin_date     )
                                        
-- where not ( trim( t1.chss_id ) like '' )

group by  -- trim( t1.chss_id ), 
          t1.person_id
having    count( * ) >= 1
;