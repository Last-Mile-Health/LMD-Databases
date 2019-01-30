USE `lastmile_dataportal`;
DROP procedure IF EXISTS `diagnostic_loader_materialize_view`;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `diagnostic_loader_materialize_view` ()
BEGIN


-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) VALUES ('diagnostic_loader_materialize_view', 'none', NOW(), @errorMessage);

END;


-- Log procedure call
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('diagnostic_loader_materialize_view', 'none', NOW());

-- Create "materialized" views to improve performance

drop table if exists lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type;
drop table if exists lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type;

drop table if exists lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type;
drop table if exists lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type;

create table lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type as
select * from lastmile_report.view_diagnostic_de_id_invalid_original_total_table_type;

create table lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type as
select * from lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type;

create table lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type as
select * from lastmile_report.view_diagnostic_odk_id_invalid_original_total_table_type;

create table lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type as
select * from lastmile_report.view_diagnostic_odk_id_invalid_repair_total_table_type;

END$$

DELIMITER ;
