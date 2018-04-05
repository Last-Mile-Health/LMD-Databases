USE `lastmile_dataportal`;
DROP procedure IF EXISTS `dataPortalValues`;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `dataPortalValues`(IN p_month INT, IN p_year INT)
BEGIN


-- !!!!! unchanged when imported; check all of this !!!!!
-- !!!!! check if all temporary tables are needed !!!!!
-- !!!!! stop tracking numerators / denominators (unless n-value is in report) ?????
-- !!!!! Move as many calculations as possible into queries (rather than DP script); e.g. month(restock_date)=@p_month --> restock_month=@p_month !!!!!
-- NOTES:
--  1. This procedure is called by the MySQL event `evt_dataPortalValues` on a monthly basis
--  2. This entire procedure is idempotent (en.wikipedia.org/wiki/Idempotence). That is, it can be run multiple times consecutively, and assuming the underlying data hasn't changed, the second run, third run, etc. should not change the values stored in the tbl_values warehouse. This allows for the procedure to be re-run if the underlying data DOES change (e.g. if data errors are corrected and we want to re-run the procedure)
--  2. Each block below generates a single value for one month/year (or in some cases, on quarter), and inserts or replaces it in the table `lastmile_dataportal.tbl_values`
--  3. Code is generally written in order of instID. However, sometimes this convention is broken when values for certain instanceIDs need to be calculated before others.
--  4. If a "percent" indicator is created, be sure to always create indicators for the numerator and denominator. This enables calculations of aggregates.
--  5. Ensure that all queries account for the fact that MySQL treats most strings as zero in comparisons (e.g. 'hello'=0 is true); sometimes, values need to be typecasted to enable comparisons
--  6. The REPLACE INTO commands don't have effect if the returned value is NULL (by setting the @instID variable to 0 if the value is NULL). This is to make it easier when the data source switches (e.g. Sick Child Form --> Monthly Service Report) to not overwrite historical data.
--  7. If the calculation does not calculate historical values, wrap it in the following: IF(@isCurrentMonth,(calculation),NULL)
--  8. If the calculation runs quarterly, wrap it in the following: IF(@isEndOfQuarter,(calculation),NULL). See @instID 28 for an example.
--  9. Some calculations suppress values if the "n-value" isn't high enough. Wrap these in the following: IF(@nValueIsLargeEnough,(calculation),NULL). See @instID 296 for an example.
-- 10. In SQL, NULL+number=NULL, so wrap calculations in COALESCE(value,0) before performing addition, subtraction, etc. However, this does not apply to GROUP BY statements involving the SUM() function.
-- 11. Generally, the assumption is made that if an event isn't reported, it didn't happen. One exception to this convention is restock data


-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_stored_procedure_errors (`proc_name`, `parameters`, `timestamp`,`error_message`) VALUES ('dataPortalValues', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW(), @errorMessage);

END;


-- Log procedure call (START)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('dataPortalValues START', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());



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



-- --------------- --
-- Set scale table --
-- --------------- --

-- TO DO: Description


-- Create table
DROP TABLE IF EXISTS `lastmile_report`.`mart_program_scale`;
CREATE TABLE `lastmile_report`.`mart_program_scale` (`territory_id` VARCHAR(20) NOT NULL, `num_cha` INT NULL, `num_chss` INT NULL, `num_communities` INT NULL, `num_households` INT NULL, `num_people` INT NULL, PRIMARY KEY (`territory_id`)) DEFAULT CHARACTER SET = utf8mb4;


-- !!!!! TEMP: Set territories !!!!!
INSERT INTO `lastmile_report`.`mart_program_scale` (`territory_id`) VALUES ('6_31'), ('6_26'), ('1_14'), ('1_4'), ('6_16');


-- 28. Number of CHAs deployed
UPDATE `lastmile_report`.`mart_program_scale` a LEFT JOIN (
SELECT IF(county_id=6,'6_31',CONCAT('1_',county_id)) AS county_id_mod, COUNT(1) as num_cha FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county_id_mod
UNION SELECT '6_16', COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date)
) b ON a.territory_id = b.county_id_mod SET a.num_cha = b.num_cha;


