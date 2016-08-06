DELIMITER $$
CREATE PROCEDURE `dataPortalValues`(IN p_month INT, IN p_year INT)
BEGIN


-- NOTES:
-- 1. This procedure is called by the MySQL event `evt_dataPortalValues` on a monthly basis
-- 2. Each block below generates a single value for one month/year, and inserts or replaces it in the table `lastmile_dataportal.tbl_values`
-- 3. Eventually, it may be easier to maintain queries as prepared statements (e.g. many queries with the same bulky WHERE clause), as follows:
-- 			SET @c = "c1";
-- 			SET @s = CONCAT("SELECT ", @c, " FROM t");
-- 			PREPARE stmt FROM @s;
-- 4. Ensure that all queries account for the fact that MySQL treats most strings as zero in comparisons (e.g. 'hello'=0 is true)
-- 5. The REPLACE INTO commands effectively don't run if the returned value is NULL (by setting the @instID variable to 0 if the value is NULL). This is to make it easier when the data source switches (e.g. Sick Child Form --> Monthly Service Report) to not overwrite historical data.


-- TO DO:
--   1. Ensure that all "Konobo" indicators are actually restricted to Konobo
--   2. Create queries for all scale indicators; check to see if values match


-- Log errors
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN

	GET DIAGNOSTICS CONDITION 1
	@errorMessage = MESSAGE_TEXT;
	INSERT INTO lastmile_dataportal.tbl_storedProcedureErrors (`procName`, `procParameters`, `procTimestamp`,`errorMessage`) VALUES ('dataPortalValues', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW(), @errorMessage);

END;


-- Log procedure call (START)
INSERT INTO lastmile_dataportal.tbl_storedProcedureLog (`procName`, `procParameters`, `procTimestamp`) VALUES ('dataPortalValues START', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


-- Set @variables based on parameters (to avoid ambiguity)
SET @p_month := p_month;
SET @p_year := p_year;


-- Create temporary tables based off of views (dramatically improves speed of stored procedure)
DROP TABLE IF EXISTS lastmile_dataportal.TEMP_view_msr_cohort;
CREATE TABLE lastmile_dataportal.TEMP_view_msr_cohort SELECT * FROM lastmile_chwdb.view_msr_cohort;
DROP TABLE IF EXISTS lastmile_dataportal.TEMP_view_vaccinetracker1;
CREATE TABLE lastmile_dataportal.TEMP_view_vaccinetracker1 SELECT * FROM lastmile_chwdb.view_vaccinetracker1;
DROP TABLE IF EXISTS lastmile_dataportal.TEMP_view_vaccinetracker2;
CREATE TABLE lastmile_dataportal.TEMP_view_vaccinetracker2 SELECT * FROM lastmile_chwdb.view_vaccinetracker2;


-- Set useful variables: dates
SET @p_date := CONCAT(@p_year,'-',@p_month,'-01');
SET @p_monthMinus1 := MONTH(DATE_ADD(@p_date, INTERVAL -1 MONTH));
SET @p_monthMinus2 := MONTH(DATE_ADD(@p_date, INTERVAL -2 MONTH));
SET @p_yearMinus1 := YEAR(DATE_ADD(@p_date, INTERVAL -1 MONTH));
SET @p_yearMinus2 := YEAR(DATE_ADD(@p_date, INTERVAL -2 MONTH));
SET @oneMonthIntervalStart := DATE(CONCAT(@p_year,'-',@p_month,'-01'));
SET @oneMonthIntervalEnd := DATE_ADD(DATE_ADD(@oneMonthIntervalStart, INTERVAL +1 MONTH), INTERVAL -1 DAY);
SET @isEndOfQuarter := IF(@p_month IN (3,6,9,12),1,0);


-- Set useful variables: staff counts
SET @CHWs_K := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
        lastmile_chwdb.staffCohort(staffID) = 'Konobo' AND 
        lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
SET @CHWs_GP := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
        lastmile_chwdb.staffCohort(staffID) = 'Gboe-Ploe' AND 
        lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
SET @CHWs_RC1 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
        lastmile_chwdb.staffCohort(staffID) = 'Rivercess 1' AND 
        lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
SET @CHWs_RC2 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
        lastmile_chwdb.staffCohort(staffID) = 'Rivercess 2' AND 
        lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);


-- Set useful variables: staff counts (# of staff reporting)
SET @CHWs_K_rep := (
	SELECT nReports FROM lastmile_dataportal.TEMP_view_msr_cohort WHERE 
		yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
SET @CHWs_GP_rep := (
	SELECT nReports FROM lastmile_dataportal.TEMP_view_msr_cohort WHERE 
		yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
SET @CHWs_RC1_rep := (
	SELECT nReports FROM lastmile_dataportal.TEMP_view_msr_cohort WHERE 
		yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
SET @CHWs_RC2_rep := (
	SELECT nReports FROM lastmile_dataportal.TEMP_view_msr_cohort WHERE 
		yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);


-- Number of CHWs deployed (---)
SET @instID = 1;
SET @instValue_1 := @CHWs_K + @CHWs_GP + @CHWs_RC1 + @CHWs_RC2;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_1 IS NOT NULL,@instID,0),@instValue_1);


-- Number of CHW supervisors (---)
SET @instID = 2;
SET @instValue_2 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) IN (2,3) AND 
        lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_2 IS NOT NULL,@instID,0),@instValue_2);


-- Number of people served (---)
-- !!!!! Owen TO DO !!!!!
-- !!!!! use new registration table !!!!!
SET @instID = 3;


-- Number of communities served (---)
-- !!!!! Owen TO DO !!!!!
-- !!!!! use new registration table !!!!!
SET @instID = 4;


-- Number of CHWs deployed (Konobo)
SET @instID = 16;
SET @instValue_16 := @CHWs_K;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_16 IS NOT NULL,@instID,0),@instValue_16);


-- ANC 1+ rate (quarterly) (Konobo)
SET @instID = 17;
SET @num0 := (
	SELECT SUM(nANC_0) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE chwCohort='Konobo' AND (
		(yearReported=@p_year AND monthReported=@p_month) OR 
		(yearReported=@p_yearMinus1 AND monthReported=@p_monthMinus1) OR 
		(yearReported=@p_yearMinus2 AND monthReported=@p_monthMinus2)
	)
);
SET @num1to3 := (
	SELECT SUM(nANC_1to3) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE chwCohort='Konobo' AND (
		(yearReported=@p_year AND monthReported=@p_month) OR 
		(yearReported=@p_yearMinus1 AND monthReported=@p_monthMinus1) OR 
		(yearReported=@p_yearMinus2 AND monthReported=@p_monthMinus2)
	)
);
SET @num4plus := (
	SELECT SUM(nANC_4plus) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE chwCohort='Konobo' AND (
		(yearReported=@p_year AND monthReported=@p_month) OR 
		(yearReported=@p_yearMinus1 AND monthReported=@p_monthMinus1) OR 
		(yearReported=@p_yearMinus2 AND monthReported=@p_monthMinus2)
	)
);
SET @instValue_17 := if(@isEndOfQuarter,ROUND((@num1to3+@num4plus)/(@num0+@num1to3+@num4plus),3),NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_17 IS NOT NULL,@instID,0),@instValue_17);


-- ANC 4+ rate (quarterly) (Konobo)
-- Note: Uses @variables from above (instID=17)
SET @instID = 18;
SET @instValue_18 := if(@isEndOfQuarter,ROUND((@num4plus)/(@num0+@num1to3+@num4plus),3),NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_18 IS NOT NULL,@instID,0),@instValue_18);


-- Number of CHW Leaders (Konobo)
SET @instID = 23;
SET @instValue_23 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 2 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Konobo' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_23 IS NOT NULL,@instID,0),@instValue_23);


-- Number of people served (Konobo)
-- !!!!! Owen TO DO !!!!!
SET @instID = 24;


-- Number of villages served (Konobo)
-- !!!!! Owen TO DO !!!!!
SET @instID = 25;


