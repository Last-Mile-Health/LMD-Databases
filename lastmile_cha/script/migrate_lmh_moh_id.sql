use lastmile_cha;

-- trim everything...

-- Step 1: drop all indexes, keys, and constraints in the lastmile_cha schema that refer to position_id.

-- position_community
alter table lastmile_cha.position_community drop foreign key position_id_position_community;
alter table lastmile_cha.position_community drop primary key;

-- position_supervisor
alter table lastmile_cha.position_supervisor drop foreign key  position_id_position_supervisor;
alter table lastmile_cha.position_supervisor drop foreign key  position_id_position_supervisor_id_position_supervisor;
alter table lastmile_cha.position_supervisor drop primary key;
alter table lastmile_cha.position_supervisor drop key position_id_position_supervisor_id_position_supervisor;

-- position_person
alter table lastmile_cha.position_person drop foreign key position_id_position_person; 
alter table lastmile_cha.position_person drop foreign key person_id_position_person;
alter table lastmile_cha.position_person drop primary key;
alter table lastmile_cha.position_person drop key person_id_position_person;

-- position
alter table lastmile_cha.position drop primary key;
alter table lastmile_cha.position drop key UK_position_id; 

-- Step 2: Copy lmh position_id for active CHA and CHSS positions to position_id_lmh.  Active positions have null end_date. 

update lastmile_cha.position 
    set position_id_lmh = position_id 
where job_id = 1 and end_date is null;

update lastmile_cha.position 
    set position_id_lmh = position_id 
where job_id = 3 and end_date is null and not position_id like '%CHSS%TEMP%';


-- Step 3: Start updating the postion tables with new position_id taken from lastmile_temp moh_cha_id andmoh_chss_id.

-- position_community, cha only
update lastmile_cha.position_community pc, lastmile_temp.moh_cha_id m
    set pc.position_id = m.position_id_moh 
where pc.position_id = m.position_id_lmh;

-- position_supervisor, cha and chss
update lastmile_cha.position_supervisor ps, lastmile_temp.moh_cha_id m
    set ps.position_id = m.position_id_moh
where ps.position_id = m.position_id_lmh;

update lastmile_cha.position_supervisor ps, lastmile_temp.moh_chss_id s
    set ps.position_supervisor_id = s.position_id_moh
where ps.position_supervisor_id = s.position_id_lmh;

update lastmile_cha.position_person pr, lastmile_temp.moh_cha_id m
    set pr.position_id = m.position_id_moh
where pr.position_id = m.position_id_lmh;

update lastmile_cha.position_person pr, lastmile_temp.moh_chss_id s
    set pr.position_id = s.position_id_moh
where pr.position_id = s.position_id_lmh;

update lastmile_cha.position p, lastmile_temp.moh_cha_id m
    set p.position_id = m.position_id_moh
where p.position_id = m.position_id_lmh;

update lastmile_cha.position p, lastmile_temp.moh_chss_id s
    set p.position_id = s.position_id_moh
where p.position_id = s.position_id_lmh;

-- Last Step: Drop all the old _orig keys, they're going to be obsolete in new moh id system.
--    Keep the historical fhw/chw IDs in person_id_lmh;

alter table lastmile_cha.health_facility     drop health_facility_id_orig;
alter table lastmile_cha.position_supervisor drop position_id_orig;
alter table lastmile_cha.position_supervisor drop position_supervisor_id_orig;
alter table lastmile_cha.position_community  drop position_id_orig;
alter table lastmile_cha.position_person     drop position_id_orig;
alter table lastmile_cha.position_person     drop person_id_orig;
alter table lastmile_cha.person              change person_id_orig person_id_lmh varchar( 100 );
alter table lastmile_cha.position            drop position_id_orig;
alter table lastmile_cha.position            drop health_facility_id_orig;

-- Now, recreate all keys, indexes, and constraints

