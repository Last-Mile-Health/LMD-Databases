USE `lastmile_dataportal`;
DROP procedure IF EXISTS `dataPortalValues`;

DELIMITER $$
USE `lastmile_dataportal`$$
CREATE PROCEDURE `dataPortalValues`(IN p_month INT, IN p_year INT)
BEGIN


-- NOTES:
--  1. This procedure is called by the MySQL event `evt_dataPortalValues` on a monthly basis and populates a data warehouse, `lastmile_dataportal`.`tbl_values`.
--  2. This entire procedure is idempotent (en.wikipedia.org/wiki/Idempotence). That is, it can be run multiple times consecutively, and assuming the underlying data hasn't changed, the second run, third run, etc. should not change the values stored in tbl_values. This allows for the procedure to be re-run if the underlying data DOES change (e.g. if data errors are corrected and we want to re-run the procedure).
--  3. Each block in the "core updates" section below generates a set of values for one indicator and inserts or replaces it in tbl_values.
--  4. Code is generally written in order of indicator ID# ("ind_id"). Therefore, dependencies (i.e. calculations that depend on previous calculations) should be avoided
--  5. Ensure that all queries account for the fact that MySQL treats most strings as zero in comparisons (e.g. 'hello'=0 is true); sometimes, values need to first be typecasted to enable comparisons.
--  6. If the data source for an indicator switches, historical data can be accidentally overwritten (usually by NULLs). To avoid this, if a data source changes, account for this in the underlying SQL by creating a query that merges both source tables and read from that table here.
--  7. If the calculation does not calculate historical values, wrap it in the following: IF(@isCurrentMonth,(calculation),NULL).
--  8. If the calculation runs quarterly, wrap it in the following: IF(@isEndOfQuarter,(calculation),NULL). See ind_id #28 for an example.
--  9. Some calculations suppress values if the "n-value" isn't high enough. Wrap these in the following: IF([test],(calculation),NULL). See ind_id #147 for an example.
-- 10. In SQL, NULL+number=NULL, so wrap calculations in COALESCE(value,0) before performing addition, subtraction, etc. However, this does not apply to GROUP BY statements involving the SUM() function.
-- 11. For populating historical values, do not run the entire script. Instead, use the procedure `dataPortalValues_backfill` to run only the new block of code.


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

/*
 *
 * Set Global variables
 *
*/

-- The estimated ratio of CHAs to population served.
set @cha_population_ratio = 235;
-- set @cha_population_ratio = 300;



-- ------------ --
-- Misc cleanup --
-- ------------ --



-- --------------- --
-- Set scale table --
-- --------------- --

-- Delete blank values from tbl_values
delete from  lastmile_dataportal.tbl_values where trim( value ) like '';


/*  dhis2 upload of CHSS MSR data aggregated by counties
    
    This code "replicates" the Excel spreadsheet we were using to upload the dhis2 CHSS MSR data, although
    has been expeanded to accomodate all 43 CHSS MSR indicators.
    
    First, run the pivot table "LMH NCHA CHSS MSR Monthly Totals" for prior month and uploaded it
    into the table lastmile_dataportal.tbl_moh_dhis2_chss_msr_upload.
    
    If dhis2 indicator has been mapped to a portal ind_id, then there will be an entry for it in the table
    lastmile_dataportal.tbl_moh_dhis2_chss_msr_map_indicator_id.  Otherwise, the ind_id is null for a dhis2
    indicator.
    
    The upload table can hold multiple months of data and aggregate and sum it by months, years, and county.
    
*/


-- dhis2 moh cbis data:  See lastmile_dataportal.tbl_moh_dhis2_chss_msr_map_indicator_id for list of indicator being
-- uploaded every month from dhis2
-- 
-- Currently, these are the indicator values being brought into into tbl_values every month: 
-- 19, 21, 119, 347, 349, 356, 357, 358, 381, 382, 383, 432, 459, 460, 461, 462, 463	

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select ind_id, territory_id, 1 as period_id, month_report, year_report, value   
from lastmile_dataportal.view_moh_dhis2_chss_msr
where not ( ind_id is null ) and  month_report = @p_month and year_report = @p_year 
;


-- 23. Number of child cases of malaria treated.
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 23, territory_id, 1 as period_id, month_report, year_report, sum( value ) as value   
from lastmile_dataportal.view_moh_dhis2_chss_msr
where ind_id in ( 461, 462) and  month_report = @p_month and year_report = @p_year 
group by territory_id
;

-- 235. Number of malnutrition screenings (MUAC) conducted for children under-five
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 235, territory_id, 1 as period_id, month_report, year_report, sum( value ) as value   
from lastmile_dataportal.view_moh_dhis2_chss_msr
where ind_id in ( 382, 383, 463 ) and  month_report = @p_month and year_report = @p_year 
group by territory_id
;

/* end of dhis2 upload code */


--  -----------------------------------------------------------------------------------------------------------------------------------
--
--  begin: create and load data into mart_program_scale and mart_program_scale tables
--
--  -----------------------------------------------------------------------------------------------------------------------------------

-- Note: num_communities and num_people currently only used to populate scale indicators (#45 and #50); num_households not used at all
DROP TABLE IF EXISTS lastmile_report.mart_program_scale;
CREATE TABLE lastmile_report.mart_program_scale (`territory_id` VARCHAR(20) NOT NULL, `num_cha` INT NULL, `num_chss` INT NULL, `num_communities` INT NULL, `num_households` INT NULL, `num_people` INT NULL, PRIMARY KEY (`territory_id`)) DEFAULT CHARACTER SET = utf8mb4;


-- !!!!! TEMP: Set territories !!!!!
INSERT INTO lastmile_report.mart_program_scale (territory_id) VALUES ('6_31'), ('6_26'), ('1_14'), ('1_4'), ('1_6'), ('6_16');


-- 28. Number of CHAs deployed
-- Pull the number of active CHA positions from snapshot data mart.  
-- First, GG Unicef
update lastmile_report.mart_program_scale a, lastmile_report.view_snapshot_position_cha as v

    set a.num_cha = v.cha_count

where a.territory_id like '6\\_26' and v.snapshot_date like @p_date and v.cohort like '%Grand%Gedeh%UNICEF%'
;

-- Grand Gedeh LMH
update lastmile_report.mart_program_scale a, lastmile_report.view_snapshot_position_cha as v
  
    set a.num_cha = v.cha_count
    
where a.territory_id like '6\\_31' and v.snapshot_date like @p_date and v.cohort like '%Grand%Gedeh%LMH%'
;

-- Rivercess
update lastmile_report.mart_program_scale a, lastmile_report.view_snapshot_position_cha as v
  
    set a.num_cha = v.cha_count
    
where a.territory_id like '1\\_14' and v.snapshot_date like @p_date and v.cohort like '%River%cess%'
;
-- Grand Bassa
update lastmile_report.mart_program_scale a, lastmile_report.view_snapshot_position_cha as v
  
    set a.num_cha = v.cha_count
    
where a.territory_id like '1\\_4' and v.snapshot_date like @p_date and v.cohort like '%Grand%Bassa%'
;

-- Grand Gedeh (LMH + UNICEF)
update lastmile_report.mart_program_scale a
  
  set a.num_cha = ( select sum( cha_count ) from lastmile_report.view_snapshot_position_cha
                    where snapshot_date like @p_date and ( cohort like '%Grand%Gedeh%UNICEF%' or cohort like '%Grand%Gedeh%LMH%' )
                  )
    
where a.territory_id like '1\\_6'
;


-- Managed areas total
update lastmile_report.mart_program_scale a
  
  set a.num_cha = ( select sum( cha_count ) from lastmile_report.view_snapshot_position_cha
                    where snapshot_date like @p_date and (  cohort like '%Grand%Gedeh%UNICEF%'  or 
                                                            cohort like '%Grand%Gedeh%LMH%'     or
                                                            cohort like '%River%cess%'          or
                                                            cohort like '%Grand%Bassa%'
                                                          )
                  )
    
where a.territory_id like '6\\_16'
;


/* For now, obsolete this code.  It looks at view_base_history_person and checks if there is a 
 * person assigned to a cha position at a point of time.
 * We count number of CHAs as the number of active positions and not person filling those positions.
 * Keep this code lying around in case we revert back to number of actives persons.  However in that case
 * we should have migrated the code over to lastmile_datamart.dimension_position.  So both counts are
 * availabe by querying the data mart.
*/
/*
UPDATE lastmile_report.mart_program_scale a 

    LEFT JOIN (

                SELECT 
                        IF(cohort IS NULL,'6_31',IF(cohort='UNICEF','6_26','error')) AS territory_id, 
                        COUNT(1) as num_cha 
                FROM lastmile_report.mart_view_base_history_person
                WHERE county_id=6 AND job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY territory_id

                UNION 
                
                SELECT 
                      CONCAT('1_',county_id), 
                      COUNT(1) 
                FROM lastmile_report.mart_view_base_history_person
                WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county_id

                UNION 
                
                SELECT '6_16', COUNT(1) 
                FROM lastmile_report.mart_view_base_history_person
                WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date)

              ) b ON a.territory_id = b.territory_id 

SET a.num_cha = b.num_cha;

*/

-- 29. Number of CHSSs deployed
-- !!!!! the "cohort IS NULL" clause needs to be changed once cohorts are assigned !!!!!
UPDATE lastmile_report.mart_program_scale a LEFT JOIN (
SELECT IF(cohort IS NULL,'6_31',IF(cohort='UNICEF','6_26','error')) AS territory_id, COUNT(1) as num_chss FROM lastmile_report.mart_view_base_history_person
WHERE county_id=6 AND job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY territory_id
UNION SELECT CONCAT('1_',county_id), COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county_id
UNION SELECT '6_16', COUNT(1) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date)
) b ON a.territory_id = b.territory_id SET a.num_chss = b.num_chss;


-- 45. Number of people served (CHA program)
/* Avi's hard-coded numbers
UPDATE lastmile_report.mart_program_scale SET num_people = 12185 WHERE territory_id = '6_31';
UPDATE lastmile_report.mart_program_scale SET num_people = 45367 WHERE territory_id = '6_26';
UPDATE lastmile_report.mart_program_scale SET num_people = 40483 WHERE territory_id = '1_14';
UPDATE lastmile_report.mart_program_scale SET num_people = 0 WHERE territory_id = '1_4';
UPDATE lastmile_report.mart_program_scale SET num_people = 57552 WHERE territory_id = '1_6';
UPDATE lastmile_report.mart_program_scale SET num_people = 98035 WHERE territory_id = '6_16';
*/


-- Pull these from the snapshot data mart for the year/month.

/* Owen's note 9/20/2021: When we merge these two 6_31 and 6_26 into one 1_6, we'll need a conditional to calculate these
  values, depending on whether we are supporting the whole county or not.  At some month, 6_31 will equal 1_6, and the previous
  month 6_31 not equal 6_26.
*/

-- GG LMH 6_31
update lastmile_report.mart_program_scale s
    set s.num_people = ( 
                          select 
                                  if( min( coalesce( c.population, 0 ) ) = 0, 
                                      min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                      min( coalesce( c.population, 0 ) )     
                                  )  as population
                          from lastmile_report.view_snapshot_position_cha as c
                          where ( year( c.snapshot_date )   = @p_year )       and 
                                ( month( c.snapshot_date ) = @p_month )       and
                                ( trim( c.cohort ) like '%Grand%Gedeh%LMH%' )                             
                        )
where territory_id like '6\\_31'
;

-- GG UNICEF 6_26
update lastmile_report.mart_program_scale s
    set s.num_people = ( 
                          select
                                 c.population_estimate as population
                                  /* Temporary workaround for UNICEF until we begin reporting the whole county as Managed county.
                                  if( min( coalesce( c.population, 0 ) ) = 0, 
                                      min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                      min( coalesce( c.population, 0 ) )     
                                  )  as population
                                  */
                          from lastmile_report.view_snapshot_position_cha as c
                          where ( year( c.snapshot_date   ) = @p_year   )       and 
                                ( month( c.snapshot_date  ) = @p_month  )       and
                                ( trim( c.cohort ) like '%Grand%Gedeh%UNICEF%' )                                                            
                        )
where territory_id like '6\\_26'
;


-- GG LMH 1_6
update lastmile_report.mart_program_scale s
    set s.num_people = (
                          select sum( a.population ) as population
                          from ( 
                                  select 
                                        if( min( coalesce( c.population, 0 ) ) = 0, 
                                            min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                            min( coalesce( c.population, 0 ) )     
                                        ) as population
                                  from lastmile_report.view_snapshot_position_cha as c
                                  where ( year( c.snapshot_date )   = @p_year   )       and 
                                        ( month( c.snapshot_date )  = @p_month  )       and
                                        ( trim( c.cohort ) like '%Grand%Gedeh%LMH%' )  
                                
                                  union all
                          
                                  select 
                                        c.population_estimate as population
                                        /* Temporary workaround for UNICEF until we begin reporting the whole county as Managed county.
                                        if( min( coalesce( c.population, 0 ) ) = 0, 
                                            min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                            min( coalesce( c.population, 0 ) )     
                                        )  as population
                                        */
                                  from lastmile_report.view_snapshot_position_cha as c
                                  where ( year( c.snapshot_date   ) = @p_year   )       and 
                                        ( month( c.snapshot_date  ) = @p_month  )       and
                                        ( trim( c.cohort ) like '%Grand%Gedeh%UNICEF%' )   
                          
                              ) as a
                        )
where territory_id like '1\\_6'
;

-- Rivercess 1_14
update lastmile_report.mart_program_scale s
    set s.num_people = ( 
                          select 
                                  if( min( coalesce( c.population, 0 ) ) = 0, 
                                      min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                      min( coalesce( c.population, 0 ) )     
                                  ) as population
                          from lastmile_report.view_snapshot_position_cha as c
                          where ( year( c.snapshot_date   ) = @p_year   )       and 
                                ( month( c.snapshot_date  ) = @p_month  )       and
                                ( trim( c.cohort ) like '%Rivercess%' )                                                            
                        )
where territory_id like '1\\_14'
;

-- Grand Bassa 1_4

update lastmile_report.mart_program_scale s
    set s.num_people = ( 
                          select 
                                  ifnull( if( min( coalesce( c.population, 0 ) ) = 0, 
                                              min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                              min( coalesce( c.population, 0 ) )     
                                  ), 0 ) as population
                          from lastmile_report.view_snapshot_position_cha as c
                          where ( year( c.snapshot_date   ) = @p_year   )       and 
                                ( month( c.snapshot_date  ) = @p_month  )       and
                                ( trim( c.cohort ) like '%Grand%Bassa%' )                                                            
                        )
where territory_id like '1\\_4'
;

-- Total (LMH) 6_16
update lastmile_report.mart_program_scale s
    set s.num_people = (
                          select sum( a.population ) as population
                          from ( 
                                  select 
                                        if( min( coalesce( c.population, 0 ) ) = 0, 
                                            min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                            min( coalesce( c.population, 0 ) )     
                                        ) as population
                                  from lastmile_report.view_snapshot_position_cha as c
                                  where ( year( c.snapshot_date )   = @p_year   )       and 
                                        ( month( c.snapshot_date )  = @p_month  )       and
                                        ( trim( c.cohort ) like '%Grand%Gedeh%LMH%' )  
                                        
                                  union all
                          
                                  select 
                                        c.population_estimate as population
                                        /* Temporary workaround for UNICEF until we begin reporting the whole county as Managed county.
                                        if( min( coalesce( c.population, 0 ) ) = 0, 
                                            min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                            min( coalesce( c.population, 0 ) )     
                                        )  as population
                                        */
                                  from lastmile_report.view_snapshot_position_cha as c
                                  where ( year( c.snapshot_date   ) = @p_year   )       and 
                                        ( month( c.snapshot_date  ) = @p_month  )       and
                                        ( trim( c.cohort ) like '%Grand%Gedeh%UNICEF%' )         
                                
                                  union all
                                                                                    
                                  select 
                                        if( min( coalesce( c.population, 0 ) ) = 0, 
                                            min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                            min( coalesce( c.population, 0 ) )     
                                        ) as population
                                  from lastmile_report.view_snapshot_position_cha as c
                                  where ( year( c.snapshot_date   ) = @p_year   )       and 
                                        ( month( c.snapshot_date  ) = @p_month  )       and
                                        ( trim( c.cohort ) like '%Rivercess%' ) 
                                      
                                  union all 
                                 
                                  select 
                                        ifnull( if( min( coalesce( c.population, 0 ) ) = 0, 
                                                    min( coalesce( c.cha_count, 0 ) ) * @cha_population_ratio,                                
                                                    min( coalesce( c.population, 0 ) )     
                                        ), 0 ) as population
                                  from lastmile_report.view_snapshot_position_cha as c
                                  where ( year( c.snapshot_date   ) = @p_year   )       and 
                                        ( month( c.snapshot_date  ) = @p_month  )       and
                                        ( trim( c.cohort ) like '%Grand%Bassa%' )         


                              ) as a
                       )
where territory_id like '6\\_16'
;

-- 50. Number of communities served
-- Pull these from the snapshot data mart for the year/month.

-- GG LMH 6_31
update lastmile_report.mart_program_scale s
    set s.num_communities = ( select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                              from lastmile_report.view_snapshot_position_cha as c
                              where ( year( c.snapshot_date   ) = @p_year   ) and 
                                    ( month( c.snapshot_date  ) = @p_month  ) and    
                                    ( trim( c.cohort ) like '%Grand%Gedeh%LMH%' )                             
                            )
where territory_id like '6\\_31'
;

-- GG LMH 6_26
update lastmile_report.mart_program_scale s
    set s.num_communities = ( select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                              from lastmile_report.view_snapshot_position_cha as c
                              where ( year( c.snapshot_date   ) = @p_year   ) and 
                                    ( month( c.snapshot_date  ) = @p_month  ) and    
                                    ( trim( c.cohort ) like '%Grand%Gedeh%UNICEF%' )                                                            
                            )
where territory_id like '6\\_26'
;

-- GG LMH 1_6
update lastmile_report.mart_program_scale s
    set s.num_communities = (
                              select sum( a.community_count ) as community_count
                              from ( 
                                    select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                                    from lastmile_report.view_snapshot_position_cha as c
                                    where ( year( c.snapshot_date   ) = @p_year   ) and 
                                          ( month( c.snapshot_date  ) = @p_month  ) and   
                                          ( trim( c.cohort ) like '%Grand%Gedeh%LMH%' )  
                                
                                    union all
                                    
                                    select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                                    from lastmile_report.view_snapshot_position_cha as c
                                    where ( year( c.snapshot_date   ) = @p_year   ) and 
                                          ( month( c.snapshot_date  ) = @p_month  ) and   
                                        ( trim( c.cohort ) like '%Grand%Gedeh%UNICEF%' )   
                          
                              ) as a
                        )
where territory_id like '1\\_6'
;

-- Rivercess 1_14
update lastmile_report.mart_program_scale s
    set s.num_communities = ( select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                              from lastmile_report.view_snapshot_position_cha as c
                              where ( year( c.snapshot_date   ) = @p_year   ) and 
                                    ( month( c.snapshot_date  ) = @p_month  ) and    
                                    ( trim( c.cohort ) like '%Rivercess%' )                                                            
                            )
where territory_id like '1\\_14'
;

-- Grand Bassa 1_4
update lastmile_report.mart_program_scale s
    set s.num_communities = ( select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                              from lastmile_report.view_snapshot_position_cha as c
                              where ( year( c.snapshot_date   ) = @p_year   ) and 
                                    ( month( c.snapshot_date  ) = @p_month  ) and                              
                                    ( trim( c.cohort ) like '%Grand%Bassa%' )    
                            )
