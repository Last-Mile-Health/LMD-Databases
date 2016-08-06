DELIMITER $$
CREATE FUNCTION `turnover`(p_startDate DATE, p_endDate DATE, p_positionID INT(5), p_turnoverType INT(5), p_countyID INT(5)) RETURNS decimal(3,3)
BEGIN

# Calculates staff turnover
# Parameters:
#	p_positionID				Corresponds with `admin_position` (1 = CHW, 2 = CHWL, 3 = CCS, 23 = CHWL/CCS)
#	p_countyID					Corresponds with `admin_territoryLevel1` (6 = Grand Gedeh, 14 = Rivercess, ...)
#	p_turnoverType				Corresponds with `admin_reasonPositionEnded` (1 = terminated, 2 = resigned, 3 = unknown, 4 = reassigned)
#	Note: enter "0" for any parameters to accept all values (i.e. ignore the parameter restriction in all where clauses)

# Numerator
SET @numExits := (
	SELECT COUNT(*) FROM lastmile_chwdb.view_turnover WHERE
		datePositionBegan <= p_startDate AND 
		datePositionEnded > p_startDate AND 
		datePositionEnded <= DATE_ADD(p_endDate, INTERVAL 1 DAY) AND 
		IF(p_positionID=0,1,IF(p_positionID=23,positionID=2||positionID=3,positionID=p_positionID)) AND 
		IF(p_turnoverType=0,1,reasonPositionEndedID=p_turnoverType) AND 
		IF(p_countyID=0,1,countyID=p_countyID)
);

# Denominator
SET @numStaffAtStart := (
	SELECT COUNT(*) FROM lastmile_chwdb.view_turnover WHERE
		datePositionBegan <= p_startDate AND 
		( datePositionEnded > p_startDate OR (datePositionEnded IS NULL) OR datePositionEnded = '' ) AND 
		IF(p_positionID=0,1,IF(p_positionID=23,positionID=2||positionID=3,positionID=p_positionID)) AND 
		IF(p_countyID=0,1,countyID=p_countyID)
);

RETURN @numExits/@numStaffAtStart;

END$$
DELIMITER ;
