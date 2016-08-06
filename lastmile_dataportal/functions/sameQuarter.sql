DELIMITER $$
CREATE FUNCTION `sameQuarter`(month1 INT,month2 INT) RETURNS tinyint(1)
BEGIN
	
    SET @month1 := month1;
    SET @month2 := month2;
    
	SET @q1 := if(@month1 IN (1,2,3) AND @month2 IN (1,2,3), 1, 0);
	SET @q2 := if(@month1 IN (4,5,6) AND @month2 IN (4,5,6), 1, 0);
	SET @q3 := if(@month1 IN (7,8,9) AND @month2 IN (7,8,9), 1, 0);
	SET @q4 := if(@month1 IN (10,11,12) AND @month2 IN (10,11,12), 1, 0);
    
    SET @sameQuarter := if(@q1+@q2+@q3+@q4>0,true,false);

RETURN @sameQuarter;
END$$
DELIMITER ;
