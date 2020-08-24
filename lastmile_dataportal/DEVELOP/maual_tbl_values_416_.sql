
-- ------------------ --
-- Set date variables --
-- ------------------ --

-- Set @variables based on parameters (always use @variables below to avoid ambiguity)
SET @p_month := 6;
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


-- ------------ --
-- Misc cleanup --
-- ------------ --


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
/*
-- replace INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
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

*/

-- if @p_month = 6 then

-- replace into lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
-- select 416, '6_27' as territory_id, 1 as period_id, @p_month + 1 as `month`, @p_year - 1 as `year`,
select ind_id, territory_id, 1 as period_id, month_reported, year_reported,

 num_pregnant_woman_visits,
 num_catchment_people_iccm
 
--         round(  ( ( sum( coalesce( num_pregnant_woman_visits, 0 ) ) / sum( coalesce( num_catchment_people_iccm, 0 ) ) ) * 1000 ) / 
--                 ( 28.8 * ( 2 / 3 ) ), 2 ) as value
        
 
from (
      -- Only use whole county values for GG and GB
      select null as ind_id, territory_id, month_reported, year_reported, num_pregnant_woman_visits, num_catchment_people_iccm
      from lastmile_report.mart_view_base_msr_county 
      where 
            not ( county_id is null )                                   and
            ( territory_id like '1\\_4' or territory_id like '1\\_14' ) and
            ( 
              ( month_reported in ( 7, 8, 9, 10, 11, 12 ) and ( year_reported = ( @p_year - 1 ) ) ) or
              ( month_reported in ( 1, 2, 3, 4, 5, 6    ) and ( year_reported =   @p_year       ) ) 
            )


      union all

      select ind_id, territory_id, `month`, `year`, null as num_pregnant_woman_visits, if( ind_id = 381, value * @cha_population_ratio, null ) as num_catchment_people_iccm
      from lastmile_dataportal.tbl_values
      where 
            ind_id = 381                                                        and
            territory_id like '1\\_%'                                           and
            not ( ( territory_id like '1\\_4' or territory_id like '1\\_14' ) ) and
            ( 
              ( `month` in ( 7, 8, 9, 10, 11, 12 ) and ( `year` = ( @p_year - 1 ) ) ) or
              ( `month` in ( 1, 2, 3, 4, 5, 6    ) and ( `year` =   @p_year       ) ) 
            )


      union all

      select ind_id, territory_id, `month`, `year`, if( ind_id = 349, value, null ) as num_pregnant_woman_visits, null as num_catchment_people_iccm
      from lastmile_dataportal.tbl_values
      where 
            ind_id = 349                                                        and
            territory_id like '1\\_%'                                           and
            not ( ( territory_id like '1\\_4' or territory_id like '1\\_14' ) ) and
            ( 
              ( `month` in ( 7, 8, 9, 10, 11, 12 ) and ( `year` = ( @p_year - 1 ) ) ) or
              ( `month` in ( 1, 2, 3, 4, 5, 6    ) and ( `year` =   @p_year       ) ) 
            )

) as a;

-- end if;




-- ------ --
-- Finish --
-- ------ --

