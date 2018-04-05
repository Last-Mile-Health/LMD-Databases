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


-- Clear all leaflet data FROM tbl_values
DELETE FROM lastmile_dataportal.tbl_values WHERE leaflet=1;



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
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 18, CONCAT('5_',community_id), 1, 1, num_births FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 18, CONCAT('5_',community_id), 2, 1, SUM(num_births) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 18, CONCAT('5_',community_id), 3, 1, SUM(num_births) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 18, CONCAT('2_',health_district_id), 1, 1, num_births FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 18, CONCAT('2_',health_district_id), 2, 1, SUM(num_births) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 18, CONCAT('2_',health_district_id), 3, 1, SUM(num_births) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 18, CONCAT('1_',county_id), 1, 1, num_births FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 18, CONCAT('1_',county_id), 2, 1, SUM(num_births) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 18, CONCAT('1_',county_id), 3, 1, SUM(num_births) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 28. Number of CHAs deployed
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 28, CONCAT('2_',health_district_id), 99, 1, COUNT(*) FROM lastmile_cha.view_base_cha GROUP BY health_district_id
UNION SELECT 28, CONCAT('1_',county_id), 99, 1, COUNT(*) FROM lastmile_cha.view_base_cha GROUP BY county_id;


-- 29. Number of CHSSs deployed
-- !!!!! check if this is still true !!!!! Note: the second SELECT is disabled because it is manually being overwritten by NCHA scale numbers !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 29, CONCAT('2_',health_district_id), 99, 1, COUNT(*) FROM lastmile_cha.view_base_chss GROUP BY health_district_id
UNION SELECT 29, CONCAT('1_',county_id), 99, 1, COUNT(*) FROM lastmile_cha.view_base_chss GROUP BY county_id;


