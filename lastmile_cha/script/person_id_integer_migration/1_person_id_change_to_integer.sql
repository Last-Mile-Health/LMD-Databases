use lastmile_cha;

-- -------------------------------------------------------------------------------------------------------------------------
-- Step 1: drop all indexes, keys, and constraints in the lastmile_cha schema that refer to person_id.
-- position_person
alter table lastmile_cha.position_person drop foreign key position_id_position_person;
alter table lastmile_cha.position_person drop foreign key person_id_position_person;
alter table lastmile_cha.position_person drop primary key;
alter table lastmile_cha.position_person drop key person_id_position_person;
alter table lastmile_cha.person drop primary key;
alter table lastmile_cha.person drop key UK_person_id;
-- -------------------------------------------------------------------------------------------------------------------------

-- case where person_id has a zero to right of pipe.  Also, left side of
-- pipe is equal to person_id_lmh.  This should be true in all cases.
-- If there is no pipe then it's a person_id for a CHSS and both the 
-- person_id and the person_id_lmh will be integers and the same.

update position_person
    set person_id = trim( substring_index( person_id, '|',  1 ) )  
where ( person_id like '%|%' ) and ( trim( substring_index( person_id, '|', -1 ) ) like '0' )
;

update person
    set person_id = trim( substring_index( person_id, '|',  1 ) )   
where ( person_id like '%|%' ) and ( trim( substring_index( person_id, '|', -1 ) ) like '0' )
; 

-- case where person_id has a negative integer to the right of the pipe.  These are persons who
-- previously were assigned to positions.  In the case of position_person table, assign the matching
-- person_id_lmh from the person table to person_id.  And in the case of the person table just
-- assign person_id_lmh to person_id.

update position_person pr,  person r
    set pr.person_id = trim( r.person_id_lmh )
where ( pr.person_id like '%|%' )                                                 and 
      ( cast( trim( substring_index( pr.person_id, '|', -1 ) ) as signed ) < 0 )  and
      trim( pr.person_id ) like trim( r.person_id )
;

update person r
    set r.person_id = trim( r.person_id_lmh )
where ( r.person_id like '%|%' ) and 
      ( cast( trim( substring_index( r.person_id, '|', -1 ) ) as signed ) < 0 )  
;

alter table lastmile_cha.person           modify person_id int(10) unsigned NOT NULL;
alter table lastmile_cha.position_person  modify person_id int(10) unsigned NOT NULL;


-- -------------------------------------------------------------------------------------------------------------------------
-- Now, recreate all keys, indexes, and constraints
-- Change person_id in person and position_person tables to integer
alter table lastmile_cha.person add unique UK_person_id ( person_id );
alter table lastmile_cha.person add primary key ( person_id );
alter table lastmile_cha.position_person add primary key ( position_id, person_id, begin_date );
alter table lastmile_cha.position_person add constraint person_id_position_person    foreign key ( person_id )   references person   ( person_id )   on delete no action on update no action;
alter table lastmile_cha.position_person add constraint position_id_position_person  foreign key ( position_id ) references position ( position_id ) on delete no action on update no action;
-- -------------------------------------------------------------------------------------------------------------------------

-- Now change person_id in training cha table
update lastmile_program.train_cha
    set person_id = trim( substring_index( person_id, '|',  1 ) )   
where ( person_id like '%|%' ) and ( trim( substring_index( person_id, '|', -1 ) ) like '0' )
;

-- make person_id an int.  Nulls okay.
alter table lastmile_program.train_cha modify   person_id int(10) unsigned null;
alter table lastmile_program.train_chss modify  person_id int(10) unsigned null;

