use lastmile_cha;

drop view if exists view_base_position_cha_basic_info;

create view view_base_position_cha_basic_info as

select
      -- cha position fields
      p.position_id,
      p.position_id_lmh,
      p.position_begin_date,
      
      -- cha health facility and geographical info
      p.health_facility_id,
      f.health_facility,
      
      -- f.cohort, stop pulling cohort from health facility and pull from position
      p.cohort,
      
      f.health_district_id,
      f.health_district,
      f.county_id,
      f.county,
      
      -- list of communityIDs, communities, and dates assocaited with the CHA position
      c.begin_date                        as communtiy_begin_date,
      c.begin_date_list                   as communtiy_begin_date_list,  
      c.community_id_list,
      c.community_list,
      

      if( pr.position_person_begin_date is null, 'N', 'Y' )                                         as position_filled,
      if( pr.position_person_begin_date is null, d.end_date_last, pr.position_person_begin_date )   as position_filled_last_date,
      
      -- cha person fields
      pr.position_person_begin_date,
      rf.begin_date                       as hire_date,
      pr.person_id,
      pr.first_name,
      pr.last_name,
      pr.birth_date,
      pr.gender,
      pr.phone_number,
      pr.phone_number_alternate,
   
      -- ---------------------------------------------------------------------------------------------------
      -- Beginning of CHSS info
      -- ---------------------------------------------------------------------------------------------------
         
      ps.position_supervision_begin_date  as chss_position_supervision_begin_date,  
     
      pr1.position_id                     as chss_position_id,
      pr1.position_begin_date             as chss_position_begin_date,
      pr1.health_facility_id              as chss_health_facility_id,
      pr1.health_facility                 as chss_health_facility,
      
      pr1.position_person_begin_date      as chss_position_person_begin_date,
      pr1.person_id                       as chss_person_id,
      pr1.person_id_lmh                   as chss_person_id_lmh,
      
      pr1.first_name                      as chss_first_name,
      pr1.last_name                       as chss_last_name,
      pr1.birth_date                      as chss_birth_date,
      pr1.gender                          as chss_gender,
      pr1.phone_number                    as chss_phone_number,
      pr1.phone_number_alternate          as chss_phone_number_alternate,
      
      -- ---------------------------------------------------------------------------------------------------
      -- Beginning of QAO info
      -- ---------------------------------------------------------------------------------------------------
         
      ps1.position_supervision_begin_date as qao_position_supervision_begin_date,  
      
      poq.position_person_begin_date      as qao_position_person_begin_date,
      poq.hire_date                       as qao_hire_date,
      poq.person_id                       as qao_person_id,
      poq.person_id_lmh                   as qao_person_id_lmh,
      poq.first_name                      as qao_first_name,
      poq.last_name                       as qao_last_name,
      poq.birth_date                      as qao_birth_date,
      poq.gender                          as qao_gender,
      poq.phone_number                    as qao_phone_number,
      poq.phone_number_alternate          as qao_phone_number_alternate
       
from view_position_cha as p

    left outer join           view_geo_health_facility                  as f    on p.health_facility_id       like f.health_facility_id
    left outer join           view_position_cha_community_list          as c    on p.position_id              like c.position_id   
    left outer join           view_position_cha_person                  as pr   on p.position_id              like pr.position_id
        
        left outer join       view_history_position_last_date           as d    on pr.position_id             like d.position_id
        left outer join       view_history_position_person_first        as rf   on pr.person_id               like rf.person_id
   
    left outer join           view_position_cha_supervisor              as ps   on p.position_id              like ps.position_id
        left outer join       view_position_chss_person                 as pr1  on ps.position_supervisor_id  like pr1.position_id
               
            left outer join           view_position_chss_supervisor     as ps1  on ps.position_supervisor_id  like ps1.position_id
                left outer join           view_position_qao_person_geo  as poq  on ps1.position_supervisor_id like poq.position_id   
;