-- 29. Number of CHSSs deployed
UPDATE `lastmile_report`.`mart_program_scale` a LEFT JOIN (
SELECT IF(county_id=6,'6_31',CONCAT('1_',county_id)) AS county_id_mod, COUNT(1) as num_chss FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county_id_mod
UNION SELECT '6_16', COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date)
) b ON a.territory_id = b.county_id_mod SET a.num_chss = b.num_chss;


-- 45. Number of people served (CHA program)
-- !!!!! TEMP until Owen fixes data mart adjusted for county !!!!!
UPDATE `lastmile_report`.`mart_program_scale` SET num_people = 12185 WHERE territory_id = '6_31';
UPDATE `lastmile_report`.`mart_program_scale` SET num_people = 30400 WHERE territory_id = '6_26';
UPDATE `lastmile_report`.`mart_program_scale` SET num_people = 40483 WHERE territory_id = '1_14';
UPDATE `lastmile_report`.`mart_program_scale` SET num_people = 0 WHERE territory_id = '1_4';
UPDATE `lastmile_report`.`mart_program_scale` SET num_people = 83068 WHERE territory_id = '6_16';


-- 50. Number of communities served
-- !!!!! TEMP until Owen fixes data mart adjusted for county !!!!!
UPDATE `lastmile_report`.`mart_program_scale` SET num_communities = 58 WHERE territory_id = '6_31';
UPDATE `lastmile_report`.`mart_program_scale` SET num_communities = 152 WHERE territory_id = '6_26';
UPDATE `lastmile_report`.`mart_program_scale` SET num_communities = 240 WHERE territory_id = '1_14';
UPDATE `lastmile_report`.`mart_program_scale` SET num_communities = 0 WHERE territory_id = '1_4';
UPDATE `lastmile_report`.`mart_program_scale` SET num_communities = 450 WHERE territory_id = '6_16';


-- X. Misc GG UNICEF + Grand Bassa
-- !!!!! TEMP until UNICEF CHAs and CHSSs are in database !!!!!
UPDATE `lastmile_report`.`mart_program_scale` SET num_cha = 152 WHERE territory_id = '6_26';
UPDATE `lastmile_report`.`mart_program_scale` SET num_chss = 17 WHERE territory_id = '6_26';
UPDATE `lastmile_report`.`mart_program_scale` SET num_cha = 0 WHERE territory_id = '1_4';
UPDATE `lastmile_report`.`mart_program_scale` SET num_chss = 0 WHERE territory_id = '1_4';



-- ------------ --
-- Core updates --
-- ------------ --

-- 7. Monthly supervision rate
-- Currently based off of ODK data
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 7, a.territory_id, 1, @p_month, @p_year, ROUND(SUM(supervisionAttendance)/num_cha,1)
FROM lastmile_report.mart_view_base_odk_supervision a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 7, '6_16', 1, @p_month, @p_year, ROUND(SUM(supervisionAttendance)/num_cha,1)
FROM lastmile_report.mart_view_base_odk_supervision a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL;


-- 11. CHA attendance rate at supervision
-- Currently based off of ODK data
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 11, territory_id, 1, @p_month, @p_year, ROUND(SUM(supervisionAttendance)/COUNT(1),3)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 11, '6_16', 1, @p_month, @p_year, ROUND(SUM(supervisionAttendance)/COUNT(1),3)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL;


-- 14. Estimated facility-based delivery rate
-- Updated quarterly
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 14, territory_id, 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_births_facility,0))/(SUM(COALESCE(num_births_facility,0))+SUM(COALESCE(num_births_home,0))),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL AND @isEndOfQuarter AND
((year_reported=@p_year AND month_reported=@p_month) OR (year_reported=@p_yearMinus1 AND month_reported=@p_monthMinus1) OR (year_reported=@p_yearMinus2 AND month_reported=@p_monthMinus2)) GROUP BY territory_id
UNION SELECT 14, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_births_facility,0))/(SUM(COALESCE(num_births_facility,0))+SUM(COALESCE(num_births_home,0))),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL AND @isEndOfQuarter AND
((year_reported=@p_year AND month_reported=@p_month) OR (year_reported=@p_yearMinus1 AND month_reported=@p_monthMinus1) OR (year_reported=@p_yearMinus2 AND month_reported=@p_monthMinus2));


