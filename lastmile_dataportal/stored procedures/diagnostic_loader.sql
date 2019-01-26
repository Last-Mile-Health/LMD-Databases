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

/*
 * 501. CHA MSR original CHA position ID total
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 501, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 501, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 501, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 501, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 501, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;

/*
 * 502. CHA MSR original CHA position ID valid

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 502, '6_16', 1, @p_month, @p_year, id_valid  
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 502, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 502, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 502, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 502, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 502, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 503. CHA MSR original CHA position ID invalid

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 503, '6_16', 1, @p_month, @p_year, id_invalid  
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 503, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 503, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 503, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 503, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 503, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 504. CHA MSR original CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 504, '6_16', 1, @p_month, @p_year, id_invalid_999  
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 504, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 504, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 504, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 504, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 504, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 505. CHA MSR original CHA position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 505, '6_16', 1, @p_month, @p_year, id_invalid_lmh_integer  
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 505, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 505, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 505, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 505, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 505, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 506. CHA MSR original CHA position ID invalid other

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 506, '6_16', 1, @p_month, @p_year, id_invalid_other  
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 506, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 506, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 506, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 506, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 506, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 507. CHA MSR repaired CHA position ID total

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 507, '6_16', 1, @p_month, @p_year, id_total  
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 507, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 507, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 507, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 507, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 507, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;



/*
 * 508. CHA MSR repaired CHA position ID valid

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 508, '6_16', 1, @p_month, @p_year, id_valid  
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 508, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 508, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 508, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 508, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 508, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;



/*
 * 509. CHA MSR repaired CHA position ID invalid

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 509, '6_16', 1, @p_month, @p_year, id_invalid
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 509, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 509, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 509, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 509, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 509, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 510. CHA MSR repaired CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 510, '6_16', 1, @p_month, @p_year, id_invalid_999  
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 510, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 510, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 510, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 510, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 510, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 511. CHA MSR repaired CHA position ID invalid LMH integer
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 511, '6_16', 1, @p_month, @p_year, id_invalid_lmh_integer  
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 511, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 511, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 511, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 511, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 511, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;



/*
 * 512. CHA MSR repaired CHA position ID invalid other
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 512, '6_16', 1, @p_month, @p_year, id_invalid_other  
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
;
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 512, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

union all

select 512, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 512, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 512, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 512, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;



/*
 * 513. CHA MSR total number of invalid CHA position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 513, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha'
) as a

union all

select 513, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'
) as a

union all

select 513, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'
) as a

union all

select 513, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
) as a
;



-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('diagnostic_loader END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
