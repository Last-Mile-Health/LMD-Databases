
use lastmile_cha;

drop view if exists view_position;

create view view_position as

select
      trim( p.position_id )                                                     as position_id,
      trim( j.title )                                                           as job,
            p.begin_date                                                        as position_begin_date,
            p.end_date                                                          as position_end_date,
      trim( p.health_facility_id )                                              as health_facility_id,
      trim( f.health_facility)                                                  as health_facility,
      trim( f.description )                                                     as health_facility_description

from `position` as p
    left outer join job as j              on trim( p.job_id )             like trim( j.job_id )
    left outer join health_facility as f  on trim( p.health_facility_id ) like trim( f.health_facility_id )
where p.end_date is null
;

use lastmile_cha;

drop view if exists view_position_cha;

create view view_position_cha as

select
      p.position_id,
      p.position_begin_date,
      p.health_facility_id,
      p.health_facility,
      p.health_facility_description
from view_position as p
where p.job like 'CHA'
;

use lastmile_cha;

drop view if exists view_position_person;

create view view_position_person as

select

      pr.position_id,
      pr.begin_date               as position_person_begin_date,

      r.person_id,
      r.first_name,
      r.last_name,
      r.other_name,
      r.birth_date,
      r.gender,
      r.phone_number,
      r.phone_number_alternate
      
from position_person as pr
    left outer join person as r on  pr.person_id = r.person_id 
where pr.end_date is null -- only return active position_person records
;

use lastmile_program;
  
drop view if exists view_registration_year;

create view view_registration_year as 

select
      year( trim( g.registrationDate ) )                                        as registration_year,
      trim( g.communityID )                                                     as community_id,
      trim( g.chaID )                                                           as position_id,
      
      max( trim( g.registrationDate ) )                                         as  registration_date,

      sum( cast( g.1_1_A_total_number_households as unsigned ) )                as total_household,
      sum( cast( g.1_1_B_total_household_members as unsigned ) )                as total_household_member,
                                                    
      sum( cast( g.1_1_C_total_zero_eleven_months_male as unsigned ) )          as total_zero_eleven_month_male,
      sum( cast( g.1_1_D_total_zero_eleven_months_female as unsigned ) )        as total_zero_eleven_month_female,
  
      sum( cast( g.1_1_E_total_one_five_years_male as unsigned ) )              as total_one_five_year_male,
      sum( cast( g.1_1_F_total_one_five_years_female as unsigned ) )            as total_one_five_year_female,
  
      sum( cast( g.1_1_G_total_six_fourteen_years_male as unsigned ) )          as total_six_fourteen_year_male,
      sum( cast( g.1_1_H_total_six_fourteen_years_female as unsigned ) )        as total_six_fourteen_year_female,
  
      sum( cast( g.1_1_I_total_fifteen_forty_nine_years_male as unsigned ) )    as total_fifteen_forty_nine_year_male,
      sum( cast( g.1_1_J_total_fifteen_forty_nine_years_female as unsigned ) )  as total_fifteen_forty_nine_year_female,
  
      sum( cast( g.1_1_K_total_fifty_plus_years_male as unsigned ) )            as total_fifty_plus_year_male,
      sum( cast( g.1_1_L_total_fifty_plus_years_female as unsigned ) )          as total_fifty_plus_year_female
  
from lastmile_upload.de_chaHouseholdRegistration as g
group by registration_year, community_id, position_id
;


use lastmile_program;
  
drop view if exists view_registration;

create view view_registration as 

select
      g1.community_id, 
      g1.position_id, 
      g1.registration_year,
      
      g1.registration_date,
      
      g1.total_household,
      g1.total_household_member,
      
      g1.total_zero_eleven_month_male,
      g1.total_zero_eleven_month_female,
  
      g1.total_one_five_year_male,
      g1.total_one_five_year_female,
  
      g1.total_six_fourteen_year_male,
      g1.total_six_fourteen_year_female,
  
      g1.total_fifteen_forty_nine_year_male,
      g1.total_fifteen_forty_nine_year_female,
  
      g1.total_fifty_plus_year_male,
      g1.total_fifty_plus_year_female
      
from view_registration_year as g1
    left outer join view_registration_year as g2 on ( trim( g1.community_id ) like trim( g2.community_id  )  ) and 
                                                    ( trim( g1.position_id )  like trim( g2.position_id   )  ) and
                                                    ( g1.registration_year    > g2.registration_year      )
