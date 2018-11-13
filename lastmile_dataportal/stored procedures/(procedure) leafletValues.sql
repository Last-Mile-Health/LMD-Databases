USE `lastmile_dataportal`;
DROP procedure IF EXISTS `leafletValues`;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `leafletValues`(IN p_month INT, IN p_year INT)
BEGIN


-- NOTES:
-- 1. This procedure is called by the MySQL event `evt_dataPortalValues` on a monthly basis
-- 2. The procedure is similar in structure to `dataPortalValues`; see that procedure for reference
-- 3. Note that this procedure uses 1_6 for Grand Gedeh LMH data instead of 6_31
-- !!!!! document this code further !!!!!


-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) VALUES ('leafletValues', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW(), @errorMessage);

END;


-- Log procedure call (START)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('leafletValues START', 'none', NOW());



-- ----- --
-- Setup --
-- ----- --


-- Set @variables based on parameters (always use @variables below to avoid ambiguity)
SET @p_month := p_month;
SET @p_year := p_year;


-- Set @variables for dates
SET @p_date := DATE(CONCAT(@p_year,'-',@p_month,'-01'));
SET @p_monthMinus1 := MONTH(DATE_ADD(@p_date, INTERVAL -1 MONTH));
SET @p_monthMinus2 := MONTH(DATE_ADD(@p_date, INTERVAL -2 MONTH));
SET @p_monthMinus5 := MONTH(DATE_ADD(@p_date, INTERVAL -5 MONTH));
SET @p_yearMinus1 := YEAR(DATE_ADD(@p_date, INTERVAL -1 MONTH));
SET @p_yearMinus2 := YEAR(DATE_ADD(@p_date, INTERVAL -2 MONTH));
SET @p_yearMinus5 := YEAR(DATE_ADD(@p_date, INTERVAL -5 MONTH));
SET @p_totalMonths := @p_month+(12*@p_year);
SET @p_totalMonthsMinus2 := @p_monthMinus2+(12*@p_yearMinus2);
SET @p_totalMonthsMinus5 := @p_monthMinus5+(12*@p_yearMinus5);
SET @isEndOfQuarter := IF(@p_month IN (3,6,9,12),1,0);


-- Clear all data FROM tbl_values_leaflet_leaflet
DELETE FROM lastmile_dataportal.tbl_values_leaflet;



-- -------- --
-- Set data --
-- -------- --

-- Most of these queries follow the same pattern, as follows:
--		Community, last month
--		Community, last 3 months
--		Community, last 6 months
--		Health district, last month
--		Health district, last 3 months
--		Health district, last 6 months
--		County, last month
--		County, last 3 months
--		County, last 6 months


-- 18. Number of births tracked
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 18, CONCAT('5_',community_id), 1, num_births FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 18, CONCAT('5_',community_id), 2, SUM(num_births) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 18, CONCAT('5_',community_id), 3, SUM(num_births) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 18, CONCAT('2_',health_district_id), 1, num_births FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 18, CONCAT('2_',health_district_id), 2, SUM(num_births) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 18, CONCAT('2_',health_district_id), 3, SUM(num_births) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 18, CONCAT('1_',county_id), 1, num_births FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 18, CONCAT('1_',county_id), 2, SUM(num_births) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 18, CONCAT('1_',county_id), 3, SUM(num_births) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 19. Number of child cases of ARI treated

replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 19, concat('5_',community_id), 1, coalesce(num_tx_ari,0) 
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month AND year_reported=@p_year

union 