where territory_id like '1\\_4'
;

-- Total (LMH) 6_16
update lastmile_report.mart_program_scale s
    set s.num_communities = (
                              select sum( a.community_count ) as community_count
                              from ( 
                                    select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                                    from lastmile_report.view_snapshot_position_cha as c
                                    where ( year( c.snapshot_date   ) = @p_year   ) and 
                                          ( month( c.snapshot_date  ) = @p_month  ) and   
                                          ( trim( c.cohort ) like '%Grand%Gedeh%LMH%' )  
                                
                                    union all
                                    
                                    select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                                    from lastmile_report.view_snapshot_position_cha as c
                                    where ( year( c.snapshot_date   ) = @p_year   ) and 
                                          ( month( c.snapshot_date  ) = @p_month  ) and   
                                          ( trim( c.cohort ) like '%Grand%Gedeh%UNICEF%' )   
                          
                                    union all
                                    
                                    select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                                    from lastmile_report.view_snapshot_position_cha as c
                                    where ( year( c.snapshot_date   ) = @p_year   ) and 
                                          ( month( c.snapshot_date  ) = @p_month  ) and   
                                          ( trim( c.cohort ) like '%Rivercess%' )   
                          
                                    union all
                                    
                                    select ifnull( min( coalesce( c.community_count, 0 ) ), 0 ) as community_count
                                    from lastmile_report.view_snapshot_position_cha as c
                                    where ( year( c.snapshot_date   ) = @p_year   ) and 
                                          ( month( c.snapshot_date  ) = @p_month  ) and   
                                          ( trim( c.cohort ) like '%Grand%Bassa%' ) 
                                                
                              ) as a
                        )
where territory_id like '6\\_16'
;


-- X. Misc GG UNICEF + Grand Bassa
-- !!!!! TEMP until UNICEF CHAs and CHSSs are in database !!!!!
-- UPDATE lastmile_report.mart_program_scale SET num_cha = 0 WHERE territory_id = '1_4';
-- UPDATE lastmile_report.mart_program_scale SET num_chss = 21 WHERE territory_id = '1_4';



/*
 *
 * QAO progam scale mart build
 *
*/

drop table if exists lastmile_report.mart_program_scale_qao;

create table lastmile_report.mart_program_scale_qao (

  qao_position_id               varchar(50 )  not null, 
  qao                           varchar(50 )      null, 
  
  num_cha                       int               null, 
  num_chss                      int               null,
  num_position_chss             int               null,
  num_communities               int               null, 
  num_households                int               null,  
  num_people                    int               null, 
  
  primary key ( qao_position_id )

) default character set = utf8mb4;

-- First, build list of QAO position IDs and names for a point in time (the first day of the month).

insert into lastmile_report.mart_program_scale_qao ( qao_position_id, qao )
select dp.qao_position_id, dp.qao_full_name
from lastmile_datamart.dimension_position as dp
where date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )
group by dp.qao_position_id, dp.qao_full_name
;

-- Calculate the number of active CHAs each QAO is supervising.
update lastmile_report.mart_program_scale_qao q
    left outer join (
                      select dp.qao_position_id, sum( if( dp.person_id is null, 0, 1 ) ) as number_cha
                      from lastmile_datamart.dimension_position dp
                      where date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )            
                      group by dp.qao_position_id
                    
    ) as s on q.qao_position_id like s.qao_position_id
  
  set q.num_cha = s.number_cha
;


-- Calculate the number of active CHSSs each QAO is supervising.
update lastmile_report.mart_program_scale_qao q
    left outer join (
                      select a.qao_position_id, sum( if( a.chss_person_id is null, 0, 1 ) ) as number_chss
                      from ( 
                            select dp.qao_position_id, dp.chss_position_id, dp.chss_person_id
                            from lastmile_datamart.dimension_position dp
                            where date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )
                            group by dp.qao_position_id, dp.chss_position_id
                      ) as a
                      group by a.qao_position_id 

    ) as s on q.qao_position_id like s.qao_position_id
    
  set q.num_chss = s.number_chss
;


-- Calculate the number of CHSS positions each QAO is supervising.
update lastmile_report.mart_program_scale_qao q
    left outer join (
                      select a.qao_position_id, count( * ) as number_position_chss
                      from ( 
                            select dp.qao_position_id, dp.chss_position_id
                            from lastmile_datamart.dimension_position dp
                            where date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )
                            group by dp.qao_position_id, dp.chss_position_id
                       ) as a
                      group by a.qao_position_id 

    ) as s on q.qao_position_id like s.qao_position_id
    
  set q.num_position_chss = s.number_position_chss
;


-- Calculate the number of communties with active CHAs that QAO is supervising.
update lastmile_report.mart_program_scale_qao q
    left outer join (
                      select dp.qao_position_id, sum( coalesce( s.position_community_count, 0 ) ) as number_community
                      from lastmile_datamart.dimension_position dp
                          left outer join lastmile_report.data_mart_snapshot_position_cha as s on dp.date_key = s.date_key and dp.position_id like s.position_id
                      where  dp.date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )        
                      group by dp.qao_position_id

    ) as s on q.qao_position_id like s.qao_position_id
    
  set q.num_communities = s.number_community
;

-- Calculate the number of households with active CHAs that QAO is supervising.
update lastmile_report.mart_program_scale_qao q
    left outer join (
                      select dp.qao_position_id, sum( coalesce( s.household, 0 ) ) as number_household
                      from lastmile_datamart.dimension_position dp
                          left outer join lastmile_report.data_mart_snapshot_position_cha as s on dp.date_key = s.date_key and dp.position_id like s.position_id
                      where  dp.date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )           
                      group by dp.qao_position_id

    ) as s on q.qao_position_id like s.qao_position_id
    
  set q.num_households = s.number_household
;

-- Calculate the population that active CHAs are serving that a QAO is supervising.
update lastmile_report.mart_program_scale_qao q
    left outer join (
                      select dp.qao_position_id, sum( coalesce( s.population, 0 ) ) as population
                      from lastmile_datamart.dimension_position dp
                          left outer join lastmile_report.data_mart_snapshot_position_cha as s on dp.date_key = s.date_key and dp.position_id like s.position_id
                      where  dp.date_key = @p_date_key and not ( dp.qao_position_id is null ) and ( dp.cohort is null or not ( dp.cohort like '%UNICEF%' ) )       
                      group by dp.qao_position_id

    ) as s on q.qao_position_id like s.qao_position_id
    
  set q.num_people = s.population
;

--  -----------------------------------------------------------------------------------------------------------------------------------
--
--  end: create and load data into mart_program_scale and mart_program_scale tables
--
--  -----------------------------------------------------------------------------------------------------------------------------------


-- ------------ --
-- Core updates --
-- ------------ --

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

-- 7. Monthly CHA supervision rate by QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      7 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      round( sum( q.supervisionAttendance ) / s.num_cha, 1 ) as rate
      
      -- ROUND( SUM( supervisionAttendance ) / num_cha, 1 )
from lastmile_report.mart_view_base_odk_supervision as q
    left outer join lastmile_datamart.dimension_position            as dp on q.date_key = dp.date_key and q.supervisedCHAID like dp.position_id
        left outer join lastmile_dataportal.tbl_territories_other   as o on dp.qao_position_id like trim( o.territory_name ) 
            left outer join lastmile_report.mart_program_scale_qao  as s on dp.qao_position_id like s.qao_position_id
where q.date_key = @p_date_key and not ( dp.qao_position_id is null ) 
group by dp.qao_position_id
;



-- For now, let's continue adding GG Unicef cha counts to denominator.  However, the Total rates in the table will all look
-- like they are under water because numerator will only be the supervision counts for GG LMH and RI.  The code below will
-- construct the a numerator with just GG LMH and RI for the Totals.
-- replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
-- select 7, '6_16', 1, @p_month, @p_year, ROUND( SUM( t.supervisionAttendance_sum ) / sum( t.num_cha ), 1 ) from 
-- ( select a.territory_id, sum( a.supervisionAttendance ) as supervisionAttendance_sum, b.num_cha
-- from lastmile_report.mart_view_base_odk_supervision as a left outer join lastmile_report.mart_program_scale b on a.territory_id = b.territory_id
-- where a.territory_id like '6_31' and a.manualMonth = @p_month and a.manualYear = @p_year and a.county_id IS NOT NULL
-- union all select a.territory_id, sum( a.supervisionAttendance )  as supervisionAttendance_sum, b.num_cha
-- from lastmile_report.mart_view_base_odk_supervision as a left outer join lastmile_report.mart_program_scale b on a.territory_id = b.territory_id
-- where a.territory_id like '1_14' and a.manualMonth = @p_month and a.manualYear = @p_year and a.county_id IS NOT NULL ) as t;


-- 11. CHA attendance rate at supervision
-- Currently based off of ODK data
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 11, territory_id, 1, @p_month, @p_year, ROUND(SUM(supervisionAttendance)/COUNT(1),3)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 11, '6_16', 1, @p_month, @p_year, ROUND(SUM(supervisionAttendance)/COUNT(1),3)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL;


-- 14. Estimated facility-based delivery rate
-- Module 2 is updated quarterly

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  14, territory_id, 1, @p_month, @p_year, 
        round(  ( sum( coalesce( num_births_facility,0 ) ) ) /
                ( sum( coalesce( num_births_facility, 0 ) ) + sum( coalesce( num_births_home, 0 ) ) ), 
                3 
              )

FROM lastmile_report.mart_view_base_msr_county 
where not ( county_id is null ) and
      ( @isEndOfQuarter         and
        ( 
          ( year_reported = @p_year  and month_reported =  @p_month        )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus1  )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus2  ) 
        ) 
      )
group by territory_id

union all 
 
select  14, '6_16', 1, @p_month, @p_year, 
        round(  ( sum( coalesce( num_births_facility,0 ) ) ) /
                ( sum( coalesce( num_births_facility, 0 ) ) + sum( coalesce( num_births_home, 0 ) ) ), 
                3 
              )

from lastmile_report.mart_view_base_msr_county 

where not ( county_id is null ) and
      ( @isEndOfQuarter         and
        ( 
          ( year_reported = @p_year  and month_reported =  @p_month        )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus1  )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus2  ) 
        ) 
      )
;

/*
 * Executive impact ind_id=14 6_27 for Liberia is reported annually.
 * For annual indicators calculate them at end of FY, June, but store them in the first month of FY, July.
 * So first month of fiscal year is current month June plus one, and the fiscal year is current year minus one.
 * Note: home and facility births (459, 460) for all counties are loaded into tbl_values from the dhis2
 * upload at beginning of this script.
 *
 * Only update the annual indicators on June.
 *
*/

/*
if @p_month = 6 then

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 14, '6_27' as territory_id, 1 as period_id, @p_month + 1 as `month`, @p_year - 1 as `year`,
        
        round(  ( sum( coalesce( num_births_facility,0 ) ) ) /
                ( sum( coalesce( num_births_facility, 0 ) ) + sum( coalesce( num_births_home, 0 ) ) ), 3 ) as value

from (
      -- Only use whole county values for GG and GB
      select 0 as ind_id, territory_id, month_reported, year_reported, num_births_facility, num_births_home
      from lastmile_report.mart_view_base_msr_county 
      where 
            not ( county_id is null )                                   and
            ( territory_id like '1\\_4' or territory_id like '1\\_14' ) and
            ( 
              ( month_reported in ( 7, 8, 9, 10, 11, 12 ) and ( year_reported = ( @p_year - 1 ) ) ) or
              ( month_reported in ( 1, 2, 3, 4, 5, 6    ) and ( year_reported =   @p_year       ) ) 
            )

      union all

      select ind_id, territory_id, `month`, `year`, null as num_births_facility, if( ind_id = 459, value, null ) as num_births_home
      from lastmile_dataportal.tbl_values
      where 
            ind_id = 459                                                        and
            not ( ( territory_id like '1\\_4' or territory_id like '1\\_14' ) ) and
            ( 
              ( `month` in ( 7, 8, 9, 10, 11, 12 ) and ( `year` = ( @p_year - 1 ) ) ) or
              ( `month` in ( 1, 2, 3, 4, 5, 6    ) and ( `year` =   @p_year       ) ) 
            )

      union all

      select ind_id, territory_id, `month`, `year`, if( ind_id = 460, value, null ) as num_births_facility, null as num_births_home
      from lastmile_dataportal.tbl_values
      where 
            ind_id = 460                                                        and
            not ( ( territory_id like '1\\_4' or territory_id like '1\\_14' ) ) and
            ( 
              ( `month` in ( 7, 8, 9, 10, 11, 12 ) and ( `year` = ( @p_year - 1 ) ) ) or
              ( `month` in ( 1, 2, 3, 4, 5, 6    ) and ( `year` =   @p_year       ) ) 
            )
) as a;

end if;

*/

-- 17. Number of attempted supervision visits
-- Currently based off of ODK data
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 17, territory_id, 1, @p_month, @p_year, COUNT(1)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 17, '6_16', 1, @p_month, @p_year, SUM(1)
FROM lastmile_report.mart_view_base_odk_supervision WHERE manualMonth=@p_month AND manualYear=@p_year AND county_id IS NOT NULL;


-- Number of births tracked

-- 459. Community births
--      Overwrite the dhis2 values for Rivercess and Grand Bassa
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 459 as ind_id, territory_id, 1 as period_id, @p_month, @p_year, num_births_home as value
from lastmile_report.mart_view_base_msr_county
where (  month_reported = @p_month and  year_reported = @p_year ) and
      ( territory_id like '1_4' or  territory_id like '1_14'  )
;
--      sum the values for all 1_%, mix of dhis2 CHSS MSRs for non-managed and LMH collected CHA MSRs for managed counties
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 459 as ind_id, '6_27' as terrrority_id, 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as value   
from lastmile_dataportal.tbl_values
where ind_id = 459  and 
      period_id = 1 and 
      territory_id like '1_%' and 
      ( `month` = @p_month and `year` = @p_year )    
;

-- 460. facility births
--      Overwrite the dhis2 values for Rivercess and Grand Bassa
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 460 as ind_id, territory_id, 1 as period_id, @p_month, @p_year, num_births_facility as value
from lastmile_report.mart_view_base_msr_county
where (  month_reported = @p_month and  year_reported = @p_year ) and
      ( territory_id like '1_4' or  territory_id like '1_14'  )
;
--      sum the values for all 1_%, mix of dhis2 CHSS MSRs for non-managed and LMH collected CHA MSRs for managed counties
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 460 as ind_id, '6_27' as terrrority_id, 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as value   
from lastmile_dataportal.tbl_values
where ind_id = 460  and 
      period_id = 1 and 
      territory_id like '1_%' and 
      ( `month` = @p_month and `year` = @p_year )    
;

-- 18. #births = #community births + facility births 
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 18, territory_id, 1 as period_id, `month`, `year`, sum( value ) as value   
from lastmile_dataportal.tbl_values
where ind_id in ( 459, 460 )    and  
      period_id = 1             and 
      territory_id like '1_%'   and 
      ( `month` = @p_month and `year` = @p_year )
group by territory_id
;
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 18 as ind_id, '6_27' as terrrority_id, 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as value   
from lastmile_dataportal.tbl_values
where ind_id in ( 459, 460 ) and 
      period_id = 1 and 
      territory_id like '6_27' and 
      ( `month` = @p_month and `year` = @p_year )    
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 18, '6_31' as territory_id, 1 as period_id, @p_month, @p_year, coalesce( num_births, 0 )
from lastmile_report.mart_view_base_msr_county 
where ( month_reported=@p_month and year_reported=@p_year ) and territory_id like '6_31'

union all

select 18, '6_16' as territory_id, 1 as period_id, @p_month, @p_year, sum( coalesce( num_births, 0 ) )
from lastmile_report.mart_view_base_msr_county 
where ( month_reported = @p_month and year_reported = @p_year ) and not ( county_id is null )
;


-- 19. Number of child cases of ARI treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 19, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_ari,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 19, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_ari,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 19. NCHA Outputs: Number of child cases of ARI treated
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 19                       ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        19,       '6_27',         1,            @p_month, @p_year,  @liberia_total;


-- 21. Number of child cases of diarrhea treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 21, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_diarrhea,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 21, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_diarrhea,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 21. NCHA Outputs: Number of child cases of diarrhea treated
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 21                       ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        21,       '6_27',         1,            @p_month, @p_year,  @liberia_total;