group by trim( g1.community_id ), trim( g1.position_id )
having count( * ) >= 1
;


use lastmile_cha;

drop view if exists view_position_cha_id_community_id;

create view view_position_cha_id_community_id as

select
      p.position_id,
      pc.community_id
      
from view_position_cha as p
    left outer join position_community as pc on p.position_id like trim( pc.position_id )
where pc.end_date is null
;  



use lastmile_cha;
  
drop view if exists view_position_cha_registration;

create view view_position_cha_registration as 

select
      pc.position_id,

      sum( g.total_household )                        as total_household,
      sum( g.total_household_member )                 as total_household_member,
      
      sum( g.total_zero_eleven_month_male )           as total_zero_eleven_month_male,
      sum( g.total_zero_eleven_month_female )         as total_zero_eleven_month_female,
  
      sum( g.total_one_five_year_male )               as total_one_five_year_male,
      sum( g.total_one_five_year_female )             as total_one_five_year_female,
  
      sum( g.total_six_fourteen_year_male )           as total_six_fourteen_year_male,
      sum( g.total_six_fourteen_year_female )         as total_six_fourteen_year_female,
  
      sum( g.total_fifteen_forty_nine_year_male )     as total_fifteen_forty_nine_year_male,
      sum( g.total_fifteen_forty_nine_year_female )   as total_fifteen_forty_nine_year_female,
  
      sum( g.total_fifty_plus_year_male )             as total_fifty_plus_year_male,
      sum( g.total_fifty_plus_year_female )           as total_fifty_plus_year_female
      

from view_position_cha_id_community_id as pc
    left outer join lastmile_program.view_registration as g on ( pc.position_id like g.position_id ) and ( pc.community_id = cast( g.community_id as unsigned) )
group by pc.position_id
;


use lastmile_cha;

drop view if exists view_history_position_person_first;

create view view_history_position_person_first as

select
      pr1.person_id,
      trim( pr1.position_id )     as position_id,
      pr1.begin_date,
      pr1.end_date
     
from position_person as pr1
    left outer join position_person as pr2 on  ( pr1.person_id  = pr2.person_id   ) and 
                                               ( pr1.begin_date < pr2.begin_date  )
group by  pr1.person_id
having    count( * ) >= 1
;

use lastmile_cha;

drop view if exists view_history_position_person_last;

create view view_history_position_person_last as

select
      pr1.person_id,
      trim( pr1.position_id ) as position_id,
      pr1.begin_date,
      pr1.end_date
     
from position_person as pr1
    left outer join position_person as pr2 on  (  pr1.person_id   = pr2.person_id   ) and 
                                               (  pr1.begin_date  > pr2.begin_date  )
group by  pr1.person_id
having    count( * ) >= 1
;


use lastmile_program;

drop view if exists view_train_cha_last;

-- Throw out duplicate records by cha_id, person_id, module.  There will be instances where specific CHAs
-- will be retrain in particular modules.  Only take the latest one.

create view view_train_cha_last as

select
      trim( t1.cha_id    )            as position_id,
      t1.person_id,
      
      t1.module,
      t1.begin_date,
      t1.end_date,
      
      trim( t1.cha_id_inserted )      as position_id_inserted,
      
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
    left outer join train_cha as t2 on  ( trim( t1.cha_id ) like trim( t2.cha_id ) )  and
                                        ( t1.person_id      = t2.person_id )          and
                                        ( t1.module         = t2.module     )         and
                                        ( t1.begin_date     > t2.begin_date )
                                       
group by  trim( t1.cha_id    ), 
          t1.person_id,
          t1.module
having    count( * ) >= 1
;

use lastmile_program;

drop view if exists view_train_cha_module;

create view view_train_cha_module as

select
      t.position_id,
      t.person_id,
      group_concat( distinct t.module order by cast( t.module as unsigned ) asc separator ', ' ) as cha_module_list
      
from view_train_cha_last as t
group by t.position_id, t.person_id
;

use lastmile_cha;

drop view if exists view_position_chss_person_geo;

create view view_position_chss_person_geo as