alter table lastmile_cha.position add unique UK_position_id ( position_id );
alter table lastmile_cha.position add primary key ( position_id );

alter table lastmile_cha.position_community add primary key ( position_id, community_id, begin_date );
alter table lastmile_cha.position_community add constraint position_id_position_community foreign key ( position_id ) references position ( position_id ) on delete no action on update no action;

alter table lastmile_cha.position_supervisor add primary key ( position_id, position_supervisor_id, begin_date );
alter table lastmile_cha.position_supervisor add constraint  position_id_position_supervisor                         foreign key (position_id)             references position (position_id) on delete no action on update no action;
alter table lastmile_cha.position_supervisor add constraint  position_id_position_supervisor_id_position_supervisor  foreign key (position_supervisor_id)  references position (position_id) on delete no action on update no action;

alter table lastmile_cha.position_person add primary key ( position_id, person_id, begin_date );
alter table lastmile_cha.position_person add constraint person_id_position_person    foreign key ( person_id )   references person   ( person_id )   on delete no action on update no action;
alter table lastmile_cha.position_person add constraint position_id_position_person  foreign key ( position_id ) references position ( position_id ) on delete no action on update no action;


-- Now, create view to map position_id to historical cha_id

drop view if exists lastmile_cha.view_base_history_moh_lmh_cha_id;

create view lastmile_cha.view_base_history_moh_lmh_cha_id as

select

      p.position_id,
       
      if( p.position_id_lmh is null or  trim( p.position_id_lmh ) like '', 
      
          null,
          
          if( p.position_id_lmh like r.person_id_lmh, p.position_id_lmh, r.person_id_lmh ) 
      
      ) as cha_id_historical,
      
      p.position_id_lmh,
      p.begin_date        as position_begin_date,
      p.end_date          as position_end_date,
      
      pr.begin_date       as position_person_begin_date,
      pr.end_date         as position_person_end_date,
      
      r.person_id,
      r.person_id_lmh
      
from lastmile_cha.position as p
    left outer join lastmile_cha.position_person as pr on p.position_id  like pr.position_id
        left outer join lastmile_cha.person      as r  on pr.person_id   like r.person_id
where ( p.job_id = 1 ) 
;

-- Note: view_base_history_moh_lmh_cha_id is too slow.  When integrated into view_base_position_cha it
-- takes about a minute and 45 secs to run.  So I create a "temp" table to act as a stand in for this view.
-- The execution time drops down to about 2-4 secs.  Doable.

drop table if exists lastmile_cha.temp_view_base_history_moh_lmh_cha_id;

create table lastmile_cha.temp_view_base_history_moh_lmh_cha_id as 
select * from lastmile_cha.view_base_history_moh_lmh_cha_id;


drop view if exists lastmile_cha.view_base_history_moh_lmh_chss_id;

create view lastmile_cha.view_base_history_moh_lmh_chss_id as

select
      trim( p.position_id ) as position_id,
      trim( pr.person_id )  as chss_id_historical,
      trim( pr.person_id )  as person_id
from lastmile_cha.position as p
    left outer join lastmile_cha.position_person as pr on trim( p.position_id ) like trim( pr.position_id ) 
where ( p.job_id = 3 )
;

-- good place to break file up?

drop view if exists lastmile_program.view_registration_moh_cha_id;

create view lastmile_program.view_registration_moh_cha_id as 
  
select
      g.registrationDate,                                       
      g.communityID,                                                     
      
      -- A. If there is no historical cha id assocaited with record, then pass the orgininal chaID as the valid cha_id; otherwise use 
      -- position_id (moh id) that has been mapped.
      if( m.cha_id_historical is null, trim( g.chaID ), m.position_id ) as cha_id,
      
      g.1_1_A_total_number_households,
      g.1_1_B_total_household_members,
                                                    
      g.1_1_C_total_zero_eleven_months_male,
      g.1_1_D_total_zero_eleven_months_female,
  
      g.1_1_E_total_one_five_years_male,
      g.1_1_F_total_one_five_years_female,
  
      g.1_1_G_total_six_fourteen_years_male,
      g.1_1_H_total_six_fourteen_years_female,
  
      g.1_1_I_total_fifteen_forty_nine_years_male,
      g.1_1_J_total_fifteen_forty_nine_years_female,
  
      g.1_1_K_total_fifty_plus_years_male,
      g.1_1_L_total_fifty_plus_years_female
      

