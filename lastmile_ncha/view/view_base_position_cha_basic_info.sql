use lastmile_ncha;

/*
 *
 * This view is a hack, a workaround, for view_base_position_cha, which gives an error when you join it with
 * other views because of the arbitrary 61 join limit with MySQL  Basically, I chop off the QAO fields, except
 * for the position IDs
 *
*/

drop view if exists lastmile_ncha.view_base_position_cha_basic_info;

create view lastmile_ncha.view_base_position_cha_basic_info as
select

      -- cha position fields
      p.position_id_pk,
      p.position_id,
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
     
      ps.position_supervisor_id_pk                              as chss_position_id_pk,
      ps.position_supervisor_id                                  as chss_position_id,
      ps.position_supervisor_health_facility_id                  as chss_health_facility_id,
      ps.position_supervisor_begin_date                          as chss_position_begin_date,

      po.position_person_begin_date                              as chss_position_person_begin_date,
      po.hire_date                                               as chss_hire_date,
      po.person_id                                               as chss_person_id,
      po.person_id_lmh                                           as chss_person_id_lmh,
      po.first_name                                              as chss_first_name,
      po.last_name                                               as chss_last_name,
      po.birth_date                                              as chss_birth_date,
      po.gender                                                  as chss_gender,
      po.phone_number                                            as chss_phone_number,
      po.phone_number_alternate                                  as chss_phone_number_alternate,
      
      po.module                                                  as chss_module,
      
      -- ---------------------------------------------------------------------------------------------------
      -- Beginning of QAO info
      -- ---------------------------------------------------------------------------------------------------
      
      -- debug code
      -- ps1.position_supervisor_id as qao_id,
      -- poq.*,
      
      ps1.position_supervision_begin_date                          as qao_position_supervision_begin_date,  
 
      -- All the dates, except for position_person.[ begin, end ], are position-to-position oriented.
      -- position_supervision_beginDate only tells us when a chss position began supervising a cha position,
      -- not when a specific chss starting supervising a specific chp.
      
      -- So the actual supervision date is the later of chss and cha position_person begin dates, assuming 
      -- the chss and/or person begin dates are not null.  These would be the cases of either or both positions
      -- being unfilled.
/*  
      if( ( pr1.position_person_begin_date is null ) or ( poq.position_person_begin_date is null ), 
            null,  
            if( pr1.position_person_begin_date > poq.position_person_begin_date, 
                pr1.position_person_begin_date, 
                poq.position_person_begin_date  ) 
      )                                                           as qao_chss_supervision_begin_date,
*/ 
      ps1.position_supervisor_id_pk                               as qao_position_id_pk,
      ps1.position_supervisor_id                                  as qao_position_id,
      ps1.position_supervisor_begin_date                          as qao_position_begin_date
    
/*    
      poq.position_person_begin_date                              as qao_position_person_begin_date,
      poq.hire_date                                               as qao_hire_date,
      poq.person_id                                               as qao_person_id,
      poq.person_id_lmh                                           as qao_person_id_lmh,
      poq.first_name                                              as qao_first_name,
      poq.last_name                                               as qao_last_name,
      poq.birth_date                                              as qao_birth_date,
      poq.gender                                                  as qao_gender,
      poq.phone_number                                            as qao_phone_number,
      poq.phone_number_alternate                                  as qao_phone_number_alternate
*/
from lastmile_ncha.view_position_cha as p

    left outer join           lastmile_ncha.view_geo_health_facility            as f    on p.health_facility_id         like f.health_facility_id
    left outer join           lastmile_ncha.view_position_cha_community_list    as c    on p.position_id                like c.position_id
    left outer join           lastmile_ncha.view_position_cha_registration      as g    on p.position_id                like g.position_id
    
    left outer join           lastmile_ncha.view_position_cha_person            as pr   on p.position_id_pk             like pr.position_id_pk
        left outer join       lastmile_ncha.view_history_position_last_date     as d    on pr.position_id_pk = d.position_id_pk
        left outer join       lastmile_ncha.view_history_position_person_first  as rf   on pr.person_id                 like rf.person_id
        left outer join       lastmile_program.view_train_cha_module            as m    on pr.person_id = m.person_id
    
    left outer join           lastmile_ncha.view_position_cha_supervisor        as ps   on p.position_id_pk = ps.position_id_pk

        left outer join       lastmile_ncha.view_position_chss_person           as pr1  on ps.position_supervisor_id_pk   like pr1.position_id_pk
        left outer join       lastmile_ncha.view_position_chss_supervisor       as ps1  on ps.position_supervisor_id_pk   like ps1.position_id_pk
        left outer join       lastmile_ncha.view_position_chss_person_info      as po   on ps.position_supervisor_id_pk   like po.position_id_pk

            -- left outer join   lastmile_ncha.view_position_qao_person_info       as poq  on ps1.position_supervisor_id_pk  like poq.position_id_pk  
;