-- Percent of records QA'd (---)
SET @instID = 26;
SET @totalRecords := (
	SELECT sum(numRecords) as totalRecords FROM lastmile_dataportal.view_dataentry WHERE deMonth=@p_month AND deYear=@p_year
);
SET @totalQA := (
	SELECT sum(numQA) as totalQA FROM lastmile_dataportal.view_dataentry WHERE deMonth=@p_month AND deYear=@p_year
);
SET @instValue_26 := ROUND(@totalQA/@totalRecords,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_26 IS NOT NULL,@instID,0),@instValue_26);


-- Number of records entered (---)
SET @instID = 27;
SET @instValue_27 := (
	SELECT sum(numRecords) FROM lastmile_dataportal.view_dataentry WHERE deMonth=@p_month AND deYear=@p_year
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_27 IS NOT NULL,@instID,0),@instValue_27);


-- Facility-based delivery rate (quarterly) (Konobo)
SET @instID = 28;
SET @nHomeBirths := (
	SELECT SUM(nHomeBirths) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE chwCohort='Konobo' AND (
		(yearReported=@p_year AND monthReported=@p_month) OR 
		(yearReported=@p_yearMinus1 AND monthReported=@p_monthMinus1) OR 
		(yearReported=@p_yearMinus2 AND monthReported=@p_monthMinus2)
	)
);
SET @nFacilityBirths := (
	SELECT SUM(nFacilityBirths) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE chwCohort='Konobo' AND (
		(yearReported=@p_year AND monthReported=@p_month) OR 
		(yearReported=@p_yearMinus1 AND monthReported=@p_monthMinus1) OR 
		(yearReported=@p_yearMinus2 AND monthReported=@p_monthMinus2)
	)
);
SET @instValue_28 := if(@isEndOfQuarter,ROUND(@nFacilityBirths/(@nFacilityBirths+@nHomeBirths),3),NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_28 IS NOT NULL,@instID,0),@instValue_28);


-- Number of child cases of malaria treated (Konobo)
SET @instID = 31;
SET @instValue_31 := (
	SELECT nMalaria FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_31 IS NOT NULL,@instID,0),@instValue_31);


-- Number of child cases of diarrhea treated (Konobo)
SET @instID = 32;
SET @instValue_32 := (
	SELECT nDiarrhea FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_32 IS NOT NULL,@instID,0),@instValue_32);


-- Number of child cases of ARI treated (Konobo)
SET @instID = 33;
SET @instValue_33 := (
	SELECT nARI FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_33 IS NOT NULL,@instID,0),@instValue_33);


-- Number of births (Konobo)
SET @instID = 37;
SET @instValue_37 := (
	SELECT nBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_37 IS NOT NULL,@instID,0),@instValue_37);


-- Number of deaths (under-five) (Konobo)
#SET @instID = 38;


-- Number of deaths (over-five) (Konobo)
SET @instID = 39;
SET @instValue_39 := (
	SELECT nDeathsAdult FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_39 IS NOT NULL,@instID,0),@instValue_39);


-- Number of deaths (unknown) (Konobo)
SET @instID = 40;


-- Number of deaths (neonatal) (Konobo)
SET @instID = 41;
SET @instValue_41 := (
	SELECT nDeathsNeonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_41 IS NOT NULL,@instID,0),@instValue_41);


-- Number of deaths (post-neonatal) (Konobo)
SET @instID = 42;
SET @instValue_42 := (
	SELECT nDeathsPostneonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_42 IS NOT NULL,@instID,0),@instValue_42);


-- Number of deaths (child) (Konobo)
SET @instID = 43;
SET @instValue_43 := (
	SELECT nDeathsChild FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_43 IS NOT NULL,@instID,0),@instValue_43);


-- Number of attempted supervision visits (Konobo)
SET @instID = 48;
SET @instValue_48 := (
	SELECT nSupVisitsAttempted FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_48 IS NOT NULL,@instID,0),@instValue_48);


-- CHW attendance rate at supervision (Konobo)
SET @instID = 49;
SET @instValue_49 := (
	SELECT ROUND(1-(nCHWAbsent/nSupVisitsAttempted),3) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_49 IS NOT NULL,@instID,0),@instValue_49);


-- Number of unexcused absences at supervision (Konobo)
SET @instID = 50;
SET @instValue_50 := (
	SELECT nCHWAbsent - nCHWAbsentExcused FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_50 IS NOT NULL,@instID,0),@instValue_50);


-- Correct treatment rate (Konobo)
-- !!!!! UPDATE !!!!!!
#SET @instID = 52;
#SET @instValue := (
#	SELECT ROUND(sum(auditCorrectTreatment)/sum(if((auditCorrectTreatment=1||auditCorrectTreatment=0)&&auditCorrectTreatment!='',1,0)),3) 
#	FROM lastmile_chwdb.staging_odk_chwsupervisionreport 
#	WHERE month(meta_autoDate)=@p_month && year(meta_autoDate)=@p_year
#);
#REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue IS NOT NULL,@instID,0),@instValue);


-- Number of Community Clinical Supervisors (Konobo)
SET @instID = 61;
SET @instValue_61 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 3 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Konobo' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_61 IS NOT NULL,@instID,0),@instValue_61);




-- Number of CHWs deployed (Gboe-Ploe)
SET @instID = 63;
SET @instValue_63 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Gboe-Ploe' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_63 IS NOT NULL,@instID,0),@instValue_63);


-- Number of CHW Leaders (Gboe-Ploe)
SET @instID = 64;
SET @instValue_64 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 2 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Gboe-Ploe' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_64 IS NOT NULL,@instID,0),@instValue_64);


-- Number of people served (Gboe-Ploe)
-- !!!!! Owen TO DO !!!!!
SET @instID = 65;


-- Number of villages served (Gboe-Ploe)
-- !!!!! Owen TO DO !!!!!
SET @instID = 66;


-- Number of Community Clinical Supervisors (Gboe-Ploe)
SET @instID = 67;
SET @instValue_67 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 3 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Gboe-Ploe' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_67 IS NOT NULL,@instID,0),@instValue_67);


-- Number of CHWs deployed (Rivercess)
-- !!!!! INACTIVE !!!!!
SET @instID = 68;


-- Number of CHW Leaders (Rivercess)
-- !!!!! INACTIVE !!!!!
SET @instID = 69;


-- Number of people served (Rivercess)
-- !!!!! INACTIVE !!!!!
SET @instID = 70;


-- Number of villages served (Rivercess)
-- !!!!! INACTIVE !!!!!
SET @instID = 71;


-- Number of Community Clinical Supervisors (Rivercess)
-- !!!!! INACTIVE !!!!!
SET @instID = 72;


-- Average number of supervision visits per CHW (Konobo)
SET @instID = 73;
SET @nSuccessfulSupervisionVisits := (
	SELECT nSupVisitsAttempted - nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
SET @instValue_73 := @nSuccessfulSupervisionVisits / @CHWs_K_rep;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_73 IS NOT NULL,@instID,0),@instValue_73);


-- Number of child cases of malaria treated (Gboe-Ploe)
SET @instID = 80;
SET @instValue_80 := (
	SELECT nMalaria FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_80 IS NOT NULL,@instID,0),@instValue_80);


-- Number of child cases of diarrhea treated (Gboe-Ploe)
SET @instID = 81;
SET @instValue_81 := (
	SELECT nDiarrhea FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_81 IS NOT NULL,@instID,0),@instValue_81);


-- Number of child cases of ARI treated (Gboe-Ploe)
SET @instID = 82;
SET @instValue_82 := (
	SELECT nARI FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_82 IS NOT NULL,@instID,0),@instValue_82);


-- Number of adults treated for malaria (Konobo)
SET @instID = 83;
SET @instValue_83 := (
	SELECT sum(B4_provideACT) FROM lastmile_db.tbl_data_fhw_mat_malariaassessment WHERE month(visitDate)=@p_month && year(visitDate)=@p_year
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_83 IS NOT NULL,@instID,0),@instValue_83);


-- Number of adults referred for malaria (Konobo)
SET @instID = 84;
SET @instValue_84 := (
	SELECT
		sum(if(C5_hasSymptom+C6_palmsWhite+C7_conjunctivaPale+E12_day1_dangerSigns+E15_day2_dangerSigns+E18_day3_dangerSigns
		+E19_day3_stillHasFever>0,1,0)) 
	FROM lastmile_db.tbl_data_fhw_mat_malariaassessment 
	WHERE month(visitDate)=@p_month && year(visitDate)=@p_year
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_84 IS NOT NULL,@instID,0),@instValue_84);