from lastmile_upload.de_chaHouseholdRegistration as g
    -- B.
    left outer join lastmile_cha.temp_view_base_history_moh_lmh_cha_id as m on ( ( trim( g.chaID ) like m.position_id ) or 
                                                                                        ( trim( g.chaID ) like m.cha_id_historical ) )
;

drop view if exists lastmile_program.view_registration_year;

create view lastmile_program.view_registration_year as 

select
      year( trim( g.registrationDate ) )                                        as registration_year,
      trim( g.communityID )                                                     as community_id,
      g.cha_id,
      
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
  
from lastmile_program.view_registration_moh_cha_id as g
group by registration_year, community_id, g.cha_id
;


  
drop view if exists lastmile_program.view_train_moh_cha_id;

create view lastmile_program.view_train_moh_cha_id as 
  
select                                               
      -- A. If there is no historical cha id assocaited with record, then pass the orgininal chaID as the valid cha_id; otherwise use 
      -- the position_id (moh id), which has been mapped.
      if( m.cha_id_historical is null, trim( t.cha_id ), m.position_id ) as cha_id,
      t.person_id,
      module

from lastmile_program.view_train_cha_last as t
    -- B.
    left outer join lastmile_cha.temp_view_base_history_moh_lmh_cha_id as m on  (  ( trim( t.cha_id ) like m.position_id ) or 
                                                                                   ( trim( t.cha_id ) like m.cha_id_historical ) )
;


drop view if exists lastmile_program.view_train_cha_module;

create view lastmile_program.view_train_cha_module as

select

      t.cha_id    as cha_id,
      t.person_id as person_id,
      group_concat( distinct t.module order by cast( t.module as unsigned ) asc separator ', ' ) as cha_module_list

from lastmile_program.view_train_moh_cha_id as t
group by t.cha_id, t.person_id
;



drop view if exists lastmile_program.view_train_moh_chss_id;

create view lastmile_program.view_train_moh_chss_id as 

select                                               
      -- A. If there is no historical cha id assocaited with record, then pass the orgininal chssID as the valid chss_id; 
      -- otherwise use the position_id (moh id), which has been mapped.
      if( m.chss_id_historical is null, trim( t.chss_id ), m.position_id ) as chss_id,
      t.person_id,
      
      t.begin_date,
      t.end_date,
      
      t.participant_name,
      t.participant_type,
  
      t.facilitator_1,
      t.facilitator_2,
      t.facilitator_3,
      t.facilitator_4,
      
      t.county,
      t.health_district_training,
      t.gender,
      t.phone,
  
      t.m1_pre_test, 
      t.m1_practical_skills_check, 
      t.m1_post_test,   
      t.m1_overall_assessment,
      
      t.m2_pre_test, 
      t.m2_practical_skills_check, 
      t.m2_post_test,   
      t.m2_overall_assessment,
      
      t.m3_pre_test, 
      t.m3_practical_skills_check, 
      t.m3_post_test,
      t.m3_overall_assessment,
      
      t.m4_pre_test, 
      t.m4_practical_skills_check,
      t.m4_post_test,
      t.m4_overall_assessment,
  
      t.certificate_given,
      t.note,
      t.data_entry_name
      

from lastmile_program.view_train_chss_last as t
    -- B.
    left outer join lastmile_cha.view_base_history_moh_lmh_chss_id as m on  (  ( trim( t.chss_id ) like m.position_id ) or 
                                                                               ( trim( t.chss_id ) like m.chss_id_historical ) )
