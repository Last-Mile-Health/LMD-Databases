
-- ------------------ --
-- Set date variables --
-- ------------------ --

-- Set @variables based on parameters (always use @variables below to avoid ambiguity)

SET @p_year := 2019;
SET @p_month := 1;


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

set @cha_population_ratio = 235;

-- select @p_month, @p_year, @p_date, @p_monthMinus1, @p_monthMinus2, @p_monthPlus1, @p_yearMinus1, @p_yearMinus2, @p_yearPlus1, @p_datePlus1, @isEndOfQuarter, @cha_population_ratio;


-- ------ --
-- Begin  --
-- ------ --

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
 


-- ------ --
-- Finish --
-- ------ --