-- Number of CHW supervisors (Konobo)
SET @instID = 91;
SET @instValue_91 := @instValue_23 + @instValue_61;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_91 IS NOT NULL,@instID,0),@instValue_91);


-- Number of CHW supervisors (Gboe-Ploe)
SET @instID = 92;
SET @instValue_92 := @instValue_64 + @instValue_67;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_92 IS NOT NULL,@instID,0),@instValue_92);


-- Number of CHW supervisors (Rivercess)
-- !!!!! INACTIVE !!!!!
SET @instID = 93;


-- Facility-based delivery rate (n-value) (quarterly) (Konobo)
SET @instID = 94;
SET @instValue_94 := if(@isEndOfQuarter,@nFacilityBirths+@nHomeBirths,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_94 IS NOT NULL,@instID,0),@instValue_94);


-- ANC 1/4+ (n-value) (quarterly) (Konobo)
SET @instID = 95;
SET @instValue_95 := if(@isEndOfQuarter,@num0+@num1to3+@num4plus,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_95 IS NOT NULL,@instID,0),@instValue_95);


-- Turnover rate (CHWs; overall) (Rivercess)
SET @instID = 101;
SET @instValue_101 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 0, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_101 IS NOT NULL,@instID,0),@instValue_101);


-- Turnover rate (CHWs; termination) (Rivercess)
SET @instID = 102;
SET @instValue_102 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 1, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_102 IS NOT NULL,@instID,0),@instValue_102);


-- Turnover rate (CHWs; resignation) (Rivercess)
SET @instID = 103;
SET @instValue_103 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 2, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_103 IS NOT NULL,@instID,0),@instValue_103);


-- Turnover rate (CHWs; promotion) (Rivercess)
SET @instID = 104;
SET @instValue_104 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 5, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_104 IS NOT NULL,@instID,0),@instValue_104);


-- Turnover rate (CHWs; other/unknown) (Rivercess)
SET @instID = 105;
SET @instValue_105 := (
	@instValue_101 - ( @instValue_102 + @instValue_103 + @instValue_104 )
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_105 IS NOT NULL,@instID,0),@instValue_105);


-- Turnover rate (CHWs; overall) (Grand Gedeh)
SET @instID = 106;
SET @instValue_106 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 0, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_106 IS NOT NULL,@instID,0),@instValue_106);


-- Turnover rate (CHWs; termination) (Grand Gedeh)
SET @instID = 107;
SET @instValue_107 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 1, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_107 IS NOT NULL,@instID,0),@instValue_107);


-- Turnover rate (CHWs; resignation) (Grand Gedeh)
SET @instID = 108;
SET @instValue_108 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 2, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_108 IS NOT NULL,@instID,0),@instValue_108);


-- Turnover rate (CHWs; promotion) (Grand Gedeh)
SET @instID = 109;
SET @instValue_109 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 1, 5, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_109 IS NOT NULL,@instID,0),@instValue_109);


-- Turnover rate (CHWs; other/unknown) (Grand Gedeh)
SET @instID = 110;
SET @instValue_110 := (
	@instValue_106 - ( @instValue_107 + @instValue_108 + @instValue_109 )
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_110 IS NOT NULL,@instID,0),@instValue_110);


-- Number of child cases of malaria treated (Rivercess cohort 1)
SET @instID = 111;
SET @instValue_111 := (
	SELECT nMalaria FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_111 IS NOT NULL,@instID,0),@instValue_111);


-- Number of child cases of diarrhea treated (Rivercess cohort 1)
SET @instID = 112;
SET @instValue_112 := (
	SELECT nDiarrhea FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_112 IS NOT NULL,@instID,0),@instValue_112);


-- Number of child cases of ARI treated (Rivercess cohort 1)
SET @instID = 113;
SET @instValue_113 := (
	SELECT nARI FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_113 IS NOT NULL,@instID,0),@instValue_113);


-- Turnover rate (Supervisors; overall) (Rivercess)
SET @instID = 114;
SET @instValue_114 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 0, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_114 IS NOT NULL,@instID,0),@instValue_114);


-- Turnover rate (Supervisors; termination) (Rivercess)
SET @instID = 115;
SET @instValue_115 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 1, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_115 IS NOT NULL,@instID,0),@instValue_115);


-- Turnover rate (Supervisors; resignation) (Rivercess)
SET @instID = 116;
SET @instValue_116 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 2, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_116 IS NOT NULL,@instID,0),@instValue_116);


-- Turnover rate (Supervisors; promotion) (Rivercess)
SET @instID = 117;
SET @instValue_117 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 5, 14)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_117 IS NOT NULL,@instID,0),@instValue_117);


-- Turnover rate (Supervisors; other/unknown) (Rivercess)
SET @instID = 118;
SET @instValue_118 := (
	@instValue_114 - ( @instValue_115 + @instValue_116 + @instValue_117 )
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_118 IS NOT NULL,@instID,0),@instValue_118);


-- Turnover rate (Supervisors; overall) (Grand Gedeh)
SET @instID = 119;
SET @instValue_119 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 0, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_119 IS NOT NULL,@instID,0),@instValue_119);


-- Turnover rate (Supervisors; termination) (Grand Gedeh)
SET @instID = 120;
SET @instValue_120 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 1, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_120 IS NOT NULL,@instID,0),@instValue_120);


-- Turnover rate (Supervisors; resignation) (Grand Gedeh)
SET @instID = 121;
SET @instValue_121 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 2, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_121 IS NOT NULL,@instID,0),@instValue_121);


-- Turnover rate (Supervisors; promotion) (Grand Gedeh)
SET @instID = 122;
SET @instValue_122 := (
	SELECT `lastmile_dataportal`.turnover(@oneMonthIntervalStart, @oneMonthIntervalEnd, 23, 5, 6)
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_122 IS NOT NULL,@instID,0),@instValue_122);


-- Turnover rate (Supervisors; other/unknown) (Grand Gedeh)
SET @instID = 123;
SET @instValue_123 := (
	@instValue_119 - ( @instValue_120 + @instValue_121 + @instValue_122 )
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_123 IS NOT NULL,@instID,0),@instValue_123);


-- Number of attempted supervision visits (Gboe-Ploe)
SET @instID = 124;
SET @instValue_124 := (
	SELECT nSupVisitsAttempted FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_124 IS NOT NULL,@instID,0),@instValue_124);


-- Number of attempted supervision visits (Rivercess cohort 1)
SET @instID = 125;
SET @instValue_125 := (
	SELECT nSupVisitsAttempted FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_125 IS NOT NULL,@instID,0),@instValue_125);


-- Number of attempted supervision visits (Rivercess cohort 2)
SET @instID = 126;
SET @instValue_126 := (
	SELECT nSupVisitsAttempted FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_126 IS NOT NULL,@instID,0),@instValue_126);


-- CHW attendance rate at supervision (Gboe-Ploe)
SET @instID = 127;
SET @instValue_127 := (
	SELECT ROUND(1-(nCHWAbsent/nSupVisitsAttempted),3) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_127 IS NOT NULL,@instID,0),@instValue_127);


-- CHW attendance rate at supervision (Rivercess cohort 1)
SET @instID = 128;
SET @instValue_128 := (
	SELECT ROUND(1-(nCHWAbsent/nSupVisitsAttempted),3) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_128 IS NOT NULL,@instID,0),@instValue_128);


-- CHW attendance rate at supervision (Rivercess cohort 2)
SET @instID = 129;
SET @instValue_129 := (
	SELECT ROUND(1-(nCHWAbsent/nSupVisitsAttempted),3) FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_129 IS NOT NULL,@instID,0),@instValue_129);


-- Number of unexcused absences at supervision (Gboe-Ploe)
SET @instID = 130;
SET @instValue_130 := (
	SELECT nCHWAbsent - nCHWAbsentExcused FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_130 IS NOT NULL,@instID,0),@instValue_130);


-- Number of unexcused absences at supervision (Rivercess cohort 1)
SET @instID = 131;
SET @instValue_131 := (
	SELECT nCHWAbsent - nCHWAbsentExcused FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_131 IS NOT NULL,@instID,0),@instValue_131);


