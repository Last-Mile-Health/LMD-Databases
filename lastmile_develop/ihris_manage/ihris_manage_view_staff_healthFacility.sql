use ihrismanagesitedemo;

drop view if exists ihris_manage_view_staff_healthFacility; 

create view ihris_manage_view_staff_healthFacility as

select 
      c.name                      as country,
      c.code                      as country_code,
      r.name                      as county,
      r.code                      as county_code,
      d.name                      as health_district,
      d.code                      as health_district_code,
      y.name                      as district,
      
      -- faciltiy-level information
      f.name                      as health_facility,
      ft.name                     as health_facliity_type,
      fc.address                  as health_facility_address,
      
      p2.title                    as position_supervisor,
      p2.code                     as position_supervisor_code,
      
      p.title                     as position_title,
      j.title                     as position_job,
      p.code                      as position_code,
                           
      p.posted_date               as position_posted_date,
      p.proposed_hiring_date      as position_proposed_hiring_date,
      p.proposed_end_date         as position_proposed_end_date,

      m.name                      as position_department,
      
      p.proposed_salary           as position_proposed_salary,
      pt.name                     as position_type,
      s.name                      as position_status,
      p.i2ce_hidden               as position_hidden,
      
      pp.parent                   as person_id,
      
      pr.firstname                as person_first_name,
      pr.othername                as person_other_name,
      pr.surname                  as person_surname,
      
      rc.id                       as record_id,
      rc.form                     as form,
      
      si.staffID                  as staffID

from hippo_country                                      as c
  left outer join hippo_region                          as r    on c.id = r.country
    left outer join hippo_district                      as d    on r.id = d.region
      left outer join hippo_county                      as y    on d.id = y.district
        left outer join hippo_facility                  as f    on y.id = f.location
          left outer join hippo_facility_type           as ft   on f.facility_type = ft.id
          left outer join hippo_facility_contact        as fc   on f.id           = fc.parent
            left outer join hippo_position              as p    on f.id           = p.facility
            left outer join hippo_position_type         as pt   on p.pos_type     = pt.id
            left outer join hippo_job                   as j    on p.job          = j.id
            left outer join hippo_position              as p2   on p.supervisor   = p2.id
            left outer join hippo_department            as m    on p.department   = m.id
            left outer join hippo_position_status       as s    on p.status       = s.id
            
            left outer join hippo_person_position       as pp   on p.id           = pp.`position`
              left outer join hippo_person              as pr   on pp.parent      = pr.id
     
  -- So what happens when there is no id assigned to person?  There should be 44 records, when I added "fm.name like person_id" we
  -- cropped off five.  Need to probably do something other than like person_id to accomodate persons assigned to positions
  -- who have not been assigned ids yet.
  
                left outer join record as rc on ( trim( substring_index( pr.id, '|', 1   ) ) like trim( rc.parent_form ) )  and 
                                                ( trim( substring_index( pr.id, '|', -1  ) ) like trim( rc.parent_id   ) )
                  left outer join form as fm on rc.form = fm.id
                  left outer join ihris_manage_view_staffID as si on rc.id = si.record

where c.id like 'country|LR' and fm.name like 'person_id'
-- may need to condition on hippo_person_position.end_date to be sure the association is still valid
-- may need to condition on hippo_position.status to be sure the status is not Discontinued.
;
-- select id, surname from hippo_person;