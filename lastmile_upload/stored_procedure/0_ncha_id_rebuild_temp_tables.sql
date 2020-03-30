use lastmile_upload;

drop procedure if exists lastmile_upload.0_ncha_id_rebuild_temp_tables;
/*  
 * Rebuild the table temp_view_person_position_cha_id_update and temp_view_person_position_chss_id_update, 
 * which are just materialized "views" (tables) of view_person_position_cha_id_update and 
 * view_person_position_chss_id_update.
 * 
 * Rebuild the tables temp_view_person_position_cha_id_update and temp_view_person_position_chss_id_update.
 *
 * For temp_view_person_position_cha_id_update, index the position_id_last, position_id
 * Note: cha_id_historical is when a person_id or position_id mateches old LMH IDs as integers
 * for performance during global ID cleanup. 
 *
 * For temp_view_person_position_chss_id_update, index the X, Y, Z 
 * for performance during global ID cleanup. 
 *
*/

create procedure lastmile_upload.0_ncha_id_rebuild_temp_tables()

-- declare continue handler for sqlexception set has_error = 1;

begin

-- declare continue handler for sqlexception select 'error occurred';

declare continue handler for sqlexception
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) 
values ( now(), 'error occurred' );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'BEGIN: 0_ncha_id_rebuild_temp_tables' );


-- Rebuild the table temp_view_person_position_cha_id_update everytime this procedure is called.

drop table if exists lastmile_ncha.temp_view_history_position_position_id_cha_update;

create table lastmile_ncha.temp_view_history_position_position_id_cha_update as 
select * from lastmile_ncha.view_history_position_position_id_cha_update;

-- index on the three fields in the update where clause
alter table lastmile_ncha.temp_view_history_position_position_id_cha_update add index ( position_id_nchap( 50 ) );
alter table lastmile_ncha.temp_view_history_position_position_id_cha_update add index ( position_id( 50 )       );
alter table lastmile_ncha.temp_view_history_position_position_id_cha_update add index ( position_id_pk       );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'temp_view_history_position_position_id_cha_update' );



-- Rebuild the table temp_view_person_position_chss_id_update everytime this procedure is called.

drop table if exists lastmile_ncha.temp_view_history_position_position_id_chss_update;

create table lastmile_ncha.temp_view_history_position_position_id_chss_update as 
select * from lastmile_ncha.view_history_position_position_id_chss_update;

-- index on the three fields in the update where clause
alter table lastmile_ncha.temp_view_history_position_position_id_chss_update add index ( position_id_nchap( 50 ) );
alter table lastmile_ncha.temp_view_history_position_position_id_chss_update add index ( position_id( 50 )       );
alter table lastmile_ncha.temp_view_history_position_position_id_chss_update add index ( position_id_pk       );

insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'temp_view_history_position_position_id_chss_update' );


-- End of procedure
insert into lastmile_upload.log_update_nchap_id ( meta_date_time, table_name ) values ( now(), 'END: 0_ncha_id_rebuild_temp_tables' );

end; -- end stored procedure