;


drop view if exists lastmile_program.view_train_chss_module;

create view lastmile_program.view_train_chss_module as 

select
      trim( t.chss_id )   as chss_id,
      trim( t.person_id ) as person_id,
      
      replace( 
      trim( replace( concat(  if( not ( ( t.m1_overall_assessment is null  ) or ( trim( t.m1_overall_assessment ) like '' ) ), '1', ''  ), ' ',
                              if( not ( ( t.m2_overall_assessment is null  ) or ( trim( t.m2_overall_assessment ) like '' ) ), '2', ''  ), ' ',
                              if( not ( ( t.m3_overall_assessment is null  ) or ( trim( t.m3_overall_assessment ) like '' ) ), '3', ''  ), ' ',
                              if( not ( ( t.m4_overall_assessment is null  ) or ( trim( t.m4_overall_assessment ) like '' ) ), '4', ''  ), ' '
                            ), '  ', ' ' 
                    ) 
          ), 
          ' ', ', ' ) as module
          
from lastmile_program.view_train_moh_chss_id as t
where ( not ( ( t.chss_id   is null ) or ( trim( t.chss_id )    like '' ) ) ) and 
      ( not ( ( t.person_id is null ) or ( trim( t.person_id )  like '' ) ) ) 
      
;




drop view if exists lastmile_cha.view_position_cha_geo_community_person;

create view lastmile_cha.view_position_cha_geo_community_person as

select
      -- cha position fields
      p.position_id,
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
      pr.person_id,  -- not cha_id, this is our internal id
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate,
      
      -- CHA Training completed
      m.cha_module_list                                             as module,
         
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
      po.person_id                                               as chss_person_id, -- this is chss_id
      po.first_name                                              as chss_first_name,
      po.last_name                                               as chss_last_name,
      po.birth_date                                              as chss_birth_date,
      po.gender                                                  as chss_gender,
      po.phone_number                                            as chss_phone_number,
      po.phone_number_alternate                                  as chss_phone_number_alternate,
      
      po.module                                                  as chss_module
      
from                          lastmile_cha.view_position_cha                       as p
    left outer join           lastmile_cha.view_geo_health_facility                as f  on p.health_facility_id       like f.health_facility_id
    left outer join           lastmile_cha.view_position_cha_community_list        as c  on p.position_id              like c.position_id
    left outer join           lastmile_cha.view_position_cha_registration          as g  on p.position_id              like g.position_id
    left outer join           lastmile_cha.view_position_cha_person                as pr on p.position_id              like pr.position_id
        left outer join       lastmile_cha.view_history_position_last_date         as d  on pr.position_id             like d.position_id
        left outer join       lastmile_cha.view_history_position_person_first      as rf on pr.person_id               like rf.person_id
    left outer join           lastmile_program.view_train_cha_module  as m  on ( p.position_id like m.cha_id ) and ( pr.person_id like m.person_id )
    left outer join           lastmile_cha.view_position_cha_supervisor            as ps on p.position_id              like ps.position_id
        left outer join       lastmile_cha.view_position_chss_person_geo           as po on ps.position_supervisor_id  like po.position_id
; 



drop view if exists lastmile_cha.view_base_position_cha;

create view lastmile_cha.view_base_position_cha as

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
      
      position_id                                 as cha_id,   -- position_id is now the same as cha_id
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
    
      chss_position_begin_date,
      
      chss_cha_supervision_begin_date                         as chss_supervision_begin_date,
      
      chss_position_id,
      chss_position_id                                        as chss_id,
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
      
from lastmile_cha.view_position_cha_geo_community_person
;


drop view if exists lastmile_cha.view_base_cha;

create view lastmile_cha.view_base_cha as

select *
from lastmile_cha.view_base_position_cha
where not ( ( cha is null ) or ( trim( cha ) like '' ) )
;


drop view if exists lastmile_cha.view_position_chss_person_geo;