-- Number of unexcused absences at supervision (Rivercess cohort 2)
SET @instID = 132;
SET @instValue_132 := (
	SELECT nCHWAbsent - nCHWAbsentExcused FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_132 IS NOT NULL,@instID,0),@instValue_132);


-- Number of verbal or written warnings given to CHWs (Konobo)
SET @instID = 133;
SET @instValue_133 := (
	SELECT nVerbalWarning + nWrittenWarning FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_133 IS NOT NULL,@instID,0),@instValue_133);


-- Number of verbal or written warnings given to CHWs (Gboe-Ploe)
SET @instID = 134;
SET @instValue_134 := (
	SELECT nVerbalWarning + nWrittenWarning FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_134 IS NOT NULL,@instID,0),@instValue_134);


-- Number of verbal or written warnings given to CHWs (Rivercess cohort 1)
SET @instID = 135;
SET @instValue_135 := (
	SELECT nVerbalWarning + nWrittenWarning FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_135 IS NOT NULL,@instID,0),@instValue_135);


-- Number of verbal or written warnings given to CHWs (Rivercess cohort 2)
SET @instID = 136;
SET @instValue_136 := (
	SELECT nVerbalWarning + nWrittenWarning FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_136 IS NOT NULL,@instID,0),@instValue_136);


-- Number of births (Gboe-Ploe)
SET @instID = 137;
SET @instValue_137 := (
	SELECT nBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_137 IS NOT NULL,@instID,0),@instValue_137);


-- Number of births (Rivercess cohort 1)
SET @instID = 138;
SET @instValue_138 := (
	SELECT nBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_138 IS NOT NULL,@instID,0),@instValue_138);


-- Number of births (Rivercess cohort 2)
SET @instID = 139;
SET @instValue_139 := (
	SELECT nBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_139 IS NOT NULL,@instID,0),@instValue_139);


-- Number of deaths (neonatal) (Gboe-Ploe)
SET @instID = 140;
SET @instValue_140 := (
	SELECT nDeathsNeonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_140 IS NOT NULL,@instID,0),@instValue_140);


-- Number of deaths (neonatal) (Rivercess cohort 1)
SET @instID = 141;
SET @instValue_141 := (
	SELECT nDeathsNeonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_141 IS NOT NULL,@instID,0),@instValue_141);


-- Number of deaths (neonatal) (Rivercess cohort 2)
SET @instID = 142;
SET @instValue_142 := (
	SELECT nDeathsNeonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_142 IS NOT NULL,@instID,0),@instValue_142);


-- Number of deaths (post-neonatal) (Gboe-Ploe)
SET @instID = 143;
SET @instValue_143 := (
	SELECT nDeathsPostneonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_143 IS NOT NULL,@instID,0),@instValue_143);


-- Number of deaths (post-neonatal) (Rivercess cohort 1)
SET @instID = 144;
SET @instValue_144 := (
	SELECT nDeathsPostneonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_144 IS NOT NULL,@instID,0),@instValue_144);


-- Number of deaths (post-neonatal) (Rivercess cohort 2)
SET @instID = 145;
SET @instValue_145 := (
	SELECT nDeathsPostneonatal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_145 IS NOT NULL,@instID,0),@instValue_145);


-- Number of deaths (child) (Gboe-Ploe)
SET @instID = 146;
SET @instValue_146 := (
	SELECT nDeathsChild FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_146 IS NOT NULL,@instID,0),@instValue_146);


-- Number of deaths (child) (Rivercess cohort 1)
SET @instID = 147;
SET @instValue_147 := (
	SELECT nDeathsChild FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_147 IS NOT NULL,@instID,0),@instValue_147);


-- Number of deaths (child) (Rivercess cohort 2)
SET @instID = 148;
SET @instValue_148 := (
	SELECT nDeathsChild FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_148 IS NOT NULL,@instID,0),@instValue_148);


-- Number of child cases of malaria treated (Rivercess cohort 2)
SET @instID = 149;
SET @instValue_149 := (
	SELECT nMalaria FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_149 IS NOT NULL,@instID,0),@instValue_149);


-- Number of child cases of diarrhea treated (Rivercess cohort 2)
SET @instID = 150;
SET @instValue_150 := (
	SELECT nDiarrhea FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_150 IS NOT NULL,@instID,0),@instValue_150);


-- Number of child cases of ARI treated (Rivercess cohort 2)
SET @instID = 151;
SET @instValue_151 := (
	SELECT nARI FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_151 IS NOT NULL,@instID,0),@instValue_151);


-- Number of malnutrition referrals (Konobo)
SET @instID = 155;
SET @instValue_155 := (
	SELECT nMalnutrition FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_155 IS NOT NULL,@instID,0),@instValue_155);


-- Number of malnutrition referrals (Konobo)
SET @instID = 156;
SET @instValue_156 := (
	SELECT nMalnutrition FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_156 IS NOT NULL,@instID,0),@instValue_156);


-- Number of malnutrition referrals (Rivercess cohort 1)
SET @instID = 157;
SET @instValue_157 := (
	SELECT nMalnutrition FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_157 IS NOT NULL,@instID,0),@instValue_157);


-- Number of malnutrition referrals (Rivercess cohort 2)
SET @instID = 158;
SET @instValue_158 := (
	SELECT nMalnutrition FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_158 IS NOT NULL,@instID,0),@instValue_158);


-- Number of vaccination referrals (Konobo)
SET @instID = 159;
SET @instValue_159 := (
	SELECT nVaccineReferrals FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_159 IS NOT NULL,@instID,0),@instValue_159);


-- Number of vaccination referrals (Gboe-Ploe)
SET @instID = 160;
SET @instValue_160 := (
	SELECT nVaccineReferrals FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_160 IS NOT NULL,@instID,0),@instValue_160);


-- Number of vaccination referrals (Rivercess cohort 1)
SET @instID = 161;
SET @instValue_161 := (
	SELECT nVaccineReferrals FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_161 IS NOT NULL,@instID,0),@instValue_161);


-- Number of vaccination referrals (Rivercess cohort 2)
SET @instID = 162;
SET @instValue_162 := (
	SELECT nVaccineReferrals FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_162 IS NOT NULL,@instID,0),@instValue_162);


-- Number of deaths (over-five) (Gboe-Ploe)
SET @instID = 163;
SET @instValue_163 := (
	SELECT nDeathsAdult FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_163 IS NOT NULL,@instID,0),@instValue_163);


-- Number of deaths (over-five) (Rivercess cohort 1)
SET @instID = 164;
SET @instValue_164 := (
	SELECT nDeathsAdult FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_164 IS NOT NULL,@instID,0),@instValue_164);


-- Number of deaths (over-five) (Rivercess cohort 2)
SET @instID = 165;
SET @instValue_165 := (
	SELECT nDeathsAdult FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_165 IS NOT NULL,@instID,0),@instValue_165);


-- Number of deaths (maternal) (Konobo)
SET @instID = 166;
SET @instValue_166 := (
	SELECT nDeathsMaternal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_166 IS NOT NULL,@instID,0),@instValue_166);


-- Number of deaths (maternal) (Gboe-Ploe)
SET @instID = 167;
SET @instValue_167 := (
	SELECT nDeathsMaternal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_167 IS NOT NULL,@instID,0),@instValue_167);


-- Number of deaths (maternal) (Rivercess cohort 1)
SET @instID = 168;
SET @instValue_168 := (
	SELECT nDeathsMaternal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_168 IS NOT NULL,@instID,0),@instValue_168);


-- Number of deaths (maternal) (Rivercess cohort 2)
SET @instID = 169;
SET @instValue_169 := (
	SELECT nDeathsMaternal FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_169 IS NOT NULL,@instID,0),@instValue_169);


-- Number of stillbirths (Konobo)
SET @instID = 170;
SET @instValue_170 := (
	SELECT nStillBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_170 IS NOT NULL,@instID,0),@instValue_170);


-- Number of stillbirths (Gboe-Ploe)
SET @instID = 171;
SET @instValue_171 := (
	SELECT nStillBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_171 IS NOT NULL,@instID,0),@instValue_171);


