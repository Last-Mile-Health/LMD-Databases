-- SHOW VARIABLES LIKE 'event_scheduler';
-- SET GLOBAL event_scheduler = ON;
-- SET GLOBAL event_scheduler = OFF;

-- show events;

use lastmile_upload;

drop event if exists lastmile_upload.nightly_upload_update_nchap_id;

create event lastmile_upload.nightly_upload_update_nchap_id
on schedule every 1 day starts '2017-12-09 01:00:00' on completion preserve enable 
do  begin
      call lastmile_upload.upload_update_nchap_id();   
    end;




