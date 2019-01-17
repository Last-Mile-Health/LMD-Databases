use lastmile_dataportal;

drop procedure if exists diagnostic_loader;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `diagnostic_loader`(IN p_month INT, IN p_year INT)
BEGIN


-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) VALUES ('diagnostic_loader', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW(), @errorMessage);

END;


-- Log procedure call (START)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('diagnostic_loader START', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());



-- ------------------ --
-- Set date variables --
-- ------------------ --


-- Set @variables based on parameters (always use @variables below to avoid ambiguity)
SET @p_month := p_month;
SET @p_year := p_year;


-- Set @variables for dates
SET @p_date := DATE(CONCAT(@p_year,'-',@p_month,'-01'));
SET @p_monthMinus1 := MONTH(DATE_ADD(@p_date, INTERVAL -1 MONTH));
SET @p_monthMinus2 := MONTH(DATE_ADD(@p_date, INTERVAL -2 MONTH));
SET @p_monthPlus1 := MONTH(DATE_ADD(@p_date, INTERVAL 1 MONTH));
SET @p_yearMinus1 := YEAR(DATE_ADD(@p_date, INTERVAL -1 MONTH));
SET @p_yearMinus2 := YEAR(DATE_ADD(@p_date, INTERVAL -2 MONTH));
SET @p_yearPlus1 := YEAR(DATE_ADD(@p_date, INTERVAL 1 MONTH));
SET @p_datePlus1 := DATE(CONCAT(@p_yearPlus1,'-',@p_monthPlus1,'-01'));
SET @isEndOfQuarter := IF(@p_month IN (3,6,9,12),1,0);
#SET @isCurrentMonth := IF(@p_month=MONTH(DATE_ADD(NOW(), INTERVAL -1 MONTH)) AND @p_year=YEAR(DATE_ADD(NOW(), INTERVAL -1 MONTH)),1,0);

/*
 *
 * Set Global variables
 *
*/

-- The estimated ratio of CHAs to population served.
set @cha_population_ratio = 235;
-- set @cha_population_ratio = 300;



-- ------------ --
-- Misc cleanup --
-- ------------ --



-- --------------- --
-- Set scale table --
-- --------------- --

-- Delete blank values from tbl_values
-- delete from  lastmile_dataportal.tbl_values where trim( value ) like '';


-- table_name: de_cha_monthly_service_report; id_type: cha; ID: cha_id_original

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 501, '6_16', 1, @p_month, @p_year, id_total  
from lastmile_report.view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;


replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 502, '6_16', 1, @p_month, @p_year, id_valid  
from lastmile_report.view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 503, '6_16', 1, @p_month, @p_year, id_invalid_999  
from lastmile_report.view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 504, '6_16', 1, @p_month, @p_year, id_invalid_lmh_integer  
from lastmile_report.view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 505, '6_16', 1, @p_month, @p_year, id_invalid_other  
from lastmile_report.view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;


-- table_name: de_cha_monthly_service_report; id_type: cha; ID: cha_id

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 506, '6_16', 1, @p_month, @p_year, id_total  
from lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;


replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 507, '6_16', 1, @p_month, @p_year, id_valid  
from lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 508, '6_16', 1, @p_month, @p_year, id_invalid_999  
from lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 509, '6_16', 1, @p_month, @p_year, id_invalid_lmh_integer  
from lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 510, '6_16', 1, @p_month, @p_year, id_invalid_other  
from lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;



-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('diagnostic_loader END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
