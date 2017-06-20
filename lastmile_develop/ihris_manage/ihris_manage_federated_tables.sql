-- Note: Federated must be enabled in the local MySQL instance for federation to work.
-- On Linux, add the keyword federated to the my.cnf file.  For Windows, add it to the my.ini file

-- When you go production create tyour own database for these remote database links
-- drop database if exists ihris_manage;
-- create database ihris_manage;
use lastmile_chwdb;
-- use ihris_manage;

drop table if exists    im_hippo_person;
drop table if exists    im_hippo_person_position;
drop table if exists    im_hippo_position;


create table im_hippo_person (

  id                varchar(255)  COLLATE utf8_bin NOT NULL,
  parent            varchar(255)  COLLATE utf8_bin DEFAULT '|',
  last_modified     datetime      DEFAULT '1900-01-01 00:00:00',
  created           datetime      DEFAULT '0000-00-00 00:00:00',
  nationality       varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  residence         varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  surname           varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  firstname         varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  othername         varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  csd_uuid          varchar(255)  COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY       ( id ),
  KEY               parent            ( parent        ),
  KEY               last_modified     ( last_modified ),
  KEY               nationality       ( nationality   ),
  KEY               residence         ( residence     )
) 
DEFAULT CHARSET=utf8 
COLLATE=utf8_bin
ENGINE=FEDERATED
CONNECTION = 'mysql://ihris-manage-sit:ihris@52.35.203.122:3306/ihrismanagesitedemo/hippo_person';

CREATE TABLE `im_hippo_person_position` (
  `id` varchar(255) COLLATE utf8_bin NOT NULL,
  `parent` varchar(255) COLLATE utf8_bin DEFAULT '|',
  `last_modified` datetime DEFAULT '1900-01-01 00:00:00',
  `created` datetime DEFAULT '0000-00-00 00:00:00',
  `end_date` datetime DEFAULT NULL,
  `position` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `reason` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent` (`parent`),
  KEY `last_modified` (`last_modified`),
  KEY `position` (`position`),
  KEY `reason` (`reason`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_bin
ENGINE=FEDERATED
CONNECTION = 'mysql://ihris-manage-sit:ihris@52.35.203.122:3306/ihrismanagesitedemo/hippo_person_position'
;


CREATE TABLE `im_hippo_position` (
  `id` varchar(255) COLLATE utf8_bin NOT NULL,
  `parent` varchar(255) COLLATE utf8_bin DEFAULT '|',
  `last_modified` datetime DEFAULT '1900-01-01 00:00:00',
  `created` datetime DEFAULT '0000-00-00 00:00:00',
  `i2ce_hidden` int(11) DEFAULT NULL,
  `remap` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `code` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `comments` text COLLATE utf8_bin,
  `department` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `facility` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `interview_comments` text COLLATE utf8_bin,
  `job` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `posted_date` datetime DEFAULT NULL,
  `pos_type` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `proposed_end_date` datetime DEFAULT NULL,
  `proposed_hiring_date` datetime DEFAULT NULL,
  `proposed_salary` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `source` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `supervisor` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent` (`parent`),
  KEY `last_modified` (`last_modified`),
  KEY `remap` (`remap`),
  KEY `department` (`department`),
  KEY `facility` (`facility`),
  KEY `job` (`job`),
  KEY `pos_type` (`pos_type`),
  KEY `proposed_salary` (`proposed_salary`),
  KEY `source` (`source`),
  KEY `status` (`status`),
  KEY `supervisor` (`supervisor`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_bin
ENGINE=FEDERATED
CONNECTION = 'mysql://ihris-manage-sit:ihris@52.35.203.122:3306/ihrismanagesitedemo/hippo_position'
;

-- drop table if exists s;
-- drop table if exists im_s;

-- create table s (
--    id int( 10 ) not null auto_increment,
--    primary key ( id )
-- )
-- ;

-- insert into s ( id ) values ( 1 );
-- insert into s ( id ) values ( 2 );

-- create table im_s (
--    id int( 10 ) not null auto_increment,
--    primary key ( id )
-- )
-- ENGINE=FEDERATED
-- CONNECTION='mysql://lastmile_admin:LastMile14@104.238.125.195:3306/ihris_manage/s'
-- CONNECTION='mysql://lastmile_admin:LastMile14@104.238.125.195:3306/ihris_manage/s'
;
