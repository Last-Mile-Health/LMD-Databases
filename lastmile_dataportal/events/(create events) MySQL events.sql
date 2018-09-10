/* 
	Author:			Avi Kenny
	Last modified:	2018-02-02
	Description:	This script schedules two MySQL events, described below
*/

-- Setup
USE `lastmile_dataportal`;
DROP EVENT IF EXISTS `evt_dataMartTables`;
DROP EVENT IF EXISTS `evt_dataPortalValues`;

drop event if exists event_data_mart_snapshot_position_cha;

delimiter $$

/*
  Create event_data_mart_snapshot_position_cha

  Runs the data_mart_snapshot_position_cha() procedure once a month at 3am.  The procedure loads
  the data_mart_snapshot_position_cha table, which resides in the lastmile_report schema.

  This procedure needs to run and be completed before 4am, which is when the 
  lastmile_dataportal.updateDataMarts() procedure is called.  This procedure relies
  on the last months snapshot of the position/person tables.

*/
create event event_data_mart_snapshot_position_cha
on schedule every 1 month
starts '2018-06-15 03:00:00'
do begin

	  -- Set date variables
	  set @current_date           = curdate();
	  set @current_year           = year(   curdate() );
	  set @current_month          = month(  curdate() );
	  set @current_year_minus_1   = year(   date_add( curdate(), interval -1 month ) );
	  set @current_month_minus_1  = month(  date_add( curdate(), interval -1 month ) );
	  set @current_date_minus_1   = date(   concat(   @current_year_minus_1, '-', @current_month_minus_1, '-01' ) );

	  call lastmile_report.data_mart_snapshot_position_cha('2012-10-01', @current_date_minus_1, 'MONTH', 'FILLED');
	
end $$



-- Create `evt_dataMartTables`
-- Runs `updateDataMarts` on a daily basis
-- See the procedure code for further documentation

CREATE EVENT evt_dataMartTables
ON SCHEDULE EVERY 1 DAY
STARTS '2016-01-15 03:30:00'
DO 
BEGIN

	CALL `lastmile_dataportal`.`updateDataMarts`();

END $$



-- Create `evt_dataPortalValues`
-- Runs `dataPortalValues` procedure on a monthly basis (for each of the last three months)
-- See the procedure code for further documentation
-- For the last two months, this overwrites existing values
-- This is done because we often get a small number of records 1-2 months late
CREATE EVENT evt_dataPortalValues
ON SCHEDULE EVERY 1 MONTH
STARTS '2016-01-15 04:30:00'
DO 
BEGIN

	-- Set date variables
	SET @currDate = curdate();
	SET @currYear = year(curdate());
	SET @currMonth = month(curdate());
	SET @currYearMinus1 = year(DATE_ADD(curdate(), INTERVAL -1 MONTH));
	SET @currMonthMinus1 = month(DATE_ADD(curdate(), INTERVAL -1 MONTH));
	SET @currDateMinus1 = DATE(CONCAT(@currYearMinus1,'-',@currMonthMinus1,'-01'));
	SET @currYearMinus2 = year(DATE_ADD(curdate(), INTERVAL -2 MONTH));
	SET @currMonthMinus2 = month(DATE_ADD(curdate(), INTERVAL -2 MONTH));
	SET @currYearMinus3 = year(DATE_ADD(curdate(), INTERVAL -3 MONTH));
	SET @currMonthMinus3 = month(DATE_ADD(curdate(), INTERVAL -3 MONTH));
	
	-- Run procedure calls
	CALL `lastmile_dataportal`.`dataPortalValues`(@currMonthMinus3, @currYearMinus3);
	CALL `lastmile_dataportal`.`dataPortalValues`(@currMonthMinus2, @currYearMinus2);
	CALL `lastmile_dataportal`.`dataPortalValues`(@currMonthMinus1, @currYearMinus1);
	CALL `lastmile_dataportal`.`leafletValues`(@currMonthMinus1, @currYearMinus1);
	
END $$

DELIMITER ;