-- Number of stillbirths (Rivercess cohort 1)
SET @instID = 172;
SET @instValue_172 := (
	SELECT nStillBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_172 IS NOT NULL,@instID,0),@instValue_172);


-- Number of stillbirths (Rivercess cohort 2)
SET @instID = 173;
SET @instValue_173 := (
	SELECT nStillBirths FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_173 IS NOT NULL,@instID,0),@instValue_173);


-- Average number of supervision visits per CHW (Gboe-Ploe)
SET @instID = 174;
SET @nSuccessfulSupervisionVisits := (
	SELECT nSupVisitsAttempted - nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
SET @instValue_174 := @nSuccessfulSupervisionVisits / @CHWs_GP_rep;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_174 IS NOT NULL,@instID,0),@instValue_174);


-- Average number of supervision visits per CHW (Rivercess cohort 1)
SET @instID = 175;
SET @nSuccessfulSupervisionVisits := (
	SELECT nSupVisitsAttempted - nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
SET @instValue_175 := @nSuccessfulSupervisionVisits / @CHWs_RC1_rep;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_175 IS NOT NULL,@instID,0),@instValue_175);


-- Average number of supervision visits per CHW (Rivercess cohort 2)
SET @instID = 176;
SET @nSuccessfulSupervisionVisits := (
	SELECT nSupVisitsAttempted - nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
SET @instValue_176 := @nSuccessfulSupervisionVisits / @CHWs_RC2_rep;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_176 IS NOT NULL,@instID,0),@instValue_176);


-- Number of routine visits conducted (Konobo)
SET @instID = 177;
SET @instValue_177 := (
	SELECT nRoutineVisits FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_177 IS NOT NULL,@instID,0),@instValue_177);


-- Number of routine visits conducted (Gboe-Ploe)
SET @instID = 178;
SET @instValue_178 := (
	SELECT nRoutineVisits FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_178 IS NOT NULL,@instID,0),@instValue_178);


-- Number of routine visits conducted (Rivercess cohort 1)
SET @instID = 179;
SET @instValue_179 := (
	SELECT nRoutineVisits FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_179 IS NOT NULL,@instID,0),@instValue_179);


-- Number of routine visits conducted (Rivercess cohort 2)
SET @instID = 180;
SET @instValue_180 := (
	SELECT nRoutineVisits FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_180 IS NOT NULL,@instID,0),@instValue_180);


-- Number of CHC meetings (Konobo)
SET @instID = 181;
SET @instValue_181 := (
	SELECT nMetWithCHC FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_181 IS NOT NULL,@instID,0),@instValue_181);


-- Number of CHC meetings (Gboe-Ploe)
SET @instID = 182;
SET @instValue_182 := (
	SELECT nMetWithCHC FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_182 IS NOT NULL,@instID,0),@instValue_182);


-- Number of CHC meetings (Rivercess cohort 1)
SET @instID = 183;
SET @instValue_183 := (
	SELECT nMetWithCHC FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_183 IS NOT NULL,@instID,0),@instValue_183);


-- Number of CHC meetings (Rivercess cohort 2)
SET @instID = 184;
SET @instValue_184 := (
	SELECT nMetWithCHC FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_184 IS NOT NULL,@instID,0),@instValue_184);


-- Number of CHWs deployed (Rivercess 1)
SET @instID = 185;
SET @instValue_185 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Rivercess 1' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_185 IS NOT NULL,@instID,0),@instValue_185);


-- Number of CHWs deployed (Rivercess 2)
SET @instID = 186;
SET @instValue_186 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 1 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Rivercess 2' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_186 IS NOT NULL,@instID,0),@instValue_186);


-- Number of people served (Rivercess 1)
-- !!!!! Owen TO DO !!!!!
SET @instID = 187;


-- Number of people served (Rivercess 2)
-- !!!!! Owen TO DO !!!!!
SET @instID = 188;


-- Number of CHW Leaders (Rivercess 1)
SET @instID = 191;
SET @instValue_191 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 2 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Rivercess 1' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_191 IS NOT NULL,@instID,0),@instValue_191);


-- Number of CHW Leaders (Rivercess 2)
SET @instID = 192;
SET @instValue_192 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 2 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Rivercess 2' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_192 IS NOT NULL,@instID,0),@instValue_192);


-- Number of Community Clinical Supervisors (Rivercess 1)
SET @instID = 193;
SET @instValue_193 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 3 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Rivercess 1' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_193 IS NOT NULL,@instID,0),@instValue_193);


-- Number of Community Clinical Supervisors (Rivercess 2)
SET @instID = 194;
SET @instValue_194 := (
	SELECT count(*) FROM lastmile_chwdb.admin_staff WHERE 
		lastmile_chwdb.staffPosition(staffID,@p_date) = 3 AND 
		lastmile_chwdb.staffCohort(staffID) = 'Rivercess 2' AND 
		lastmile_chwdb.staffIsActive(staffID,@p_date) = 1
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_194 IS NOT NULL,@instID,0),@instValue_194);


-- Reporting rate (Konobo)
SET @instID = 195;
SET @instValue_195 := ROUND(@CHWs_K_rep/@CHWs_K,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_195 IS NOT NULL,@instID,0),@instValue_195);


-- Reporting rate (Gboe-Ploe)
SET @instID = 196;
SET @instValue_196 := ROUND(@CHWs_GP_rep/@CHWs_GP,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_196 IS NOT NULL,@instID,0),@instValue_196);


-- Reporting rate (Rivercess cohort 1)
SET @instID = 197;
SET @instValue_197 := ROUND(@CHWs_RC1_rep/@CHWs_RC1,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_197 IS NOT NULL,@instID,0),@instValue_197);


-- Reporting rate (Rivercess cohort 2)
SET @instID = 198;
SET @instValue_198 := ROUND(@CHWs_RC2_rep/@CHWs_RC2,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_198 IS NOT NULL,@instID,0),@instValue_198);


-- Number of vaccination referrals per CHW (Konobo)
SET @instID = 199;
SET @instValue_199 := ROUND(@instValue_159/@CHWs_K,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_199 IS NOT NULL,@instID,0),@instValue_199);


-- Number of vaccination referrals per CHW (Gboe-Ploe)
SET @instID = 200;
SET @instValue_200 := ROUND(@instValue_160/@CHWs_GP,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_200 IS NOT NULL,@instID,0),@instValue_200);


-- Number of vaccination referrals per CHW (Rivercess cohort 1)
SET @instID = 201;
SET @instValue_201 := ROUND(@instValue_161/@CHWs_RC1,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_201 IS NOT NULL,@instID,0),@instValue_201);


-- Number of vaccination referrals per CHW (Rivercess cohort 2)
SET @instID = 202;
SET @instValue_202 := ROUND(@instValue_162/@CHWs_RC2,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_202 IS NOT NULL,@instID,0),@instValue_202);


-- Number of routine visits per CHW (Konobo)
SET @instID = 203;
SET @instValue_203 := ROUND(@instValue_177/@CHWs_K,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_203 IS NOT NULL,@instID,0),@instValue_203);


-- Number of routine visits per CHW (Gboe-Ploe)
SET @instID = 204;
SET @instValue_204 := ROUND(@instValue_178/@CHWs_GP,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_204 IS NOT NULL,@instID,0),@instValue_204);


-- Number of routine visits per CHW (Rivercess cohort 1)
SET @instID = 205;
SET @instValue_205 := ROUND(@instValue_179/@CHWs_RC1,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_205 IS NOT NULL,@instID,0),@instValue_205);


-- Number of routine visits per CHW (Rivercess cohort 2)
SET @instID = 206;
SET @instValue_206 := ROUND(@instValue_180/@CHWs_RC2,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_206 IS NOT NULL,@instID,0),@instValue_206);


-- Number of child cases of malaria treated, per CHW (Konobo)
SET @instID = 207;
SET @instValue_207 := ROUND(@instValue_31/@CHWs_K,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_207 IS NOT NULL,@instID,0),@instValue_207);


-- Number of child cases of malaria treated, per CHW (Gboe-Ploe)
SET @instID = 208;
SET @instValue_208 := ROUND(@instValue_80/@CHWs_GP,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_208 IS NOT NULL,@instID,0),@instValue_208);


