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
on schedule every 1 day starts '2017-12-09 01:00:00' on completion preserve enable 
do  begin
      -- call lastmile_upload.upload_update_nchap_id(); 
      
      call lastmile_upload.1_id_repair_critical();
      call lastmile_upload.2_id_repair_routine_visit();
      call lastmile_upload.3_id_repair_sick_child();
      call lastmile_upload.4_id_repair_non_critical();
         
    end 
$$

delimiter ;