create view lastmile_cha.view_position_chss_person_geo as

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
      
from lastmile_cha.view_position_chss_person as pr
    left outer join   lastmile_cha.view_history_position_last_date           as d    on pr.position_id         like d.position_id
    left outer join   lastmile_cha.view_history_position_person_first        as rf   on pr.person_id           like rf.person_id 
    left outer join   lastmile_cha.view_geo_health_facility                  as gf   on pr.health_facility_id  like gf.health_facility_id
    left outer join   lastmile_program.view_train_chss_module   as t    on ( pr.position_id like t.chss_id ) and ( pr.person_id like t.person_id )
;


drop view if exists lastmile_cha.view_base_position_chss;

create view lastmile_cha.view_base_position_chss as

select

      county_id,
      county,
      health_district_id,
      health_district,
      cohort,
      health_facility_id,
      health_facility,
      
      position_id,
      position_id                           as chss_id,
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
      
from lastmile_cha.view_position_chss_person_geo
;

drop view if exists lastmile_cha.view_base_chss;

create view lastmile_cha.view_base_chss as

select *
from lastmile_cha.view_base_position_chss
where not ( ( chss is null ) or ( trim( chss ) like '' ) )
;



drop view if exists lastmile_cha.view_history_person_position;

create view lastmile_cha.view_history_person_position as 

select
      trim( r.person_id )                                       as person_id,
      
      -- CHA IDs will now be reused as CHAs come and go, so make position_id the public staff_id
      -- CHSS IDs will still be unique so person_id will be their staff_id for now.
      -- Likewise, for CHWLs, their person_id will be unique and diplayed as the public staff_ld
      case p.job
          when 'CHA'  then trim( pr.position_id )
          when 'CHSS' then trim( pr.position_id )
          when 'CHWL' then trim( substring_index( trim( pr.person_id ), '|', 1 ) )
         
          -- case where person is in the person table but they have not been assigned a position yet. 
          else trim( substring_index( trim( r.person_id ), '|', 1 ) )
    
      end as staff_id,
      
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

from lastmile_cha.person as r
    left outer join lastmile_cha.position_person                 as pr on trim( r.person_id )    like  trim( pr.person_id )
        left outer join lastmile_cha.reason_left                 as l  on pr.reason_left_id      =     l.reason_left_id
        left outer join lastmile_cha.view_history_position_geo   as p  on trim( pr.position_id ) like  p.position_id
;


drop view if exists lastmile_cha.view_history_position_person;

create view lastmile_cha.view_history_position_person as 

select

      p.job,
      trim( p.position_id )                                    as position_id,
      p.position_active,
      p.position_begin_date,
      p.position_end_date,

      trim( r.person_id )                                       as person_id,
      
      -- CHA IDs will now be reused as CHAs come and go, so make position_id the public staff_id
      -- CHSS IDs will still be unique so person_id will be their staff_id for now.
      -- Likewise, for CHWLs, their person_id will be unique and diplayed as the public staff_ld
      case p.job
          when 'CHA'  then trim( pr.position_id )
          when 'CHSS' then trim( pr.position_id )
          when 'CHWL' then trim( substring_index( trim( pr.person_id ), '|', 1 ) )
         
          -- case where person is in the person table but they have not been assigned a position yet. 
          else trim( substring_index( trim( r.person_id ), '|', 1 ) )
    
      end as staff_id,
      
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

from lastmile_cha.view_history_position_geo      as p
    left outer join lastmile_cha.position_person as pr on trim( p.position_id )  like  trim( pr.position_id )
        left outer join lastmile_cha.person      as r  on trim( pr.person_id )   like  trim( r.person_id )
        left outer join lastmile_cha.reason_left as l  on pr.reason_left_id      =     l.reason_left_id 
;


drop view if exists lastmile_cha.view_history_person_geo;

create view lastmile_cha.view_history_person_geo as