-- Number of child cases of malaria treated, per CHW (Rivercess cohort 1)
SET @instID = 209;
SET @instValue_209 := ROUND(@instValue_111/@CHWs_RC1,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_209 IS NOT NULL,@instID,0),@instValue_209);


-- Number of child cases of malaria treated, per CHW (Rivercess cohort 2)
SET @instID = 210;
SET @instValue_210 := ROUND(@instValue_149/@CHWs_RC2,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_210 IS NOT NULL,@instID,0),@instValue_210);


-- Number of child cases of diarrhea treated, per CHW (Konobo)
SET @instID = 211;
SET @instValue_211 := ROUND(@instValue_32/@CHWs_K,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_211 IS NOT NULL,@instID,0),@instValue_211);


-- Number of child cases of diarrhea treated, per CHW (Gboe-Ploe)
SET @instID = 212;
SET @instValue_212 := ROUND(@instValue_81/@CHWs_GP,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_212 IS NOT NULL,@instID,0),@instValue_212);


-- Number of child cases of diarrhea treated, per CHW (Rivercess cohort 1)
SET @instID = 213;
SET @instValue_213 := ROUND(@instValue_112/@CHWs_RC1,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_213 IS NOT NULL,@instID,0),@instValue_213);


-- Number of child cases of diarrhea treated, per CHW (Rivercess cohort 2)
SET @instID = 214;
SET @instValue_214 := ROUND(@instValue_150/@CHWs_RC2,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_214 IS NOT NULL,@instID,0),@instValue_214);


-- Number of child cases of ARI treated, per CHW (Konobo)
SET @instID = 215;
SET @instValue_215 := ROUND(@instValue_33/@CHWs_K,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_215 IS NOT NULL,@instID,0),@instValue_215);


-- Number of child cases of ARI treated, per CHW (Gboe-Ploe)
SET @instID = 216;
SET @instValue_216 := ROUND(@instValue_82/@CHWs_GP,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_216 IS NOT NULL,@instID,0),@instValue_216);


-- Number of child cases of ARI treated, per CHW (Rivercess cohort 1)
SET @instID = 217;
SET @instValue_217 := ROUND(@instValue_113/@CHWs_RC1,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_217 IS NOT NULL,@instID,0),@instValue_217);


-- Number of child cases of ARI treated, per CHW (Rivercess cohort 2)
SET @instID = 218;
SET @instValue_218 := ROUND(@instValue_151/@CHWs_RC2,1);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_218 IS NOT NULL,@instID,0),@instValue_218);


-- Number of CHW supervisors (Rivercess cohort 1)
SET @instID = 219;
SET @instValue_219 := @instValue_191 + @instValue_193;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_219 IS NOT NULL,@instID,0),@instValue_219);


-- Number of CHW supervisors (Rivercess cohort 2)
SET @instID = 220;
SET @instValue_220 := @instValue_192 + @instValue_194;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_220 IS NOT NULL,@instID,0),@instValue_220);


-- Number of actual supervision visits (Konobo)
SET @instID = 221;
SET @instValue_221 := (
	SELECT nSupVisitsAttempted-nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_221 IS NOT NULL,@instID,0),@instValue_221);


-- Number of actual supervision visits (Gboe-Ploe)
SET @instID = 222;
SET @instValue_222 := (
	SELECT nSupVisitsAttempted-nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_222 IS NOT NULL,@instID,0),@instValue_222);


-- Number of actual supervision visits (Rivercess cohort 1)
SET @instID = 223;
SET @instValue_223 := (
	SELECT nSupVisitsAttempted-nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_223 IS NOT NULL,@instID,0),@instValue_223);


-- Number of actual supervision visits (Rivercess cohort 2)
SET @instID = 224;
SET @instValue_224 := (
	SELECT nSupVisitsAttempted-nCHWAbsent FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_224 IS NOT NULL,@instID,0),@instValue_224);


-- Number of infants being tracked for vaccinations by CHWs (quarterly) (Konobo)
SET @instID = 239;
SET @instValue_239 := (
	SELECT sum(infantNeedsRound1) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_239 := if(@isEndOfQuarter,@instValue_239,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_239 IS NOT NULL,@instID,0),@instValue_239);


-- Number of infants being tracked for vaccinations by CHWs (quarterly) (Gboe-Ploe)
SET @instID = 240;
SET @instValue_240 := (
	SELECT sum(infantNeedsRound1) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_240 := if(@isEndOfQuarter,@instValue_240,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_240 IS NOT NULL,@instID,0),@instValue_240);


-- Number of infants being tracked for vaccinations by CHWs (quarterly) (Rivercess cohort 1)
SET @instID = 241;
SET @instValue_241 := (
	SELECT sum(infantNeedsRound1) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_241 := if(@isEndOfQuarter,@instValue_241,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_241 IS NOT NULL,@instID,0),@instValue_241);


-- Number of infants being tracked for vaccinations by CHWs (quarterly) (Rivercess cohort 2)
SET @instID = 242;
SET @instValue_242 := (
	SELECT sum(infantNeedsRound1) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_242 := if(@isEndOfQuarter,@instValue_242,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_242 IS NOT NULL,@instID,0),@instValue_242);


