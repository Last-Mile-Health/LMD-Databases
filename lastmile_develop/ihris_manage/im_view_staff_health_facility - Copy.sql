use lastmile_chwdb;

drop table if exists im_view_hippo_person;
drop table if exists im_view_staff_health_facility;

create table im_view_staff_health_facility (

  id                varchar(255)  COLLATE utf8_bin NOT NULL,
  surname           varchar(255)  COLLATE utf8_bin DEFAULT NULL
) 
DEFAULT CHARSET=utf8 
COLLATE=utf8_bin
ENGINE=FEDERATED
CONNECTION = 'mysql://ihris-manage-sit:ihris@ec2-52-89-50-207.us-west-2.compute.amazonaws.com:3306/ihrismanagesitedemo/view_hippo_person';
