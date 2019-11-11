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





-- ------ --
-- Finish --
-- ------ --

-- Log procedure call (END)
-- INSERT INTO lastmile_dataportal.tbl_stored_procedure_log (`proc_name`, `parameters`, `timestamp`) VALUES ('dataPortalValues END', CONCAT('p_month: ',p_month,', p_year: ',p_year), NOW());


END$$

DELIMITER ;
