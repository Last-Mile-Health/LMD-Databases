use lastmile_dataportal;

drop procedure if exists diagnostic_load_month;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `diagnostic_load_month`(IN p_month INT, IN p_year INT)
BEGIN


-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) VALUES ('diagnostic_load_month', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW(), @errorMessage);

END;


-- Log procedure call (START)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('diagnostic_load_month START', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());



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

-- ------------ --
-- Misc cleanup --
-- ------------ --

-- --------------- --
-- Set scale table --
-- --------------- --

-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: Data Entry CHA MSR CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 
-- 501. CHA MSR original CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 502. CHA MSR original CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 503. CHA MSR original CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 504. CHA MSR original CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 505. CHA MSR original CHA position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 506. CHA MSR original CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 507. CHA MSR repaired CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 508. CHA MSR repaired CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 509. CHA MSR repaired CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 510. CHA MSR repaired CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 511. CHA MSR repaired CHA position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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


-- 512. CHA MSR repaired CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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

-- --------------------------------------------------------------------------------------------------------------------
--                                            End: Data Entry CHA MSR CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 

-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: Data Entry CHA MSR CHSS ID
-- --------------------------------------------------------------------------------------------------------------------
 
-- 721. CHA MSR original CHSS position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 721, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 721, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 721, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 721, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 721, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 722. CHA MSR original CHSS position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 722, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 722, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 722, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 722, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 722, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 723. CHA MSR original CHSS position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 723, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 723, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 723, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 723, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 723, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 724. CHA MSR original CHSS position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 724, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 724, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 724, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 724, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 724, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 725. CHA MSR original CHSS position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 725, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 725, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 725, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 725, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 725, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 726. CHA MSR original CHSS position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 726, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 726, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 726, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 726, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 726, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 727. CHA MSR repaired CHSS position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 727, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 727, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 727, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 727, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 727, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 728. CHA MSR repaired CHSS position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 728, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 728, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 728, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 728, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 728, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 729. CHA MSR repaired CHSS position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 729, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 729, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 729, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 729, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 729, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 730. CHA MSR repaired CHSS position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 730, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 730, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 730, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 730, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 730, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 731. CHA MSR repaired CHSS position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 731, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 731, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 731, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 731, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 731, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 732. CHA MSR repaired CHSS position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 732, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

union all

select 732, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 732, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 732, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 732, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


