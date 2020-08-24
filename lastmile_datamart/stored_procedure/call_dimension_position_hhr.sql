use lastmile_datamart;

-- Once a month
call lastmile_datamart.dimension_position_hhr_populate( date_format( '2012-10-01', '%Y-%m-%d' ), date_format( '2020-08-01', '%Y-%m-%d' ), 'MONTH', 'ALL' ) ;

-- Every day
-- call lastmile_datamart.dimension_position_hhr_populate( date_format( '2020-01-01', '%Y-%m-%d' ), date_format( '2020-03-01', '%Y-%m-%d' ), 'DAY', 'ALL' ) ;
