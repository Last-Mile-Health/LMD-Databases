-- the table and the procedure already exist.  you do not need to run this when you migrate.

drop table if exists lastmile_upload.log_update_nchap_id;

create table lastmile_upload.log_update_nchap_id (

  pk_id int(10) unsigned NOT NULL AUTO_INCREMENT,

  meta_date_time datetime,
  table_name      varchar( 100 ),
  
  PRIMARY KEY ( pk_id ),
  UNIQUE KEY UK_id ( pk_id )

)
;

drop procedure if exists lastmile_upload.upload_update_nchap_id;

create procedure lastmile_upload.upload_update_nchap_id()
begin
    
    insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'none' );

end
;

call lastmile_upload.upload_update_nchap_id(); 