/*
 * 733. CHA MSR total number of invalid CHSS position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 733, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss'
) as a

union all

select 733, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'
) as a

union all

select 733, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'
) as a

union all

select 733, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_cha_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
) as a
;



-- --------------------------------------------------------------------------------------------------------------------
--                                            End: Data Entry CHA MSR CHSS ID
-- --------------------------------------------------------------------------------------------------------------------
 


-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: Data Entry CHSS MSR CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 
-- 521. CHSS MSR original CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 521, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 521, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 521, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 521, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 521, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 522. CHSS MSR original CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 522, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 522, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 522, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 522, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 522, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 523. CHSS MSR original CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 523, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 523, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 523, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 523, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 523, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 524. CHSS MSR original CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 524, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 524, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 524, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 524, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 524, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 525. CHSS MSR original CHA position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 525, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 525, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 525, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 525, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 525, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 526. CHSS MSR original CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 526, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 526, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 526, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 526, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 526, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 527. CHSS MSR repaired CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 527, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 527, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 527, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 527, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 527, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 528. CHSS MSR repaired CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 528, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 528, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 528, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 528, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 528, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 529. CHSS MSR repaired CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 529, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 529, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 529, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 529, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 529, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 530. CHSS MSR repaired CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 530, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 530, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 530, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 530, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 530, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 531. CHSS MSR repaired CHA position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 531, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 531, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 531, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 531, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 531, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


-- 532. CHSS MSR repaired CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 532, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

union all

select 532, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 532, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 532, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

union all

select 532, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 533. CHSS MSR total number of invalid CHA position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 533, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha'
) as a

union all

select 533, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Grand%Gedeh%'
) as a

union all

select 533, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Rivercess%'
) as a

union all

select 533, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'cha' and county like '%Unknown%'
) as a
;

-- --------------------------------------------------------------------------------------------------------------------
--                                            End: Data Entry CHSS MSR CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 

-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: Data Entry CHSS MSR CHSS ID
-- --------------------------------------------------------------------------------------------------------------------
 
-- 735. CHSS MSR original CHSS position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 735, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 735, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 735, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 735, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 735, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 736. CHSS MSR original CHSS position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 736, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 736, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 736, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 736, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 736, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 737. CHSS MSR original CHSS position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 737, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 737, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 737, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 737, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 737, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 738. CHSS MSR original CHSS position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 738, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 738, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 738, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 738, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 738, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 739. CHSS MSR original CHSS position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 739, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 739, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 739, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 739, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 739, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 740. CHSS MSR original CHSS position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 740, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 740, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 740, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 740, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 740, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 741. CHSS MSR repaired CHSS position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 741, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 741, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 741, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 741, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 741, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 742. CHSS MSR repaired CHSS position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 742, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 742, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 742, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 742, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 742, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 743. CHSS MSR repaired CHSS position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 743, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 743, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 743, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 743, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 743, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 744. CHSS MSR repaired CHSS position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 744, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 744, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 744, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 744, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 744, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 745. CHSS MSR repaired CHSS position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 745, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 745, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 745, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 745, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 745, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


-- 746. CHSS MSR repaired CHSS position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 746, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

union all

select 746, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 746, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 746, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

union all

select 746, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
;


/*
 * 747. CHSS MSR total number of invalid CHSS position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 747, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss'
) as a

union all

select 747, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Grand%Gedeh%'
) as a

union all

select 747, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Rivercess%'
) as a

union all

select 747, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_de_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_de_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'de_chss_monthly_service_report' and id_type like 'chss' and county like '%Unknown%'
) as a
;


-- --------------------------------------------------------------------------------------------------------------------
--                                            End: Data Entry CHSS MSR CHSS ID
-- --------------------------------------------------------------------------------------------------------------------
 



-- 601. ODK original CHA position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 601, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 602. ODK original CHA position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 602, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 603. ODK original CHA position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 603, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 604. ODK original CHA position ID invalid 999
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 604, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 605. ODK original CHA position ID invalid LMH integer 
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 605, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 606. ODK original CHA position ID invalid other
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 606, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';


-- 607. ODK repaired CHA position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 607, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 608. ODK repaired CHA position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 608, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 609. ODK repaired CHA position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 609, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 610. ODK repaired CHA position ID invalid 999
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 610, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 611. ODK repaired CHA position ID invalid LMH integer 
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 611, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

-- 612. ODK repaired CHA position ID invalid other
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 612, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'cha';

/*
 * 613. Total number of invalid CHA position IDs repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 613, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'
) as a;



/*
 * 614. Total number of invalid 999 CHA position IDs repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 614, '6_16', 1, @p_month, @p_year, sum( a.id_invalid_999 ) as number_id_repaired
from (

      select sum( id_invalid_999 ) as id_invalid_999  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'
      
      union all
      
      select sum( 0 - id_invalid_999 ) as id_invalid_999
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'

) as a;

/*
 * 615. Total number of invalid LMH Integer CHA position IDs repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 615, '6_16', 1, @p_month, @p_year, sum( a.id_invalid_lmh_integer ) as number_id_repaired
from (

      select sum( id_invalid_lmh_integer ) as id_invalid_lmh_integer  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'
      
      union all
      
      select sum( 0 - id_invalid_lmh_integer ) as id_invalid_lmh_integer
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'

) as a;

/*
 * 616. Total number of invalid CHA position IDs other than 999 or LMH Integer repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 616, '6_16', 1, @p_month, @p_year, sum( a.id_invalid_other ) as number_id_repaired
from (

      select sum( id_invalid_other ) as id_invalid_other  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'

      union all
      
      select sum( 0 - id_invalid_other ) as id_invalid_other
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'cha'

) as a;


-- 630. ODK Routine Visit repaired CHA position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 630, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_routineVisit' and id_type like 'cha';

-- 631. ODK Routine Visit repaired CHA position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 631, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_routineVisit' and id_type like 'cha';

-- 632. ODK Routine Visit repaired CHA position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 632, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_routineVisit' and id_type like 'cha';

-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: ODK Sick Child CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 

-- 680. ODK Sick Child original CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 680, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 680, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 680, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 680, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 680, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 681. ODK Sick Child original CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 681, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 681, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 681, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 681, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 681, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 682. ODK Sick Child original CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 682, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 682, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 682, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 682, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 682, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 683. ODK Sick Child original CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 683, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 683, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 683, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 683, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 683, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 684. ODK Sick Child original CHA position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 684, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 684, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 684, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 684, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 684, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 685. ODK Sick Child original CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 685, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 685, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 685, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 685, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 685, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 640. ODK Sick Child repaired CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 640, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 640, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 640, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 640, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 640, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 641. ODK Sick Child repaired CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 641, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 641, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 641, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 641, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 641, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 642. ODK Sick Child repaired CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 642, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 642, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 642, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 642, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 642, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 686. ODK Sick Child repaired CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 686, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 686, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 686, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 686, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 686, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 687. ODK Sick Child repaired CHA position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 687, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 687, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 687, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 687, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 687, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


-- 688. ODK Sick Child repaired CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 688, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

union all

select 688, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 688, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 688, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

union all

select 688, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 689. ODK Sick Child total number of invalid CHA position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 689, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha'
) as a

union all

select 689, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Grand%Gedeh%'
) as a

union all

select 689, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Rivercess%'
) as a

union all

select 689, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_sickChildForm' and id_type like 'cha' and county like '%Unknown%'
) as a
;


-- --------------------------------------------------------------------------------------------------------------------
--                                            End: ODK Sick Child
-- --------------------------------------------------------------------------------------------------------------------
 


-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: ODK Supervision Visit Log CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 

-- 690. ODK Supervision Visit Log original CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 690, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 690, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 690, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 690, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 690, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 691. ODK Supervision Visit Log original CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 691, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 691, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 691, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 691, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 691, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 692. ODK Supervision Visit Log original CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 692, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 692, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 692, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 692, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 692, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 693. ODK Supervision Visit Log original CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 693, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 693, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 693, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 693, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 693, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 694. ODK Supervision Visit Log original CHA position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 694, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 694, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 694, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 694, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 694, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 695. ODK Supervision Visit Log original CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 695, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 695, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 695, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 695, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 695, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


/*

-- 650. ODK Supervision Visit Log repaired CHA position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 650, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha';

-- 651. ODK Supervision Visit Log repaired CHA position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 651, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha';

-- 652. ODK Supervision Visit Log repaired CHA position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 652, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha';


*/