-- 146. Estimated percent of child malaria cases treated within 24 hours
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 146, CONCAT('5_',community_id), 1, 1, ROUND(num_tx_malaria_under24/num_tx_malaria_under24_denominator,3) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 146, CONCAT('5_',community_id), 2, 1, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 146, CONCAT('5_',community_id), 3, 1, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 146, CONCAT('2_',health_district_id), 1, 1, ROUND(num_tx_malaria_under24/num_tx_malaria_under24_denominator,3) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 146, CONCAT('2_',health_district_id), 2, 1, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 146, CONCAT('2_',health_district_id), 3, 1, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 146, CONCAT('1_',county_id), 1, 1, ROUND(num_tx_malaria_under24/num_tx_malaria_under24_denominator,3) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 146, CONCAT('1_',county_id), 2, 1, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 146, CONCAT('1_',county_id), 3, 1, ROUND(SUM(num_tx_malaria_under24)/SUM(num_tx_malaria_under24_denominator),3) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 168. Number of CHAs trained within the NCHA program (module 1)
-- !!!!! temporary !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (1,99,168,107);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (2,99,168,242);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (3,99,168,160);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (4,99,168,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (5,99,168,122);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (6,99,168,219);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (7,99,168,129);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (8,99,168,364);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (9,99,168,110);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (10,99,168,114);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (11,99,168,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (12,99,168,770);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (13,99,168,150);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (14,99,168,225);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (15,99,168,191);


-- 169. Number of CHAs trained within the NCHA program (modules 1-2)
-- !!!!! temporary !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (1,99,169,107);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (2,99,169,241);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (3,99,169,160);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (4,99,169,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (5,99,169,122);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (6,99,169,219);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (7,99,169,129);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (8,99,169,358);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (9,99,169,110);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (10,99,169,114);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (11,99,169,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (12,99,169,770);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (13,99,169,148);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (14,99,169,225);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (15,99,169,193);


-- 170. Number of CHAs trained within the NCHA program (modules 1-3)
-- !!!!! temporary !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (1,99,170,107);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (2,99,170,241);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (3,99,170,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (4,99,170,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (5,99,170,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (6,99,170,65);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (7,99,170,129);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (8,99,170,358);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (9,99,170,110);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (10,99,170,113);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (11,99,170,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (12,99,170,770);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (13,99,170,150);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (14,99,170,218);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (15,99,170,193);


-- 171. Number of CHAs trained within the NCHA program (modules 1-4)
-- !!!!! temporary !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (1,99,171,107);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (2,99,171,241);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (3,99,171,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (4,99,171,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (5,99,171,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (6,99,171,63);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (7,99,171,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (8,99,171,357);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (9,99,171,110);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (10,99,171,114);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (11,99,171,0);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (12,99,171,770);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (13,99,171,151);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (14,99,171,218);
REPLACE INTO lastmile_dataportal.tbl_values (`territory_id`,`period_id`,`ind_id`,`value`) VALUES (15,99,171,193);


-- 222. Number of child cases of malaria treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 222, CONCAT('5_',community_id), 1, 1, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 222, CONCAT('5_',community_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 222, CONCAT('5_',community_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 222, CONCAT('2_',health_district_id), 1, 1, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 222, CONCAT('2_',health_district_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 222, CONCAT('2_',health_district_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 222, CONCAT('1_',county_id), 1, 1, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 222, CONCAT('1_',county_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 222, CONCAT('1_',county_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 223. Number of child cases of diarrhea treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 223, CONCAT('5_',community_id), 1, 1, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 223, CONCAT('5_',community_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 223, CONCAT('5_',community_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 223, CONCAT('2_',health_district_id), 1, 1, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 223, CONCAT('2_',health_district_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 223, CONCAT('2_',health_district_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 223, CONCAT('1_',county_id), 1, 1, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 223, CONCAT('1_',county_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 223, CONCAT('1_',county_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 224. Number of child cases of ARI treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 224, CONCAT('5_',community_id), 1, 1, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 224, CONCAT('5_',community_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 224, CONCAT('5_',community_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 224, CONCAT('2_',health_district_id), 1, 1, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 224, CONCAT('2_',health_district_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 224, CONCAT('2_',health_district_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 224, CONCAT('1_',county_id), 1, 1, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 224, CONCAT('1_',county_id), 2, 1, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 224, CONCAT('1_',county_id), 3, 1, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 226. Number of routine visits conducted per household
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 226, CONCAT('5_',community_id), 1, 1, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 226, CONCAT('5_',community_id), 2, 1, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 226, CONCAT('5_',community_id), 3, 1, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 226, CONCAT('2_',health_district_id), 1, 1, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 226, CONCAT('2_',health_district_id), 2, 1, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 226, CONCAT('2_',health_district_id), 3, 1, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 226, CONCAT('1_',county_id), 1, 1, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 226, CONCAT('1_',county_id), 2, 1, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 226, CONCAT('1_',county_id), 3, 1, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;


-- 347. Number of community triggers reported
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`leaflet`,`value`)
SELECT 347, CONCAT('5_',community_id), 1, 1, COALESCE(num_community_triggers,0) FROM lastmile_report.mart_view_base_msr_community WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 347, CONCAT('5_',community_id), 2, 1, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY community_id
UNION SELECT 347, CONCAT('5_',community_id), 3, 1, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_community WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY community_id
UNION SELECT 347, CONCAT('2_',health_district_id), 1, 1, COALESCE(num_community_triggers,0) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 347, CONCAT('2_',health_district_id), 2, 1, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY health_district_id
UNION SELECT 347, CONCAT('2_',health_district_id), 3, 1, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_healthdistrict WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY health_district_id
UNION SELECT 347, CONCAT('1_',county_id), 1, 1, COALESCE(num_community_triggers,0) FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year
UNION SELECT 347, CONCAT('1_',county_id), 2, 1, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus2 GROUP BY county_id
UNION SELECT 347, CONCAT('1_',county_id), 3, 1, SUM(COALESCE(num_community_triggers,0)) FROM lastmile_report.mart_view_base_msr_county WHERE (month_reported+(12*year_reported))<=@p_totalMonths AND (month_reported+(12*year_reported))>=@p_totalMonthsMinus5 GROUP BY county_id;



-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('leafletValues END', 'none', NOW());


END$$

DELIMITER ;