-- Percent of infants at least 7 days old who have received BCG + OPV-0 (quarterly) (Konobo)
SET @instID = 243;
SET @instValue_243 := (
	SELECT ROUND(sum(infantReceivedRound1)/sum(infantNeedsRound1),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_243 := if(@isEndOfQuarter,@instValue_243,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_243 IS NOT NULL,@instID,0),@instValue_243);


-- Percent of infants at least 7 days old who have received BCG + OPV-0 (quarterly) (Gboe-Ploe)
SET @instID = 244;
SET @instValue_244 := (
	SELECT ROUND(sum(infantReceivedRound1)/sum(infantNeedsRound1),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_244 := if(@isEndOfQuarter,@instValue_244,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_244 IS NOT NULL,@instID,0),@instValue_244);


-- Percent of infants at least 7 days old who have received BCG + OPV-0 (quarterly) (Rivercess cohort 1)
SET @instID = 245;
SET @instValue_245 := (
	SELECT ROUND(sum(infantReceivedRound1)/sum(infantNeedsRound1),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_245 := if(@isEndOfQuarter,@instValue_245,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_245 IS NOT NULL,@instID,0),@instValue_245);


-- Percent of infants at least 7 days old who have received BCG + OPV-0 (quarterly) (Rivercess cohort 2)
SET @instID = 246;
SET @instValue_246 := (
	SELECT ROUND(sum(infantReceivedRound1)/sum(infantNeedsRound1),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_246 := if(@isEndOfQuarter,@instValue_246,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_246 IS NOT NULL,@instID,0),@instValue_246);


-- Percent of infants at least 10 weeks old who have received OPV-1 + Penta-1 (quarterly) (Konobo)
SET @instID = 247;
SET @instValue_247 := (
	SELECT ROUND(sum(infantReceivedRound2)/sum(infantNeedsRound2),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_247 := if(@isEndOfQuarter,@instValue_247,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_247 IS NOT NULL,@instID,0),@instValue_247);


-- Percent of infants at least 10 weeks old who have received OPV-1 + Penta-1 (quarterly) (Gboe-Ploe)
SET @instID = 248;
SET @instValue_248 := (
	SELECT ROUND(sum(infantReceivedRound2)/sum(infantNeedsRound2),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_248 := if(@isEndOfQuarter,@instValue_248,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_248 IS NOT NULL,@instID,0),@instValue_248);


-- Percent of infants at least 10 weeks old who have received OPV-1 + Penta-1 (quarterly) (Rivercess cohort 1)
SET @instID = 249;
SET @instValue_249 := (
	SELECT ROUND(sum(infantReceivedRound2)/sum(infantNeedsRound2),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_249 := if(@isEndOfQuarter,@instValue_249,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_249 IS NOT NULL,@instID,0),@instValue_249);


-- Percent of infants at least 10 weeks old who have received OPV-1 + Penta-1 (quarterly) (Rivercess cohort 2)
SET @instID = 250;
SET @instValue_250 := (
	SELECT ROUND(sum(infantReceivedRound2)/sum(infantNeedsRound2),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_250 := if(@isEndOfQuarter,@instValue_250,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_250 IS NOT NULL,@instID,0),@instValue_250);


-- Percent of infants at least 14 weeks old who have received OPV-2 + Penta-2 (quarterly) (Konobo)
SET @instID = 251;
SET @instValue_251 := (
	SELECT ROUND(sum(infantReceivedRound3)/sum(infantNeedsRound3),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_251 := if(@isEndOfQuarter,@instValue_251,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_251 IS NOT NULL,@instID,0),@instValue_251);


-- Percent of infants at least 14 weeks old who have received OPV-2 + Penta-2 (quarterly) (Gboe-Ploe)
SET @instID = 252;
SET @instValue_252 := (
	SELECT ROUND(sum(infantReceivedRound3)/sum(infantNeedsRound3),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_252 := if(@isEndOfQuarter,@instValue_252,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_252 IS NOT NULL,@instID,0),@instValue_252);


-- Percent of infants at least 14 weeks old who have received OPV-2 + Penta-2 (quarterly) (Rivercess cohort 1)
SET @instID = 253;
SET @instValue_253 := (
	SELECT ROUND(sum(infantReceivedRound3)/sum(infantNeedsRound3),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_253 := if(@isEndOfQuarter,@instValue_253,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_253 IS NOT NULL,@instID,0),@instValue_253);


-- Percent of infants at least 14 weeks old who have received OPV-2 + Penta-2 (quarterly) (Rivercess cohort 2)
SET @instID = 254;
SET @instValue_254 := (
	SELECT ROUND(sum(infantReceivedRound3)/sum(infantNeedsRound3),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_254 := if(@isEndOfQuarter,@instValue_254,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_254 IS NOT NULL,@instID,0),@instValue_254);


-- Percent of infants at least 18 weeks old who have received OPV-3 + Penta-3 (quarterly) (Konobo)
SET @instID = 255;
SET @instValue_255 := (
	SELECT ROUND(sum(infantReceivedRound4)/sum(infantNeedsRound4),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_255 := if(@isEndOfQuarter,@instValue_255,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_255 IS NOT NULL,@instID,0),@instValue_255);


-- Percent of infants at least 18 weeks old who have received OPV-3 + Penta-3 (quarterly) (Gboe-Ploe)
SET @instID = 256;
SET @instValue_256 := (
	SELECT ROUND(sum(infantReceivedRound4)/sum(infantNeedsRound4),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_256 := if(@isEndOfQuarter,@instValue_256,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_256 IS NOT NULL,@instID,0),@instValue_256);


-- Percent of infants at least 18 weeks old who have received OPV-3 + Penta-3 (quarterly) (Rivercess cohort 1)
SET @instID = 257;
SET @instValue_257 := (
	SELECT ROUND(sum(infantReceivedRound4)/sum(infantNeedsRound4),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_257 := if(@isEndOfQuarter,@instValue_257,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_257 IS NOT NULL,@instID,0),@instValue_257);


-- Percent of infants at least 18 weeks old who have received OPV-3 + Penta-3 (quarterly) (Rivercess cohort 2)
SET @instID = 258;
SET @instValue_258 := (
	SELECT ROUND(sum(infantReceivedRound4)/sum(infantNeedsRound4),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_258 := if(@isEndOfQuarter,@instValue_258,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_258 IS NOT NULL,@instID,0),@instValue_258);


-- Percent of infants at least 45 weeks old who have received Measles + Yellow Fever (quarterly) (Konobo)
SET @instID = 259;
SET @instValue_259 := (
	SELECT ROUND(sum(infantReceivedRound5)/sum(infantNeedsRound5),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_259 := if(@isEndOfQuarter,@instValue_259,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_259 IS NOT NULL,@instID,0),@instValue_259);


-- Percent of infants at least 45 weeks old who have received Measles + Yellow Fever (quarterly) (Gboe-Ploe)
SET @instID = 260;
SET @instValue_260 := (
	SELECT ROUND(sum(infantReceivedRound5)/sum(infantNeedsRound5),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_260 := if(@isEndOfQuarter,@instValue_260,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_260 IS NOT NULL,@instID,0),@instValue_260);


-- Percent of infants at least 45 weeks old who have received Measles + Yellow Fever (quarterly) (Rivercess cohort 1)
SET @instID = 261;
SET @instValue_261 := (
	SELECT ROUND(sum(infantReceivedRound5)/sum(infantNeedsRound5),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_261 := if(@isEndOfQuarter,@instValue_261,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_261 IS NOT NULL,@instID,0),@instValue_261);


-- Percent of infants at least 45 weeks old who have received Measles + Yellow Fever (quarterly) (Rivercess cohort 2)
SET @instID = 262;
SET @instValue_262 := (
	SELECT ROUND(sum(infantReceivedRound5)/sum(infantNeedsRound5),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker1
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_262 := if(@isEndOfQuarter,@instValue_262,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_262 IS NOT NULL,@instID,0),@instValue_262);


-- Percent of infants at least 7 days old on track for full vaccination (quarterly) (Konobo)
SET @instID = 263;
SET @instValue_263 := (
	SELECT ROUND(sum(onTrack)/count(onTrack),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker2
	WHERE cohort='Konobo' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_263 := if(@isEndOfQuarter,@instValue_263,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_263 IS NOT NULL,@instID,0),@instValue_263);


-- Percent of infants at least 7 days old on track for full vaccination (quarterly) (Gboe-Ploe)
SET @instID = 264;
SET @instValue_264 := (
	SELECT ROUND(sum(onTrack)/count(onTrack),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker2
	WHERE cohort='Gboe-Ploe' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_264 := if(@isEndOfQuarter,@instValue_264,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_264 IS NOT NULL,@instID,0),@instValue_264);


-- Percent of infants at least 7 days old on track for full vaccination (quarterly) (Rivercess cohort 1)
SET @instID = 265;
SET @instValue_265 := (
	SELECT ROUND(sum(onTrack)/count(onTrack),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker2
	WHERE cohort='Rivercess 1' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_265 := if(@isEndOfQuarter,@instValue_265,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_265 IS NOT NULL,@instID,0),@instValue_265);


-- Percent of infants at least 7 days old on track for full vaccination (quarterly) (Rivercess cohort 2)
SET @instID = 266;
SET @instValue_266 := (
	SELECT ROUND(sum(onTrack)/count(onTrack),3) FROM lastmile_dataportal.TEMP_view_vaccinetracker2
	WHERE cohort='Rivercess 2' AND (
		(vaccYear=@p_year AND vaccMonth=@p_month) OR 
		(vaccYear=@p_yearMinus1 AND vaccMonth=@p_monthMinus1) OR 
		(vaccYear=@p_yearMinus2 AND vaccMonth=@p_monthMinus2)
	)
);
SET @instValue_266 := if(@isEndOfQuarter,@instValue_266,NULL);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_266 IS NOT NULL,@instID,0),@instValue_266);


-- Number of child cases of ARI treated (---)
SET @instID = 267;
SET @instValue_267 := (
	SELECT nARI FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_267 IS NOT NULL,@instID,0),@instValue_267);


-- Number of child cases of malaria treated (---)
SET @instID = 268;
SET @instValue_268 := (
	SELECT nMalaria FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_268 IS NOT NULL,@instID,0),@instValue_268);


-- Number of child cases of diarrhea treated (---)
SET @instID = 269;
SET @instValue_269 := (
	SELECT nDiarrhea FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_269 IS NOT NULL,@instID,0),@instValue_269);


-- Cumulative number of malaria cases treated (---)
SET @instID = 270;
SET @instValue_270 := (
	SELECT instValue FROM lastmile_dataportal.tbl_values 
    WHERE `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND instID=@instID
);
SET @instValue_270 := @instValue_270 + @instValue_268;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_270 IS NOT NULL,@instID,0),@instValue_270);


-- Cumulative number of diarrhea cases treated (---)
SET @instID = 271;
SET @instValue_271 := (
	SELECT instValue FROM lastmile_dataportal.tbl_values 
    WHERE `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND instID=@instID
);
SET @instValue_271 := @instValue_271 + @instValue_269;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_271 IS NOT NULL,@instID,0),@instValue_271);


-- Cumulative number of ARI cases treated (---)
SET @instID = 272;
SET @instValue_272 := (
	SELECT instValue FROM lastmile_dataportal.tbl_values 
    WHERE `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND instID=@instID
);
SET @instValue_272 := @instValue_272 + @instValue_267;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_272 IS NOT NULL,@instID,0),@instValue_272);


-- Cumulative number of routine visits conducted (---)
SET @instID = 273;
SET @instValue_273 := (
	SELECT instValue FROM lastmile_dataportal.tbl_values 
    WHERE `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND instID=@instID
);
SET @instValue_273 := @instValue_273 + @instValue_177 + @instValue_178 + @instValue_179 + @instValue_180;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_273 IS NOT NULL,@instID,0),@instValue_273);


-- Cumulative number of supervision visits conducted (---)
SET @instID = 274;
SET @instValue_274 := (
	SELECT instValue FROM lastmile_dataportal.tbl_values 
    WHERE `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND instID=@instID
);
SET @instValue_274 := @instValue_274 + @instValue_221 + @instValue_222 + @instValue_223 + @instValue_224;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_274 IS NOT NULL,@instID,0),@instValue_274);


-- Cumulative number of births tracked by CHWs (---)
SET @instID = 275;
SET @instValue_275 := (
	SELECT instValue FROM lastmile_dataportal.tbl_values 
    WHERE `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND instID=@instID
);
SET @instValue_275 := @instValue_275 + @instValue_37 + @instValue_137 + @instValue_138 + @instValue_139;
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_275 IS NOT NULL,@instID,0),@instValue_275);


-- Average audit score (Konobo)
SET @instID = 276;
SET @instValue_276 := (
	SELECT ((auditScore_w1*nAudits_w1)+(auditScore_w2*nAudits_w2)+(auditScore_w3*nAudits_w3)+(auditScore_w4*nAudits_w4))/(nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_276 IS NOT NULL,@instID,0),@instValue_276);


-- Average audit score (Gboe-Ploe)
SET @instID = 277;
SET @instValue_277 := (
	SELECT ((auditScore_w1*nAudits_w1)+(auditScore_w2*nAudits_w2)+(auditScore_w3*nAudits_w3)+(auditScore_w4*nAudits_w4))/(nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_277 IS NOT NULL,@instID,0),@instValue_277);


-- Average audit score (Rivercess 1)
SET @instID = 278;
SET @instValue_278 := (
	SELECT ((auditScore_w1*nAudits_w1)+(auditScore_w2*nAudits_w2)+(auditScore_w3*nAudits_w3)+(auditScore_w4*nAudits_w4))/(nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_278 IS NOT NULL,@instID,0),@instValue_278);


-- Average audit score (Rivercess 2)
SET @instID = 279;
SET @instValue_279 := (
	SELECT ((auditScore_w1*nAudits_w1)+(auditScore_w2*nAudits_w2)+(auditScore_w3*nAudits_w3)+(auditScore_w4*nAudits_w4))/(nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_279 IS NOT NULL,@instID,0),@instValue_279);


-- Patient audit rate (Konobo)
SET @instID = 280;
SET @instValue_280 := (
	SELECT (nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
SET @instValue_280 := ROUND(@instValue_280/@instValue_221,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_280 IS NOT NULL,@instID,0),@instValue_280);


-- Patient audit rate (Gboe-Ploe)
SET @instID = 281;
SET @instValue_281 := (
	SELECT (nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
SET @instValue_281 := ROUND(@instValue_281/@instValue_222,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_281 IS NOT NULL,@instID,0),@instValue_281);


-- Patient audit rate (Rivercess 1)
SET @instID = 282;
SET @instValue_282 := (
	SELECT (nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
SET @instValue_282 := ROUND(@instValue_282/@instValue_223,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_282 IS NOT NULL,@instID,0),@instValue_282);


-- Patient audit rate (Rivercess 2)
SET @instID = 283;
SET @instValue_283 := (
	SELECT (nAudits_w1 + nAudits_w2 + nAudits_w3 + nAudits_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
SET @instValue_283 := ROUND(@instValue_283/@instValue_224,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_283 IS NOT NULL,@instID,0),@instValue_283);


-- Home visit evaluation rate (Konobo)
SET @instID = 284;
SET @instValue_284 := (
	SELECT (nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
SET @instValue_284 := ROUND(@instValue_284/@instValue_221,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_284 IS NOT NULL,@instID,0),@instValue_284);


-- Home visit evaluation rate (Gboe-Ploe)
SET @instID = 285;
SET @instValue_285 := (
	SELECT (nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
SET @instValue_285 := ROUND(@instValue_285/@instValue_221,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_285 IS NOT NULL,@instID,0),@instValue_285);


-- Home visit evaluation rate (Rivercess 1)
SET @instID = 286;
SET @instValue_286 := (
	SELECT (nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
SET @instValue_286 := ROUND(@instValue_286/@instValue_221,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_286 IS NOT NULL,@instID,0),@instValue_286);


-- Home visit evaluation rate (Rivercess 2)
SET @instID = 287;
SET @instValue_287 := (
	SELECT (nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
SET @instValue_287 := ROUND(@instValue_287/@instValue_221,3);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_287 IS NOT NULL,@instID,0),@instValue_287);


-- Average audit score (Konobo)
SET @instID = 288;
SET @instValue_288 := (
	SELECT ((homeVisitEvalScore_w1*nHomeVisitEvals_w1)+(homeVisitEvalScore_w2*nHomeVisitEvals_w2)+(homeVisitEvalScore_w3*nHomeVisitEvals_w3)+(homeVisitEvalScore_w4*nHomeVisitEvals_w4))/(nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Konobo'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_288 IS NOT NULL,@instID,0),@instValue_288);


-- Average audit score (Gboe-Ploe)
SET @instID = 289;
SET @instValue_289 := (
	SELECT ((homeVisitEvalScore_w1*nHomeVisitEvals_w1)+(homeVisitEvalScore_w2*nHomeVisitEvals_w2)+(homeVisitEvalScore_w3*nHomeVisitEvals_w3)+(homeVisitEvalScore_w4*nHomeVisitEvals_w4))/(nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Gboe-Ploe'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_289 IS NOT NULL,@instID,0),@instValue_289);


-- Average audit score (Rivercess 1)
SET @instID = 290;
SET @instValue_290 := (
	SELECT ((homeVisitEvalScore_w1*nHomeVisitEvals_w1)+(homeVisitEvalScore_w2*nHomeVisitEvals_w2)+(homeVisitEvalScore_w3*nHomeVisitEvals_w3)+(homeVisitEvalScore_w4*nHomeVisitEvals_w4))/(nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 1'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_290 IS NOT NULL,@instID,0),@instValue_290);


-- Average audit score (Rivercess 2)
SET @instID = 291;
SET @instValue_291 := (
	SELECT ((homeVisitEvalScore_w1*nHomeVisitEvals_w1)+(homeVisitEvalScore_w2*nHomeVisitEvals_w2)+(homeVisitEvalScore_w3*nHomeVisitEvals_w3)+(homeVisitEvalScore_w4*nHomeVisitEvals_w4))/(nHomeVisitEvals_w1 + nHomeVisitEvals_w2 + nHomeVisitEvals_w3 + nHomeVisitEvals_w4)
    FROM lastmile_dataportal.TEMP_view_msr_cohort
	WHERE yearReported=@p_year AND monthReported=@p_month AND chwCohort='Rivercess 2'
);
REPLACE INTO lastmile_dataportal.tbl_values (`month`,`year`,`instID`,`instValue`) VALUES (@p_month,@p_year,if(@instValue_291 IS NOT NULL,@instID,0),@instValue_291);


-- Drop temporary tables
DROP TABLE IF EXISTS lastmile_dataportal.TEMP_view_msr_cohort;
DROP TABLE IF EXISTS lastmile_dataportal.TEMP_view_vaccinetracker1;
DROP TABLE IF EXISTS lastmile_dataportal.TEMP_view_vaccinetracker2;


-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_storedProcedureLog (`procName`, `procParameters`, `procTimestamp`) VALUES ('dataPortalValues END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$
DELIMITER ;