-- 650. ODK Supervision Visit Log repaired CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 650, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 650, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 650, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 650, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 650, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 651. ODK Supervision Visit Log repaired CHA position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 651, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 651, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 651, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 651, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 651, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 652. ODK Supervision Visit Log repaired CHA position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 652, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 652, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 652, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 652, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 652, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 696. ODK Supervision Visit Log repaired CHA position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 696, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 696, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 696, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 696, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 696, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 697. ODK Supervision Visit Log repaired CHA position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 697, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 697, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 697, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 697, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 697, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


-- 698. ODK Supervision Visit Log repaired CHA position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 698, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

union all

select 698, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Bassa%'

union all

select 698, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

union all

select 698, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

union all

select 698, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
;


/*
 * 699. ODK Supervision Visit Log total number of invalid CHA position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 699, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha'
) as a

union all

select 699, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Grand%Gedeh%'
) as a

union all

select 699, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Rivercess%'
) as a

union all

select 699, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'cha' and county like '%Unknown%'
) as a
;


-- --------------------------------------------------------------------------------------------------------------------
--                                            End: ODK Supervision Visit Log CHA ID
-- --------------------------------------------------------------------------------------------------------------------
 



-- 660. ODK CHA Restock repaired CHA position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 660, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_chaRestock' and id_type like 'cha';

-- 661. ODK Supervision Visit Log repaired CHA position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 661, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_chaRestock' and id_type like 'cha';

-- 662. ODK Supervision Visit Log repaired CHA position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 662, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_chaRestock' and id_type like 'cha';


-- 670. ODK QAO Supervision Checklist repaired CHA position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 670, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'cha';

-- 671. ODK QAO Supervision Checklist repaired CHA position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 671, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'cha';

-- 672. ODK QAO Supervision Checklist repaired CHA position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 672, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'cha';


-- 701. ODK original CHSS position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 701, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 702. ODK original CHSS position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 702, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 703. ODK original CHSS position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 703, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 704. ODK original CHSS position ID invalid 999
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 704, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 705. ODK original CHSS position ID invalid LMH integer 
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 705, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 706. ODK original CHSS position ID invalid other
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 706, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';


-- 707. ODK repaired CHSS position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 707, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 708. ODK repaired CHSS position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 708, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 709. ODK repaired CHSS position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 709, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 710. ODK repaired CHSS position ID invalid 999
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 710, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 711. ODK repaired CHSS position ID invalid LMH integer 
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 711, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

-- 712. ODK repaired CHSS position ID invalid other
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 712, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and id_type like 'chss';

/*
 * 713. Total number of invalid CHSS position IDs repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 713, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'
) as a;



/*
 * 714. Total number of invalid 999 CHSS position IDs repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 714, '6_16', 1, @p_month, @p_year, sum( a.id_invalid_999 ) as number_id_repaired
from (

      select sum( id_invalid_999 ) as id_invalid_999  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'
      
      union all
      
      select sum( 0 - id_invalid_999 ) as id_invalid_999
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'

) as a;

/*
 * 715. Total number of invalid LMH Integer CHSS position IDs repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 715, '6_16', 1, @p_month, @p_year, sum( a.id_invalid_lmh_integer ) as number_id_repaired
from (

      select sum( id_invalid_lmh_integer ) as id_invalid_lmh_integer  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'
      
      union all
      
      select sum( 0 - id_invalid_lmh_integer ) as id_invalid_lmh_integer
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'

) as a;

/*
 * 716. Total number of invalid CHSS position IDs other than 999 or LMH Integer repaired across all the ODK tables.
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen, but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 716, '6_16', 1, @p_month, @p_year, sum( a.id_invalid_other ) as number_id_repaired
from (

      select sum( id_invalid_other ) as id_invalid_other  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'

      union all
      
      select sum( 0 - id_invalid_other ) as id_invalid_other
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and id_type like 'chss'

) as a;


-- --------------------------------------------------------------------------------------------------------------------
--                                            Begin: ODK Supervision Visit Log CHSS ID
-- --------------------------------------------------------------------------------------------------------------------
 
-- 790. ODK Supervision Visit Log original CHSS position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 790, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 790, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 790, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 790, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 790, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 791. ODK Supervision Visit Log original CHSS position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 791, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 791, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 791, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 791, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 791, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 792. ODK Supervision Visit Log original CHSS position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 792, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 792, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 792, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 792, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 792, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 793. ODK Supervision Visit Log original CHSS position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 793, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 793, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 793, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 793, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 793, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 794. ODK Supervision Visit Log original CHSS position ID invalid LMH integer 

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 794, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 794, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 794, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 794, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 794, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 795. ODK Supervision Visit Log original CHSS position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 795, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 795, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 795, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 795, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 795, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;

-- 750. ODK Supervision Visit Log repaired CHA position ID total

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 750, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 750, '1_4', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 750, '1_6', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 750, '1_14', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 750, '6_36', 1, @p_month, @p_year, id_total as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 751. ODK Supervision Visit Log repaired CHSS position ID valid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 751, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 751, '1_4', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 751, '1_6', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 751, '1_14', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 751, '6_36', 1, @p_month, @p_year, id_valid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 752. ODK Supervision Visit Log repaired CHSS position ID invalid

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 752, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 752, '1_4', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 752, '1_6', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 752, '1_14', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 752, '6_36', 1, @p_month, @p_year, id_invalid as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 796. ODK Supervision Visit Log repaired CHSS position ID invalid 999

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 796, '6_16', 1, @p_month, @p_year, sum( id_invalid_999 ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 796, '1_4', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 796, '1_6', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 796, '1_14', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 796, '6_36', 1, @p_month, @p_year, id_invalid_999 as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 797. ODK Supervision Visit Log repaired CHSS position ID invalid LMH integer

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 797, '6_16', 1, @p_month, @p_year, sum( id_invalid_lmh_integer ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 797, '1_4', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 797, '1_6', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 797, '1_14', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 797, '6_36', 1, @p_month, @p_year, id_invalid_lmh_integer as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


-- 798. ODK Supervision Visit Log repaired CHSS position ID invalid other

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 798, '6_16', 1, @p_month, @p_year, sum( id_invalid_other ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

union all

select 798, '1_4', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Bassa%'

union all

select 798, '1_6', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

union all

select 798, '1_14', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

union all

select 798, '6_36', 1, @p_month, @p_year, id_invalid_other as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
;


/*
 * 799. ODK Supervision Visit Log total number of invalid CHSS position IDs repaired
 *      It is possible for this code to return a negative number.  In those cases the repair process
 *      created fewer valid IDs than were originally there.  This should never happen but could if the
 *      person doing the cleanup made things worst.  So allow for negative numbers.   
*/

replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 799, '6_16', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select sum( id_valid ) as id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'

      union all

      select sum( 0 - id_valid ) as id_valid  -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss'
) as a

union all

select 799, '1_6', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Grand%Gedeh%'
) as a

union all

select 799, '1_14', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Rivercess%'
) as a

union all

select 799, '6_36', 1, @p_month, @p_year, sum( a.id_valid ) as number_id_repaired
from (
      select id_valid
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'

      union all

      select 0 - id_valid -- Subtract value from zero, so when it is summed from the repaired value, it gives the difference, or the number of ID repaired
      from lastmile_report.mart_view_diagnostic_odk_id_invalid_original_total_table_type
      where month_form = @p_month and year_form = @p_year and table_name like 'odk_supervisionVisitLog' and id_type like 'chss' and county like '%Unknown%'
) as a
;


-- --------------------------------------------------------------------------------------------------------------------
--                                            End: ODK Supervision Visit Log CHSS ID
-- --------------------------------------------------------------------------------------------------------------------
 

-- 760. ODK CHA Restock repaired CHSS position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 760, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_chaRestock' and id_type like 'chss';

-- 761. ODK Supervision Visit Log repaired CHSS position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 761, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_chaRestock' and id_type like 'chss';

-- 762. ODK Supervision Visit Log repaired CHSS position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 762, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_chaRestock' and id_type like 'chss';


-- 770. ODK QAO Supervision Checklist repaired CHSS position ID total
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 770, '6_16', 1, @p_month, @p_year, sum( id_total ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'chss';

-- 771. ODK QAO Supervision Checklist repaired CHSS position ID valid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 771, '6_16', 1, @p_month, @p_year, sum( id_valid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'chss';

-- 772. ODK QAO Supervision Checklist repaired CHSS position ID invalid
replace into lastmile_dataportal.tbl_values_diagnostic (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 772, '6_16', 1, @p_month, @p_year, sum( id_invalid ) as value
from lastmile_report.mart_view_diagnostic_odk_id_invalid_repair_total_table_type
where month_form = @p_month and year_form = @p_year and table_name like 'odk_QAOSupervisionChecklistForm' and id_type like 'chss';



-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('diagnostic_load_month END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
