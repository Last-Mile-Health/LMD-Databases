USE `lastmile_dataportal`;
DROP procedure IF EXISTS data_mart_other;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `data_mart_other` ()
BEGIN

-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) 
  VALUES ('data_mart_other', 'none', NOW(), @errorMessage);

END;


-- Log procedure call
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) 
VALUES ('BEGIN: data_mart_other', 'none', NOW());


-- Creates temporary tables from views, all prefixed with mart_* and stored in lastmile_report
-- Called daily by evt_dataMartTables. Daily updates done because some reports look directly at these tables
-- The dataPortalValues procedure works mainly off of the data marts created here

drop table if exists lastmile_report.mart_de_integrated_supervision_tool_community;
create table lastmile_report.mart_de_integrated_supervision_tool_community as 
select * from lastmile_liberiamohdata.federated_de_integrated_supervision_tool_community;

drop table if exists lastmile_report.mart_de_integrated_supervision_tool_community_spot_check;
create table lastmile_report.mart_de_integrated_supervision_tool_community_spot_check as 
select * from lastmile_liberiamohdata.federated_de_integrated_supervision_tool_community_spot_check;

drop table if exists lastmile_report.mart_de_integrated_supervision_tool_facility;
create table lastmile_report.mart_de_integrated_supervision_tool_facility as 
select * from lastmile_liberiamohdata.federated_de_integrated_supervision_tool_facility;

drop table if exists lastmile_report.mart_de_integrated_supervision_tool_facility_spot_check;
create table lastmile_report.mart_de_integrated_supervision_tool_facility_spot_check as 
select * from lastmile_liberiamohdata.federated_de_integrated_supervision_tool_facility_spot_check;

drop table if exists lastmile_report.mart_view_base_history_person;
create table lastmile_report.mart_view_base_history_person as 
select * from lastmile_ncha.view_base_history_person;

drop table if exists lastmile_report.mart_view_base_history_person_position;
create table lastmile_report.mart_view_base_history_person_position as 
select * from lastmile_ncha.view_base_history_person_position;

drop table if exists lastmile_report.mart_view_history_position_geo;
create table lastmile_report.mart_view_history_position_geo as 
select * from lastmile_ncha.view_history_position_geo;

drop table if exists lastmile_report.mart_view_base_history_position;
create table lastmile_report.mart_view_base_history_position as 
select * from lastmile_ncha.view_base_history_position;

drop table if exists lastmile_report.mart_view_base_position_cha;
create table lastmile_report.mart_view_base_position_cha as
select * from lastmile_ncha.view_base_position_cha;

drop table if exists lastmile_report.mart_view_history_position_person;
create table lastmile_report.mart_view_history_position_person as
select * from lastmile_ncha.view_history_position_person;

drop table if exists lastmile_report.mart_view_history_position_person_aggregate;
create table lastmile_report.mart_view_history_position_person_aggregate as
select  position_id, 
        group_concat( distinct full_name  order by position_person_begin_date desc separator ', ' ) as full_name, 
        group_concat( distinct job        order by position_person_begin_date desc separator ', ' ) as job 
from lastmile_ncha.view_history_position_person group by position_id;


drop table if exists lastmile_report.mart_view_base_position_chss;
create table lastmile_report.mart_view_base_position_chss as
select * from lastmile_ncha.view_base_position_chss;

drop table if exists lastmile_report.mart_view_base_restock_cha;
create table lastmile_report.mart_view_base_restock_cha as 
select * from lastmile_report.view_base_restock_cha;

drop table if exists lastmile_report.mart_view_base_restock_chss;
create table lastmile_report.mart_view_base_restock_chss as 
select * from lastmile_report.view_base_restock_chss;

drop table if exists lastmile_report.mart_view_base_odk_supervision;
create table lastmile_report.mart_view_base_odk_supervision as 
select * from lastmile_report.view_base_odk_supervision;

drop table if exists lastmile_report.mart_view_base_ifi;
create table lastmile_report.mart_view_base_ifi as 
select * from lastmile_report.view_base_ifi;

drop table if exists lastmile_report.mart_view_kobo_ifi;
create table lastmile_report.mart_view_kobo_ifi as 
select * from lastmile_report.view_kobo_ifi;

drop table if exists lastmile_report.mart_view_odk_sickchild;
create table lastmile_report.mart_view_odk_sickchild as 
select * from lastmile_report.view_odk_sickchild;


INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) 
VALUES ('END: data_mart_other', 'none', NOW());


END$$

DELIMITER ;
