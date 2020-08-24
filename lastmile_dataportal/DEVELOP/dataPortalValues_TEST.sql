USE `lastmile_dataportal`;
DROP procedure IF EXISTS `dataPortalValues_test`;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `dataPortalValues_test`(IN p_month INT, IN p_year INT)
BEGIN

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

-- Convert date to date_key, the integer representation for a date we are going to use for indexing dimension and fact table dates
set @p_date_key = ( @p_year * 10000 ) + ( @p_month * 100 ) + 1;

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

-- ------ --
-- Begin  --
-- ------ --


-- 7. Monthly supervision rate
-- Calculated from the ODK Supervision Visit Log form
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 7, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.number_supervision, 0 ) / m.num_cha, 1 ) as monthly_rate
from (
      select territory_id, sum( coalesce( supervisionAttendance, 0 ) ) as number_supervision
      from lastmile_report.mart_view_base_odk_supervision
      where manualMonth = @p_month and manualYear = @p_year and not( territory_id is null )
      group by territory_id   
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 

union all

select 7, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.number_supervision, 0 ) ) / sum( m.num_cha ), 1 ) as monthly_rate
from (
      select territory_id, sum( coalesce( supervisionAttendance, 0 ) ) as number_supervision
      from lastmile_report.mart_view_base_odk_supervision
      where manualMonth = @p_month and manualYear = @p_year and not( territory_id is null )
      group by territory_id     
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
;


-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
-- INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('dataPortalValues END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