select 19, concat('5_',community_id), 2, sum(coalesce(num_tx_ari,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 19, concat('5_',community_id), 3, sum(coalesce(num_tx_ari,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 19, concat('2_',health_district_id), 1, coalesce(num_tx_ari,0) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported=@p_month AND year_reported=@p_year

union 

select 19, concat('2_',health_district_id), 2, sum(coalesce(num_tx_ari,0))
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union 

select 19, concat('2_',health_district_id), 3, sum(coalesce(num_tx_ari,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 19, concat('1_',county_id), 1, coalesce(num_tx_ari,0) 
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month AND year_reported=@p_year

union 

select 19, concat('1_',county_id), 2, sum(coalesce(num_tx_ari,0))
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 19, concat('1_',county_id), 3, sum(coalesce(num_tx_ari,0)) 
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;


-- 21. Number of child cases of diarrhea treated

replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 21, concat('5_',community_id), 1, coalesce(num_tx_diarrhea,0) 
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month AND year_reported=@p_year

union 

select 21, concat('5_',community_id), 2, sum(coalesce(num_tx_diarrhea,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 21, concat('5_',community_id), 3, sum(coalesce(num_tx_diarrhea,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 21, concat('2_',health_district_id), 1, coalesce(num_tx_diarrhea,0) 
from lastmile_report.mart_view_base_msr_healthdistrict where month_reported=@p_month AND year_reported=@p_year

union 

select 21, concat('2_',health_district_id), 2, sum(coalesce(num_tx_diarrhea,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union select 21, concat('2_',health_district_id), 3, sum(coalesce(num_tx_diarrhea,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 21, concat('1_',county_id), 1, coalesce(num_tx_diarrhea,0)
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month AND year_reported=@p_year

union 

select 21, concat('1_',county_id), 2, sum(coalesce(num_tx_diarrhea,0)) 
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 21, concat('1_',county_id), 3, sum(coalesce(num_tx_diarrhea,0))
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;


-- 23. Number of child cases of malaria treated
replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 23, concat('5_',community_id), 1, num_tx_malaria
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month AND year_reported=@p_year

union 

select 23, concat('5_',community_id), 2, SUM(num_tx_malaria)
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 23, concat('5_',community_id), 3, SUM(num_tx_malaria) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 23, concat('2_',health_district_id), 1, num_tx_malaria
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported=@p_month AND year_reported=@p_year

union 

select 23, concat('2_',health_district_id), 2, SUM(num_tx_malaria)
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union 

select 23, concat('2_',health_district_id), 3, SUM(num_tx_malaria) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 23, concat('1_',county_id), 1, num_tx_malaria
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month AND year_reported=@p_year

union 

select 23, concat('1_',county_id), 2, SUM(num_tx_malaria) 
from lastmile_report.mart_view_base_msr_county where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 23, concat('1_',county_id), 3, SUM(num_tx_malaria) 
from lastmile_report.mart_view_base_msr_county where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;


-- 28. Number of CHAs deployed (LMH)
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 28, CONCAT('2_',health_district_id), 1, COUNT(*) FROM lastmile_cha.view_base_cha GROUP BY health_district_id
UNION SELECT 28, CONCAT('1_',county_id), 1, COUNT(*) FROM lastmile_cha.view_base_cha GROUP BY county_id;


-- 28. Number of CHAs deployed (NCHA)
-- !!!!! temporary !!!!! 
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_1',1,28,107);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_2',1,28,229);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_3',1,28,160);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_4',1,28,0);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_5',1,28,122);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_6',1,28,219);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_7',1,28,129);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_8',1,28,357);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_9',1,28,110);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_10',1,28,114);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_11',1,28,0);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_12',1,28,770);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_13',1,28,150);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_14',1,28,213);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_15',1,28,193);


-- 29. Number of CHSSs deployed
-- !!!!! check if this is still true !!!!! Note: the second SELECT is disabled because it is manually being overwritten by NCHA scale numbers !!!!!
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 29, CONCAT('2_',health_district_id), 1, COUNT(*) FROM lastmile_cha.view_base_chss GROUP BY health_district_id
UNION SELECT 29, CONCAT('1_',county_id), 1, COUNT(*) FROM lastmile_cha.view_base_chss GROUP BY county_id;




-- 31. Number of deaths (neonatal)

replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 31, concat('5_',community_id), 1, coalesce(num_deaths_neonatal,0) 
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month and year_reported=@p_year

union 

select 31, concat('5_',community_id), 2, sum(coalesce(num_deaths_neonatal,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 31, concat('5_',community_id), 3, sum(coalesce(num_deaths_neonatal,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 31, concat('2_',health_district_id), 1, coalesce(num_deaths_neonatal,0) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported=@p_month and year_reported=@p_year

union 

select 31, concat('2_',health_district_id), 2, sum(coalesce(num_deaths_neonatal,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union 

select 31, concat('2_',health_district_id), 3, sum(coalesce(num_deaths_neonatal,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 31, concat('1_',county_id), 1, coalesce(num_deaths_neonatal,0) 
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and year_reported=@p_year

union 

select 31, concat('1_',county_id), 2, sum(coalesce(num_deaths_neonatal,0)) 
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 31, concat('1_',county_id), 3, sum(coalesce(num_deaths_neonatal,0)) 
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;


-- 33. Number of deaths (post-neonatal)

replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 33, concat('5_',community_id), 1, coalesce(num_deaths_postneonatal,0) 
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month and year_reported=@p_year

union 

select 33, concat('5_',community_id), 2, sum(coalesce(num_deaths_postneonatal,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 33, concat('5_',community_id), 3, sum(coalesce(num_deaths_postneonatal,0)) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 33, concat('2_',health_district_id), 1, coalesce(num_deaths_postneonatal,0) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported=@p_month and year_reported=@p_year

union 

select 33, concat('2_',health_district_id), 2, sum(coalesce(num_deaths_postneonatal,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union 

select 33, concat('2_',health_district_id), 3, sum(coalesce(num_deaths_postneonatal,0)) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 33, concat('1_',county_id), 1, coalesce(num_deaths_postneonatal,0) 
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and year_reported=@p_year

union 

select 33, concat('1_',county_id), 2, sum(coalesce(num_deaths_postneonatal,0)) 
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 33, concat('1_',county_id), 3, sum(coalesce(num_deaths_postneonatal,0)) 
from lastmile_report.mart_view_base_msr_county 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;



-- 34. Number of deaths (under-five)
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 34, CONCAT('5_',community_id), 1, COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 34, CONCAT('5_',community_id), 2, SUM(COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 34, CONCAT('5_',community_id), 3, SUM(COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 34, CONCAT('2_',health_district_id), 1, COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 34, CONCAT('2_',health_district_id), 2, SUM(COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 34, CONCAT('2_',health_district_id), 3, SUM(COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 34, CONCAT('1_',county_id), 1, COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 34, CONCAT('1_',county_id), 2, SUM(COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 34, CONCAT('1_',county_id), 3, SUM(COALESCE(num_deaths_neonatal,0)+COALESCE(num_deaths_postneonatal,0)+COALESCE(num_deaths_child,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 117. Number of deaths (maternal)
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 117, CONCAT('5_',community_id), 1, COALESCE(num_deaths_maternal,0) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 117, CONCAT('5_',community_id), 2, SUM(COALESCE(num_deaths_maternal,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 117, CONCAT('5_',community_id), 3, SUM(COALESCE(num_deaths_maternal,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 117, CONCAT('2_',health_district_id), 1, COALESCE(num_deaths_maternal,0) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 117, CONCAT('2_',health_district_id), 2, SUM(COALESCE(num_deaths_maternal,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 117, CONCAT('2_',health_district_id), 3, SUM(COALESCE(num_deaths_maternal,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 117, CONCAT('1_',county_id), 1, COALESCE(num_deaths_maternal,0) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 117, CONCAT('1_',county_id), 2, SUM(COALESCE(num_deaths_maternal,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 117, CONCAT('1_',county_id), 3, SUM(COALESCE(num_deaths_maternal,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 146. Estimated percent of child malaria cases treated within 24 hours
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 146, CONCAT('5_',community_id), 1, ROUND(num_tx_malaria_under24/num_tx_malaria_under24_denominator,3) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 146, CONCAT('5_',community_id), 2, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 146, CONCAT('5_',community_id), 3, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 146, CONCAT('2_',health_district_id), 1, ROUND(num_tx_malaria_under24/num_tx_malaria_under24_denominator,3) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 146, CONCAT('2_',health_district_id), 2, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 146, CONCAT('2_',health_district_id), 3, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 146, CONCAT('1_',county_id), 1, ROUND(num_tx_malaria_under24/num_tx_malaria_under24_denominator,3) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 146, CONCAT('1_',county_id), 2, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 146, CONCAT('1_',county_id), 3, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 222. Number of child cases of malaria treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 222, CONCAT('5_',community_id), 1, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 222, CONCAT('5_',community_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 222, CONCAT('5_',community_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 222, CONCAT('2_',health_district_id), 1, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 222, CONCAT('2_',health_district_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 222, CONCAT('2_',health_district_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 222, CONCAT('1_',county_id), 1, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 222, CONCAT('1_',county_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 222, CONCAT('1_',county_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 223. Number of child cases of diarrhea treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 223, CONCAT('5_',community_id), 1, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 223, CONCAT('5_',community_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 223, CONCAT('5_',community_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 223, CONCAT('2_',health_district_id), 1, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 223, CONCAT('2_',health_district_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 223, CONCAT('2_',health_district_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 223, CONCAT('1_',county_id), 1, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 223, CONCAT('1_',county_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 223, CONCAT('1_',county_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 224. Number of child cases of ARI treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 224, CONCAT('5_',community_id), 1, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 224, CONCAT('5_',community_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 224, CONCAT('5_',community_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 224, CONCAT('2_',health_district_id), 1, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 224, CONCAT('2_',health_district_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 224, CONCAT('2_',health_district_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 224, CONCAT('1_',county_id), 1, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 224, CONCAT('1_',county_id), 2, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 224, CONCAT('1_',county_id), 3, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 226. Number of routine visits conducted per household
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 226, CONCAT('5_',community_id), 1, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 226, CONCAT('5_',community_id), 2, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 226, CONCAT('5_',community_id), 3, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 226, CONCAT('2_',health_district_id), 1, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 226, CONCAT('2_',health_district_id), 2, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 226, CONCAT('2_',health_district_id), 3, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 226, CONCAT('1_',county_id), 1, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 226, CONCAT('1_',county_id), 2, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 226, CONCAT('1_',county_id), 3, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 347. Number of community triggers reported
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 347, CONCAT('5_',community_id), 1, COALESCE(num_community_triggers,0) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 347, CONCAT('5_',community_id), 2, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 347, CONCAT('5_',community_id), 3, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 347, CONCAT('2_',health_district_id), 1, COALESCE(num_community_triggers,0) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 347, CONCAT('2_',health_district_id), 2, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 347, CONCAT('2_',health_district_id), 3, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 347, CONCAT('1_',county_id), 1, COALESCE(num_community_triggers,0) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 347, CONCAT('1_',county_id), 2, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 347, CONCAT('1_',county_id), 3, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 356. Number of women currently using a modern method of family planning

replace into lastmile_dataportal.tbl_values_leaflet ( ind_id, territory_id, period_id, value )

-- community

-- last month
select 356, concat( '5_', community_id ), 1, coalesce( num_clients_modern_fp, 0) 
from lastmile_report.mart_view_base_msr_community 
where month_reported = @p_month and year_reported = @p_year

union 

-- last 3 months

select 356, concat( '5_', community_id ), 2, sum( coalesce( num_clients_modern_fp, 0 ) ) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths and (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

-- last 6 months

select 356, concat( '5_', community_id ), 3, sum( coalesce( num_clients_modern_fp, 0 ) ) 
from lastmile_report.mart_view_base_msr_community 
where ( month_reported+(12*year_reported) ) <= @p_totalMonths and ( month_reported + ( 12 * year_reported ) ) >= @p_totalMonthsMinus5 
group by community_id

union 

-- health district, last month

select 356, concat( '2_', health_district_id ), 1, coalesce( num_clients_modern_fp, 0 ) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported = @p_month and year_reported = @p_year

union 

-- health district, last 3 months

select 356, concat( '2_', health_district_id ), 2, sum( coalesce( num_clients_modern_fp, 0 ) ) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where ( month_reported + ( 12 * year_reported ) ) <= @p_totalMonths and ( month_reported + ( 12 * year_reported ) ) >= @p_totalMonthsMinus2 
group by health_district_id

union 

-- health district, last 6 months

select 356, concat( '2_', health_district_id ), 3, sum( coalesce( num_clients_modern_fp, 0 ) ) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where ( month_reported + ( 12 * year_reported ) ) <= @p_totalMonths and ( month_reported + ( 12 * year_reported ) ) >= @p_totalMonthsMinus5 
group by health_district_id

union 

-- county, last month

select 356, concat( '1_', county_id ), 1, coalesce( num_clients_modern_fp, 0 ) 
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and year_reported = @p_year

union 

-- county, last 3 months

select 356, concat( '1_', county_id ), 2, sum( coalesce( num_clients_modern_fp, 0 ) ) 
from lastmile_report.mart_view_base_msr_county 
where ( month_reported + ( 12 * year_reported ) ) <= @p_totalMonths and ( month_reported + ( 12 * year_reported ) ) >= @p_totalMonthsMinus2 
group by county_id

union 

-- county, last 6 months

select 356, concat( '1_', county_id ), 3, sum( coalesce( num_clients_modern_fp, 0 ) ) 
from lastmile_report.mart_view_base_msr_county 
where ( month_reported + ( 12 * year_reported ) ) <= @p_totalMonths and ( month_reported + ( 12 * year_reported ) ) >= @p_totalMonthsMinus5 
group by county_id
;


-- 382. Number of children with moderate acute malnutrition (yellow MUAC)
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 382, CONCAT('5_',community_id), 1, num_muac_yellow FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 382, CONCAT('5_',community_id), 2, SUM(num_muac_yellow) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 382, CONCAT('5_',community_id), 3, SUM(num_muac_yellow) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 382, CONCAT('2_',health_district_id), 1, num_muac_yellow FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 382, CONCAT('2_',health_district_id), 2, SUM(num_muac_yellow) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 382, CONCAT('2_',health_district_id), 3, SUM(num_muac_yellow) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 382, CONCAT('1_',county_id), 1, num_muac_yellow FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 382, CONCAT('1_',county_id), 2, SUM(num_muac_yellow) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 382, CONCAT('1_',county_id), 3, SUM(num_muac_yellow) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 383. Number of children with severe acute malnutrition (red MUAC)
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 383, CONCAT('5_',community_id), 1, num_muac_red FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 383, CONCAT('5_',community_id), 2, SUM(num_muac_red) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 383, CONCAT('5_',community_id), 3, SUM(num_muac_red) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 383, CONCAT('2_',health_district_id), 1, num_muac_red FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 383, CONCAT('2_',health_district_id), 2, SUM(num_muac_red) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 383, CONCAT('2_',health_district_id), 3, SUM(num_muac_red) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 383, CONCAT('1_',county_id), 1, num_muac_red FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 383, CONCAT('1_',county_id), 2, SUM(num_muac_red) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 383, CONCAT('1_',county_id), 3, SUM(num_muac_red) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


 
-- 457. Number of child cases of malaria treated in less than 24 hours

replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 457, concat('5_',community_id), 1, num_tx_malaria_under24
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month AND year_reported=@p_year

union 

select 457, concat('5_',community_id), 2, SUM(num_tx_malaria_under24)
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 457, concat('5_',community_id), 3, SUM(num_tx_malaria_under24) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 457, concat('2_',health_district_id), 1, num_tx_malaria_under24
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported=@p_month AND year_reported=@p_year

union 

select 457, concat('2_',health_district_id), 2, SUM(num_tx_malaria_under24)
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union 

select 457, concat('2_',health_district_id), 3, SUM(num_tx_malaria_under24) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 457, concat('1_',county_id), 1, num_tx_malaria_under24
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month AND year_reported=@p_year

union 

select 457, concat('1_',county_id), 2, SUM(num_tx_malaria_under24) 
from lastmile_report.mart_view_base_msr_county where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 457, concat('1_',county_id), 3, SUM(num_tx_malaria_under24) 
from lastmile_report.mart_view_base_msr_county where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;


-- 458. Number of child cases of malaria treated in more than 24 hours

replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)

select 458, concat('5_',community_id), 1, num_tx_malaria_over24
from lastmile_report.mart_view_base_msr_community 
where month_reported=@p_month AND year_reported=@p_year

union 

select 458, concat('5_',community_id), 2, SUM(num_tx_malaria_over24)
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by community_id

union 

select 458, concat('5_',community_id), 3, SUM(num_tx_malaria_over24) 
from lastmile_report.mart_view_base_msr_community 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by community_id

union 

select 458, concat('2_',health_district_id), 1, num_tx_malaria_over24
from lastmile_report.mart_view_base_msr_healthdistrict 
where month_reported=@p_month AND year_reported=@p_year

union 

select 458, concat('2_',health_district_id), 2, SUM(num_tx_malaria_over24)
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by health_district_id

union 

select 458, concat('2_',health_district_id), 3, SUM(num_tx_malaria_over24) 
from lastmile_report.mart_view_base_msr_healthdistrict 
where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by health_district_id

union 

select 458, concat('1_',county_id), 1, num_tx_malaria_over24
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month AND year_reported=@p_year

union 

select 458, concat('1_',county_id), 2, SUM(num_tx_malaria_over24) 
from lastmile_report.mart_view_base_msr_county where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 
group by county_id

union 

select 458, concat('1_',county_id), 3, SUM(num_tx_malaria_over24) 
from lastmile_report.mart_view_base_msr_county where (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 
group by county_id
;


-- 459. Number of in-home births
replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 459, CONCAT('5_',community_id), 1, num_births_home FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 459, CONCAT('5_',community_id), 2, SUM(num_births_home) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 459, CONCAT('5_',community_id), 3, SUM(num_births_home) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 459, CONCAT('2_',health_district_id), 1, num_births_home FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 459, CONCAT('2_',health_district_id), 2, SUM(num_births_home) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 459, CONCAT('2_',health_district_id), 3, SUM(num_births_home) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 459, CONCAT('1_',county_id), 1, num_births_home FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 459, CONCAT('1_',county_id), 2, SUM(num_births_home) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 459, CONCAT('1_',county_id), 3, SUM(num_births_home) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 460. Number of in-facility births
replace into lastmile_dataportal.tbl_values_leaflet (`ind_id`,`territory_id`,`period_id`,`value`)
SELECT 460, CONCAT('5_',community_id), 1, num_births_facility FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 460, CONCAT('5_',community_id), 2, SUM(num_births_facility) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 460, CONCAT('5_',community_id), 3, SUM(num_births_facility) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 460, CONCAT('2_',health_district_id), 1, num_births_facility FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 460, CONCAT('2_',health_district_id), 2, SUM(num_births_facility) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 460, CONCAT('2_',health_district_id), 3, SUM(num_births_facility) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 460, CONCAT('1_',county_id), 1, num_births_facility FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 460, CONCAT('1_',county_id), 2, SUM(num_births_facility) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 460, CONCAT('1_',county_id), 3, SUM(num_births_facility) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('leafletValues END', 'none', NOW());


END$$

DELIMITER ;