-- 17. Number of attempted supervision visits
-- Currently based off of ODK data
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 17, territory_id, 1, @p_month, @p_year, COUNT(1)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 17, '6_16', 1, @p_month, @p_year, SUM(1)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL;


-- 18. Number of births tracked
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 18, territory_id, 1, @p_month, @p_year, COALESCE(num_births,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 18, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_births,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 19. Number of child cases of ARI treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 19, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_ari,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 19, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_ari,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 21. Number of child cases of diarrhea treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 21, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_diarrhea,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 21, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_diarrhea,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 23. Number of child cases of malaria treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 23, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_malaria,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 23, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_malaria,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 28. Number of CHAs deployed
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 28, IF(county_id=6,'6_31',CONCAT('1_',county_id)), 1, @p_month, @p_year, COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county_id
UNION SELECT 28, '6_16', 1, @p_month, @p_year, COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date);


-- 29. Number of CHSSs deployed
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 29, IF(county_id=6,'6_31',CONCAT('1_',county_id)), 1, @p_month, @p_year, COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county_id
UNION SELECT 29, '6_16', 1, @p_month, @p_year, COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date);


-- 30. Number of deaths (child)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 30, territory_id, 1, @p_month, @p_year, COALESCE(num_deaths_child,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 30, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_deaths_child,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 31. Number of deaths (neonatal)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 31, territory_id, 1, @p_month, @p_year, COALESCE(num_deaths_neonatal,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 31, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_deaths_neonatal,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 33. Number of deaths (post-neonatal)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 33, territory_id, 1, @p_month, @p_year, COALESCE(num_deaths_postneonatal,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 33, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_deaths_postneonatal,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 45. Number of people served (CHA program)
# !!!!! TO DO !!!!!


-- 47. Number of records entered
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 47, '6_16', 1, @p_month, @p_year, SUM(`# records entered`) FROM lastmile_report.view_data_entry WHERE `Month`=@p_month AND `Year`=@p_year;


-- 50. Number of communities served
# !!!!! TO DO !!!!!


-- 59. Percent of records QA'd
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 59, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(`# records receiving QA`,0))/SUM(COALESCE(`# records entered`,0)),3) FROM lastmile_report.view_data_entry WHERE `Month`=@p_month AND `Year`=@p_year;


-- 104. Turnover rate (CHAs; overall)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 104, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 104, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Rivercess', 'rate');


-- 105. Turnover rate (CHAs; termination)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 105, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 105, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Rivercess', 'rate');


-- 106. Turnover rate (CHAs; resignation)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 106, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 106, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Rivercess', 'rate');


-- 107. Turnover rate (CHAs; promotion)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 107, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 107, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Rivercess', 'rate');


-- 108. Turnover rate (CHAs; other/unknown)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 108, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 108, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Rivercess', 'rate');


-- 109. Turnover rate (Supervisors; overall)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 109, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 109, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Rivercess', 'rate');


-- 110. Turnover rate (Supervisors; termination)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 110, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 110, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Rivercess', 'rate');


-- 111. Turnover rate (Supervisors; resignation)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 111, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 111, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Rivercess', 'rate');


-- 112. Turnover rate (Supervisors; promotion)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 112, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 112, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Rivercess', 'rate');


-- 113. Turnover rate (Supervisors; other/unknown)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 113, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 113, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Rivercess', 'rate');


-- 117. Number of deaths (maternal)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 117, territory_id, 1, @p_month, @p_year, COALESCE(num_deaths_maternal,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 117, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_deaths_maternal,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 118. Number of stillbirths
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 118, territory_id, 1, @p_month, @p_year, COALESCE(num_stillbirths,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 118, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_stillbirths,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 119. Number of routine visits conducted
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 119, territory_id, 1, @p_month, @p_year, COALESCE(num_routine_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 119, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_routine_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 121. CHA reporting rate
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 121, a.territory_id, 1, @p_month, @p_year, ROUND(COALESCE(num_reports,0)/num_cha,3)
FROM lastmile_report.mart_view_base_msr_county a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 121, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_reports,0))/num_cha,3)
FROM lastmile_report.mart_view_base_msr_county a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 127. Number of actual supervision visits
-- Currently based off of ODK data
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 127, territory_id, 1, @p_month, @p_year, SUM(supervisionAttendance)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 127, '6_16', 1, @p_month, @p_year, SUM(supervisionAttendance)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL;


-- 128. Cumulative number of child cases of malaria treated
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=128 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_tx_malaria,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 128, '6_16', 1, @p_month, @p_year, @new_value;


-- 129. Cumulative number of child cases of diarrhea treated
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=129 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_tx_diarrhea,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 129, '6_16', 1, @p_month, @p_year, @new_value;


-- 130. Cumulative number of child cases of ARI treated
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=130 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_tx_ari,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 130, '6_16', 1, @p_month, @p_year, @new_value;


-- 131. Cumulative number of routine visits conducted
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=131 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_routine_visits,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 131, '6_16', 1, @p_month, @p_year, @new_value;


-- 132. Cumulative number of supervision visits conducted
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=132 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(supervisionAttendance) FROM lastmile_report.mart_view_base_odk_supervision
WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 132, '6_16', 1, @p_month, @p_year, @new_value;


-- 133. Cumulative number of births tracked by CHAs
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=133 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_births,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 133, '6_16', 1, @p_month, @p_year, @new_value;


-- 146. Estimated percent of child malaria cases treated within 24 hours
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 146, territory_id, 1, @p_month, @p_year, ROUND(COALESCE(num_tx_malaria_under24,0)/(COALESCE(num_tx_malaria_under24,0)+COALESCE(num_tx_malaria_over24,0)),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 146, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_tx_malaria_under24,0))/(SUM(COALESCE(num_tx_malaria_under24,0)+COALESCE(num_tx_malaria_over24,0))),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 147. Percent of CHAs with all essential commodities in stock
-- The if-clause suppresses the results if the reporting rate is below 25%
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 147, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(COUNT(1),0) - COALESCE(SUM(stockout_essentials),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 147, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(COUNT(1),0) - COALESCE(SUM(stockout_essentials),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 148. Percent of CHAs stocked out of ACT-25mg
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 148, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ACT25mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 148, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ACT25mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 149. Percent of CHAs stocked out of ACT-50mg
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 149, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ACT50mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 149, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ACT50mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 150. Percent of CHAs stocked out of Paracetamol-100mg
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 150, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_Paracetamol100mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 150, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_Paracetamol100mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 151. Percent of CHAs stocked out of ORS
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 151, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ORS),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 151, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ORS),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 152. Percent of CHAs stocked out of Zinc sulfate
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 152, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ZincSulfate),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 152, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_ZincSulfate),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 153. Percent of CHAs stocked out of Amoxicillin-250mg
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 153, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_Amoxicillin250mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 153, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_Amoxicillin250mg),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 155. Percent of CHAs stocked out of MUAC strap
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 155, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_muacStrap),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 155, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_muacStrap),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 156. Percent of CHAs stocked out of Malaria RDT
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 156, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_MalariaRDT),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 156, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_MalariaRDT),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 157. Percent of CHAs stocked out of Disposable gloves
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 157, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_disposableGloves),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 157, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_disposableGloves),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 220. Percent of CHAs who are female
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 220, IF(county_id=6,'6_31',CONCAT('1_',county_id)), 1, @p_month, @p_year, ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county
UNION SELECT 220, '6_16', 1, @p_month, @p_year, ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date);


