-- 1. Runtime 28+ minutes
-- OBSOLETE:call lastmile_upload.upload_update_nchap_id();

-- call lastmile_upload.1_id_repair_critical();

-- call lastmile_upload.2_id_repair_routine_visit();
-- call lastmile_upload.3_id_repair_sick_child();
-- call lastmile_upload.4_id_repair_non_critical();


-- 2. Runtime 1+ minutes 
-- call lastmile_report.data_mart_snapshot_position_cha( '2012-10-01', '2019-09-01', 'MONTH', 'ALL' );


-- 2.5 Runtime about 34+ minutes on linux vps server, at least twice that on laptop
/*
set @begin_date       = '2012-10-01';
set @end_date         = current_date();
set @unit             = 'DAY';
set @position_status  = 'ALL';
call dimension_position_populate( @begin_date, @end_date, @unit, @position_status );
call lastmile_datamart.dimension_position_populate( '2012-10-01', current_date(), 'DAY', 'ALL' );
call lastmile_datamart.dimension_position_populate( '2012-10-01', current_date(), 'DAY', 'ALL' );
*/

-- Only load dimension table for current date minus 6 months

-- call lastmile_datamart.dimension_position_populate( date_format( date_sub( current_date(), INTERVAL 6 month ), '%Y-%m-%d' ), 
--                                                    date_format( current_date(), '%Y-%m-%d' ), 'DAY', 'ALL' ) ;



-- 3. Runtime 18+ mins
-- OBSOLETE: call lastmile_dataportal.updateDataMarts();
-- call lastmile_dataportal.data_mart_other();
-- call lastmile_dataportal.data_mart_msr_1();
-- call lastmile_dataportal.data_mart_msr_2();
-- call lastmile_dataportal.data_mart_msr_3();

-- 4. Runtime 2+ mins each
-- call lastmile_dataportal.dataPortalValues( 7, 2019 );
-- call lastmile_dataportal.dataPortalValues( 8, 2019 );
-- call lastmile_dataportal.dataPortalValues( 9, 2019 );


-- 5. Runtime 30+ secs
-- call lastmile_dataportal.leafletValues( 9, 2019 );


-- 6. Runtime 1+ mins 
-- call lastmile_dataportal.diagnostic_loader( '2018-11-01',  current_date() );


