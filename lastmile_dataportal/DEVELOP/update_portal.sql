-- 1. Runtime 28+ minutes
-- v1.0 OBSOLETE: call lastmile_upload.upload_update_nchap_id();
-- v2.0 OBSOLETE: call lastmile_upload.1_id_repair_critical(); -- 10+ mins
-- v2.0 OBSOLETE: call lastmile_upload.2_id_repair_routine_visit();
-- v2.0 OBSOLETE: call lastmile_upload.3_id_repair_sick_child();
-- v2.0 OBSOLETE: call lastmile_upload.4_id_repair_non_critical();

-- v 3.0 of ID repair code, 53 minutes to run this on server, beginning at midnight

-- call lastmile_upload.0_ncha_id_rebuild_temp_tables();
-- call lastmile_upload.1_ncha_id_repair_critical();         -- 8+ mins

-- call lastmile_upload.2_ncha_id_repair_routine_visit();    -- 12+ mins
-- call lastmile_upload.3_ncha_id_repair_sick_child();       -- 13+ mins
-- call lastmile_upload.4_ncha_id_repair_non_critical();     -- 1+ mins

-- these four each run about a minute faster than their analogs above
-- call lastmile_upload.1_legacy_position_id_pk_critical();

-- call lastmile_upload.2_legacy_position_id_pk_routine_visit();
-- call lastmile_upload.3_legacy_position_id_pk_sick_child();
-- call lastmile_upload.4_legacy_position_id_pk_non_critical();


-- 2. Runtime 1+ minutes     FILLED
-- call lastmile_report.data_mart_snapshot_position_cha( '2012-10-01', '2020-07-01', 'MONTH', 'ALL' );


-- 3. Runtime about 34+ minutes on linux vps server, at least twice that on laptop
-- Only load dimension table for current date minus 6 months (6+ minutes.)
-- call lastmile_datamart.dimension_position_populate( date_format( '2018-04-01', '%Y-%m-%d' ), date_format( current_date(), '%Y-%m-%d' ), 'DAY', 'ALL' ) ;

-- approx. 14 mins
-- call lastmile_datamart.dimension_position_populate( date_format( date_sub( current_date(), INTERVAL 1 month ), '%Y-%m-%d' ), date_format( current_date(), '%Y-%m-%d' ), 'DAY', 'ALL' ) ;
-- call lastmile_datamart.dimension_position_populate( date_format( date_sub( current_date(), INTERVAL 12 month ), '%Y-%m-%d' ), date_format( current_date(), '%Y-%m-%d' ), 'DAY', 'ALL' ) ;

-- call lastmile_datamart.dimension_position_populate( date_format( date_sub( current_date(), INTERVAL 6 month ), '%Y-%m-%d' ), date_format( current_date(), '%Y-%m-%d' ), 'DAY', 'ALL' ) ;


-- 4. Runtime 5+ mins
-- OBSOLETE: call lastmile_dataportal.updateDataMarts();
/*
call lastmile_dataportal.data_mart_other();
call lastmile_dataportal.data_mart_msr_1();
call lastmile_dataportal.data_mart_msr_2();
call lastmile_dataportal.data_mart_msr_3();
*/

-- 5. Runtime approx 25 seconds each

-- Note to self: Edit event script to test the last three months once you sure the coding changes are all good.

-- call lastmile_dataportal.dataPortalValues( 5,  2020 );
-- call lastmile_dataportal.dataPortalValues( 6,  2020 );
-- call lastmile_dataportal.dataPortalValues( 7,  2020 );


-- 6. Runtime 30+ secs
-- call lastmile_dataportal.leafletValues( 7, 2020 );


-- 7. Runtime 10+ mins 
-- call lastmile_dataportal.diagnostic_loader( '2018-11-01',  current_date() );