-- 221. Percent of CHSSs who are female
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 221, IF(county_id=6,'6_31',CONCAT('1_',county_id)), 1, @p_month, @p_year, ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county
UNION SELECT 221, '6_16', 1, @p_month, @p_year, ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date);


-- 222. Number of child cases of malaria treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 222, territory_id, 1, @p_month, @p_year, ROUND(1000*(COALESCE(num_tx_malaria,0)/COALESCE(num_catchment_people_iccm,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 222, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 223. Number of child cases of diarrhea treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 223, territory_id, 1, @p_month, @p_year, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/COALESCE(num_catchment_people_iccm,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 223, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 224. Number of child cases of ARI treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 224, territory_id, 1, @p_month, @p_year, ROUND(1000*(COALESCE(num_tx_ari,0)/COALESCE(num_catchment_people_iccm,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 224, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm,0))),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 226. Number of routine visits conducted per household
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 226, territory_id, 1, @p_month, @p_year, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 226, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 229. Estimated percent of births tracked by a CHA
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 229, territory_id, 1, @p_month, @p_year, ROUND(COALESCE(num_births,0)/(0.0032*COALESCE(num_catchment_people,0)),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 229, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_births,0))/(0.0032*SUM(COALESCE(num_catchment_people,0))),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 235. Number of children screened for malnutrition (MUAC)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 235, territory_id, 1, @p_month, @p_year, COALESCE(num_muac_red,0)+COALESCE(num_muac_yellow,0)+COALESCE(num_muac_green,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 235, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_muac_red,0)+COALESCE(num_muac_yellow,0)+COALESCE(num_muac_green,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 237. Number of CHAs who received a restock visit
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 237, territory_id, 1, @p_month, @p_year, COALESCE(COUNT(1),0)
FROM lastmile_report.mart_view_base_restock_cha WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 237, '6_16', 1, @p_month, @p_year, COALESCE(COUNT(1),0)
FROM lastmile_report.mart_view_base_restock_cha WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 238. Percent of CHAs who received a restock visit
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 238, a.territory_id, 1, @p_month, @p_year, ROUND(COALESCE(COUNT(1),0)/num_cha,3)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 238, '6_16', 1, @p_month, @p_year, ROUND(COALESCE(COUNT(1),0)/num_cha,3)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 247. Numerator (indID 104)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 247, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 247, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Rivercess', 'numerator');


-- 249. Numerator (indID 105)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 249, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 249, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Rivercess', 'numerator');


-- 250. Numerator (indID 106)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 250, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 250, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Rivercess', 'numerator');


-- 251. Numerator (indID 107)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 251, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 251, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Rivercess', 'numerator');


-- 252. Numerator (indID 108)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 252, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 252, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Rivercess', 'numerator');


-- 253. Numerator (indID 109)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 253, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 253, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Rivercess', 'numerator');


-- 255. Numerator (indID 110)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 255, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 255, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Rivercess', 'numerator');


-- 256. Numerator (indID 111)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 256, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 256, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Rivercess', 'numerator');


-- 257. Numerator (indID 112)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 257, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 257, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Rivercess', 'numerator');


-- 258. Numerator (indID 113)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 258, '6_31', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 258, '1_14', 1, @p_month, @p_year, lastmile_cha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Rivercess', 'numerator');


-- 302. CHSS reporting rate
-- !!!!! This and certain other queries should be left-joined to a table of "expected counties" so that zeros are inserted
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 302, a.territory_id, 1, @p_month, @p_year, ROUND(COUNT(1)/num_chss,3)
FROM lastmile_report.view_chss_msr a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE month_reported=@p_month AND year_reported=@p_year AND a.territory_id IS NOT NULL GROUP BY a.territory_id
UNION SELECT 302, '6_16', 1, @p_month, @p_year, ROUND(COUNT(1)/num_chss,3)
FROM lastmile_report.view_chss_msr a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE month_reported=@p_month AND year_reported=@p_year AND a.territory_id IS NOT NULL;


-- 305. Percent of expected CHSS mHealth supervision visit logs received
-- !!!!! This and certain other queries should be left-joined to a table of "expected counties" so that zeros are inserted
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 305, a.territory_id, 1, @p_month, @p_year, ROUND(COUNT(1)/(2*num_cha),3)
FROM lastmile_report.mart_view_base_odk_supervision a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE manualMonth=@p_month AND manualYear=@p_year AND a.territory_id IS NOT NULL GROUP BY territory_id
UNION SELECT 305, '6_16', 1, @p_month, @p_year, ROUND(COUNT(1)/(2*num_cha),3)
FROM lastmile_report.mart_view_base_odk_supervision a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE manualMonth=@p_month AND manualYear=@p_year AND a.territory_id IS NOT NULL;


-- 307. Percent of CHAs stocked out of Microlut
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 307, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_microlut),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 307, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_microlut),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 309. Percent of CHAs stocked out of Microgynon
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 309, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_microgynon),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 309, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_microgynon),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 311. Percent of CHAs stocked out of Male condom
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 311, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_maleCondom),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 311, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_maleCondom),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 313. Percent of CHAs stocked out of Female condom
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 313, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_femaleCondom),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 313, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_femaleCondom),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 315. Percent of CHAs stocked out of Artesunate suppository
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 315, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_artesunateSuppository),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 315, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_artesunateSuppository),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 317. Percent of CHAs stocked out of Dispensing bags
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 317, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_dispensingBags),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 317, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_dispensingBags),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 319. Percent of CHAs stocked out of Safety box
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 319, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_safetyBox),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 319, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(SUM(stockout_safetyBox),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 320. Number of child cases treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 320, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_ari,0) + COALESCE(num_tx_diarrhea,0) + COALESCE(num_tx_malaria,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 320, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_ari,0) + COALESCE(num_tx_diarrhea,0) + COALESCE(num_tx_malaria,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 323. Number of child cases treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 323, territory_id, 1, @p_month, @p_year, ROUND(1000*((COALESCE(num_tx_malaria,0)+COALESCE(num_tx_diarrhea,0)+COALESCE(num_tx_ari,0))/COALESCE(num_catchment_people_iccm,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 323, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM((COALESCE(num_tx_malaria,0)+COALESCE(num_tx_diarrhea,0)+COALESCE(num_tx_ari,0)))/SUM(COALESCE(num_catchment_people_iccm,0))),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 331. CHSS restock rate
-- !!!!! This and certain other queries should be left-joined to a table of "expected counties" so that zeros are inserted
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 331, a.territory_id, 1, @p_month, @p_year, ROUND(COUNT(DISTINCT chss_id)/num_chss,3)
FROM lastmile_report.view_base_restock_chss a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE restock_month=@p_month AND restock_year=@p_year AND a.territory_id IS NOT NULL GROUP BY county
UNION SELECT 331, '6_16', 1, @p_month, @p_year, ROUND(COUNT(DISTINCT chss_id)/num_chss,3)
FROM lastmile_report.view_base_restock_chss a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE restock_month=@p_month AND restock_year=@p_year AND a.territory_id IS NOT NULL;


-- 347. Number of community triggers reported
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 347, territory_id, 1, @p_month, @p_year, COALESCE(num_community_triggers,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 347, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_community_triggers,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 348. Number of referrals for HIV / TB / CM-NTD / mental health
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 348, territory_id, 1, @p_month, @p_year, COALESCE(num_referrals_mod4,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 348, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_referrals_mod4,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 349. Number of pregnant woman visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 349, territory_id, 1, @p_month, @p_year, COALESCE(num_pregnant_woman_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 349, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_pregnant_woman_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 350. Number of women referred to a health facility for delivery
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 350, territory_id, 1, @p_month, @p_year, COALESCE(num_referred_delivery,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 350, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_referred_delivery,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 351. Number of women referred for ANC visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 351, territory_id, 1, @p_month, @p_year, COALESCE(num_referred_anc,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 351, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_referred_anc,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 352. Number of postnatal visits conducted
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 352, territory_id, 1, @p_month, @p_year, COALESCE(num_post_natal_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 352, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_post_natal_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 353. Number of RMNH danger signs detected
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 353, territory_id, 1, @p_month, @p_year, COALESCE(num_referred_rmnh_danger_sign,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 353, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_referred_rmnh_danger_sign,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 354. Number of mothers who received home-based care within 48 hours of delivery
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 354, territory_id, 1, @p_month, @p_year, COALESCE(num_hbmnc_48_hours_mother,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 354, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_hbmnc_48_hours_mother,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 355. Number of infants who received home-based care within 48 hours of delivery
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 355, territory_id, 1, @p_month, @p_year, COALESCE(num_hbmnc_48_hours_infant,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 355, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_hbmnc_48_hours_infant,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 356. Number of women currently using a modern method of family planning
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 356, territory_id, 1, @p_month, @p_year, COALESCE(num_clients_modern_fp,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 356, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_clients_modern_fp,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 357. Number of HIV client visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 357, territory_id, 1, @p_month, @p_year, COALESCE(num_hiv_client_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 357, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_hiv_client_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 358. Number of TB client visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 358, territory_id, 1, @p_month, @p_year, COALESCE(num_tb_client_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 358, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tb_client_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 359. Number of CM-NTD client visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 359, territory_id, 1, @p_month, @p_year, COALESCE(num_cm_ntd_client_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 359, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_cm_ntd_client_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 360. Number of mental health client visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 360, territory_id, 1, @p_month, @p_year, COALESCE(num_mental_health_client_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 360, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_mental_health_client_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 361. Number of LTFU HIV clients traced
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 361, territory_id, 1, @p_month, @p_year, COALESCE(num_ltfu_hiv_clients_traced,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 361, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_ltfu_hiv_clients_traced,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 362. Number of LTFU TB clients traced
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 362, territory_id, 1, @p_month, @p_year, COALESCE(num_ltfu_tb_clients_traced,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 362, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_ltfu_tb_clients_traced,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 366. Number of IFI visits conducted (CHAs)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 366, territory_id, 1, @p_month, @p_year, COALESCE(numReports,0)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 366, '6_27', 1, @p_month, @p_year, SUM(COALESCE(numReports,0))
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 366, territory_id, 2, @p_month, @p_year, SUM(COALESCE(numReports,0))
FROM lastmile_report.mart_view_base_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;


-- 367. Percent of CHAs who received a restock visit in the past month (IFI)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 367, territory_id, 1, @p_month, @p_year, ROUND(SUM(COALESCE(restockedInLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year GROUP BY territory_id
UNION SELECT 367, '6_27', 1, @p_month, @p_year, ROUND(SUM(COALESCE(restockedInLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 367, territory_id, 2, @p_month, @p_year, ROUND(SUM(COALESCE(restockedInLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;


-- 368. Percent of CHAs who received a supervision visit in the past month (IFI)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 368, territory_id, 1, @p_month, @p_year, ROUND(SUM(COALESCE(supervisedLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year GROUP BY territory_id
UNION SELECT 368, '6_27', 1, @p_month, @p_year, ROUND(SUM(COALESCE(supervisedLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 368, territory_id, 2, @p_month, @p_year, ROUND(SUM(COALESCE(supervisedLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;


-- 369. Percent of CHAs who received their last monetary incentive on time (IFI)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 369, territory_id, 1, @p_month, @p_year, ROUND(SUM(COALESCE(receivedLastIncentiveOnTime,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year GROUP BY territory_id
UNION SELECT 369, '6_27', 1, @p_month, @p_year, ROUND(SUM(COALESCE(receivedLastIncentiveOnTime,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 369, territory_id, 2, @p_month, @p_year, ROUND(SUM(COALESCE(receivedLastIncentiveOnTime,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_base_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;


-- 382. Number of children with malnutrition (yellow MUAC)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 382, territory_id, 1, @p_month, @p_year, COALESCE(num_muac_yellow,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 382, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_muac_yellow,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 383. Number of children with severe acute malnutrition (red MUAC)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 383, territory_id, 1, @p_month, @p_year, COALESCE(num_muac_red,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 383, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_muac_red,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 384. Number of child cases of ARI treated (ODK)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 384, territory_id, 1, @p_month, @p_year, COALESCE(ari_odk,0)
FROM lastmile_report.mart_view_odk_sickchild WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 385. Number of child cases of diarrhea treated (ODK)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 385, territory_id, 1, @p_month, @p_year, COALESCE(diarrhea_odk,0)
FROM lastmile_report.mart_view_odk_sickchild WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 386. Number of child cases of malaria treated (ODK)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 386, territory_id, 1, @p_month, @p_year, COALESCE(malaria_odk,0)
FROM lastmile_report.mart_view_odk_sickchild WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;



-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('dataPortalValues END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