select
      pr.position_id,
      pr.position_begin_date,
      pr.health_facility_id,
      pr.health_facility,
      
      if( pr.position_person_begin_date is null, 'N', 'Y' )                                         as position_filled,
      if( pr.position_person_begin_date is null, d.end_date_last, pr.position_person_begin_date )   as position_filled_last_date,
      
      pr.position_person_begin_date,
      rf.begin_date                       as hire_date,
      pr.person_id,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate,

      gf.cohort,
      gf.health_district,
      gf.health_district_id,
      gf.county_id,
      gf.county,
      
      t.module
      
from view_position_chss_person as pr
    left outer join   view_history_position_last_date           as d    on pr.position_id         like  d.position_id
    left outer join   view_history_position_person_first        as rf   on pr.person_id           =     rf.person_id 
    left outer join   view_geo_health_facility                  as gf   on pr.health_facility_id  like  gf.health_facility_id
    left outer join   lastmile_program.view_train_chss_module   as t    on ( pr.position_id like t.position_id ) and ( pr.person_id = t.person_id )
;


use lastmile_cha;

drop view if exists view_position_cha_geo_community_person;

create view view_position_cha_geo_community_person as

select
      -- cha position fields
      p.position_id,
      p.
      p.position_begin_date,
      
      -- cha health facility and geographical info
      p.health_facility_id,
      f.health_facility,
      f.cohort,
      f.health_district_id,
      f.health_district,
      f.county_id,
      f.county,
      
      -- list of communityIDs, communities, and dates assocaited with the CHA position
      c.begin_date                                               as communtiy_begin_date,
      c.begin_date_list                                          as communtiy_begin_date_list,  
      c.community_id_list,
      c.community_list,
      
      -- household registration data from paper forms
      g.total_household,
      g.total_household_member,
      
      if( pr.position_person_begin_date is null, 'N', 'Y' )                                         as position_filled,
      if( pr.position_person_begin_date is null, d.end_date_last, pr.position_person_begin_date )   as position_filled_last_date,
      
      -- cha person fields
      pr.position_person_begin_date,
      rf.begin_date                                               as hire_date,
      pr.person_id,  -- not position_id for CHA, this is our internal id, unique for every person.
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate,
      
      -- CHA Training completed
      m.cha_module_list                                             as module,
      
      -- ---------------------------------------------------------------------------------------------------
      -- Beginning of CHSS info
      -- ---------------------------------------------------------------------------------------------------
         
      ps.position_supervision_begin_date                            as chss_position_supervision_begin_date,  
      
      -- All the dates, except for position_person.[ begin, end ], are position-to-position oriented.
      -- position_supervision_beginDate only tells us when a chss position began supervising a cha position,
      -- not when a specific chss starting supervising a specific chp.
      
      -- So the actual supervision date is the later of chss and cha position_person begin dates, assuming 
      -- the chss and/or person begin dates are not null.  These would be the cases of either or both positions
      -- being unfilled.
      
      if( ( pr.position_person_begin_date is null ) or ( po.position_person_begin_date is null ), 
            null,  
            if( pr.position_person_begin_date > po.position_person_begin_date, 
                pr.position_person_begin_date, 
                po.position_person_begin_date  ) 
      )                                                         as chss_cha_supervision_begin_date,
      
      ps.position_supervisor_id                                  as chss_position_id,
      ps.position_supervisor_health_facility_id                  as chss_health_facility_id,
      ps.position_supervisor_begin_date                          as chss_position_begin_date,
      
      -- When chwdb data was migrated into lastmile_cha and the CHAs and CHSSs changes were made for the NCHAP, 
      -- all CHA and CHSS position were assigned to the same health facility.  I can see that changing over time
      -- So I added the CHSS geo fields for future reference.
      po.health_facility                                         as chss_health_facility,
      po.health_district_id                                      as chss_health_district_id,
      po.health_district                                         as chss_health_district,
      po.county_id                                               as chss_county_id,
      po.county                                                  as chss_county,
      
      po.position_person_begin_date                              as chss_position_person_begin_date,
      po.hire_date                                               as chss_hire_date,
      po.person_id                                               as chss_person_id,
      po.first_name                                              as chss_first_name,
      po.last_name                                               as chss_last_name,
      po.birth_date                                              as chss_birth_date,
      po.gender                                                  as chss_gender,
      po.phone_number                                            as chss_phone_number,
      po.phone_number_alternate                                  as chss_phone_number_alternate,
      
      po.module                                                  as chss_module
      
