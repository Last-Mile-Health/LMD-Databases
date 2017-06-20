use lastmile_chwdb;

drop table if exists im_view_staff_healthFacility;

create table im_view_staff_healthFacility (
  
  country                                                     varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  country_code                                                varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  county                                                      varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  county_code                                                 varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  health_district                                             varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  health_district_code                                        varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  district                                                    varchar(255)  COLLATE utf8_bin DEFAULT NULL,
      
  -- faciltiy-level information
  health_facility                                             varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  health_facliity_type                                        varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  health_facility_address                                     varchar(255)  COLLATE utf8_bin DEFAULT NULL,
      
  position_supervisor                                         varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  position_supervisor_code                                    varchar(255)  COLLATE utf8_bin DEFAULT NULL,
      
  position_title                                              varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  position_job                                                varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  position_code                                               varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  
  -- Use originating tables column type
  position_posted_date                                        datetime  DEFAULT NULL,
  position_proposed_hiring_date                               datetime  DEFAULT NULL,
  position_proposed_end_date                                  datetime  DEFAULT NULL,
 
  position_department                                         varchar(255)  COLLATE utf8_bin DEFAULT NULL,
      
  position_proposed_salary                                    varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  position_type                                               varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  position_status                                             varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  position_hidden                                             varchar(255)  COLLATE utf8_bin DEFAULT NULL,
      
  person_id                                                   varchar(255)  COLLATE utf8_bin DEFAULT NULL,
      
  person_first_name                                           varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  person_other_name                                           varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  person_surname                                              varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  
  
  record_id                                                   varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  form                                                        varchar(255)  COLLATE utf8_bin DEFAULT NULL,   
  staffID                                                     varchar(255)  COLLATE utf8_bin DEFAULT NULL
  
  -- need to extract and display the staff ID, which is not being held in a normalized structure.
) 
DEFAULT CHARSET=utf8 
COLLATE=utf8_bin
ENGINE=FEDERATED
CONNECTION = 'mysql://ihris-manage-sit:ihris@52.35.203.122:3306/ihrismanagesitedemo/ihris_manage_view_staff_healthFacility';
