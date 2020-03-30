/* Author: Owen Eddins
 * December 17, 2017
 *
 
sql> SHOW VARIABLES LIKE 'event_scheduler';
sql> SET GLOBAL event_scheduler = ON;
sql> SET GLOBAL event_scheduler = OFF;
sql> show events;
 
*/

use lastmile_upload;

drop event if exists lastmile_upload.nightly_upload_update_nchap_id;

delimiter $$

create event lastmile_upload.nightly_upload_update_nchap_id
on schedule every 1 day starts '2017-12-09 00:00:00' on completion preserve enable 
do  begin

      -- original upate script
      -- call lastmile_upload.upload_update_nchap_id(); 
      
      -- broke original script up into 4 because it was taking too long to run
      -- call lastmile_upload.1_id_repair_critical();
      -- call lastmile_upload.2_id_repair_routine_visit();
      -- call lastmile_upload.3_id_repair_sick_child();
      -- call lastmile_upload.4_id_repair_non_critical();
      
      -- March 26, 2020
      -- Ported update scripts from lastmile_cha to lastmile_ncha schema
      -- 0 script builds the two temp table for CHSS and CHA historical IDs that the other four
      -- update scripts used to repair and update the IDs
      
      call lastmile_upload.0_ncha_id_rebuild_temp_tables();

      call lastmile_upload.1_ncha_id_repair_critical();         
      call lastmile_upload.2_ncha_id_repair_routine_visit();    
      call lastmile_upload.3_ncha_id_repair_sick_child();      
      call lastmile_upload.4_ncha_id_repair_non_critical();     

      call lastmile_upload.1_legacy_position_id_pk_critical();
      call lastmile_upload.2_legacy_position_id_pk_routine_visit();
      call lastmile_upload.3_legacy_position_id_pk_sick_child();
      call lastmile_upload.4_legacy_position_id_pk_non_critical();
      
    end 
$$

delimiter ;