from view_position_cha as p

    left outer join           view_geo_health_facility                as f  on p.health_facility_id       like f.health_facility_id
    left outer join           view_position_cha_community_list        as c  on p.position_id              like c.position_id
    left outer join           view_position_cha_registration          as g  on p.position_id              like g.position_id
    
    left outer join           view_position_cha_person                as pr on p.position_id              like pr.position_id
        left outer join       view_history_position_last_date         as d  on pr.position_id             like d.position_id
        left outer join       view_history_position_person_first      as rf on pr.person_id               like rf.person_id
    
    left outer join           lastmile_program.view_train_cha_module  as m  on ( p.position_id like m.position_id ) and ( pr.person_id = m.person_id )
    
    left outer join           view_position_cha_supervisor            as ps on p.position_id              like ps.position_id
        left outer join       view_position_chss_person_geo           as po on ps.position_supervisor_id  like po.position_id
; 



use lastmile_cha;

drop view if exists view_base_position_cha;

create view view_base_position_cha as

select
      county_id,
      county,
      
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      position_filled,
      position_filled_last_date,
      
      position_id,                                
      person_id,
      
      concat( first_name, ' ', last_name )        as cha,
      position_person_begin_date,
      position_begin_date,
          
      -- cha person fields
      hire_date,
      
      birth_date,
      gender,
      phone_number,
      phone_number_alternate,
      
      community_id_list,
      community_list,
      
      -- household registration data from paper forms
      total_household,
      total_household_member,
      
      -- CHA Training completed
      module,
      
      -- Beginning of the CHSS info
      
      chss_position_begin_date,
      chss_cha_supervision_begin_date                         as chss_supervision_begin_date,
      
      chss_position_id,
      chss_person_id,
      concat( chss_first_name, ' ', chss_last_name )          as chss,
      
      chss_position_person_begin_date,
      chss_hire_date,

      chss_birth_date,
      chss_gender,
      chss_phone_number,
      chss_phone_number_alternate,
      
      chss_module,
      
      chss_health_facility_id,
      chss_health_facility,
      
      chss_health_district_id,
      chss_health_district,
      
      chss_county_id,
      chss_county
      
from view_position_cha_geo_community_person
;

use lastmile_cha;

drop view if exists view_base_cha;

create view view_base_cha as

select
      *
from view_base_position_cha
where not ( ( cha is null ) or ( trim( cha ) like '' ) )
;


use lastmile_cha;

drop view if exists view_base_history_position;

create view view_base_history_position as

select
      j.title                   as job,
      p.position_id,
      p.begin_date,
      p.end_date,
      p.health_facility_id,
      f.health_facility,
      f.health_district_id,
      h.health_district,
      h.county_id,
      c.county
        
from `position`                               as p
    left outer join job                       as j  on p.job_id = j.job_id
    left outer join health_facility           as f  on trim( p.health_facility_id ) like trim( f.health_facility_id )
        left outer join health_district       as h  on f.health_district_id = h.health_district_id
            left outer join county            as c  on h.county_id = c.county_id
;


use lastmile_program;

drop view if exists view_train_chss_last;

-- Throw out duplicate records by chss_id and person_id .  There will be instances where CHSSs
-- will be retrain in particular modules.  Only take the latest one.

create view view_train_chss_last as

select
      trim( t1.chss_id )                      as position_id,
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
    left outer join train_chss as t2 on ( trim( t1.chss_id )  like  trim( t2.chss_id  ) ) and
                                        ( t1.person_id        =     t2.person_id      )   and                                     
                                        ( t1.begin_date       >     t2.begin_date     )
                                        
where not ( trim( t1.chss_id ) like '' )

group by  trim( t1.chss_id ), 
          t1.person_id
having    count( * ) >= 1
;


use lastmile_program;

drop view if exists view_train_chss_module;

create view view_train_chss_module as 

select
      t.position_id,
      t.person_id,
      
      replace( 
      trim( replace( concat(  if( not ( ( t.m1_overall_assessment is null  ) or ( trim( t.m1_overall_assessment ) like '' ) ), '1', ''  ), ' ',
                              if( not ( ( t.m2_overall_assessment is null  ) or ( trim( t.m2_overall_assessment ) like '' ) ), '2', ''  ), ' ',
                              if( not ( ( t.m3_overall_assessment is null  ) or ( trim( t.m3_overall_assessment ) like '' ) ), '3', ''  ), ' ',
                              if( not ( ( t.m4_overall_assessment is null  ) or ( trim( t.m4_overall_assessment ) like '' ) ), '4', ''  ), ' '
                            ), '  ', ' ' 
                    ) 
          ), 
          ' ', ', ' ) as module
          