-- 23. Number of child cases of malaria treated
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 23, territory_id, 1, @p_month, @p_year, COALESCE(num_tx_malaria,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 23, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tx_malaria,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 23.	NCHA Outputs: Number of child cases of malaria treated
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 23                       ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        23,       '6_27',         1,            @p_month, @p_year,  @liberia_total;

-- 23.Number of child cases of malaria treated.  Qtrly totals for Assisted
replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`, `month`, `year`, `value` )
select 23, '6_27', 2, @p_month, @p_year, sum( coalesce( `value`, 0 ) ) as `value`
from lastmile_dataportal.tbl_values
where ind_id = 23               and
      territory_id like '6_27'  and
      period_id = 1             and 
      ( @isEndOfQuarter         and
        ( 
          ( `year` = @p_year    and `month` =  @p_month        )   or 
          ( `year` = @p_year    and `month` =  @p_monthMinus1  )   or 
          ( `year` = @p_year    and `month` =  @p_monthMinus2  ) 
        ) 
      )
;


-- 28. Number of CHAs deployed

-- Update the number of active CHAs deployed in LMH Assisted areas, so exclude Grand Bassa, Grand Gedeh, Rivercess
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 28, t.territory_id, 1 as period_id, s.month_report, s.year_report, s.cha_number_active
from lastmile_dataportal.tbl_nchap_scale_chss_cha as s
    left outer join lastmile_dataportal.view_territories as t on  ( trim( s.county )          like trim( t.territory_name ) ) and 
                                                                  ( trim( t.territory_type )  like 'county' )
where not ( s.county like '%Grand%Bassa%' or s.county like '%Grand%Gedeh%' or s.county like '%Rivercess%' )
;

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 28, territory_id, 1, @p_month, @p_year, num_cha FROM lastmile_report.mart_program_scale;

-- Total number of CHAs in LMH Assisted Areas
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 28, '6_32', 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as num_cha
from lastmile_dataportal.tbl_values
where ind_id = 28 and period_id = 1 and `month` = @p_month and `year` = @p_year and      
      ( territory_id like '1\\_%' and not ( territory_id like '1\\_4'  or territory_id like '1\\_6' or territory_id like '1\\_14' ) )
;

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 28, '6_27', 1 as period_id, @p_month, @p_year, sum( coalesce( a.number_cha, 0 ) ) as number_cha
from (
      select min( value ) as number_cha
      from lastmile_dataportal.tbl_values 
      where ind_id = 28 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_16' 

      union all

      select min( value ) as number_cha
      from lastmile_dataportal.tbl_values 
      where ind_id = 28 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_32' 
  ) as a;
  
  
-- 28. # of frontline and community health workers supported in all Anchor Country Programs annually
--      Here we will add 6_27 (Liberia) plus however we eventually bring in Malawi and other anchor countries.
--      But for now just copy 28, 6_27 value for year, month, period_id to 28, 6_36 Global (LMH)
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 28, '6_35', 1 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 28 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;


-- 28. Co-impact KPIs are reported on for March and August.  Use period_id = 38 (month 3 and month 8) to specific them.
if ( @p_month = 3 ) or ( @p_month = 8 ) then 

-- 28.  # of CHAs in Liberia (6_27), same as period_id for months 3, 8.
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 28, '6_27', 38 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 28 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;

end if;

  
-- 29. Number of CHSSs deployed

-- Update the number of active CHSSs deployed in LMH Assisted areas, so exclude Grand Bassa, Grand Gedeh, Rivercess
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 29, t.territory_id, 1 as period_id, s.month_report, s.year_report, s.chss_number_active
from lastmile_dataportal.tbl_nchap_scale_chss_cha as s
    left outer join lastmile_dataportal.view_territories as t on  ( trim( s.county )          like trim( t.territory_name ) ) and 
                                                                  ( trim( t.territory_type )  like 'county' )
where not ( s.county like '%Grand%Bassa%' or s.county like '%Grand%Gedeh%' or s.county like '%Rivercess%' )
;

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 29, territory_id, 1, @p_month, @p_year, num_chss FROM lastmile_report.mart_program_scale;

-- Total number of CHAs in LMH Assisted Areas
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 29, '6_32', 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as num_chss
from lastmile_dataportal.tbl_values
where ind_id = 29 and period_id = 1 and `month` = @p_month and `year` = @p_year and      
      ( territory_id like '1\\_%' and not ( territory_id like '1\\_4'  or territory_id like '1\\_6' or territory_id like '1\\_14' ) );

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 29, '6_27', 1 as period_id, @p_month, @p_year, sum( coalesce( a.number_chss, 0 ) ) as number_chss
from (
      select min( value ) as number_chss
      from lastmile_dataportal.tbl_values 
      where ind_id = 29 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_16' 

      union all

      select min( value ) as number_chss
      from lastmile_dataportal.tbl_values 
      where ind_id = 29 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_32' 
 ) as a;


-- 29. Co-impact KPIs are reported on for March and August.  Use period_id = 38 (month 3 and month 8) to specific them.
if ( @p_month = 3 ) or ( @p_month = 8 ) then 

-- 29.  # of CSSs in Liberia (6_27), same as period_id for months 3, 8.
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 29, '6_27', 38 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 29 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;

end if;


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

-- First, bring mart_program_scale numbers into tbl_value for the month

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 45, territory_id, 1, @p_month, @p_year, num_people from lastmile_report.mart_program_scale
;

-- Second, generate the population totals for all the assisted counties from the number of CHAs (ind_id 28)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 45, a.territory_id, 1, @p_month, @p_year, a.population
from ( 
        select
              territory_id,
              round( coalesce( value, 0 ) * @cha_population_ratio , 0 ) as population
        from lastmile_dataportal.tbl_values
        where ind_id = 28 and period_id = 1 and `month` = @p_month and `year` = @p_year and
              territory_id like '1\\_%' and not ( territory_id like '1\\_4' or territory_id like '1\\_6' or territory_id like '1\\_14' )
) as a
;

-- Third, add up the population totals for all the assisted counties to get a assiated total.
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 45, '6_32', 1, @p_month, @p_year, a.population
from ( 
        select 
                round( sum( coalesce( value, 0 ) ), 0 ) as population
        from lastmile_dataportal.tbl_values
        where ind_id = 45 and period_id = 1 and `month` = @p_month and `year` = @p_year and
              territory_id like '1\\_%' and not ( territory_id like '1\\_4' or territory_id like '1\\_6' or territory_id like '1\\_14' )
) as a
;

-- Fourth, add up the population totals for all the assisted counties and LMH managed to get the total for Liberia.
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 45, '6_27', 1, @p_month, @p_year, a.population
from ( 
        select round( sum( coalesce( value, 0 ) ), 0 ) as population
        from lastmile_dataportal.tbl_values
        where ind_id = 45 and period_id = 1 and `month` = @p_month and `year` = @p_year and
              ( territory_id like '6\\_32' or territory_id like '6\\_16' )
) as a
;

-- 45. Just copy 6_27 for now.
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 45, '6_35', 1 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 45 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;

-- 47. Number of records entered
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 47, '6_16', 1, @p_month, @p_year, SUM(`# records entered`) FROM lastmile_report.view_data_entry WHERE `Month`=@p_month AND `Year`=@p_year;


-- 50. Number of communities served
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 50, territory_id, 1, @p_month, @p_year, num_communities FROM lastmile_report.mart_program_scale;


-- 59. Percent of records QA'd
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 59, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(`# records receiving QA`,0))/SUM(COALESCE(`# records entered`,0)),3) FROM lastmile_report.view_data_entry WHERE `Month`=@p_month AND `Year`=@p_year;




-- 104. Turnover rate (CHAs; overall)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 104, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 104, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Rivercess', 'rate');


-- 105. Turnover rate (CHAs; termination)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 105, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 105, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Rivercess', 'rate');


-- 106. Turnover rate (CHAs; resignation)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 106, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 106, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Rivercess', 'rate');


-- 107. Turnover rate (CHAs; promotion)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 107, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 107, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Rivercess', 'rate');


-- 108. Turnover rate (CHAs; other/unknown)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 108, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 108, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Rivercess', 'rate');


-- 109. Turnover rate (Supervisors; overall)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 109, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 109, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Rivercess', 'rate');


-- 110. Turnover rate (Supervisors; termination)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 110, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 110, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Rivercess', 'rate');


-- 111. Turnover rate (Supervisors; resignation)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 111, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 111, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Rivercess', 'rate');


-- 112. Turnover rate (Supervisors; promotion)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 112, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 112, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Rivercess', 'rate');


-- 113. Turnover rate (Supervisors; other/unknown)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 113, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Grand Gedeh', 'rate');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 113, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Rivercess', 'rate');


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




-- 119.	NCHA Outputs: Number of routine visits conducted
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 119                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        119,      '6_27',         1,            @p_month, @p_year,  @liberia_total;


-- 121. CHA reporting rate
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 121, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.num_reports, 0 ) / b.num_cha, 3 ) as report_rate
from lastmile_report.mart_view_base_msr_county as a 
    left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
where a.month_reported=@p_month and a.year_reported=@p_year and not ( a.territory_id is null )

union all

select 121, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.num_reports, 0 ) ) / sum( coalesce( b.num_cha, 0 ) ), 3 ) as report_rate
from lastmile_report.mart_view_base_msr_county as a 
    left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id
where month_reported=@p_month and year_reported=@p_year and not ( a.territory_id is null )
;


-- 124.  Number of malaria treatments per CHA.  CHA is number of active CHAs in territory_id
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
      124 as ind_id, 
      m.territory_id, 
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( coalesce( m.num_tx_malaria, 0 ) / coalesce( s.num_cha, 0 ) ), 1 ) as malaria_treat_per_cha
         
from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id
    
where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )

union all

select 
      124 as ind_id,
      '6_16',
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( sum( coalesce( m.num_tx_malaria, 0 ) ) / sum( coalesce( s.num_cha, 0 ) ) ), 1 ) as malaria_treat_per_cha

from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id

where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )
;

-- 125.  Number of diarrhea treatments per CHA.  CHA is number of active CHAs in territory_id
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
      125 as ind_id, 
      m.territory_id, 
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( coalesce( m.num_tx_diarrhea, 0 ) / coalesce( s.num_cha, 0 ) ), 1 ) as diarrhea_treat_per_cha
          
from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id
    
where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )

union all

select 
      125 as ind_id,
      '6_16',
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( sum( coalesce( m.num_tx_diarrhea, 0 ) ) / sum( coalesce( s.num_cha, 0 ) ) ), 1 ) as diarrhea_treat_per_cha

from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id

where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )
;

-- 126.  Number of ari treatments per CHA.  CHA is number of active CHAs in territory_id
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
      126 as ind_id, 
      m.territory_id, 
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( coalesce( m.num_tx_ari, 0 ) / coalesce( s.num_cha, 0 ) ), 1 ) as ari_treat_per_cha
          
from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id
    
where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )

union all

select 
      126 as ind_id,
      '6_16',
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( sum( coalesce( m.num_tx_ari, 0 ) ) / sum( coalesce( s.num_cha, 0 ) ) ), 1 ) as ari_treat_per_cha

from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id

