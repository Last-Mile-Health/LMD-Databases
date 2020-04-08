use lastmile_ncha;

DROP FUNCTION IF EXISTS lastmile_ncha.turnover;
CREATE FUNCTION lastmile_ncha.`turnover`(p_start_date DATE, p_end_date DATE, p_job VARCHAR(30), p_reason_left VARCHAR(30), p_county VARCHAR(30), p_return VARCHAR(20)) RETURNS float
BEGIN

# Calculates staff turnover
# Parameters:
#	p_job		Corresponds with lastmile_ncha.job.title ("CHA", "CHWL", "CHSS")
#	p_county_id			Corresponds with lastmile_ncha.county.county ("Grand Gedeh", "Rivercess", ...)
#	p_reason_left		Loosely corresponds with lastmile_ncha.reason_left.reason_left
#						Options: 'any', 'terminated', 'resigned', 'promoted', 'other/unknown'
#	p_return			Returned value ("rate", "numerator", "denominator")
#	Note: enter 'any' for a parameter to accept all values (i.e. ignore the parameter restriction in all where clauses)

# Numerator
SET @num_exits := NULL;
SET @num_exits := (

select count(*) from lastmile_ncha.view_base_history_person_position 
where ( ( position_person_begin_date <= p_start_date ) and 
		    ( position_person_end_date > p_start_date and position_person_end_date <= p_end_date )  ) and
        
      ( position_id_end_date is null or position_id_end_date > p_start_date                     ) and
      
      ( job = p_job or p_job = 'any' ) and ( reason_left = p_reason_left OR p_reason_left = 'any' or ( p_reason_left = 'other/unknown' and ( reason_left IS NULL or reason_left NOT IN ('terminated','resigned','promoted') ) ) ) and 
		  ( county=p_county OR p_county='any' )
      
);

# Denominator
SET @num_staff_at_start := NULL;
SET @num_staff_at_start := (

select count( * ) from lastmile_ncha.view_base_history_person_position
where
      ( ( position_person_begin_date <= p_start_date ) and 
        ( position_person_end_date > p_start_date or ( position_person_end_date is null  or position_person_end_date = '' ) ) ) and 
        
      ( position_id_end_date is null or position_id_end_date > p_start_date ) and

		  ( job = p_job or p_job = 'any' ) and 
		  ( county = p_county or p_county = 'any' )
      
);

CASE p_return
	WHEN "rate" THEN RETURN @num_exits/@num_staff_at_start;
	WHEN "numerator" THEN RETURN @num_exits;
	WHEN "denominator" THEN RETURN @num_staff_at_start;
    ELSE RETURN NULL;
END CASE;

END;