from lastmile_program.view_train_chss_last as t
where ( not ( ( t.position_id is null ) or ( trim( t.position_id ) like '' ) ) ) and 
      ( not (   t.person_id   is null ) ) 
;












use lastmile_cha;

drop view if exists view_base_position_chss;

create view view_base_position_chss as

select

      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      position_id,
      position_begin_date,
      
      position_filled,
      position_filled_last_date,
      
      person_id,
      concat( first_name, ' ', last_name )  as chss,
      position_person_begin_date,
      hire_date,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate,

      module
      
from view_position_chss_person_geo
;


use lastmile_cha;

drop view if exists view_base_chss;

create view view_base_chss as

select 
      *
from view_base_position_chss
where not ( ( chss is null ) or ( trim( chss ) like '' ) )
;


/*
  This view does not work on Windows MySQL.  Because the two views it is buitlt on are themselves built on self-joins,
  it returns zeron records.  It works fine on our production Linux instance of MySQL.  Not sure if this is a problem 
  with the specific version of MySQL we are using on Windows or 

*/

use lastmile_cha;

drop view if exists view_base_position;

create view view_base_position as

select
      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      'CHA'                       as job,
      position_id,
      cha                         as full_name,
      
      position_filled,
      position_filled_last_date
      
from view_base_position_cha

union all

select

      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      'CHSS'                    as job,
      position_id,
      chss                      as full_name,
      
      position_filled,
      position_filled_last_date
      
from view_base_position_chss
;


use lastmile_cha;

drop view if exists view_history_position_person;

create view view_history_position_person as 

