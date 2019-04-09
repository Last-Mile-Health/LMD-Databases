use lastmile_datamart;

drop table if exists dimension_position;

create table dimension_position (

  -- CHA position
 
  -- date_key and position id are the unique composite key
  date_key                              int( 10 ) unsigned      not null,
  position_id                           varchar( 50 )           not null,
 
  position_begin_date                   date                    not null,
  position_end_date                     date                        null,
 
  -- CHA position geographical data         
  county                                varchar( 50 )           not null,
  health_district                       varchar( 50 )           not null,
  cohort                                varchar( 50 )               null,
  health_facility_id                    varchar( 10 )           not null,
  health_facility                       varchar( 50 )           not null,
        
  -- CHA person info
  person_id                             int(10) unsigned            null,
  full_name                             varchar( 50 )               null,
  birth_date                            date                        null,
  gender                                enum('M','F')       default null,
  phone_number                          varchar( 50 )               null,
  phone_number_alternate                varchar( 50 )               null, 
  position_person_begin_date            date                        null,
  position_person_end_date              date                        null,
  reason_left                           varchar( 255 )              null,
  reason_left_description               varchar( 255 )              null,
 
-- CHSS 
  chss_position_id                      varchar( 50 )               null,
  
  chss_position_begin_date              date                        null,
  chss_position_end_date                date                        null,
  chss_person_id                        int(10) unsigned            null,
  chss_full_name                        varchar( 50 )               null,
  chss_birth_date                       date                        null,
  chss_gender                           enum('M','F')       default null,
  chss_phone_number                     varchar( 50 )               null,
  chss_phone_number_alternate           varchar( 50 )               null, 
  chss_position_person_begin_date       date                        null,
  chss_position_person_end_date         date                        null,
  chss_reason_left                      varchar( 255 )              null,
  chss_reason_left_description          varchar( 255 )              null,
  
  -- QAO
  qao_position_id                       varchar( 50 )               null,
  qao_position_supervisor_begin_date    date                        null,
  qao_position_supervisor_end_date      date                        null,
  qao_person_id                         int( 10 ) unsigned          null,
  qao_full_name                         varchar( 50 )               null,
  
  qao_birth_date                        date                        null,
  qao_gender                            enum('M','F')       default null,
  qao_phone_number                      varchar( 50 )               null,
  qao_phone_number_alternate            varchar( 50 )               null, 
  qao_reason_left                       varchar( 255 )              null,
  qao_reason_left_description           varchar( 255 )              null,

  qao_position_begin_date               date                        null,
  qao_position_end_date                 date                        null,
  qao_position_person_begin_date        date                        null,
  qao_position_person_end_date          date                        null,

  meta_insert_date_time                 datetime                    null,
 
  primary key ( date_key, position_id )

) engine = InnoDB default charset = utf8;

alter table lastmile_datamart.dimension_position add index index_dimension_chss_position_id_begin_end_date_key  ( date_key, chss_position_id );
alter table lastmile_datamart.dimension_position add index index_dimension_qao_position_id_begin_end_date_key   ( date_key, qao_position_id );

-- alter table lastmile_datamart.dimension_position add index index_dimension_date_key   ( date_key );

