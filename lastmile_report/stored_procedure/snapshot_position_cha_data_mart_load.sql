use lastmile_report;

/*
* This procedure requires two parameters: a valid snapshot date and position status.
* Valid position statuses are the strings FILLED, OPEN, or ALL.
*/

truncate data_mart_snapshot_position_cha;

-- 2012
call snapshot_position_cha_data_mart( '2012-10-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2012-11-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2012-12-01', 'FILLED' );

-- 2013
call snapshot_position_cha_data_mart( '2013-01-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-02-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-03-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-04-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-05-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-06-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-07-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-08-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-09-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-10-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-11-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2013-12-01', 'FILLED' );

-- 2014
call snapshot_position_cha_data_mart( '2014-01-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-02-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-03-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-04-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-05-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-06-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-07-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-08-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-09-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-10-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-11-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2014-12-01', 'FILLED' );

-- 2015
call snapshot_position_cha_data_mart( '2015-01-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-02-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-03-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-04-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-05-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-06-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-07-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-08-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-09-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-10-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-11-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2015-12-01', 'FILLED' );

-- 2016
call snapshot_position_cha_data_mart( '2016-01-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-02-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-03-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-04-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-05-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-06-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-07-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-08-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-09-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-10-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-11-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2016-12-01', 'FILLED' );



-- 2017
call snapshot_position_cha_data_mart( '2017-01-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2017-02-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2017-03-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2017-04-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2017-05-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2017-06-01', 'FILLED' );
call snapshot_position_cha_data_mart( '2017-07-01', 'FILLED' );

drop view if exists view_snapshot_position_cha;

create view view_snapshot_position_cha as 
select 
      position_status, 
      snapshot_date, 
      cohort, 
      count( * )        as cha_count,
      sum( population ) as population,
      sum( household )  as household
from data_mart_snapshot_position_cha
group by position_status, snapshot_date, cohort
order by position_status, snapshot_date asc, cohort asc
;
