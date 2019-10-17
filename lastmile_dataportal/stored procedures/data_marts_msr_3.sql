USE `lastmile_dataportal`;
DROP procedure IF EXISTS `data_mart_msr_3`;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `data_mart_msr_3` ()
BEGIN

-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) 
  VALUES ('data_mart_msr_3', 'none', NOW(), @errorMessage);

END;

-- Log procedure call
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) 
VALUES ('BEGIN: data_mart_msr_3', 'none', NOW());

-- Creates temporary tables from views, all prefixed with mart_* and stored in lastmile_report
-- Called daily by evt_dataMartTables. Daily updates done because some reports look directly at these tables
-- The dataPortalValues procedure works mainly off of the data marts created here

DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_chss;
CREATE TABLE lastmile_report.mart_view_base_msr_chss as 
SELECT * FROM lastmile_report.view_base_msr_chss;

INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) 
VALUES ('END: data_mart_msr_3', 'none', NOW());


END$$

DELIMITER ;