select
      trim( r.person_id )                               as person_id,
      
      -- CHA IDs will now be reused as CHAs come and go, so make position_id the public staff_id
      -- CHSS IDs will still be unique so person_id will be their staff_id for now.
      -- Likewise, for CHWLs, their person_id will be unique and diplayed as the public staff_ld
      case pl.job
      
          when 'CHA'  then trim( pl.position_id )
          when 'CHSS' then trim( pl.position_id )
          when 'CHWL' then trim( substring_index( trim( r.person_id ), '|', 1 ) )
          
          -- case where person is in the person table but they have not been assigned a position yet. 
          else trim( substring_index( trim( r.person_id ), '|', 1 ) )
          
      end as staff_id,
      
      trim( concat( r.first_name, ' ', r.last_name ) )  as full_name,
      r.birth_date,
      trim( r.gender )                                  as gender,
      trim( r.phone_number )                            as phone_number,
      trim( r.phone_number_alternate )                  as phone_number_alternate,
      
      pl.job,
      rl.position_id,
      rl.begin_date                         as position_person_begin_date,
      rl.end_date                           as position_person_end_date,
      if( rl.end_date is null, 'Y', 'N' )   as position_person_active, 
      
      pl.health_facility,
      pl.health_facility_id,
      pl.cohort,
      pl.health_district,
      pl.health_district_id,
      pl.county,
      pl.county_id,
      
      pf.job                                as job_first,
      rf.position_id                        as position_id_first,
      rf.begin_date                         as position_person_begin_date_first,
      rf.end_date                           as position_person_end_date_first,
      if( rf.end_date is null, 'Y', 'N' )   as position_person_active_first 
      
from lastmile_cha.person as r
    left outer join       lastmile_cha.view_history_position_person_last     as rl on r.person_id              like rl.person_id
        left outer join   lastmile_cha.view_history_position_geo             as pl on rl.position_id           like pl.position_id
    left outer join       lastmile_cha.view_history_position_person_first    as rf on r.person_id              like rf.person_id
        left outer join   lastmile_cha.view_history_position_geo             as pf on rf.position_id           like pf.position_id
;


drop view if exists lastmile_cha.view_community_cha;

create view lastmile_cha.view_community_cha as

select
      pc.community_id,
      group_concat( pc.position_id  order by pc.position_id separator ', ' )  as position_id_list,
      count( pc.position_id )                                                 as position_count,
      group_concat( pc.person_id    order by pc.person_id   separator ', ' )  as person_id_list,
      count( pc.person_id )                                                   as person_count   
from lastmile_cha.view_position_community_cha as pc
group by pc.community_id
;


drop view if exists lastmile_cha.view_geo_community_cha_population;

create view lastmile_cha.view_geo_community_cha_population as 

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
      g.cha_id_list                 as registration_cha_id_list,
      g.registration_year_list,
      
      a.position_id_list,
      a.position_count,
      if( a.position_id_list is null, 'N', 'Y' )              as active_position,
      
      a.person_id_list,
      a.person_count,
      if( a.person_id_list is null, 'N', 'Y' )                as active_cha
      
from lastmile_cha.view_geo_community as c
    left outer join lastmile_cha.view_community_registration as g on c.community_id = g.community_id
    left outer join lastmile_cha.view_community_cha          as a on c.community_id = a.community_id
;

drop view if exists lastmile_cha.view_base_geo_community;

create view lastmile_cha.view_base_geo_community as 

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

from lastmile_cha.view_geo_community_cha_population
;

drop view if exists lastmile_cha.view_base_geo_community_remote;

create view lastmile_cha.view_base_geo_community_remote as 

select *
from lastmile_cha.view_base_geo_community
where health_facility_proximity like 'remote'
;

drop view if exists lastmile_cha.view_base_geo_community_in_program;

create view lastmile_cha.view_base_geo_community_in_program as 

select *
from lastmile_cha.view_base_geo_community
where active_position like 'Y'
;




