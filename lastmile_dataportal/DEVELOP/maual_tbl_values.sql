
-- ------------------ --
-- Set date variables --
-- ------------------ --

-- Set @variables based on parameters (always use @variables below to avoid ambiguity)
SET @p_month := 5;
SET @p_year := 2020;

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

select 418, a.territory_id, 1, @p_month, @p_year, round( sum( coalesce( a.number_visit, 0 ) ) / sum( coalesce( m.num_cha, 0 ) ), 3 ) as report_rate
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





/*  418. Percent of CHAs who received a supervision visit in the past month. 
    Notes:  For Grand Gedeh, the UNICEF CHAs are not being counted in the denominator.  To add them in, remove the
            the "cohort is null" from the where clause (two places) below.

*/
/*
replace into lastmile_dataportal.tbl_values ( ind_id , territory_id, period_id, `month`, `year`, value )
select
      418,
      case 
          when a.county like 'Rivercess'    then '1_14'
          when a.county like 'Grand Gedeh'  then '6_31'
          when a.county like 'Grand Bassa'  then '1_4'
          else null
      end  as territory_id, 
      1, 
      @p_month, 
      @p_year,
      round( count( a.position_id_supervision ) / count( a.position_id), 2 ) as supervision_rate 
from ( 
        select c.county, c.position_id, s.position_id_supervision
        from lastmile_report.data_mart_snapshot_position_cha as c
            left outer join ( 
                              select supervisedCHAID   as position_id_supervision
                              from lastmile_upload.odk_supervisionVisitLog
                              where                          
                                    ( meta_fabricated = 0 )           and
                                    ( supervisionAttendance = 1 )     and -- only count record if this flag is set.
                                    ( month( manualDate ) = @p_month  and year( manualDate ) = @p_year ) 
                              group by supervisedCHAID 
                              
                            ) as s on c.position_id like s.position_id_supervision                   
        where 
              (       
                ( c.county like 'Rivercess'   ) or
                ( c.county like 'Grand Bassa' ) or
                ( c.county like 'Grand Gedeh' and c.cohort is null  )
              ) 
              and
              ( ( month( c.snapshot_date ) =  @p_month ) and ( year( c.snapshot_date ) = @p_year ) ) 
      
) as a
group by a.county

union all

select
      418,
      '6_16' as territory_id,
      1, 
      @p_month, 
      @p_year,
      round( count( a.position_id_supervision ) / count( a.position_id ), 2 ) as supervision_rate 
from ( 
        select c.county, c.position_id, s.position_id_supervision
        from lastmile_report.data_mart_snapshot_position_cha as c
            left outer join ( 
                              select supervisedCHAID   as position_id_supervision
                              from lastmile_upload.odk_supervisionVisitLog
                              where                          
                                    ( meta_fabricated = 0 )           and
                                    ( supervisionAttendance = 1 )     and -- only count record if this flag is set.
                                    ( month( manualDate ) = @p_month  and year( manualDate ) = @p_year ) 
                              group by supervisedCHAID 
                              
                            ) as s on c.position_id like s.position_id_supervision                   
        where
              (       
                ( c.county like 'Rivercess'   ) or
                ( c.county like 'Grand Bassa' ) or
                ( c.county like 'Grand Gedeh' and c.cohort is null  )
              ) 
              and
              ( ( month( c.snapshot_date ) =  @p_month ) and ( year( c.snapshot_date ) = @p_year ) ) 
      
) as a
;

*/
/*

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
*/
/*

-- 305. Percent of expected CHSS mHealth supervision visit logs received
-- !!!!! This and certain other queries should be left-joined to a table of "expected counties" so that zeros are inserted
-- !!!!! Note: this currently does not calculate figures for GG-UNICEF !!!!!
REPLACE INTO lastmile_dataportal.tbl_values (`ind_id`,`territory_id`,`period_id`,`month`,`year`,`value`)
SELECT 305, a.territory_id, 1, @p_month, @p_year, ROUND(COUNT(1)/(2*num_cha),3)
FROM lastmile_report.mart_view_base_odk_supervision a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON a.territory_id = b.territory_id 
WHERE manualMonth=@p_month AND manualYear=@p_year AND a.territory_id IS NOT NULL GROUP BY territory_id
UNION SELECT 305, '6_16', 1, @p_month, @p_year, ROUND(COUNT(1)/(2*num_cha),3)
FROM lastmile_report.mart_view_base_odk_supervision a LEFT JOIN `lastmile_report`.`mart_program_scale` b ON '6_16' = b.territory_id
WHERE manualMonth=@p_month AND manualYear=@p_year AND a.territory_id IS NOT NULL;


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
*/

-- ------------ --
-- Misc cleanup --
-- ------------ --

-- ------ --
-- Finish --
-- ------ --

