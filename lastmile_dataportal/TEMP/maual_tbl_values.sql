
-- ------------------ --
-- Set date variables --
-- ------------------ --

-- Set @variables based on parameters (always use @variables below to avoid ambiguity)
SET @p_month := 10;
SET @p_year := 2019;

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

-- select @p_month, @p_year, @p_date, @p_monthMinus1, @p_monthMinus2, @p_monthPlus1, @p_yearMinus1, @p_yearMinus2, @p_yearPlus1, @p_datePlus1, @isEndOfQuarter, @cha_population_ratio;


-- ------ --
-- Begin  --
-- ------ --


-- 474. QAO number of correct treatment forms
-- replace into lastmile_dataportal.tbl_values (ind_id,territory_id,period_id, `month`, `year`, value )
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


-- ------------ --
-- Misc cleanup --
-- ------------ --



-- ------ --
-- Finish --
-- ------ --

