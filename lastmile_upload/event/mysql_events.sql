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
      call lastmile_upload.upload_update_nchap_id();   
    end 
$$

delimiter ;