select

      p.job,
      p.position_id,
      p.position_active,
      p.position_begin_date,
      p.position_end_date,

      r.person_id,
      concat( trim( r.first_name ), ' ', trim( r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                          as gender,
      trim( r.phone_number )                                    as phone_number,
      trim( r.phone_number_alternate )                          as phone_number_alternate, 
         
      -- position person relationship active Y/N
      if( pr.end_date is null, 'Y', 'N' )                       as position_person_active,
      pr.begin_date                                             as position_person_begin_date,
      pr.end_date                                               as position_person_end_date,
      trim( l.reason_left )                                     as reason_left,
      trim( pr.reason_left_description )                        as reason_left_description,
      
      p.health_facility_id,
      p.health_facility,
      p.cohort,
      p.health_district_id,
      p.health_district,
      p.county_id,
      p.county

from view_history_position_geo      as p
    left outer join position_person as pr on p.position_id      like trim( pr.position_id )
        left outer join person      as r  on pr.person_id       = r.person_id
        left outer join reason_left as l  on pr.reason_left_id  = l.reason_left_id 
;



use lastmile_cha;

drop view if exists view_history_position_person_chwl;

create view view_history_position_person_chwl as 

select

      position_id,
      position_active,
      position_begin_date,
      position_end_date,

      person_id,
      full_name,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate, 
         
      position_person_active,
      position_person_begin_date,
      position_person_end_date,
      reason_left,
      reason_left_description,
      
      health_facility_id,
      health_facility,
      cohort,
      health_district_id,
      health_district,
      county_id,
      county

from view_history_position_person
where job like 'CHWL'
;


use lastmile_cha;

drop view if exists view_history_position_person_cha;

create view view_history_position_person_cha as 

select
 
      position_id,
      position_active,
      position_begin_date,
      position_end_date,
 
      person_id,    
      full_name,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate, 
      
      position_person_active,
      position_person_begin_date,
      position_person_end_date,
      
      reason_left,
      reason_left_description,
      
      health_facility_id,
      health_facility,
      
      cohort,
      health_district_id,
      health_district,
      county_id,
      county
      
from view_history_position_person
where job like 'CHA'
;

use lastmile_cha;

drop view if exists view_history_position_person_chss;

create view view_history_position_person_chss as 

select
      position_id,                                    
      full_name,
      person_id,    
      position_person_begin_date,
      position_person_end_date
from view_history_position_person
where job like 'CHSS'
;

use lastmile_cha;

drop view if exists view_history_person_position;

create view view_history_person_position as 

select
      r.person_id,
      concat( trim( r.first_name ), ' ', trim( r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                          as gender,
      trim( r.phone_number )                                    as phone_number,
      trim( r.phone_number_alternate )                          as phone_number_alternate, 
   
      p.job,
      trim( pr.position_id )                                    as position_id,
      p.position_active,
      p.position_begin_date,
      p.position_end_date,
      
      -- position person relationship active Y/N
      if( pr.end_date is null, 'Y', 'N' )                       as position_person_active,
      pr.begin_date                                             as position_person_begin_date,
      pr.end_date                                               as position_person_end_date,
      trim( l.reason_left )                                     as reason_left,
      trim( pr.reason_left_description )                        as reason_left_description,
      
      p.health_facility_id,
      p.health_facility,
      p.cohort,
      p.health_district_id,
      p.health_district,
      p.county_id,
      p.county

from person as r
    left outer join position_person                 as pr on r.person_id            = pr.person_id
        left outer join reason_left                 as l  on pr.reason_left_id      = l.reason_left_id
        left outer join view_history_position_geo   as p  on trim( pr.position_id ) like  p.position_id
;

use lastmile_cha;

drop view if exists view_history_person_position_cha;

create view view_history_person_position_cha as 

select

      person_id,
      full_name,
      birth_date,
      gender,
      phone_number,
      phone_number_alternate, 
 
      position_id,
      position_active,
      position_begin_date,
      position_end_date,
      
      position_person_active,
      position_person_begin_date,
      position_person_end_date,
      
      reason_left,
      reason_left_description,
      
      health_facility_id,
      health_facility,
      
      cohort,
      health_district_id,
      health_district,
      county_id,
      county
      
from view_history_person_position
where job like 'CHA'
;

use lastmile_cha;

drop view if exists view_history_person_geo;

create view view_history_person_geo as

select
      r.person_id,
      trim( concat( r.first_name, ' ', r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                  as gender,
      trim( r.phone_number )                            as phone_number,
      trim( r.phone_number_alternate )                  as phone_number_alternate,
      
      pl.job,
      rl.position_id,
      rl.begin_date                                     as position_person_begin_date,
      rl.end_date                                       as position_person_end_date,
      if( rl.end_date is null, 'Y', 'N' )               as position_person_active, 
      
      pl.health_facility,
      pl.health_facility_id,
      pl.cohort,
      pl.health_district,
      pl.health_district_id,
      pl.county,
      pl.county_id,
      
      pf.job                                            as job_first,
      rf.position_id                                    as position_id_first,
      rf.begin_date                                     as position_person_begin_date_first,
      rf.end_date                                       as position_person_end_date_first,
      if( rf.end_date is null, 'Y', 'N' )               as position_person_active_first 
      
from person as r
    left outer join       view_history_position_person_last     as rl on r.person_id              like rl.person_id
        left outer join   view_history_position_geo             as pl on rl.position_id           like pl.position_id
    left outer join       view_history_position_person_first    as rf on r.person_id              like rf.person_id
        left outer join   view_history_position_geo             as pf on rf.position_id           like pf.position_id
;


use lastmile_cha;

-- View of all commuunities, the CHAs asssigned to them, and the household and member registration counts.

drop view if exists view_community_registration;

create view view_community_registration as 

select
      pc.community_id,
      
      -- have the cha_id and year be lists ordered by the cha_id
      group_concat( pc.position_id        order by cast( pc.position_id as unsigned ) separator ', ' )  as position_id_list,
      group_concat( g.registration_year   order by cast( pc.position_id as unsigned ) separator ', ' )  as registration_year_list, 
      
      sum( g.total_household )                      as total_household, 
      sum( g.total_household_member )               as total_household_member,
      
      sum( g.total_zero_eleven_month_male )         as total_zero_eleven_month_male, 
      sum( g.total_zero_eleven_month_female )       as total_zero_eleven_month_female, 
      sum( g.total_one_five_year_male )             as total_one_five_year_male, 
      sum( g.total_one_five_year_female )           as total_one_five_year_female, 
      sum( g.total_six_fourteen_year_male )         as total_six_fourteen_year_male, 
      sum( g.total_six_fourteen_year_female )       as total_six_fourteen_year_female, 
      sum( g.total_fifteen_forty_nine_year_male )   as total_fifteen_forty_nine_year_male, 
      sum( g.total_fifteen_forty_nine_year_female ) as total_fifteen_forty_nine_year_female, 
      sum( g.total_fifty_plus_year_male )           as total_fifty_plus_year_male, 
      sum( g.total_fifty_plus_year_female )         as total_fifty_plus_year_female
      
from view_position_community as pc 
        left outer join lastmile_program.view_registration as g on  ( pc.community_id = cast( g.community_id as unsigned ) ) and 
                                                                    ( pc.position_id  like g.position_id )
group by pc.community_id
;

use lastmile_cha;

drop view if exists view_geo_community_cha_population;

create view view_geo_community_cha_population as 

select

      c.county_id,
      c.county,
      
      c.health_district_id,
      c.health_district,
      
      c.district_id,
      c.district,
      
      c.community_health_facility_id,
      c.community_health_facility,
      
      c.community_id,
      c.community,
      c.community_alternate,
      c.health_facility_proximity,
      c.health_facility_km,
      c.x,
      c.y,
      
      c.motorbike_access,
      c.cell_reception,
      c.mining_community,
      c.lms_2015,
      c.lms_2016,
      c.archived,
      c.note,
      
      -- If a household registration has never been completed for a community estimate population from the household
      -- mapping value in community table, six persons per household.
      if( g.total_household_member is null, c.household_map_count * 6, g.total_household_member ) as population,
      if( g.total_household is null, c.household_map_count, g.total_household )                   as household_total,
      
      c.household_map_count,
      g.total_household             as registration_total_household,
      g.total_household_member      as registration_total_household_member,
      g.position_id_list            as registration_position_id_list,
      g.registration_year_list,
      
      a.position_id_list,
      a.position_count,
      if( a.position_id_list is null, 'N', 'Y' )              as active_position,
      
      a.person_id_list,
      a.person_count,
      if( a.person_id_list is null, 'N', 'Y' )                as active_cha
      
from view_geo_community as c
    left outer join view_community_registration as g on c.community_id = g.community_id
    left outer join view_community_cha          as a on c.community_id = a.community_id
;


use lastmile_cha;

drop view if exists view_base_geo_community;

create view view_base_geo_community as 

select

      county_id,
      county,
      
      health_district_id,
      health_district,
      
      district_id,
      district,
      
      community_health_facility_id,
      community_health_facility,
      
      community_id,
      community,
      community_alternate,
      health_facility_proximity,
      health_facility_km,
      x,
      y,
      
      motorbike_access,
      cell_reception,
      mining_community,
      lms_2015,
      lms_2016,
      archived,
      note,
      
      population,
      household_total,
      
      active_position,
      active_cha,
      
      if( active_position like 'N', 'None',
        if( active_cha like 'N', 'No CHA',
          if( person_count < position_count, 'Partial', 'Full' )
        )
      ) as service_level,
              
      position_id_list,
      position_count,
      
      person_id_list,
      person_count

from view_geo_community_cha_population
;

use lastmile_cha;

drop view if exists view_base_geo_community_in_program;

create view view_base_geo_community_in_program as 

select *
from view_base_geo_community
where active_position like 'Y'
;

use lastmile_cha;

drop view if exists view_base_geo_community_remote;

create view view_base_geo_community_remote as 

select *
from view_base_geo_community
where health_facility_proximity like 'remote'
;


use lastmile_cha;

drop view if exists view_geo_community_primary;
 
create view view_geo_community_primary as 
select substring_index( community_id_list, ',', 1 ) as community_id_primary 
from view_base_cha 
group by community_id_primary;



use lastmile_cha;

drop view if exists view_base_geo_community_primary;

create view view_base_geo_community_primary as 
select 
      a.county_id,
      a.county,
      a.health_district_id,
      a.health_district,
      a.district_id,
      a.district,
      a.community_health_facility_id,
      a.community_health_facility,
      a.community_id,
      a.community,
      a.community_alternate,
      a.health_facility_proximity,
      a.health_facility_km,
      a.x,
      a.y AS y,
      a.motorbike_access,
      a.cell_reception,
      a.mining_community,
      a.lms_2015,
      a.lms_2016,
      a.archived,
      a.note,
      a.population,
      a.household_total,
      a.active_position,
      a.active_cha,
      a.service_level,
      a.position_id_list,
      a.position_count
      
 from lastmile_cha.view_base_geo_community a 
    join lastmile_cha.view_geo_community_primary b on a.community_id = b.community_id_primary
 where a.archived <> 1
 ;
 