where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )
;

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

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 128, '6_32', 1, @p_month, @p_year, sum( a.number_malaria ) as number_malaria from (

    --  Cummulative malaria  screens for previous month. 
    select coalesce( value, 0 ) as number_malaria 
    from lastmile_dataportal.tbl_values 
    where ind_id = 128 and territory_id like '6\\_32' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Cummulative malaria  screens for current month.
    select coalesce( value, 0 ) as number_malaria 
    from lastmile_dataportal.tbl_values 
    where ind_id = 23 and 
    ( ( territory_id like '1\\_%' ) and not ( territory_id like '1\\_4'  or territory_id like '1\\_6' or territory_id like '1\\_14' ) ) and 
    `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;

-- 129. Cumulative number of child cases of diarrhea treated
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=129 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_tx_diarrhea,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 129, '6_16', 1, @p_month, @p_year, @new_value;

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 129, '6_32', 1, @p_month, @p_year, sum( a.number_diarrhea ) as number_diarrhea from (

    --  Cummulative malaria  screens for previous month. 
    select coalesce( value, 0 ) as number_diarrhea 
    from lastmile_dataportal.tbl_values 
    where ind_id = 129 and territory_id like '6\\_32' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Cummulative malaria  screens for current month.
    select coalesce( value, 0 ) as number_diarrhea 
    from lastmile_dataportal.tbl_values 
    where ind_id = 21 and 
    ( ( territory_id like '1\\_%' ) and not ( territory_id like '1\\_4'  or territory_id like '1\\_6' or territory_id like '1\\_14' ) ) and 
    `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;
 
-- 130. Cumulative number of child cases of ARI treated
SET @old_value = ( SELECT `value` FROM lastmile_dataportal.tbl_values
WHERE ind_id=130 AND `month`=@p_monthMinus1 AND `year`=@p_yearMinus1 AND territory_id='6_16' AND period_id=1 );
SET @new_value = @old_value + ( SELECT SUM(COALESCE(num_tx_ari,0)) FROM lastmile_report.mart_view_base_msr_county
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL );
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 130, '6_16', 1, @p_month, @p_year, @new_value;

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 130, '6_32', 1, @p_month, @p_year, sum( a.number_ari ) as number_ari from (

    --  Cummulative malaria  screens for previous month. 
    select coalesce( value, 0 ) as number_ari 
    from lastmile_dataportal.tbl_values 
    where ind_id = 130 and territory_id like '6\\_32' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Cummulative malaria  screens for current month.
    select coalesce( value, 0 ) as number_ari 
    from lastmile_dataportal.tbl_values 
    where ind_id = 19 and 
    ( ( territory_id like '1\\_%' ) and not ( territory_id like '1\\_4'  or territory_id like '1\\_6' or territory_id like '1\\_14' ) ) and 
    `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;

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
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
-- Note: the denominator here is the number of CHAs per territory_id who are reporting one or more restock and NOT the
-- number of CHAs in the territory.
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 147, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(COUNT(1),0) - COALESCE(SUM(any_stockouts_essentials),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 147, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(COUNT(1),0) - COALESCE(SUM(any_stockouts_essentials),0))/COALESCE(COUNT(1),0),3),NULL)
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
-- !!!!! the "cohort IS NULL" clause needs to be changed once cohorts are assigned !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 220, IF(county_id=6 AND cohort IS NULL,'6_31',IF(county_id=6 AND cohort='UNICEF','6_26',CONCAT('1_',county_id))), 1, @p_month, @p_year,
ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county
UNION SELECT 220, '6_16', 1, @p_month, @p_year, ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHA' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date);


-- 221. Percent of CHSSs who are female
-- !!!!! the "cohort IS NULL" clause needs to be changed once cohorts are assigned !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 221, IF(county_id=6 AND cohort IS NULL,'6_31',IF(county_id=6 AND cohort='UNICEF','6_26',CONCAT('1_',county_id))), 1, @p_month, @p_year,
ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date) GROUP BY county
UNION SELECT 221, '6_16', 1, @p_month, @p_year, ROUND(SUM(IF(gender='F',1,0))/COUNT(1),3) FROM lastmile_report.mart_view_base_history_person
WHERE job='CHSS' AND position_person_begin_date <= @p_date AND (position_person_end_date IS NULL OR position_person_end_date > @p_date);



-- 222. Number of child cases of malaria treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 222, territory_id, 1, @p_month, @p_year, ROUND(1000*(COALESCE(num_tx_malaria,0)/ ( COALESCE( num_catchment_people_iccm, 0 ) * 0.16 ) ), 0 )
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 222, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM(COALESCE(num_tx_malaria,0))/ SUM( COALESCE( num_catchment_people_iccm, 0 ) * 0.16 ) ), 0 )
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 222. Number of child cases of malaria treated per 1,000 population by QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      222 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      round( ( sum( coalesce( q.num_tx_malaria, 0 ) ) / sum( coalesce( q.num_catchment_people_iccm, 0 ) * 0.16 ) ) * 1000, 0 ) as rate
      
from lastmile_report.mart_view_msr as q
    left outer join lastmile_datamart.dimension_position   as dp on q.date_key = dp.date_key and q.cha_id like dp.position_id
        left outer join lastmile_dataportal.tbl_territories_other   as o on dp.qao_position_id like trim( o.territory_name ) 
where q.date_key = @p_date_key and not ( dp.qao_position_id is null ) 
group by dp.qao_position_id
;


-- 223. Number of child cases of diarrhea treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 223, territory_id, 1, @p_month, @p_year, ROUND(1000*(COALESCE(num_tx_diarrhea,0)/( COALESCE(num_catchment_people_iccm,0) * 0.16 ) ), 0 )
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 223, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM(COALESCE(num_tx_diarrhea,0))/SUM(COALESCE(num_catchment_people_iccm,0) * 0.16 ) ), 0 )
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 223. Number of child cases of diarrhea treated per 1,000 population by QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      223 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      round( ( sum( coalesce( q.num_tx_diarrhea, 0 ) ) / sum( coalesce( q.num_catchment_people_iccm, 0 ) * 0.16 ) ) * 1000, 0 ) as rate
      
from lastmile_report.mart_view_msr as q
    left outer join lastmile_datamart.dimension_position   as dp on q.date_key = dp.date_key and q.cha_id like dp.position_id
        left outer join lastmile_dataportal.tbl_territories_other   as o on dp.qao_position_id like trim( o.territory_name ) 
where q.date_key = @p_date_key and not ( dp.qao_position_id is null ) 
group by dp.qao_position_id
;


-- 224. Number of child cases of ARI treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 224, territory_id, 1, @p_month, @p_year, ROUND(1000*(COALESCE(num_tx_ari,0)/ ( COALESCE(num_catchment_people_iccm, 0 ) * 0.16 ) ), 0 )
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 224, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM(COALESCE(num_tx_ari,0))/SUM(COALESCE(num_catchment_people_iccm, 0 ) * 0.16 ) ), 0 )
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 224. Number of child cases of ARI treated per 1,000 population by QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      224 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      round( ( sum( coalesce( q.num_tx_ari, 0 ) ) / sum( coalesce( q.num_catchment_people_iccm, 0 ) * 0.16  ) ) * 1000, 0 ) as rate
      
from lastmile_report.mart_view_msr as q
    left outer join lastmile_datamart.dimension_position   as dp on q.date_key = dp.date_key and q.cha_id like dp.position_id
        left outer join lastmile_dataportal.tbl_territories_other   as o on dp.qao_position_id like trim( o.territory_name ) 
where q.date_key = @p_date_key and not ( dp.qao_position_id is null ) 
group by dp.qao_position_id
;


-- 226. Number of routine visits conducted per household
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 226, territory_id, 1, @p_month, @p_year, ROUND(COALESCE(num_routine_visits,0)/COALESCE(num_catchment_households,0),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 226, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_routine_visits,0))/SUM(COALESCE(num_catchment_households,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

/*
For NCHA value use an estimate of the  population, which is the number of CHA MSRs turned in multiplied by 350 
persons served per CHA. (ind_id = 381)

Then, use population divided by 6 to estimate the number of households.
The numerator is ind_id 119, which is the number of routine visits conducted in Liberia.
*/

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  226, 
        '6_27', 
        1, 
        @p_month, 
        @p_year, 
        round( r.value /p.number_household, 2 )
from tbl_values as r 
    left outer join ( select  ind_id, 
                              territory_id, 
                              period_id, 
                              `month`, 
                              `year`, 
                               round( ( coalesce( value, 0 ) * 350 ) / 6, 0 ) as number_household
                      from tbl_values where ( ind_id = 381 ) and ( territory_id like '6_27' ) and ( period_id = 1 ) and  ( `year` = @p_year )  and ( `month` = @p_month )
                    ) as p on ( r.territory_id like p.territory_id ) and ( r.`year` = p.`year` ) and ( r.`month` = p.`month` ) and ( r.period_id = p.period_id )
                
where ( r.ind_id = 119 ) and ( r.territory_id like '6_27' ) and ( r.period_id = 1 ) and ( r.`year` = @p_year )  and ( r.`month` = @p_month )
;




-- 229. Estimated percent of births tracked by a CHA
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 229, territory_id, 1, @p_month, @p_year, ROUND(COALESCE(num_births,0)/(0.0032*COALESCE(num_catchment_people,0)),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 229, '6_16', 1, @p_month, @p_year, ROUND(SUM(COALESCE(num_births,0))/(0.0032*SUM(COALESCE(num_catchment_people,0))),3)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 233. Ratio of CHAs to CHSS
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 233, territory_id, 1 as period_id, @p_month, @p_year, 
       round( min( if( a.fraction_part like 'numerator',  a.value, null ) ) -- numerator
              / 
              min( if( a.fraction_part like 'denominator',      a.value, null ) )  -- denominator
              , 3 ) as rate
from ( 

      select 
            'numerator' as fraction_part, 
            territory_id,
            min( value )      as value
      from lastmile_dataportal.tbl_values 
      where ind_id = 28                                                 and           
            ( territory_id like '1\\_%' or territory_id like '6\\_27' ) and 
            `year` = @p_year                                            and 
            `month` = @p_month                                          and 
            period_id = 1
      group by territory_id
 
      union all
      
      select 
            'denominator' as fraction_part,  
            territory_id,
            min( value )  as value
      from lastmile_dataportal.tbl_values 
      where ind_id = 29                                                 and 
            ( territory_id like '1\\_%' or territory_id like '6\\_27' ) and 
            `year` = @p_year                                            and 
            `month` = @p_month                                          and 
            period_id = 1
      group by territory_id
      
) as a
group by territory_id;

-- 235. Number of children screened for malnutrition (MUAC)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 235, territory_id, 1, @p_month, @p_year, COALESCE(num_muac_red,0)+COALESCE(num_muac_yellow,0)+COALESCE(num_muac_green,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 235, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_muac_red,0)+COALESCE(num_muac_yellow,0)+COALESCE(num_muac_green,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 235.	NCHA Outputs: Number of malnutrition screenings (MUAC) conducted for children under-five
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 235                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        235,      '6_27',         1,            @p_month, @p_year,  @liberia_total;

-- 237. Number of CHAs who received a restock visit
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 237, territory_id, 1, @p_month, @p_year, COALESCE(COUNT(1),0)
FROM lastmile_report.mart_view_base_restock_cha WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 237, '6_16', 1, @p_month, @p_year, COALESCE(COUNT(1),0)
FROM lastmile_report.mart_view_base_restock_cha WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


-- 238. Percent of CHAs who received a restock visit
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 238, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.number_restock, 0 ) / m.num_cha, 3 ) as restock_rate
from (
      select territory_id, count( * ) as number_restock
      from lastmile_report.mart_view_base_restock_cha
      where `month`=@p_month and `year`=@p_year and not( territory_id is null )
      group by territory_id     
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 

union all

select 238, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.number_restock, 0 ) ) / sum( m.num_cha ), 3 ) as restock_rate
from (
      select territory_id, count( * ) as number_restock
      from lastmile_report.mart_view_base_restock_cha
      where `month`=@p_month and `year`=@p_year and not( territory_id is null )
      group by territory_id     
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
;


-- 245. Estimated facility-based delivery rate n-value, which is the sum of the number of births in home and the number of births in facility.
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  245, territory_id, 1, @p_month, @p_year, 
        sum( coalesce( num_births_facility, 0 ) ) + sum( coalesce( num_births_home, 0 ) ) as n_value
FROM lastmile_report.mart_view_base_msr_county 
where not ( county_id is null ) and
      ( @isEndOfQuarter         and
        ( 
          ( year_reported = @p_year  and month_reported =  @p_month        )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus1  )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus2  ) 
        ) 
      )
group by territory_id

union all 
 
select  245, '6_16', 1, @p_month, @p_year, 
        sum( coalesce( num_births_facility, 0 ) ) + sum( coalesce( num_births_home, 0 ) ) as n_value

from lastmile_report.mart_view_base_msr_county 

where not ( county_id is null ) and
      ( @isEndOfQuarter         and
        ( 
          ( year_reported = @p_year  and month_reported =  @p_month        )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus1  )   or 
          ( year_reported = @p_year  and month_reported =  @p_monthMinus2  ) 
        ) 
      )
;




-- 247. Numerator (indID 104)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 247, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 247, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'any', 'Rivercess', 'numerator');


-- 249. Numerator (indID 105)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 249, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 249, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'terminated', 'Rivercess', 'numerator');


-- 250. Numerator (indID 106)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 250, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 250, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'resigned', 'Rivercess', 'numerator');


-- 251. Numerator (indID 107)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 251, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 251, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'promoted', 'Rivercess', 'numerator');


-- 252. Numerator (indID 108)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 252, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 252, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHA', 'other/unknown', 'Rivercess', 'numerator');


-- 253. Numerator (indID 109)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 253, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 253, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'any', 'Rivercess', 'numerator');


-- 255. Numerator (indID 110)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 255, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 255, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'terminated', 'Rivercess', 'numerator');


-- 256. Numerator (indID 111)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 256, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 256, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'resigned', 'Rivercess', 'numerator');


-- 257. Numerator (indID 112)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 257, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 257, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'promoted', 'Rivercess', 'numerator');


-- 258. Numerator (indID 113)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 258, '6_31', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Grand Gedeh', 'numerator');
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 258, '1_14', 1, @p_month, @p_year, lastmile_ncha.turnover(@p_date, @p_datePlus1, 'CHSS', 'other/unknown', 'Rivercess', 'numerator');


-- 302. CHSS reporting rate by territory_id
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )

-- Step 3. calculate the CHSS reporting rate based on number of repots / number of chss for territory_id
select 302, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.number_report, 0 ) / m.num_chss, 3 ) as report_rate
from (
      -- Step 2.  Aggregate the records based on county_id, generate territory_id from county_id, 
      -- and calculate the report counts for month.  Note: 1 in territory_id() signifies GG (LMH) (6_31), not 1_6
      select lastmile_report.territory_id( p.county_id, 1 ) as territory_id, count( * ) as number_report
      from (
            -- Step 1. Filter the reports based on year and month and toss out duplicate chss_id(s)
            select s.chss_id
            from lastmile_report.view_chss_msr as s
            where s.month_reported = @p_month and s.year_reported = @p_year
            group by s.chss_id
      
      ) as r
          left outer join lastmile_ncha.view_history_position_geo as p on ( r.chss_id like p.position_id ) and ( p.job like 'CHSS' )
      where not ( p.position_id is null )
      group by p.county_id
 
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
where not ( a.territory_id is null )

union all

select 302, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.number_report, 0 ) ) / sum( coalesce( m.num_chss, 0 ) ), 3 ) as report_rate

from (
      -- Step 2.  Aggregate the records based on county_id, generate territory_id from county_id, 
      -- and calculate the report counts for month.  Note: 1 in territory_id() signifies GG (LMH) (6_31), not 1_6
      select lastmile_report.territory_id( p.county_id, 1 ) as territory_id, count( * ) as number_report
      from (
            -- Step 1. Filter the reports based on year and month and toss out duplicate chss_id(s)
            select s.chss_id
            from lastmile_report.view_chss_msr as s
            where s.month_reported = @p_month and s.year_reported = @p_year
            group by s.chss_id
      
      ) as r
          left outer join lastmile_ncha.view_history_position_geo as p on ( r.chss_id like p.position_id ) and ( p.job like 'CHSS' )
      where not ( p.position_id is null )
      group by p.county_id
 
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
where not ( a.territory_id is null )
;


-- 302. CHSS reporting rate by QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      302 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( count( * ) / min( s.num_position_chss ), 3 ) as rate

from lastmile_report.view_chss_msr_qao as q
    left outer join lastmile_datamart.view_dimension_position_chss as v on q.date_key = v.date_key and q.chss_position_id like v.chss_position_id
    left outer join lastmile_dataportal.tbl_territories_other as o on v.qao_position_id like trim( o.territory_name ) 
        left outer join lastmile_report.mart_program_scale_qao as s on v.qao_position_id like s.qao_position_id
where q.date_key = @p_date_key and not ( v.qao_position_id is null ) 
group by v.qao_position_id
;


-- 305. Percent of expected CHSS mHealth supervision visit logs received
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 305, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.number_visit, 0 ) / ( m.num_cha * 2 ), 3 ) as report_rate
from (
      -- Filter the reports based on year and month and territory_id being not null
      select s.territory_id, count( * ) number_visit
      from lastmile_report.mart_view_base_odk_supervision as s
      where s.manualMonth = @p_month and s.manualYear = @p_year and not ( s.territory_id is null )
      group by s.territory_id
            
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
where not ( a.territory_id is null )

union all

select 305, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.number_visit, 0 ) ) / ( sum( coalesce( m.num_cha, 0 ) ) * 2 ), 3 ) as report_rate
from (
      -- Step 1. Filter the reports based on year and month and territory_id being not null
      select s.territory_id, count( * ) number_visit
      from lastmile_report.mart_view_base_odk_supervision as s
      where s.manualMonth = @p_month and s.manualYear = @p_year and not ( s.territory_id is null )
      group by s.territory_id
            
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
where not ( a.territory_id is null )
;

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


-- 322. Number of people served by LMH Primary Health Center activities
-- Before 1/2019 we manually entered these values.
if @p_date_key between 20190101 and 20210301 then
    replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
    select 322, '1_4',  1, @p_month, @p_year, 26418 union all
    select 322, '1_6',  1, @p_month, @p_year, 50000 union all
    select 322, '1_14', 1, @p_month, @p_year, 25246 union all
    select 322, '6_16', 1, @p_month, @p_year, 101664
    ;
elseif @p_date_key >= 20210401 then -- GB cohort 3 goes online

    replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
    select 322, '1_4',  1, @p_month, @p_year, 34326 union all
    select 322, '1_6',  1, @p_month, @p_year, 50000 union all
    select 322, '1_14', 1, @p_month, @p_year, 25246 union all
    select 322, '6_16', 1, @p_month, @p_year, 101664
    ;
end if
;


-- 323. Number of child cases treated per 1,000 population
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 323, territory_id, 1, @p_month, @p_year, ROUND(1000*((COALESCE(num_tx_malaria,0)+COALESCE(num_tx_diarrhea,0)+COALESCE(num_tx_ari,0))/COALESCE(num_catchment_people_iccm,0)),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 323, '6_16', 1, @p_month, @p_year, ROUND(1000*(SUM((COALESCE(num_tx_malaria,0)+COALESCE(num_tx_diarrhea,0)+COALESCE(num_tx_ari,0)))/SUM(COALESCE(num_catchment_people_iccm,0))),1)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select
      323,
      '6_27',
      1,
      @p_month,
      @p_year,
      round( ( coalesce( s.total_treatment, 0 ) / coalesce( p.population, 0 ) ) * 1000, 1 ) as rate

from (  
        select
              r.territory_id,
              r.period_id,
              r.`month`,
              r.`year`,
              sum( r.value ) as total_treatment  
              from tbl_values as r 
        where ( r.ind_id in ( 19, 21, 23) )   and 
              ( r.territory_id like '6_27' )  and 
              ( r.period_id = 1 )             and 
              ( r.`year` = @p_year )          and 
              ( r.`month` = @p_month )
      ) as s
          left outer join (
                            select  ind_id, 
                                    territory_id, 
                                    period_id, 
                                    `month`, 
                                    `year`, 
                                    round( coalesce( value, 0 ) * 350 , 0 ) as population
                            from tbl_values where ( ind_id = 381 ) and ( territory_id like '6_27' ) and ( period_id = 1 ) and  ( `year` = @p_year )  and ( `month` = @p_month )
                    ) as p on ( s.territory_id like p.territory_id ) and ( s.`year` = p.`year` ) and ( s.`month` = p.`month` ) and ( s.period_id = p.period_id )
;    

-- 324. QAO supervision rate

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 324, c.territory_id, 1 as period_id, @p_month,  @p_year,

       round( coalesce( c.number_supervision_visit, 0 ) / coalesce( s.num_cha, 0 ), 3 ) as qao_supervision_rate
      
from lastmile_report.view_qao_supervision_rate_county as c
    left outer join lastmile_report.mart_program_scale as s on trim( c.territory_id ) like trim( s.territory_id )
where c.year_reported = @p_year and c.month_reported = @p_month

union all

select 324, '6_16', 1 as period_id, @p_month,  @p_year,

       round( sum( coalesce(c.number_supervision_visit, 0 ) )/sum( coalesce( s.num_cha, 0 ) ), 3) as qao_supervision_rate
       
from lastmile_report.view_qao_supervision_rate_county as c
    left outer join lastmile_report.mart_program_scale as s on trim( c.territory_id ) like trim( s.territory_id )
where c.year_reported = @p_year and c.month_reported = @p_month
;


-- 325. National implementation fidelity reporting rate (LMH Assisted and Managed Networks)

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 325, '6_27', 1, @p_month,  @p_year,  round( count( * ) / coalesce( d.number_county_report, 0 ), 3 ) as ifi_report_rate
from (  
        select county 
        from lastmile_report.mart_view_kobo_ifi 
        where `month` = @p_month and `year` = @p_year 
        group by county
) as n
  cross join (  -- As new counties begin reporting over time, dynamically create a list and count of counties that have reported so far.
                select count( * ) as number_county_report
                from (  
                        select county 
                        from lastmile_report.mart_view_kobo_ifi  
                        where date( concat( `year`, '-', `month`,'-', '-01' ) ) <= date( concat( @p_year, '-', @p_month,'-', '-01' ) )
                        group by county
                ) as t

  ) as d;



-- 331. CHSS restock rate
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 331, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.number_restock, 0 ) / m.num_chss, 3 ) as restock_rate
from (
      select r.territory_id, count( * ) as number_restock
      from (
            select territory_id, chss_id
            from lastmile_report.mart_view_base_restock_chss
            where restock_month = @p_month and restock_year = @p_year and not ( territory_id is null ) 
            group by territory_id, chss_id
      ) as r
      group by r.territory_id
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 

union all

select 331, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.number_restock, 0 ) ) / sum( m.num_chss ), 3 ) as restock_rate
from (
      select r.territory_id, count( * ) as number_restock
      from (
            select territory_id, chss_id
            from lastmile_report.mart_view_base_restock_chss
            where restock_month = @p_month and restock_year = @p_year and not ( territory_id is null ) 
            group by territory_id, chss_id
      ) as r
      group by r.territory_id
) as a
    left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
;


-- 347. Number of community triggers reported
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 347, territory_id, 1, @p_month, @p_year, COALESCE(num_community_triggers,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 347, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_community_triggers,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 347.	NCHA Outputs: Number of community triggers reported
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 347                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        347,      '6_27',         1,            @p_month, @p_year,  @liberia_total;


-- 348. Number of referrals for HIV / TB / CM-NTD / mental health
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 348, territory_id, 1, @p_month, @p_year, COALESCE(num_referrals_suspect_hiv_tb_cm_ntd_mh,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 348, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_referrals_suspect_hiv_tb_cm_ntd_mh,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 349. Number of pregnant woman visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 349, territory_id, 1, @p_month, @p_year, COALESCE(num_pregnant_woman_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 349, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_pregnant_woman_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 349. NCHA Outputs: Number of pregnant woman visits
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 349                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        349,      '6_27',         1,            @p_month, @p_year,  @liberia_total;


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
FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL

UNION 

SELECT 356, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_clients_modern_fp,0))
FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 356.	NCHA Outputs: Number of women currently using a modern method of family planning
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators 
-- (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) and uploading them into
-- the dhis2 ncahap upload table.

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
select 356, '6_27', 1, @p_month, @p_year,  sum( coalesce( value, 0 ) ) 
from lastmile_dataportal.tbl_values 
where ind_id = 356 and `month` = @p_month and `year` = @p_year and period_id = 1 and territory_id like '1\\_%' 
;

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
select 356, '6_32', 1, @p_month, @p_year,  sum( coalesce( value, 0 ) ) 
from lastmile_dataportal.tbl_values 
where ind_id = 356 and `month` = @p_month and `year` = @p_year and period_id = 1 and 
      ( territory_id like '1\\_%' and not ( territory_id like '1\\_6' or territory_id like '1\\_14'  or territory_id like '1\\_4' ) ) 
;

-- 391. TARGET: 356. Number of women currently using a modern method of family planning
 case
       -- fy 2017 and earlier
      when @p_year <  2017                                then set @target_fy_356_6_27 = null;
      when @p_year =  2017 and @p_month between 1 and 6   then set @target_fy_356_6_27 = null;
      
      -- fy 2018
      -- Data doesnt' begin until 1/2018, so set first half of fy to null to make graph look better.
      when @p_year =  2017 and @p_month between 7 and 12  then set @target_fy_356_6_27 = null;
      when @p_year =  2018 and @p_month between 1 and 6   then set @target_fy_356_6_27 = 20530;
      
      -- fy 2019
      when @p_year =  2018 and @p_month between 7 and 12  then set @target_fy_356_6_27 = 41060;
      when @p_year =  2019 and @p_month between 1 and 6   then set @target_fy_356_6_27 = 41060;
      
      -- fy 2020
      when @p_year =  2019 and @p_month between 7 and 12  then set @target_fy_356_6_27 = 41060;
      when @p_year =  2020 and @p_month between 1 and 6   then set @target_fy_356_6_27 = 41060;
      
      else 
           set @target_fy_356_6_27 = 41060;     
        
 end case;
    
if not ( @target_fy_356_6_27 is null ) then

  replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`,value )
  select 391, '6_27', 1 as period_id, @p_month, @p_year, @target_fy_356_6_27 as target;

end if;


-- 357. Number of HIV client visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 357, territory_id, 1, @p_month, @p_year, COALESCE(num_hiv_client_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 357, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_hiv_client_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;


-- 357. NCHA Outputs: Number of HIV client visits
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 357                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        357,      '6_27',         1,            @p_month, @p_year,  @liberia_total;

-- 358. Number of TB client visits
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 358, territory_id, 1, @p_month, @p_year, COALESCE(num_tb_client_visits,0)
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL
UNION SELECT 358, '6_16', 1, @p_month, @p_year, SUM(COALESCE(num_tb_client_visits,0))
FROM lastmile_report.mart_view_base_msr_county WHERE month_reported=@p_month AND year_reported=@p_year AND county_id IS NOT NULL;

-- 358.	NCHA Outputs: Number of TB client visits
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 358                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                          
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           ) 
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        358,      '6_27',         1,            @p_month, @p_year,  @liberia_total;

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
FROM lastmile_report.mart_view_kobo_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 366, '6_27', 1, @p_month, @p_year, SUM(COALESCE(numReports,0))
FROM lastmile_report.mart_view_kobo_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 366, territory_id, 2, @p_month, @p_year, SUM(COALESCE(numReports,0))
FROM lastmile_report.mart_view_kobo_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;

-- 367. Percent of CHAs who received a restock visit in the past month (IFI)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 367, territory_id, 1, @p_month, @p_year, ROUND(SUM(COALESCE(restockedInLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_kobo_ifi WHERE `month`=@p_month AND `year`=@p_year GROUP BY territory_id
UNION SELECT 367, '6_27', 1, @p_month, @p_year, ROUND(SUM(COALESCE(restockedInLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_kobo_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 367, territory_id, 2, @p_month, @p_year, ROUND(SUM(COALESCE(restockedInLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_kobo_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;


-- 368. Percent of CHAs who received a supervision visit in the past month (IFI)
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 368, territory_id, 1, @p_month, @p_year, ROUND(SUM(COALESCE(supervisedLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_kobo_ifi WHERE `month`=@p_month AND `year`=@p_year GROUP BY territory_id
UNION SELECT 368, '6_27', 1, @p_month, @p_year, ROUND(SUM(COALESCE(supervisedLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_kobo_ifi WHERE `month`=@p_month AND `year`=@p_year
UNION SELECT 368, territory_id, 2, @p_month, @p_year, ROUND(SUM(COALESCE(supervisedLastMonth,0))/SUM(COALESCE(numReports,0)),3)
FROM lastmile_report.mart_view_kobo_ifi WHERE ((`year`=@p_year AND `month`=@p_month) OR (`year`=@p_yearMinus1 AND `month`=@p_monthMinus1) OR (`year`=@p_yearMinus2 AND `month`=@p_monthMinus2)) GROUP BY territory_id;


-- 368. Co-impact KPIs are reported on for March and August.  Use period_id = 38 (month 3 and month 8) to specific them.
if ( @p_month = 3 ) or ( @p_month = 8 ) then 

-- 368.  Percent of CHAs who received a supervision visit in the past month (IFI)
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 368, '6_27', 38 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 368 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;

end if;


-- Before July 2019 we were excluding managed counties.
if @p_date_key < 20190701 then

    replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
    select 368, '6_32', 1, @p_month, @p_year, round( sum( coalesce( supervisedLastMonth, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 )
    from lastmile_report.mart_view_kobo_ifi 
    where `month`=@p_month and `year`=@p_year and 
    not ( county like '%Grand%Bassa%' or county like '%Grand%Gedeh%' or county like '%Rivercess%' );

else

    replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
    select 368, '6_32', 1, @p_month, @p_year, round( sum( coalesce( supervisedLastMonth, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 )
    from lastmile_report.mart_view_kobo_ifi 
    where `month`=@p_month and `year`=@p_year;

end if;


-- 369. Percent of CHAs who received their last monetary incentive on time (IFI)

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select
      369               as ind_id,
      a.territory_id    as territory_id,
      1                 as period_id,
      @p_month,
      @p_year,
      coalesce( round( sum( coalesce( i.receivedLastIncentiveOnTime, 0 ) ) / sum( coalesce( i.numReports, 0 ) ), 3 ), 0 ) as value
     
from lastmile_dataportal.view_territories_active as a
    left outer join lastmile_report.mart_view_kobo_ifi as i on  ( a.territory_id like i.territory_id  ) and
                                                                ( i.`month` = @p_month                ) and 
                                                                ( i.`year` = @p_year                  )
                                                                
where ( a.territory_type like 'county' ) and not ( a.territory_id like '1\\_11' )
group by a.territory_id

union all 

select
      369               as ind_id,
      '6_27'            as territory_id,
      1                 as period_id,
      @p_month,
      @p_year,
      coalesce( round( sum( coalesce( i.receivedLastIncentiveOnTime, 0 ) ) / sum( coalesce( i.numReports, 0 ) ), 3 ), 0 ) as value
     
from lastmile_dataportal.view_territories_active as a
    left outer join lastmile_report.mart_view_kobo_ifi as i on  ( a.territory_id like i.territory_id  ) and
                                                                ( i.`month` = @p_month                ) and 
                                                                ( i.`year` = @p_year                  )
                                                                
where ( a.territory_type like 'county' ) and not ( a.territory_id like '1\\_11' )

union all

select
      369               as ind_id,
      a.territory_id    as territory_id,
      2                 as period_id,
      @p_month,
      @p_year,
      coalesce( round( sum( coalesce( i.receivedLastIncentiveOnTime, 0 ) ) / sum( coalesce( i.numReports, 0 ) ), 3 ), 0 ) as value
     
from lastmile_dataportal.view_territories_active as a
    left outer join lastmile_report.mart_view_kobo_ifi as i on  ( a.territory_id like i.territory_id  ) and
                                                                ( 
                                                                  ( ( i.`month` = @p_month        ) and ( i.`year` = @p_year       ) ) or 
                                                                  ( ( i.`month` = @p_monthMinus1  ) and ( i.`year` = @p_yearMinus1 ) ) or 
                                                                  ( ( i.`month` = @p_monthMinus2  ) and ( i.`year` = @p_yearMinus2 ) )                                                              
                                                                )
                                                                
where ( a.territory_type like 'county' ) and not ( a.territory_id like '1\\_11' )
group by a.territory_id
;

replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
      369, 
      '6_16', 
      1, 
      @p_month, 
      @p_year, 
      round( sum( coalesce( receivedLastIncentiveOnTime, 0 ) )/sum( coalesce( numReports, 0 ) ), 3)
      
from lastmile_report.mart_view_kobo_ifi 
where `month` = @p_month and `year`=@p_year and 
      ( territory_id like '1\\_4' or territory_id like '1\\_6' or territory_id like '1\\_14' )

union all

select 
      369, 
      '6_32', 
      1, 
      @p_month, 
      @p_year, 
      round( sum( coalesce( receivedLastIncentiveOnTime, 0 ) )/sum( coalesce( numReports, 0 ) ), 3)
      
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month AND `year`=@p_year and 
      not ( territory_id like '1\\_4' or territory_id like '1\\_6' or territory_id like '1\\_14' )
;


-- 369. Co-impact KPIs are reported on for March and August.  Use period_id = 38 (month 3 and month 8) to specific them.
if ( @p_month = 3 ) or ( @p_month = 8 ) then 

-- 369. Percent of CHAs who received their last monetary incentive on time (IFI)
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 369, '6_27', 38 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 369 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;

end if;


-- 372.  Number of MUAC test (red + yellow + green) per CHA.  CHA is number of active CHAs in territory_id
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
      372 as ind_id, 
      m.territory_id, 
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( 
              ( coalesce( m.num_muac_green, 0 ) + coalesce( m.num_muac_yellow, 0 ) + coalesce( m.num_muac_red, 0 ) ) 
              / coalesce( s.num_cha, 0 ) ), 1 ) as muac_per_cha
          
from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id
    
where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )

union all

select 
      372 as ind_id,
      '6_16',
      1 as period_id, 
      @p_month, 
      @p_year, 
      round( ( 
              sum( ( coalesce( m.num_muac_green, 0 ) + coalesce( m.num_muac_yellow, 0 ) + coalesce( m.num_muac_red, 0 ) ) ) 
              / sum( coalesce( s.num_cha, 0 ) ) ), 1 ) as muac_per_cha

from lastmile_report.mart_view_base_msr_county as m
    left outer join lastmile_report.mart_program_scale as s on m.territory_id like s.territory_id

where m.month_reported = @p_month and m.year_reported = @p_year and not( m.county_id is null )
;



-- 381. NCHA Outputs: Number of CHA monthly service reports (MSRs) received by MOH
-- The 15 county values are manually uploaded monthly from dhis2 by downloading the indicators (381, 357, 358, 19, 21, 347, 349, 119, 356, 18, 23, 235) in excel and uploading  
-- them into tbl_values using Avi's excel/sql spreadsheet.  We need to calculate the Liberia totals (6_27) for the 15 counties.

set @liberia_total = (  select sum( value ) from tbl_values 
                        where ( ind_id = 381                      ) and 
                              ( `month` = @p_month                ) and 
                              ( `year` = @p_year                  ) and                               
                              ( period_id = 1                     ) and
                              ( territory_id like '1_%'           )                             
);

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        381,      '6_27',         1,            @p_month, @p_year,  @liberia_total;


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

-- 388. Cumulative TARGET number of routine visits conducted
--      Every month the cumulative target increases by 30664

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 388, '6_27', 1, @p_month, @p_year,(  a.number_routine_visit_target + 30664 ) as number_routine_visit_target from (

    -- Audacious TARGET cummulative routine visits in Liberia for previous month. 
    select min( coalesce( value, 0 ) ) as number_routine_visit_target 
    from lastmile_dataportal.tbl_values 
    where ind_id = 388 and territory_id like '6_27' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
        
) as a;

-- 389. Cummulative TARGET child cases of malaria, diarrhea,and ARI trieated.  (Target for 393.)
--      Every month the cumulative target increases by 14593

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 389, '6_27', 1, @p_month, @p_year, ( a.number_child_case_target + 14593 ) as number_child_case_target from (

    -- Audacious cummulative TARGET child cases of malaria, diarrhea,and ARI trieated in Liberia for previous month. 
    select min( coalesce( value, 0 ) ) as number_child_case_target 
    from lastmile_dataportal.tbl_values 
    where ind_id = 389 and territory_id like '6_27' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
) as a;

-- 390. Cumulative TARGET number of pregnant woman visits in Liberia.  (Target for 394.)
-- Every month the cumulative target increases by 4415

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 390, '6_27', 1, @p_month, @p_year, ( a.number_pregnant_woman_target + 4415 ) as number_pregnant_woman_target from (

    -- Audacious cumulative TARGET number of pregnant woman visits in Liberia for previous month. 
    select min( coalesce( value, 0 ) ) as number_pregnant_woman_target
    from lastmile_dataportal.tbl_values 
    where ind_id = 390 and territory_id like '6_27' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
) as a;



-- 393. Cummulative child cases of malaria, diarrhea,and ARI trieated

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 393, '6_27', 1, @p_month, @p_year, sum( a.number_child_case ) as total_child_case from (

    -- Audacious cummulative child cases of malaria, diarrhea,and ARI trieated in Liberia for previous month. 
    select coalesce( value, 0 ) as number_child_case 
    from lastmile_dataportal.tbl_values 
    where ind_id = 393 and territory_id like '6_27' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- NCHA Output of child cases of malaria, diarrhea,and ARI trieated in Liberia for the current month.  For this to work, the 
    -- dhis2 NCHA Output data must have been uploaded manually already.
    select coalesce( value, 0 ) as number_child_case 
    from lastmile_dataportal.tbl_values 
    where ind_id in ( 19, 21, 23 ) and territory_id like '6_27' and `year` = @p_year and `month` = @p_month and period_id = 1
        
) as a;



replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 393, '6_16', 1, @p_month, @p_year, sum( a.number_child_case ) as total_child_case from (

    -- Audacious cummulative child cases of malaria, diarrhea,and ARI trieated in Liberia for previous month. 
    select coalesce( value, 0 ) as number_child_case 
    from lastmile_dataportal.tbl_values 
    where ind_id = 393 and territory_id like '6_16' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- NCHA Output of child cases of malaria, diarrhea,and ARI trieated in Liberia for the current month.
    select coalesce( value, 0 ) as number_child_case 
    from lastmile_dataportal.tbl_values 
    where ind_id in ( 19, 21, 23 ) and ( territory_id like '6\\_31' or territory_id like '1\\_14' or territory_id like '1\\_4' ) and `year` = @p_year and `month` = @p_month and period_id = 1
  
) as a;

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 393, '6_32', 1, @p_month, @p_year, sum( a.number_child_case ) as total_child_case from (

    -- Audacious cummulative child cases of malaria, diarrhea,and ARI trieated in Liberia for previous month. 
    select coalesce( value, 0 ) as number_child_case 
    from lastmile_dataportal.tbl_values 
    where ind_id = 393 and territory_id like '6_32' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- NCHA Output of child cases of malaria, diarrhea,and ARI trieated in Liberia for the current month.
    select coalesce( value, 0 ) as number_child_case 
    from lastmile_dataportal.tbl_values 
    where ind_id in ( 19, 21, 23 ) and ( territory_id like '1\\_%' and not ( territory_id like '1\\_6' or territory_id like '1\\_14'  or territory_id like '1\\_4' ) ) and `year` = @p_year and `month` = @p_month and period_id = 1
  
) as a;


-- 394. Cumulative number of pregnant woman visits in Liberia

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 394, '6_27', 1, @p_month, @p_year, sum( a.number_pregnant_woman ) as total_pregnant_woman from (

    -- Audacious cumulative number of pregnant woman visits in Liberia for previous month. 
    select coalesce( value, 0 ) as number_pregnant_woman 
    from lastmile_dataportal.tbl_values 
    where ind_id = 394 and territory_id like '6\\_27' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- NCHA Output number of pregnant woman visits in Liberia for the current month.  For this to work, the 
    -- dhis2 NCHA Output data must have been uploaded manually already.
    select coalesce( value, 0 ) as number_pregnant_woman 
    from lastmile_dataportal.tbl_values 
    where ind_id = 349 and territory_id like '6\\_27' and `year` = @p_year and `month` = @p_month and period_id = 1
    
) as a;

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 394, '6_16', 1, @p_month, @p_year, sum( a.number_pregnant_woman ) as number_pregnant_woman from (

    select coalesce( value, 0 ) as number_pregnant_woman 
    from lastmile_dataportal.tbl_values 
    where ind_id = 394 and territory_id like '6\\_16' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    select coalesce( value, 0 ) as number_pregnant_woman 
    from lastmile_dataportal.tbl_values 
    where ind_id = 349 and territory_id like '6\\_16' and `year` = @p_year and `month` = @p_month and period_id = 1
  
) as a;

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 394, '6_32', 1, @p_month, @p_year, sum( a.number_pregnant_woman ) as number_pregnant_woman from (
 
    select coalesce( value, 0 ) as number_pregnant_woman 
    from lastmile_dataportal.tbl_values 
    where ind_id = 394 and territory_id like '6\\_32' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    select coalesce( value, 0 ) as number_pregnant_woman 
    from lastmile_dataportal.tbl_values 
    where ind_id = 349 and ( territory_id like '1\\_%' and not ( territory_id like '1\\_6' or territory_id like '1\\_14'  or territory_id like '1\\_4' ) ) and `year` = @p_year and `month` = @p_month and period_id = 1
  
) as a;


-- 396. Cumulative number of child cases of malaria treated in Liberia
--      This indicator is the cumulative calculation of indicator 23, which is inputted monthly. If indicator 23 
--      is not updated before the 15th of the month then the stored procedure needs to be rerun.
                                     
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 396             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 23       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        396,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 397. Cumulative number of child cases of diarrhea treated in Liberia
--      This indicator is the cumulative calculation of indicator 21, which is inputted monthly.  If indicator 21
--      is not updated before the 15th of the month then the stored procedure needs to be rerun.

set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 397             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               ) );

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 21       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        397,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 398. Cumulative number of child cases of ARI treated in Liberia
--      This indicator is the cumulative calculation of indicator 19, which is inputted monthly.  If indicator 19
--      is not updated before the 15th of the month then the stored procedure needs to be rerun.

set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 398             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               ) );

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 19       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        398,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 399. Cumulative number of routine visits conducted in Liberia
--      This indicator is the cumulative calculation of indicator 119, which is inputted monthly.  If indicator 119
--      is not updated before the 15th of the month then the stored procedure needs to be rerun.
                                    
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 399             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 119       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        399,      '6_27',         1,            @p_month, @p_year,  @new_value;

-- 425. TARGET: 399. Cumulative number of routine visits conducted in Liberia
 case
       -- fy 2017 and earlier
      when @p_year <  2017                                then set @target_fy_399_6_27 = null;
      when @p_year =  2017 and @p_month between 1 and 6   then set @target_fy_399_6_27 = null;
      
      -- fy 2018
      -- Data doesnt' begin until 1/2018, so set first half of fy to null to make graph look better.
      when @p_year =  2017 and @p_month between 7 and 12  then set @target_fy_399_6_27 = 367967;
      when @p_year =  2018 and @p_month between 1 and 6   then set @target_fy_399_6_27 = 367967;
      
      -- fy 2019
      when @p_year =  2018 and @p_month between 7 and 12  then set @target_fy_399_6_27 = 735934;
      when @p_year =  2019 and @p_month between 1 and 6   then set @target_fy_399_6_27 = 735934;
      
      -- fy 2020
      when @p_year =  2019 and @p_month between 7 and 12  then set @target_fy_399_6_27 = 735934;
      when @p_year =  2020 and @p_month between 1 and 6   then set @target_fy_399_6_27 = 735934;
      
      else 
           set @target_fy_399_6_27 = 735934;     
        
 end case;
    
if not ( @target_fy_399_6_27 is null ) then

  replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`,value )
  select 425, '6_27', 1 as period_id, @p_month, @p_year, @target_fy_399_6_27 as target;

end if;


-- 400. Cumulative number of monthly service reports (MSRs) collected in Liberia
--      This indicator is the cumulative calculation of indicator 381, which is inputted monthly.  If indicator 381 
--      is not updated before the 15th of the month then the stored procedure needs to be rerun.
                                     
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 400             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 381       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        400,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 401. Cumulative number of births tracked in Liberia
--      This indicator is the cumulative calculation of indicator 18, which is inputted monthly.  
--      If indicator 18 is not updated before the 15th of the month then the stored procedure 
--      needs to be rerun.

                                     
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 401             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 18       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        401,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 402. Cumulative number of community triggers tracked in Liberia
--      This indicator is the cumulative calculation of indicator 347, which is inputted monthly.  
--      If indicator 347 is not updated before the 15th of the month then the stored procedure 
--      needs to be rerun.
                                  
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 402             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 347       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        402,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 402. (6_35) # of potential epidemic events identified across Anchor Country Programs, beginning with FY20.
-- This code is now the preferred way to code cummulative, not 402/6_27 above or the other way I (owen) was doing 
-- it with unions and subqueries.  Also, see 429/6_35 as well.

if @p_date_key >= 20170701 then

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
select
      402                         as ind_id, 
      '6_35'                      as territory_id,
      1                           as period_id, 
      @p_month                    as `month`,
      @p_year                     as `year`,
      sum( coalesce( value, 0 ) ) as value

from lastmile_dataportal.tbl_values 
where ( 
        ind_id = 347                      and
        territory_id like '6\\_27'        and 
        `month`   = @p_month              and 
        `year`    = @p_year               and
        period_id = 1
      ) or
      ( 
        ind_id = 402                      and
        territory_id like '6\\_35'        and 
        `month`   = @p_monthMinus1        and 
        `year`    = @p_yearMinus1         and
        period_id = 1
      ); 
        
end if;
 

-- 403. Average number of essential commodity stock-outs per CHA
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 403, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND(COALESCE(SUM(num_stockouts_essentials),0)/COALESCE(COUNT(1),0),1),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 403, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND(COALESCE(SUM(num_stockouts_essentials),0)/COALESCE(COUNT(1),0),1),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;


                                     
-- 405. Cumulative number of pregnant woman visits tracked in Liberia
--      This indicator is the cumulative calculation of indicator 349, which is inputted monthly.  
--      If indicator 349 is not updated before the 15th of the month then the stored procedure 
--      needs to be rerun.
                                  
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 405             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 349       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        405,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- 424. TARGET: 405. Cumulative number of pregnant woman visits tracked in Liberia ( territory_id = 6_27 )
 case
 
       -- fy 2017 and earlier
      when @p_year <  2017                                then set @target_fy_405_6_27 = null;
      when @p_year =  2017 and @p_month between 1 and 6   then set @target_fy_405_6_27 = null;
      
      -- fy 2018
      when @p_year =  2017 and @p_month between 7 and 12  then set @target_fy_405_6_27 = 52979;
      when @p_year =  2018 and @p_month between 1 and 6   then set @target_fy_405_6_27 = 52979;
      
      -- fy 2019
      when @p_year =  2018 and @p_month between 7 and 12  then set @target_fy_405_6_27 = 105959;
      when @p_year =  2019 and @p_month between 1 and 6   then set @target_fy_405_6_27 = 105959;
      
      -- fy 2020
      when @p_year =  2019 and @p_month between 7 and 12  then set @target_fy_405_6_27 = 105959;
      when @p_year =  2020 and @p_month between 1 and 6   then set @target_fy_405_6_27 = 105959;
      
      else 
           set @target_fy_405_6_27 = 105959;     
           
 end case;
    
if not ( @target_fy_405_6_27 is null ) then

  replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`,value )
  select 424, '6_27', 1 as period_id, @p_month, @p_year, @target_fy_405_6_27 as target;

end if;


-- 407. Cumulative number of number of children screened for malnutrition (MUAC) tracked in Liberia
--      This indicator is the cumulative calculation of indicator 235, which is inputted monthly.  
--      If indicator 235 is not updated before the 15th of the month then the stored procedure 
--      needs to be rerun.
                       
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 407             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 235       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        407,      '6_27',         1,            @p_month, @p_year,  @new_value;


-- LMH Managed Areas 6_16.  Recode 6_27 like below.  It's cleaner code.
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 407, '6_16', 1, @p_month, @p_year, sum( a.number_muac ) as total_number_muac from (

    --  Cummulative muac screens for PREVIOUS month. 
    select coalesce( value, 0 ) as number_muac 
    from lastmile_dataportal.tbl_values 
    where ind_id = 407 and territory_id like '6\\_16' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Cummulative muac screens for CURRENT month.
    select coalesce( value, 0 ) as number_muac 
    from lastmile_dataportal.tbl_values 
    where ind_id = 235 and territory_id like '6\\_16' and `year` = @p_year and `month` = @p_month and period_id = 1
    
) as a
;

-- 6_32 LMH Not Managed areas

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 407, '6_32', 1, @p_month, @p_year, sum( a.number_muac ) as total_number_muac from (

    --  Cummulative muac screens for previous month. 
    select coalesce( value, 0 ) as number_muac 
    from lastmile_dataportal.tbl_values 
    where ind_id = 407 and territory_id like '6\\_32' and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Cummulative muac screens for current month.
    select coalesce( value, 0 ) as number_muac 
    from lastmile_dataportal.tbl_values 
    where ind_id = 235 and 
    ( ( territory_id like '1\\_%' ) and not ( territory_id like '1\\_4'  or territory_id like '1\\_6' or territory_id like '1\\_14' ) ) and 
    `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;




-- 408. Cumulative number of Number of HIV client visits tracked in Liberia
--      This indicator is the cumulative calculation of indicator 357, which is inputted monthly.  
--      If indicator 357 is not updated before the 15th of the month then the stored procedure 
--      needs to be rerun.

                                     
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 408             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 357       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        408,      '6_27',         1,            @p_month, @p_year,  @new_value;



-- 409. Cumulative number of Number of TB client visits tracked in Liberia
--      This indicator is the cumulative calculation of indicator 358, which is inputted monthly.  
--      If indicator 358 is not updated before the 15th of the month then the stored procedure 
--      needs to be rerun.

                                     
set @old_value =                ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 409             ) and 
                                        ( `month`       = @p_monthMinus1  ) and 
                                        ( `year`        = @p_yearMinus1   ) and 
                                        ( territory_id  = '6_27'          ) and 
                                        ( period_id     = 1               )                                                               
                                );                                       
                                        

set @new_value = @old_value +   ( select coalesce( min( value ), 0 )
                                  from lastmile_dataportal.tbl_values
                                  where ( `ind_id`      = 358       ) and 
                                        ( `month`       = @p_month ) and 
                                        ( `year`        = @p_year  ) and
                                        ( territory_id  = '6_27'   ) and 
                                        ( period_id     = 1        ) );

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
SELECT                                        409,      '6_27',         1,            @p_month, @p_year,  @new_value;


/* 410. Number of community triggers reported per 1,000 population.

For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data collected in the LMD CHA MSRs.

For all other counties it is based on the number of community triggers reported (347) and the number of CHA MSRs reported by counties (381) 
from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15

The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
number of CHAs deployed (ind_id 28).

Lastly, 410 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 
        410, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        ROUND( 1000 * ( COALESCE( num_community_triggers, 0 ) / COALESCE( num_catchment_people_iccm, 0 ) ), 1 )

FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported=@p_month AND 
      year_reported=@p_year   AND 
      county_id IS NOT NULL
UNION  
SELECT 
      410, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      ROUND( 1000 * ( SUM( COALESCE( num_community_triggers, 0 ) ) / SUM( COALESCE( num_catchment_people_iccm, 0 ) ) ), 1 )
FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported = @p_month AND 
      year_reported=@p_year     AND 
      county_id IS NOT NULL
;

-- Next, calculate indicator values for all counties except Rivercess.
REPLACE INTO lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select
      410,
      a.territory_id,
      1,
      @p_month,
      @p_year,
      if( max( a.number_cha_msr ) is null          or 
          trim( max( a.number_cha_msr ) ) like ''  or
          trim( max( a.number_cha_msr ) ) like '0' , 
          0, 
          round( ( max( a.number_community_triggers ) / ( max( a.number_cha_msr ) * 300 ) ) * 1000, 1 )
        ) as rate                              
from ( 
      select 
            territory_id, 
            value         as number_community_triggers, 
            null          as number_cha_msr
      from lastmile_dataportal.tbl_values    
      where ( ind_id = 347 )  and ( `month` = @p_month ) and ( `year` = @p_year ) and 
            ( period_id = 1 ) and ( trim( territory_id ) like '1_%' and ( not trim( territory_id ) like '1_14' ) )
              
      union all
        
      select 
            territory_id, 
            null          as number_community_triggers, 
            value         as number_cha_msr
      from lastmile_dataportal.tbl_values    
      where ( ind_id = 381 )  and ( `month` = @p_month ) and ( `year` = @p_year ) and 
            ( period_id = 1 ) and ( trim( territory_id ) like '1_%' and ( not trim( territory_id ) like '1_14' ) )
   
) as a
group by a.territory_id
;


-- Lastly, calculate the national community trigger rate per 1000
REPLACE INTO lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 410, '6_27', 1, @p_month, @p_year, round( ( sum( b.number_community_triggers ) / sum( b.population ) ) * 1000, 1 ) as rate
from (
      -- Add in the Rivercess totals.  Note: the populationn is a combination of LMH registration data and estimates where 
      -- registration is not available.
      select  
            num_community_triggers      as number_community_triggers, 
            num_catchment_people_iccm   as population
      from lastmile_report.mart_view_base_msr_county 
      where month_reported=@p_month and year_reported=@p_year and ( not county_id is null ) and territory_id like '1_14'

      union all

      select
            -- Use indicator as a switch.  Sum indicator value when matched to indicator; otherwise, add 0.  Bit of a hack.
            sum( if( a.ind_id = 347, a.value, 0 ) )         as number_community_triggers, -- sum of all the community triggers recorded for the month in dhis2, except for Rivercess
            sum( if( a.ind_id = 381, a.value, 0 ) ) * 300   as population                 -- sum of all the CHA MSRs recorded for the month in dhis2, except for Rivercess
      from ( 
            select ind_id, value 
            from lastmile_dataportal.tbl_values    
            where ( ind_id = 347 )  and ( `month` = @p_month ) and ( `year` = @p_year ) and 
                  ( period_id = 1 ) and ( trim( territory_id ) like '1_%' and ( not trim( territory_id ) like '1_14' ) )
              
            union all
        
            select ind_id, value
            from lastmile_dataportal.tbl_values    
            where ( ind_id = 381 )  and ( `month` = @p_month ) and ( `year` = @p_year ) and 
                  ( period_id = 1 ) and ( trim( territory_id ) like '1_%' and ( not trim( territory_id ) like '1_14' ) )
   
      ) as a

) as b;


-- 412. Number of women with access to family planning services Definition: Total population served 
-- of reproductive age (i.e. population served * 24%)

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`,value)
select 412, territory_id,  1 as period_id, @p_month, @p_year, round( coalesce(value, 0 ) * 0.24, 0 ) as number_women
from lastmile_dataportal.tbl_values
where ind_id = 45 and period_id = 1 and `month` = @p_month and `year` = @p_year and
      ( territory_id like '6\\_16' or territory_id like '6\\_27' or territory_id like '6\\_32' )
;


-- 414. TARGET: 412. Number of women with access to family planning services Definition: 
-- Total population served of reproductive age (i.e. population served * 24%)

 case
 
       -- fy 2017 and earlier
      when @p_year <  2017                                then set @target_fy_412_6_27 = null;
      when @p_year =  2017 and @p_month between 1 and 6   then set @target_fy_412_6_27 = null;
      
      -- fy 2018
      -- Target doesnt' begin until 1/2018, so set first half of fy to null to make graph look better.
      when @p_year =  2017 and @p_month between 7 and 12  then set @target_fy_412_6_27 = null;
      when @p_year =  2018 and @p_month between 1 and 6   then set @target_fy_412_6_27 = 167970;
      
      -- fy 2019
      when @p_year =  2018 and @p_month between 7 and 12  then set @target_fy_412_6_27 = 335940;
      when @p_year =  2019 and @p_month between 1 and 6   then set @target_fy_412_6_27 = 335940;
      
      -- fy 2020
      when @p_year =  2019 and @p_month between 7 and 12  then set @target_fy_412_6_27 = 335940;
      when @p_year =  2020 and @p_month between 1 and 6   then set @target_fy_412_6_27 = 335940;
      
      else 
           set @target_fy_412_6_27 = 335940;     
        
 end case;
    
if not ( @target_fy_412_6_27 is null ) then

  replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`,value )
  select 414, '6_27', 1 as period_id, @p_month, @p_year, @target_fy_412_6_27 as target;

end if;



/* 415. Number of referrals for HIV / TB / CM-NTD / mental health per 1,000 population.

For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data collected in the LMD CHA MSRs.

For all other counties it is based on the number of referrals for HIV / TB / CM-NTD / mental health reported (348) 
and the number of CHA MSRs reported by counties (381) from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15

The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
number of CHAs deployed (ind_id 28).

Lastly, 415 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia-wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 
        415, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        ROUND( 1000 * ( COALESCE( num_referrals_suspect_hiv_tb_cm_ntd_mh, 0 ) / COALESCE( num_catchment_people_iccm, 0 ) ), 1 )

FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported=@p_month AND 
      year_reported=@p_year   AND 
      county_id IS NOT NULL
UNION  
SELECT 
      415, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      ROUND( 1000 * ( SUM( COALESCE( num_referrals_suspect_hiv_tb_cm_ntd_mh, 0 ) ) / SUM( COALESCE( num_catchment_people_iccm, 0 ) ) ), 1 )
FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported = @p_month AND 
      year_reported=@p_year     AND 
      county_id IS NOT NULL
;


/* 416. Expected percentage of pregnant women visited (excluding first trimester) per 1,000 population.

I think this is wrong.  I think we can expect 28.8 women to be pregnant in a pop of 1000.
Change the comment accordingly.

( ( ( number pregnant woman visits per month / population ) * 1000 ) / ( 28.8 * ( 2 / 3 ) ) ) * 100

where 28.8 is the expected number of pregnant woman visits per month per 1000 population

2/3 factors in that visits do not begin until the 2nd trimester


For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data 
collected in the LMD CHA MSRs.

For all other counties it is based on the number of pregnant woman visits (349) and the number of CHA MSRs 
reported by counties (381) from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15.

The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
number of CHAs deployed (ind_id 28).

Lastly, 416 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia-wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

replace INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
        416, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        round( ( ( coalesce( num_pregnant_woman_visits, 0 ) / coalesce( num_catchment_people_iccm, 0 ) ) * 1000 ) / ( 28.8 * ( 2 / 3 ) ), 2 )
        
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and 
      year_reported=@p_year   and 
      not county_id is null

union

select
      416, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      round( ( ( sum( coalesce( num_pregnant_woman_visits, 0 ) ) / sum( coalesce( num_catchment_people_iccm, 0 ) ) ) * 1000 ) / ( 28.8 * ( 2 / 3 ) ), 2 )
        
 
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and 
      year_reported=@p_year     and 
      not county_id is null
;


/* 417. �	Number of RMNH danger signs detected, per 1,000 population.

For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data collected in the LMD CHA MSRs.

For all other counties it is based on the number of RMNH danger signs detected (353) and the number of CHA MSRs reported by counties (381) 
from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15

The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
number of CHAs deployed (ind_id 28).

Lastly, 417 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 
        417, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        ROUND( 1000 * ( COALESCE( num_referred_rmnh_danger_sign, 0 ) / COALESCE( num_catchment_people_iccm, 0 ) ), 1 )

FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported=@p_month AND 
      year_reported=@p_year   AND 
      county_id IS NOT NULL
UNION  
SELECT 
      417, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      ROUND( 1000 * ( SUM( COALESCE( num_referred_rmnh_danger_sign, 0 ) ) / SUM( COALESCE( num_catchment_people_iccm, 0 ) ) ), 1 )
FROM lastmile_report.mart_view_base_msr_county 
WHERE month_reported = @p_month AND 
      year_reported=@p_year     AND 
      county_id IS NOT NULL
;


-- 418. Percent of CHAs who received a supervision visit in the past month.
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 418, a.territory_id, 1, @p_month, @p_year, round( coalesce( a.number_visit, 0 ) / coalesce( m.num_cha, 0 ), 3 ) as report_rate
from (
      select b.territory_id, count( * ) as number_visit
      from (
              -- Filter the reports based on year and month and territory_id being not null
              select s.territory_id, s.supervisedCHAID as cha_id
              from lastmile_report.mart_view_base_odk_supervision as s
              where s.manualMonth = @p_month and s.manualYear = @p_year and not ( s.territory_id is null )
              group by s.territory_id, s.supervisedCHAID
 
      ) as b
    group by b.territory_id
) as a
left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 

union all

select 418, '6_16', 1, @p_month, @p_year, round( sum( coalesce( a.number_visit, 0 ) ) / sum( coalesce( m.num_cha, 0 ) ), 3 ) as report_rate
from (
      select b.territory_id, count( * ) as number_visit
      from (
              -- Filter the reports based on year and month and territory_id being not null
              select s.territory_id, s.supervisedCHAID as cha_id
              from lastmile_report.mart_view_base_odk_supervision as s
              where s.manualMonth = @p_month and s.manualYear = @p_year and not ( s.territory_id is null )
              group by s.territory_id, s.supervisedCHAID
 
      ) as b
    group by b.territory_id
) as a
left outer join lastmile_report.mart_program_scale as m on a.territory_id like m.territory_id 
;


/*
 419. Estimated percent of children who received a MUAC screen
 
 Number of malnutrition screenings (MUAC) conducted for children under-five divided by the number of children under 5.
 
 To estimate the number of children, multiply the popluation by 16%. (This assumes a child gets only one MUAC 
 screening per month.
 
 
  ( number of muac red + number of muac yellow + number of muac green ) / ( estimated population served * 0.16 )
    
 
 For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data collected 
 in the LMD CHA MSRs.
 
 For all other counties it is based on the number of children screened for malnutrition (MUAC) (235) and the number 
 of CHA MSRs reported by counties (381) from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15

 The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
 which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
 number of CHAs deployed (ind_id 28).

TBD: Lastly, 419 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia-wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

replace INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
        419, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        round( ( coalesce( num_muac_red, 0 ) + coalesce( num_muac_yellow, 0 ) + coalesce( num_muac_green, 0 ) ) / ( coalesce( num_catchment_people_iccm, 0 ) * 0.16 ), 2 )
        
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and 
      year_reported = @p_year   and 
      not county_id is null

union

select
      419, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      round( sum( coalesce( num_muac_red, 0 ) + coalesce( num_muac_yellow, 0 ) + coalesce( num_muac_green, 0 ) )  / sum( coalesce( num_catchment_people_iccm, 0 ) * 0.16 ), 2 )
        
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and 
      year_reported  = @p_year     and 
      not county_id is null
;



/*
 420. Number of children with moderate acute malnutrition (yellow MUAC), per 1,000 children
 
 Number of children with moderate acute malnutrition (yellow MUAC), per 1,000 children under-five divided by the 
 number of children under 5.
 
 To estimate the number of children, multiply the popluation by 16%. (This assumes only a child only gets one MUAC 
 screening per month.
 
 For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data collected 
 in the LMD CHA MSRs.
 
 For all other counties it is based on the Number of children with moderate acute malnutrition (yellow MUAC) (382) 
 and the number of CHA MSRs reported by counties (381) from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15

 The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
 which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
 number of CHAs deployed (ind_id 28).

TBD: Lastly, 420 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia-wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

replace INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
        420, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        round( ( coalesce( num_muac_yellow, 0 ) / ( coalesce( num_catchment_people_iccm, 0 ) * 0.16  ) ) * 1000, 1 )
      
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and 
      year_reported=@p_year   and 
      not county_id is null

union

select
      420, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      round( ( sum( coalesce( num_muac_yellow, 0 ) ) / sum(  coalesce( num_catchment_people_iccm, 0 ) * 0.16  ) ) * 1000, 1 )
       
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and year_reported=@p_year and not county_id is null
;


/*
 421. Number of children with moderate acute malnutrition (red MUAC), per 1,000 children
 
 Number of children with severe acute malnutrition (red MUAC), per 1,000 children under-five divided by the 
 number of children under 5.
 
 To estimate the number of children, multiply the popluation by 16%. (This assumes only a child only gets one MUAC 
 screening per month.
 
 For territories 1_14 (Rivercess), 6_31 (GG LMH), and 6_16 (Total LMH) we calculate values from the data collected 
 in the LMD CHA MSRs.
 
 For all other counties it is based on the Number of children with severe acute malnutrition (red MUAC) (383) 
 and the number of CHA MSRs reported by counties (381) from the MOH dhis2 NCHA Outputs report, so territories 1_1 ... 1_15

 The county population served is estimated from the the number of CHA MSRs reported for a month and multiplying by 300, 
 which is an estimate of the number of persons served by a CHA.  This is considered a more accurate estimate than the 
 number of CHAs deployed (ind_id 28).

TBD: Lastly, 421 indicator values for all counties (1_1..1_15) are sum'ed and used to calculate the Liberaia-wide estimate.

*/

-- First, calculate indicator values for Rivercess, GG LMH, and total LMH 

replace INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 
        421, 
        territory_id,  -- 6_31 GG LMH, 1_14 Rivercess
        1, 
        @p_month, 
        @p_year, 
        round( ( coalesce( num_muac_red, 0 ) / ( coalesce( num_catchment_people_iccm, 0 ) * 0.16  ) ) * 1000, 1 )
      
        
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and 
      year_reported=@p_year   and 
      not county_id is null

union

select
      421, 
      '6_16', -- total LMH
      1, 
      @p_month, 
      @p_year, 
      round( ( sum( coalesce( num_muac_red, 0 ) ) / sum(  coalesce( num_catchment_people_iccm, 0 ) * 0.16  ) ) * 1000, 1 )
       
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and year_reported=@p_year and not county_id is null
;



--
-- 422. Cumulative number of routine visits conducted since January 2018
-- 

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 422, '6_27', 1, @p_month, @p_year, sum( a.number_routine_visit ) as total_routine_visit from (

    -- Audacious cummulative routine visits in Liberia for previous month. 
    select coalesce( value, 0 ) as number_routine_visit 
    from lastmile_dataportal.tbl_values 
    where ind_id = 422 and territory_id like '6\\_27' and `year` > 2017 and  `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- NCHA Output for routine visits in Liberia for the current month.  For this to work, the dhis2 NCHA Output data must have been 
    -- uploaded manually already.
    select coalesce( value, 0 ) as number_routine_visit 
    from lastmile_dataportal.tbl_values 
    where ind_id = 119 and territory_id like '6\\_27' and `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;
 
 replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
 select 422, '6_16', 1, @p_month, @p_year, sum( a.number_routine_visit ) as total_routine_visit from (

    -- Audacious cummulative routine visits for LMH Total for previous month. 
    select coalesce( value, 0 ) as number_routine_visit 
    from lastmile_dataportal.tbl_values 
    where ind_id = 422 and territory_id like '6\\_16' and `year` > 2017 and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Audacious routine visits for LMH Total for previous month. 
    select coalesce( value, 0 ) as number_routine_visit 
    from lastmile_dataportal.tbl_values 
    where ind_id = 119 and ( territory_id like '1\\_4' or territory_id like '1\\_14' or territory_id like '6\\_31' ) and `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;
 
 replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
 select 422, '6_32', 1, @p_month, @p_year, sum( a.number_routine_visit ) as total_routine_visit from (

    -- Audacious cummulative routine visits for LMH Assisted for previous month. 
    select coalesce( value, 0 ) as number_routine_visit 
    from lastmile_dataportal.tbl_values 
    where ind_id = 422 and territory_id like '6\\_32' and `year` > 2017 and `year` = @p_yearMinus1 and `month` = @p_monthMinus1 and period_id = 1
    
    union all
    
    -- Audacious routine visits for LMH Assisted for previous month. 
    select coalesce( value, 0 ) as number_routine_visit 
    from lastmile_dataportal.tbl_values 
    where ( ind_id = 119 ) and 
          ( territory_id like '1\\_%' and not ( territory_id like '1\\_14' or territory_id like '1\\_4' or territory_id like '1\\_6' ) ) and 
          `year` = @p_year and `month` = @p_month and period_id = 1
    
 ) as a
 ;


-- 423. Total number of CHAS and CHSSs deployed

-- Total number of CHAS and CHSSs deployed in Assisted Areas
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 423, '6_32', 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as num_chss_cha
from lastmile_dataportal.tbl_values
where ind_id in ( 28, 29 ) and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_32'
;

-- Total number of CHAs and CHSSs deployed in LMH Managed Areas
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 423, '6_16', 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as num_chss_cha
from lastmile_dataportal.tbl_values
where ind_id in ( 28, 29 ) and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_16'
;

-- Total number of CHAs and CHSSs deployed in LMH Managed Areas and Assisted Areas
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 423, '6_27', 1 as period_id, @p_month, @p_year, sum( coalesce( value, 0 ) ) as num_chss_cha
from lastmile_dataportal.tbl_values
where ind_id in ( 28, 29 ) and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27'
;


-- 426. Treatments Delivered and Malnutrition Screens for children under age 5
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 426, '6_27', 1, @p_month, @p_year, sum( coalesce( value, 0 ) ) as number_treat
from lastmile_dataportal.tbl_values 
where (
        ( ind_id = 407 and ( territory_id like '6\\_32' or territory_id like '6\\_16' ) ) or 
        ( ind_id = 128 and ( territory_id like '6\\_32' or territory_id like '6\\_16' ) ) or
        ( ind_id = 129 and ( territory_id like '6\\_32' or territory_id like '6\\_16' ) ) or
        ( ind_id = 130 and ( territory_id like '6\\_32' or territory_id like '6\\_16' ) ) 
      ) and
     `year` = @p_year and `month` = @p_month and period_id = 1
 ;
 
 -- 426, 6_35 Global (Liberia) LMH Not Managed areas
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 426, '6_35', 1, @p_month, @p_year, sum( a.number_treatment ) as value from (

    --  Cummulative muac screens for previous month. 
    select coalesce( value, 0 ) as number_treatment 
    from lastmile_dataportal.tbl_values 
    where 
          ind_id = 426                and 
          territory_id like '6\\_35'  and 
          `year` = @p_yearMinus1      and 
          `month` = @p_monthMinus1    and 
          period_id = 1
    
    union all
    
    -- Cummulative muac screens or malaria, ARI, and diarrhea treatments current month.
    select coalesce( value, 0 ) as number_treatment 
    from lastmile_dataportal.tbl_values 
    where 
          ind_id in ( 235, 23, 21, 19 ) and 
          territory_id like '1\\_%'     and 
          `year` = @p_year              and 
          `month` = @p_month            and 
          period_id = 1
    
 ) as a;


-- 428. TARGET: Treatments Delivered and Malnutrition Screens for children under age 5 ( ind_id = 426, territory_id = 6_27 )
 case
 
       -- fy 2018 and earlier
      when @p_year <  2018                                then set @target_fy_426_6_27 = null;
      when @p_year =  2018 and @p_month between 1 and 6   then set @target_fy_426_6_27 = null;
      
      -- fy 2019
      when @p_year =  2018 and @p_month between 7 and 12  then set @target_fy_426_6_27 = 350241;
      when @p_year =  2019 and @p_month between 1 and 6   then set @target_fy_426_6_27 = 350241;
      
      -- fy 2020
      when @p_year =  2019 and @p_month between 7 and 12  then set @target_fy_426_6_27 = 350241;
      when @p_year =  2020 and @p_month between 1 and 6   then set @target_fy_426_6_27 = 350241;
      
      else 
           set @target_fy_426_6_27 = 350241;     
        
 end case;
    
if not ( @target_fy_426_6_27 is null ) then

  replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`,value )
  select 428, '6_27', 1 as period_id, @p_month, @p_year, @target_fy_426_6_27 as target;

end if;

 
-- 429. Total Number of Visits (routine, pregnant woman, HIV, TB)
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 429, '6_27', 1, @p_month, @p_year, sum( coalesce( value, 0 ) ) as number_visits
from lastmile_dataportal.tbl_values 
where (
        ( ind_id = 399 and territory_id like '6\\_27' ) or 
        ( ind_id = 405 and territory_id like '6\\_27' ) or
        ( ind_id = 408 and territory_id like '6\\_27' ) or
        ( ind_id = 409 and territory_id like '6\\_27' )
      ) and
     `year` = @p_year and `month` = @p_month and period_id = 1
 ;
 
-- 429. Total Number of Visits (routine, pregnant woman, HIV, TB) globally, beginning in FY20.
if @p_date_key >= 20190701 then

replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
select 
      429                         as ind_id, 
      '6_35'                      as territory_id,
      1                           as period_id, 
      @p_month                    as `month`,
      @p_year                     as `year`,
      sum( coalesce( value, 0 ) ) as value
from lastmile_dataportal.tbl_values 
where  -- This months totals for all Liberia for routine, pregnant, HIV, TB visits
        ( 
          ind_id in ( 119, 349, 357, 358 )  and
          territory_id like '6\\_27'        and 
          `month`   = @p_month              and 
          `year`    = @p_year               and
          period_id = 1
        ) or
        ( -- Last months cumulative totals for all Global for routine, pregnant, HIV, TB visits
          ind_id = 429                      and
          territory_id like '6\\_35'        and 
          `month`   = @p_monthMinus1        and 
          `year`    = @p_yearMinus1         and
          period_id = 1
        ); 
        
end if;

-- 430. Percent of CHAs with all life-saving commodities in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        430, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_any_stockout_life_saving, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )                      as number_restock, 
              sum( any_stockout_life_saving ) as number_any_stockout_life_saving
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

-- Note: For 6_16, Total LMH, we can't use the num_cha in the mart_program_scale because it includes UNICEF CHAs and that will
--       inflate the denomminator when we are calculating whether there is a 25% restock for month.
select 
        430, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_any_stockout_life_saving, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )                  as number_restock,
              sum( coalesce( a.number_any_stockout_life_saving, 0 ) ) as number_any_stockout_life_saving,
              sum( coalesce( b.num_cha, 0 ) )                         as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )                      as number_restock, 
                      sum( any_stockout_life_saving ) as number_any_stockout_life_saving
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;

/* Moved to code for 465-469
 * Note: For assisted areas (6_32, we are not suppressing values under any conditions.  This is IFI sample data, so
 * the denominator is the number of CHAs sampled during the month.  We could suppress is number of CHAs is too low.
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 430, '6_32', 1, @p_month, @p_year, round( sum( coalesce( number_life_saving_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 )
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year and NOT ( county like '%Grand%Bassa%' or county like '%Grand%Gedeh%' or county like '%Rivercess%' );
*/

-- 431. Percent of CHAs with ACT 25mg in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        431, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_stockout_ACT25mg, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )                      as number_restock, 
              sum( stockout_ACT25mg )         as number_stockout_ACT25mg
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

select 
        431, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_stockout_ACT25mg, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )                  as number_restock,
              sum( coalesce( a.number_stockout_ACT25mg, 0 ) )         as number_stockout_ACT25mg,
              sum( coalesce( b.num_cha, 0 ) )                         as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )                      as number_restock, 
                      sum( stockout_ACT25mg )         as number_stockout_ACT25mg
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;


-- Note: For assisted areas (6_32, we are not suppressing values under any conditions.  This is IFI sample data, so
-- the denominator is the number of CHAs sampled during the month.  We could suppress if number of CHAs is too low.
/* Note: moved to code 465-469
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 431, '6_32', 1, @p_month, @p_year, round( sum( coalesce( number_act_25_67_5_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 )
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year and NOT ( county like '%Grand%Bassa%' or county like '%Grand%Gedeh%' or county like '%Rivercess%' );
*/

-- 432. Number of CHSS monthly service reports (MSRs) received by MOH

replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 432, '6_27', 1, @p_month, @p_year, sum( coalesce( value, 0 ) )  as value
from lastmile_dataportal.tbl_values 
where ind_id = 432 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1;
 

-- 464. Number of facilities
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`,`year`,value )
select 464 as ind_id, t.territory_id, 1 as period_id, @p_month, @p_year, v.health_facility_number as value
from lastmile_dataportal.tbl_nchap_scale_chss_cha as v
    left outer join lastmile_dataportal.view_territories as t on  ( trim( v.county )          like trim( t.territory_name ) ) and 
                                                                  ( trim( t.territory_type )  like 'county' )
where ( v.year_report = @p_year ) and ( v.month_report = @p_month )    
;
 
/*
456. CHSS reporting rate by MOH and CHTs

In a sense, 456 is the same as 302, except that 302 is calculated from lastmile_upload.de_chss_monthly_service_report records, which only
collects the supervision portion of the CHSS MSR, while 456 comes from the dhis2 MOH instance and the monthly scale values for number of CHSSs
that are collected by the NCHA team.  For the national number use all dhis2 numbers.  LMH's collection of CHSS MSRs has been spotty at best.
Also, note 432 values are brought in via the dhis2 upload mechanism.

Lastly, if the number of facilities 464 is greater than the number of CHSSs in a county, use the number of facilites as the denominator
when calculating the rate.  Otherwise, use the number of CHSSs.
*/

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`,`year`,value )
select  456, territory_id, 1 as period_id, @p_month, @p_year,

        round(  min( if( a.fraction_part like 'number_chss_msr',  a.value, null ) ) /     -- numerator
        
                if( min( if( a.fraction_part like 'number_facility', a.value, null ) ) >= 
                    min( if( a.fraction_part like 'number_chss', a.value, null ) ),
                    
                    min( if( a.fraction_part like 'number_facility', a.value, null ) ),
                    min( if( a.fraction_part like 'number_chss', a.value, null ) )        -- denominator
                  ),
                  
                3 ) as rate
from (  
      select 
            'number_chss_msr' as fraction_part, 
            territory_id,
            min( value )      as value
      from lastmile_dataportal.tbl_values 
      where ind_id = 432 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1
      group by territory_id
      
      union all
      
      select 
            'number_chss' as fraction_part,  
            territory_id,
            min( value )  as value
      from lastmile_dataportal.tbl_values 
      where ind_id = 29 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1
      group by territory_id
      
      union all 
      
      select 
            'number_facility' as fraction_part,  
            territory_id,
            min( value )  as value
      from lastmile_dataportal.tbl_values 
      where ind_id = 464 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1
      group by territory_id
      
) as a
group by territory_id;

-- Now add up the totals by county and calculate the Liberia-wide rate
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`,`year`,value )
select 456, '6_27',1 as period_id, @p_month, @p_year, 
       round( sum( if( a.fraction_part like 'number_chss_msr',  a.value, null ) ) -- numerator
              / 
              sum( if( a.fraction_part like 'denominator',      a.value, null ) )
              , 3 ) as rate
from ( 
      select 
            'number_chss_msr' as fraction_part, 
            territory_id,
            min( value )  as value
      from lastmile_dataportal.tbl_values 
      where ind_id = 432 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1
      group by territory_id
      
      union all
   
      select 'denominator' as fraction_part,
              b.territory_id,
              
              if( min( if( b.fraction_part like 'number_facility', b.value, null ) ) >= 
                    min( if( b.fraction_part like 'number_chss', b.value, null ) ),
                    
                    min( if( b.fraction_part like 'number_facility', b.value, null ) ),
                    min( if( b.fraction_part like 'number_chss', b.value, null ) )
                  ) as value
             
      from (

              select 
                    'number_chss' as fraction_part,  
                    territory_id,
                    min( value )  as value
              from lastmile_dataportal.tbl_values 
              where ind_id = 29 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1
              group by territory_id
      
              union all
      
              select 
                  'number_facility' as fraction_part,  
                  territory_id,
                  min( value )  as value
            from lastmile_dataportal.tbl_values 
            where ind_id = 464 and territory_id like '1\\_%' and `year` = @p_year and `month` = @p_month and period_id = 1
            group by territory_id
 
      ) as b
      group by b.territory_id
) as a
;


-- 459. Community births
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 459 as ind_id, '6_27' as terrrority_id, 1 as period_id, month_report, year_report, sum( coalesce( value, 0 ) ) as value   
from lastmile_dataportal.view_moh_dhis2_chss_msr
where ind_id in ( 459 ) and  ( month_report = @p_month and year_report = @p_year )
;

-- 460. Facility births
replace into lastmile_dataportal.tbl_values (`ind_id`, `territory_id`,`period_id`, `month`,`year`,`value`)
select 460 as ind_id, '6_27' as terrrority_id, 1 as period_id, month_report, year_report, sum( coalesce( value, 0 ) ) as value   
from lastmile_dataportal.view_moh_dhis2_chss_msr
where ind_id in ( 460 ) and  month_report = @p_month and year_report = @p_year 
;


-- 464. # of community clinics supported by community and frontline health workers in Anchor Country Programs
replace into lastmile_dataportal.tbl_values ( `ind_id`, `territory_id`, `period_id`,  `month`,  `year`,   `value` )
select
      464                         as ind_id, 
      '6_35'                      as territory_id,
      1                           as period_id, 
      @p_month                    as `month`,
      @p_year                     as `year`,
      sum( coalesce( value, 0 ) ) as value

from lastmile_dataportal.tbl_values 
where ( 
        ind_id = 464                      and
        territory_id like '1\\_%'         and 
        `month`   = @p_month              and 
        `year`    = @p_year               and
        @isEndOfQuarter                   and
        period_id = 1
      )
;


/* 
 *
 * Need the same indicators for Assisted numbers generated from IFI database because we are calcualting GB, RI, and GG values
 * for Managed and Assisted and the Assisted numbers need to be generated from the IFI exclusively.
 *
 * 476. Percent of CHAs with all life saving commodities in stock
 * 477. Percent of CHAs with ACT 25mg in stock
 * 478.	Percent of CHAs with ACT 50mg in stock
 * 479.	Percent of CHAs with ACT 25 or 50mg in stock
 * 480.	Percent of CHAs with Amoxicillin 250mg dispersible tablet in stock	
 * 481.	Percent of CHAs with ORS sachet in stock
 * 482	Percent of CHAs with Zinc Sulfate 20mg scored tablet in stock
 *
 * Note: For assisted areas (6_32, we are not suppressing values under any conditions.  This is IFI sample data, so
 * the denominator is the number of CHAs sampled during the month.  We could suppress if number of CHAs is too low.
*/

-- Beginning of code for ifi database
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 476, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_life_saving_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 )
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 477, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_act_25_67_5_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 )
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 478, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_act_50_135_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 479, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_act_25_or_50_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 480, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_amox_250_mg_dispersible_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all 

select 481, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_ors_20_6_1l_sachet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 482, '6_27', 1, @p_month, @p_year, round( sum( coalesce( number_zinc_sulfate_20_mg_scored_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

-- For graph, generate period 2 quarterly totals for everything below

select 477, territory_id, 1, @p_month, @p_year, round( coalesce( number_act_25_67_5_mg_tablet_in_stock, 0 ) / coalesce( numReports, 0 ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 477, territory_id, 2, @p_month, @p_year, round( sum( coalesce( number_act_25_67_5_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where ( ( `year` = @p_year and `month` = @p_month             ) or 
        ( `year` = @p_yearMinus1 and `month` = @p_monthMinus1 ) or 
        ( `year` = @p_yearMinus2 and `month` = @p_monthMinus2 ) )
group by territory_id

union all

select 478, territory_id, 1, @p_month, @p_year, round( coalesce( number_act_50_135_mg_tablet_in_stock, 0 ) / coalesce( numReports, 0 ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 478, territory_id, 2, @p_month, @p_year, round( sum( coalesce( number_act_50_135_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where ( ( `year` = @p_year and `month` = @p_month             ) or 
        ( `year` = @p_yearMinus1 and `month` = @p_monthMinus1 ) or 
        ( `year` = @p_yearMinus2 and `month` = @p_monthMinus2 ) )
group by territory_id

union all

select 479, territory_id, 1, @p_month, @p_year, round( coalesce( number_act_25_or_50_mg_tablet_in_stock, 0 ) / coalesce( numReports, 0 ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 479, territory_id, 2, @p_month, @p_year, round( sum( coalesce( number_act_25_or_50_mg_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where ( ( `year` = @p_year and `month` = @p_month             ) or 
        ( `year` = @p_yearMinus1 and `month` = @p_monthMinus1 ) or 
        ( `year` = @p_yearMinus2 and `month` = @p_monthMinus2 ) )
group by territory_id

union all

select 480, territory_id, 1, @p_month, @p_year, round( coalesce( number_amox_250_mg_dispersible_tablet_in_stock, 0 ) / coalesce( numReports, 0 ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 480, territory_id, 2, @p_month, @p_year, round( sum( coalesce( number_amox_250_mg_dispersible_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where ( ( `year` = @p_year and `month` = @p_month             ) or 
        ( `year` = @p_yearMinus1 and `month` = @p_monthMinus1 ) or 
        ( `year` = @p_yearMinus2 and `month` = @p_monthMinus2 ) )
group by territory_id

union all 

select 481, territory_id, 1, @p_month, @p_year, round( coalesce( number_ors_20_6_1l_sachet_in_stock, 0 ) / coalesce( numReports, 0 ), 3 ) as value 
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 481, territory_id, 2, @p_month, @p_year, round( sum( coalesce( number_ors_20_6_1l_sachet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where ( ( `year` = @p_year and `month` = @p_month             ) or 
        ( `year` = @p_yearMinus1 and `month` = @p_monthMinus1 ) or 
        ( `year` = @p_yearMinus2 and `month` = @p_monthMinus2 ) )
group by territory_id

union all

select 482, territory_id, 1, @p_month, @p_year, round( coalesce( number_zinc_sulfate_20_mg_scored_tablet_in_stock, 0 ) / coalesce( numReports, 0 ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where `month`=@p_month and `year`=@p_year 

union all

select 482, territory_id, 2, @p_month, @p_year, round( sum( coalesce( number_zinc_sulfate_20_mg_scored_tablet_in_stock, 0 ) ) / sum( coalesce( numReports, 0 ) ), 3 ) as value
from lastmile_report.mart_view_kobo_ifi 
where ( ( `year` = @p_year and `month` = @p_month             ) or 
        ( `year` = @p_yearMinus1 and `month` = @p_monthMinus1 ) or 
        ( `year` = @p_yearMinus2 and `month` = @p_monthMinus2 ) )
group by territory_id
;

-- end of code from ifi database


-- 477. Co-impact KPIs are reported on for March and August.  Use period_id = 38 (month 3 and month 8) to specific them.
if ( @p_month = 3 ) or ( @p_month = 8 ) then 

-- 477. Percent of CHAs who received their last monetary incentive on time (IFI)
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select 477, '6_27', 38 as period_id, @p_month, @p_year, value
from lastmile_dataportal.tbl_values 
where ind_id = 477 and period_id = 1 and `month` = @p_month and `year` = @p_year and territory_id like '6\\_27' 
;

end if;



/* 

 * 465.	Percent of CHAs with ACT 50mg in stock
 * 466.	Percent of CHAs with ACT 25 or 50mg in stock
 * 467.	Percent of CHAs with Amoxicillin 250mg dispersible tablet in stock	
 * 468.	Percent of CHAs with ORS sachet in stock
 * 469	Percent of CHAs with Zinc Sulfate 20mg scored tablet in stock
 *
 * Note: For assisted areas (6_32, we are not suppressing values under any conditions.  This is IFI sample data, so
 * the denominator is the number of CHAs sampled during the month.  We could suppress if number of CHAs is too low.
*/


-- 465. Percent of CHAs with ACT 50mg in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        465, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_stockout_ACT50mg, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )                      as number_restock, 
              sum( stockout_ACT50mg )         as number_stockout_ACT50mg
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

select 
        465, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_stockout_ACT50mg, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )                  as number_restock,
              sum( coalesce( a.number_stockout_ACT50mg, 0 ) )         as number_stockout_ACT50mg,
              sum( coalesce( b.num_cha, 0 ) )                         as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )                      as number_restock, 
                      sum( stockout_ACT50mg )         as number_stockout_ACT50mg
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;


-- 466. Percent of CHAs with ACT 25 or 50mg in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        466, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_stockout_ACT_25mg_50mg, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )                      as number_restock, 
              sum( stockout_ACT_25mg_50mg )   as number_stockout_ACT_25mg_50mg
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

select 
        466, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_stockout_ACT_25mg_50mg, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )                  as number_restock,
              sum( coalesce( a.number_stockout_ACT_25mg_50mg, 0 ) )   as number_stockout_ACT_25mg_50mg,
              sum( coalesce( b.num_cha, 0 ) )                         as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )                      as number_restock, 
                      sum( stockout_ACT_25mg_50mg )   as number_stockout_ACT_25mg_50mg
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;


-- 467. Percent of CHAs with Percent of CHAs with Amoxocillin 250mg in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        467, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_stockout_Amoxicillin250mg, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )                          as number_restock, 
              sum( stockout_Amoxicillin250mg )    as number_stockout_Amoxicillin250mg
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

select 
        467, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_stockout_Amoxicillin250mg, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )                      as number_restock,
              sum( coalesce( a.number_stockout_Amoxicillin250mg, 0 ) )    as number_stockout_Amoxicillin250mg,
              sum( coalesce( b.num_cha, 0 ) )                             as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )                          as number_restock, 
                      sum( stockout_Amoxicillin250mg )    as number_stockout_Amoxicillin250mg
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;




-- 468. Percent of CHAs with ORS in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        468, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_stockout_ORS, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )          as number_restock, 
              sum( stockout_ORS ) as number_stockout_ORS
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

select 
        468, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_stockout_ORS, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )      as number_restock,
              sum( coalesce( a.number_stockout_ORS, 0 ) ) as number_stockout_ORS,
              sum( coalesce( b.num_cha, 0 ) )             as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )          as number_restock, 
                      sum( stockout_ORS ) as number_stockout_ORS
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;



-- 469. Percent of CHAs with Zinc Sulphate in stock
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  
        469, a.territory_id, 1, @p_month, @p_year, 
        
        if( ( coalesce( a.number_restock, 0 ) / b.num_cha ) >= 0.25, 
              round( ( coalesce( a.number_restock, 0 ) - coalesce( a.number_stockout_ZincSulfate, 0 ) ) / coalesce( a.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select
              territory_id,
              count( 1 )                  as number_restock, 
              sum( stockout_ZincSulfate ) as number_stockout_ZincSulfate
        from lastmile_report.mart_view_base_restock_cha
        where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
        group by territory_id
      ) as a
          left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
    
union all

select 
        469, '6_16', 1, @p_month, @p_year, 
        
        if( ( coalesce( c.number_restock, 0 ) / c.num_cha ) >= 0.25, 
              round( ( coalesce( c.number_restock, 0 ) - coalesce( c.number_stockout_ZincSulfate, 0 ) ) / coalesce( c.number_restock, 0 ), 3 ),
              null
          ) as rate
from (
        select 
              sum( coalesce( a.number_restock, 0 ) )              as number_restock,
              sum( coalesce( a.number_stockout_ZincSulfate, 0 ) ) as number_stockout_ZincSulfate,
              sum( coalesce( b.num_cha, 0 ) )                     as num_cha                 
        from (
                select
                      territory_id,
                      count( 1 )                  as number_restock, 
                      sum( stockout_ZincSulfate ) as number_stockout_ZincSulfate
                from lastmile_report.mart_view_base_restock_cha
                where `month` = @p_month and `year`= @p_year and not ( territory_id is null )
                group by territory_id
                
              ) as a
                  left outer join lastmile_report.mart_program_scale as b on a.territory_id like b.territory_id 
      ) as c
;



-- 470. Module 3: Number of active case finds
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select 470, territory_id, 1, @p_month, @p_year, coalesce( num_active_case_finds ,0 )
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and year_reported=@p_year and county_id is not null

union all 

select 470, '6_16', 1, @p_month, @p_year, sum( coalesce( num_active_case_finds, 0 ) )
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and year_reported=@p_year and county_id is not null
;

-- 471.Module 3: Number of active case finds per 1,000 population
replace INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  471, territory_id, 1, @p_month, @p_year, 
        round( ( coalesce( num_active_case_finds, 0 ) / ( coalesce( num_catchment_people_iccm, 0 ) ) ) * 1000, 1 )   
from lastmile_report.mart_view_base_msr_county 
where month_reported=@p_month and year_reported=@p_year and not county_id is null

union

select  471, '6_16', 1, @p_month, @p_year, 
        round( ( sum( coalesce( num_active_case_finds, 0 ) ) / sum(  coalesce( num_catchment_people_iccm, 0 ) ) ) * 1000, 1 ) 
from lastmile_report.mart_view_base_msr_county 
where month_reported = @p_month and year_reported=@p_year and not county_id is null
;


-- 472. Number of children screened for malnutrition (MUAC) per 1,000 population by QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      472 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      round( ( sum( coalesce( q.num_muac_red, 0 ) + coalesce( q.num_muac_yellow, 0 ) + coalesce( q.num_muac_green, 0 ) ) / sum( coalesce( q.num_catchment_people_iccm, 0 ) * 0.16  ) ) * 1000, 0 ) as rate
      
from lastmile_report.mart_view_msr as q
    left outer join lastmile_datamart.dimension_position   as dp on q.date_key = dp.date_key and q.cha_id like dp.position_id
        left outer join lastmile_dataportal.tbl_territories_other   as o on dp.qao_position_id like trim( o.territory_name ) 
where q.date_key = @p_date_key and not ( dp.qao_position_id is null ) 
group by dp.qao_position_id
;



-- 473. QAO-CHSS supervision rate
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select 
      473 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id, 
      @p_month, 
      @p_year,
      concat( coalesce( j.number_supervision, 0 ), '/', s.num_chss ) as rate
      
from lastmile_report.mart_program_scale_qao as s
    left outer join lastmile_dataportal.tbl_territories_other as o on s.qao_position_id like trim( o.territory_name )
    left outer join (
                      select 
                            c.qao_position_id, 
                            count( * ) as number_supervision
                            
                      from lastmile_report.view_qao_chss_supervision as c
                      where c.date_key = @p_date_key
                      group by c.qao_position_id
                    ) as j on s.qao_position_id = j.qao_position_id
;


-- 474. QAO number of correct treatment forms
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select
      474 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      coalesce( j.number_form, 0 )
      
from lastmile_report.mart_program_scale_qao as s
    left outer join lastmile_dataportal.tbl_territories_other as o on s.qao_position_id like trim( o.territory_name ) 
    left outer join (
                      select
                            dp.qao_position_id, 
                            count( * ) as number_form
      
                      from lastmile_report.view_correct_treatment_cha as c
                          left outer join lastmile_datamart.dimension_position as dp on c.date_key = dp.date_key and c.position_id like dp.position_id
                      where c.date_key = @p_date_key and not ( dp.qao_position_id is null ) 
                      
                      group by dp.qao_position_id
                      
                    ) as j on s.qao_position_id like j.qao_position_id
;


-- 475. Number of stockout of life-saving commodities ACT25, ACT50, ORS, Zinc Sulfate, Amoxicillian per QAO
replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
select
      475 as ind_id, 
      concat( '6_', o.territory_other_id ) as territory_id,
      1 as period_id,  
      @p_month, 
      @p_year,
      coalesce( jj.stockout_life_saving, '' )
      
from lastmile_report.mart_program_scale_qao as s
    left outer join lastmile_dataportal.tbl_territories_other as o on s.qao_position_id like trim( o.territory_name )
    left outer join (
                      select 
                            dp.qao_position_id,
                            sum( j.stockout_life_saving ) as stockout_life_saving
                      from (
                              select
                                    m.date_key,
                                    m.cha_id                                            as position_id,
              
                                    sum( coalesce( stockout_ACT25mg,          0 ) ) +
                                    sum( coalesce( stockout_ACT50mg,          0 ) ) +
                                    sum( coalesce( stockout_ORS,              0 ) ) +
                                    sum( coalesce( stockout_ZincSulfate,      0 ) ) +
                                    sum( coalesce( stockout_Amoxicillin250mg, 0 ) )     as stockout_life_saving
              
                              from lastmile_report.mart_view_base_restock_cha as m
                              where m.date_key = @p_date_key
                              group by m.cha_id                     
                    ) as j
                    
        left outer join lastmile_datamart.dimension_position as dp on j.date_key = dp.date_key and  j.position_id like dp.position_id 

where not ( dp.qao_position_id is null )
group by dp.qao_position_id

) as jj on s.qao_position_id = jj.qao_position_id
;


-- 484. % CHWs who pass a knowledge assessment by CHW provider across Anchor Country Programs
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  484, '6_35' as territory_id, 1 as period_id, @p_month, @p_year,

        round( sum( coalesce( number_service_delivery_question_correct_1_4, 0 ) ) / 
               sum( coalesce( numReports, 0 ) ), 3 ) as value
      
from lastmile_report.mart_view_kobo_ifi 
where 
      @isEndOfQuarter and 
      (
        ( `year`=@p_year        and `month`=@p_month        ) or 
        ( `year`=@p_yearMinus1  and `month`=@p_monthMinus1  ) or 
        ( `year`=@p_yearMinus2  and `month`=@p_monthMinus2  )
      )
;



/*
 * 800.	Percent of CHSSs with ACT-25mg in stock	percent	Restock
 * 801.	Percent of CHSSs with ACT-50mg in stock	percent	Restock
 * 802.	Percent of CHSSs with ORS in stock
 * 803.	Percent of CHSSs with Amoxicillin-250mg in stock
 * 804.	Percent of CHSSs with ACT-25mg, ACT-50mg, ORS, and Amoxicillin-250mg in stock  
 *
 * 1. CHSS are restocked once a month.
 * 2. For denominator use the number of CHSSs who are active for the county for the month in database.
 * 3. For numerator count a CHSS (position_id) as having a commodity in stock if there is one or more 
 *    in stock on day of restock.
 * 4. If a chss (position_id) has more than a single restock in a month take the lowest value and count
 *    as having a commodity in stock if there is one or more in stock on day of restock.
 * 5. There could be undercounting or over counting if the number of CHSSs in the database is high or low.
 * 6  If there is any ORS and amox 250 and ( ACT 25 or ACT 50 ) is present, then 804 is considered to have stock.
 *
*/

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  800, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( act_25_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  800, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( act_25_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  801, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( act_50_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  801, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( act_50_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  802, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( ors_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  802, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( ors_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  803, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( amoxicillin_250_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  803, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( amoxicillin_250_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;

replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  804, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( important_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  804, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( important_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


-- 805. Co-impact KPIs are reported for March and August.  Use period_id = 38 (month 3 and month 8) to specific them.
if ( @p_month = 3 ) or ( @p_month = 8 ) then 

-- 805. % correct treatment rate/CHA clinical practice
replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
select  805, '6_27' as territory_id, 38 as period_id, @p_month, @p_year,

        round( sum( coalesce( number_correct_treatment, 0 ) ) / 
               sum( coalesce( numReports, 0 ) ), 3 ) as value
      
from lastmile_report.mart_view_kobo_ifi 
where `year`=@p_year and `month`=@p_month
;

end if;


-- 819. Number of in-home births

replace into lastmile_dataportal.tbl_values ( ind_id , territory_id , period_id,`month`,`year`,`value`)
select 819, territory_id, 1, @p_month, @p_year, coalesce( num_births_home, 0 ) as num_births_home

from lastmile_report.mart_view_base_msr_county
where year_reported = @p_year and month_reported = @p_month and 
      ( territory_id like '1_4' or territory_id like '1_14' or territory_id like '6_31' )

union all 

select 819, '6_16', 1, @p_month, @p_year, sum( coalesce( num_births_home, 0 ) ) as num_births_home
from lastmile_report.mart_view_base_msr_county
where year_reported = @p_year and month_reported = @p_month and 
      ( territory_id like '1_4' or territory_id like '1_14' or territory_id like '6_31' )
;

-- 820. Number of in-facility births

replace into lastmile_dataportal.tbl_values ( ind_id , territory_id , period_id,`month`,`year`,`value`)
select 820, territory_id, 1, @p_month, @p_year, coalesce( num_births_facility, 0 ) as num_births_facility

from lastmile_report.mart_view_base_msr_county
where year_reported = @p_year and month_reported = @p_month and 
      ( territory_id like '1_4' or territory_id like '1_14' or territory_id like '6_31' )

union all 

select 820, '6_16', 1, @p_month, @p_year, sum( coalesce( num_births_facility, 0 ) ) as num_births_facility
from lastmile_report.mart_view_base_msr_county
where year_reported = @p_year and month_reported = @p_month and 
      ( territory_id like '1_4' or territory_id like '1_14' or territory_id like '6_31' )
;


-- 821. Percent of CHSSs with PPE surgical mask in stock
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  821, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( mask_covid_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  821, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( mask_covid_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


-- 822. Percent of CHAs stocked out of PPE surgical mask
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 822, a.territory_id, 1, @p_month, @p_year, 
       if(
          ( coalesce( number_cha_restock, 0 ) / b.num_cha ) >= 0.25, 
          round( ( coalesce( a.number_stockouts, 0 ) ) / coalesce( a.number_cha_restock, 0 ), 3 ),
          null
       )
       as value
from (
        select
              territory_id, 
              sum( stockout_surgicalMask )  as number_stockouts,
              count( * )                    as number_cha_restock
        -- from lastmile_report.view_base_restock_cha
        from lastmile_report.mart_view_base_restock_cha
        where `month`=@p_month and `year`=@p_year and not ( territory_id is null )
        group by territory_id
      ) as a
    left outer join lastmile_report.mart_program_scale b on a.territory_id = b.territory_id 

union all

select 822, '6_16', 1, @p_month, @p_year, 
       if(
          ( coalesce( number_cha_restock, 0 ) / b.num_cha ) >= 0.25, 
          round( ( coalesce( a.number_stockouts, 0 ) ) / coalesce( a.number_cha_restock, 0 ), 3 ),
          null
       )
       as value
from (
        select
              sum( stockout_surgicalMask )  as number_stockouts,
              count( * )                    as number_cha_restock
        -- from lastmile_report.view_base_restock_cha  -- use mart_ version of view
        from lastmile_report.mart_view_base_restock_cha
        where `month`=@p_month and `year`=@p_year and not ( territory_id is null )
      ) as a
    left outer join lastmile_report.mart_program_scale b on b.territory_id like '6_16'
;


-- 823. Percent of CHSSs with extra (PPE) disposable gloves in stock
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  823, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( disposable_glove_covid_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  823, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( disposable_glove_covid_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


-- 824. Percent of CHAs stocked out of extra (PPE) disposable gloves
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 824, a.territory_id, 1, @p_month, @p_year, 
       if(
          ( coalesce( number_cha_restock, 0 ) / b.num_cha ) >= 0.25, 
          round( ( coalesce( a.number_stockouts, 0 ) ) / coalesce( a.number_cha_restock, 0 ), 3 ),
          null
       )
       as value
from (
        select
              territory_id, 
              sum( stockout_glovesCovid19 ) as number_stockouts,
              count( * )                    as number_cha_restock
        -- from lastmile_report.view_base_restock_cha
        from lastmile_report.mart_view_base_restock_cha
        where `month`=@p_month and `year`=@p_year and not ( territory_id is null )
        group by territory_id
      ) as a
    left outer join lastmile_report.mart_program_scale b on a.territory_id = b.territory_id 

union all

select 824, '6_16', 1, @p_month, @p_year, 
       if(
          ( coalesce( number_cha_restock, 0 ) / b.num_cha ) >= 0.25, 
          round( ( coalesce( a.number_stockouts, 0 ) ) / coalesce( a.number_cha_restock, 0 ), 3 ),
          null
       )
       as value
from (
        select
              sum( stockout_glovesCovid19 ) as number_stockouts,
              count( * )                    as number_cha_restock
        -- from lastmile_report.view_base_restock_cha  -- use mart_ version of view
        from lastmile_report.mart_view_base_restock_cha
        where `month`=@p_month and `year`=@p_year and not ( territory_id is null )
      ) as a
    left outer join lastmile_report.mart_program_scale b on b.territory_id like '6_16'
;


-- 825. Percent of CHSSs with disposable gloves in stock: regular or extra (PPE)
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  825, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
        
from (  
        select 
              territory_id, 
              chss_id,
              min( disposable_glove_regular_covid_initial_stock_on_hand ) as value
              
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
    
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  825, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select 
              territory_id, 
              chss_id,
              min( disposable_glove_regular_covid_initial_stock_on_hand ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;


-- 826. Percent of CHAs stocked out of regular and extra (PPE) disposable gloves
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, `value` )
select 826, a.territory_id, 1, @p_month, @p_year, 
       if(
          ( coalesce( number_cha_restock, 0 ) / b.num_cha ) >= 0.25, 
          round( ( coalesce( a.number_stockouts, 0 ) ) / coalesce( a.number_cha_restock, 0 ), 3 ),
          null
       )
       as value
from (
        select
              territory_id, 
              sum( stockout_disposable_gloves_regular_covid19 ) as number_stockouts,
              count( * )                                        as number_cha_restock
        -- from lastmile_report.view_base_restock_cha
        from lastmile_report.mart_view_base_restock_cha
        where `month`=@p_month and `year`=@p_year and not ( territory_id is null )
        group by territory_id
      ) as a
    left outer join lastmile_report.mart_program_scale b on a.territory_id = b.territory_id 

union all

select 826, '6_16', 1, @p_month, @p_year, 
       if(
          ( coalesce( number_cha_restock, 0 ) / b.num_cha ) >= 0.25, 
          round( ( coalesce( a.number_stockouts, 0 ) ) / coalesce( a.number_cha_restock, 0 ), 3 ),
          null
       )
       as value
from (
        select
              sum( stockout_disposable_gloves_regular_covid19 ) as number_stockouts,
              count( * )                                        as number_cha_restock
        -- from lastmile_report.view_base_restock_cha  -- use mart_ version of view
        from lastmile_report.mart_view_base_restock_cha
        where `month`=@p_month and `year`=@p_year and not ( territory_id is null )
      ) as a
    left outer join lastmile_report.mart_program_scale b on b.territory_id like '6_16'
;


-- 827. Percent of CHSSs with disposable gloves in stock
replace into lastmile_dataportal.tbl_values ( ind_id, territory_id, period_id, `month`, `year`, value )
select  827, a.territory_id, 1 as period_id, @p_month, @p_year, 
        round( sum( if( a.value > 0, 1, 0 ) ) / s.num_chss, 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( disposable_glove_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by territory_id, chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
group by a.territory_id

union all

select  827, '6_16', 1 as period_id, @p_month, @p_year, 

        round( sum( if( a.value > 0, 1, 0 ) ) / sum( distinct s.num_chss ), 3 ) as value  
from ( 
        select territory_id, chss_id, min( coalesce( disposable_glove_initial_stock_on_hand, 0 ) ) as value
        from lastmile_report.mart_view_base_restock_chss as r
        where not ( territory_id is null ) and ( restock_month = @p_month ) and ( restock_year = @p_year )
        group by chss_id       
) as a
    left outer join lastmile_report.mart_program_scale as s on a.territory_id like s.territory_id
;

-- Recode 828 and 829 like 827...
-- 828. Percent of CHAs with all essential commodities in stock, including PPE
-- The if-clause suppresses the results if the reporting rate is below 25% (here and below)

if @p_date_key >= 20200801 then

REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 828, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(COUNT(1),0) - COALESCE(SUM(any_stockouts_essentials_ppe),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 828, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND((COALESCE(COUNT(1),0) - COALESCE(SUM(any_stockouts_essentials_ppe),0))/COALESCE(COUNT(1),0),3),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;

-- 829. Average number of essential commodity stock-outs per CHA, including PPE
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 829, a.territory_id, 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND(COALESCE(SUM(num_stockouts_essentials_ppe),0)/COALESCE(COUNT(1),0),1),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL GROUP BY county_id
UNION SELECT 829, '6_16', 1, @p_month, @p_year, IF((COALESCE(COUNT(1),0)/num_cha)>=0.25,ROUND(COALESCE(SUM(num_stockouts_essentials_ppe),0)/COALESCE(COUNT(1),0),1),NULL)
FROM lastmile_report.mart_view_base_restock_cha a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE `month`=@p_month AND `year`=@p_year AND county_id IS NOT NULL;

end if;

-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('dataPortalValues END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
