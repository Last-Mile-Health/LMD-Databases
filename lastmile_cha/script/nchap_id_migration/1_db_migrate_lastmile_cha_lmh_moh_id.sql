use lastmile_cha;

/* 
    Two lastmile_temp tables are required: moh_chss_id and moh_cha_id
*/

-- trim everything...

-- Step 1: drop all indexes, keys, and constraints in the lastmile_cha schema that refer to position_id.

-- position_community
alter table lastmile_cha.position_community drop foreign key position_id_position_community;
alter table lastmile_cha.position_community drop primary key;

-- position_supervisor
alter table lastmile_cha.position_supervisor drop foreign key  position_id_position_supervisor;
alter table lastmile_cha.position_supervisor drop foreign key  position_id_position_supervisor_id_position_supervisor;
alter table lastmile_cha.position_supervisor drop primary key;
alter table lastmile_cha.position_supervisor drop key position_id_position_supervisor_id_position_supervisor;

-- position_person
alter table lastmile_cha.position_person drop foreign key position_id_position_person; 
alter table lastmile_cha.position_person drop foreign key person_id_position_person;
alter table lastmile_cha.position_person drop primary key;
alter table lastmile_cha.position_person drop key person_id_position_person;

-- position
alter table lastmile_cha.position drop primary key;
alter table lastmile_cha.position drop key UK_position_id; 

-- Step 2: Copy lmh position_id for active CHA and CHSS positions to position_id_lmh.  Active positions have null end_date. 

update lastmile_cha.position 
    set position_id_lmh = position_id 
where job_id = 1 and end_date is null;

update lastmile_cha.position 
    set position_id_lmh = position_id 
where job_id = 3 and end_date is null and not position_id like '%CHSS%TEMP%';


-- Step 3: Start updating the postion tables with new position_id taken from lastmile_temp moh_cha_id andmoh_chss_id.

-- position_community, cha only
update lastmile_cha.position_community pc, lastmile_temp.moh_cha_id m
    set pc.position_id = m.position_id_moh 
where pc.position_id = m.position_id_lmh;

-- position_supervisor, cha and chss
update lastmile_cha.position_supervisor ps, lastmile_temp.moh_cha_id m
    set ps.position_id = m.position_id_moh
where ps.position_id = m.position_id_lmh;

update lastmile_cha.position_supervisor ps, lastmile_temp.moh_chss_id s
    set ps.position_supervisor_id = s.position_id_moh
where ps.position_supervisor_id = s.position_id_lmh;

update lastmile_cha.position_person pr, lastmile_temp.moh_cha_id m
    set pr.position_id = m.position_id_moh
where pr.position_id = m.position_id_lmh;

update lastmile_cha.position_person pr, lastmile_temp.moh_chss_id s
    set pr.position_id = s.position_id_moh
where pr.position_id = s.position_id_lmh;

update lastmile_cha.position p, lastmile_temp.moh_cha_id m
    set p.position_id = m.position_id_moh
where p.position_id = m.position_id_lmh;

update lastmile_cha.position p, lastmile_temp.moh_chss_id s
    set p.position_id = s.position_id_moh
where p.position_id = s.position_id_lmh;

-- Last Step: Drop all the old _orig keys, they're going to be obsolete in new moh id system.
--    Keep the historical fhw/chw IDs in person_id_lmh;

alter table lastmile_cha.health_facility     drop health_facility_id_orig;
alter table lastmile_cha.position_supervisor drop position_id_orig;
alter table lastmile_cha.position_supervisor drop position_supervisor_id_orig;
alter table lastmile_cha.position_community  drop position_id_orig;
alter table lastmile_cha.position_person     drop position_id_orig;
alter table lastmile_cha.position_person     drop person_id_orig;
alter table lastmile_cha.person              change person_id_orig person_id_lmh varchar( 100 );
alter table lastmile_cha.position            drop position_id_orig;
alter table lastmile_cha.position            drop health_facility_id_orig;

-- Now, recreate all keys, indexes, and constraints

alter table lastmile_cha.position add unique UK_position_id ( position_id );
alter table lastmile_cha.position add primary key ( position_id );

alter table lastmile_cha.position_community add primary key ( position_id, community_id, begin_date );
alter table lastmile_cha.position_community add constraint position_id_position_community foreign key ( position_id ) references position ( position_id ) on delete no action on update no action;

alter table lastmile_cha.position_supervisor add primary key ( position_id, position_supervisor_id, begin_date );
alter table lastmile_cha.position_supervisor add constraint  position_id_position_supervisor                         foreign key (position_id)             references position (position_id) on delete no action on update no action;
alter table lastmile_cha.position_supervisor add constraint  position_id_position_supervisor_id_position_supervisor  foreign key (position_supervisor_id)  references position (position_id) on delete no action on update no action;

alter table lastmile_cha.position_person add primary key ( position_id, person_id, begin_date );
alter table lastmile_cha.position_person add constraint person_id_position_person    foreign key ( person_id )   references person   ( person_id )   on delete no action on update no action;
alter table lastmile_cha.position_person add constraint position_id_position_person  foreign key ( position_id ) references position ( position_id ) on delete no action on update no action;


