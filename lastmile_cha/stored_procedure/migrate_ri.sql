use lastmile_cha;

-- UTY8-001	Ellen Payne	UTY8-12		Little Liberia	714	UTY8-12 to lmd position id 2529 obsolete it.

-- call position_id_cha_rename( health_facility_id, old_position_id, new_position_id, "end_date or null" , old_chss_position_id, new_chss_position_id );
call position_id_cha_rename( 'UTY8', 'UTY8-12', '2529', '2018-04-01', 'UTY8-001', 'UTY8-001' );



-- UTY8-12		Toe Town	1353	New position: Genesis Whegelee

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2542,     'Genesis' , 'Whegelee', 'F' )
;

call position_id_cha_new(  'UTY8', 'UTY8-12', '2018-04-01', 'UTY8-001', 2542, 1353, null, null, null, null );



-- UTY8-13		Dehgo	1354	New position: Paul T. Dahn

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2544,     'Paul T.' , 'Dahn',     'M' )
;

call position_id_cha_new( 'UTY8', 'UTY8-13', '2018-04-01', 'UTY8-001', 2544, 1354, null, null, null, null );



-- P1E3-001	Josephine N. Wonmei	P1E3-13	Waytay York	Toweh	956	P1E3-13 to SQB2-09, Waytay stays

call position_id_cha_rename( 'SQB2', 'P1E3-13', 'SQB2-09', null, 'P1E3-001', 'SQB2-001' );



-- P1E3-13		Gboah town	980	New Position: Jerry G. Cole

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2546,     'Jerry G.' , 'Cole',     'M' )
;

call position_id_cha_new( 'P1E3', 'P1E3-13', '2018-04-01', 'P1E3-001', 2546, 980, null, null, null, null );



-- P1E3-002	Rulex M.  Monger	P1E3-27		Kordoe	688	P1E3-27 to lmh position id 2500, obsolete it

call position_id_cha_rename( 'P1E3', 'P1E3-27', '2500', '2018-04-01', 'P1E3-002', 'P1E3-002' );




-- P1E3-27		Wehgar town, Peonwolo	696, 1334	New Position: Amos S. Zeo

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2545,     'Amos S.' , 'Zeo',     'M' )
;

call position_id_cha_new( 'P1E3', 'P1E3-27', '2018-04-01', 'P1E3-002', 2545, 696, 1334, null, null, null );




-- P1E3-28		Blay town	1316	New Position: Prince D. Sandoe

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2547,     'Prince D.' , 'Sandoe', 'M' )
;

call position_id_cha_new( 'P1E3', 'P1E3-28', '2018-04-01', 'P1E3-002', 2547, 1316, null, null, null, null );




-- BB01-001	Alice F. Langama	BB01-11		Solo	805	BB01-11 to lmh position id 2170, obsolete

call position_id_cha_rename( 'BB01', 'BB01-11', '2170', '2018-04-01', 'BB01-001', 'BB01-001' );




-- BB01-11		Gbagbo	1153	New Position: S. Shadrach George, Jr 2190

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2190,     'S. Shadrach' , 'George, Jr', 'M' )
;

call position_id_cha_new( 'BB01', 'BB01-11', '2018-04-01', 'BB01-001', 2190, 1153, null, null, null, null );



-- BB01-13		Jweh	807	New Position: Teta King 2189

insert into person ( person_id, first_name, last_name,  gender )
values              ( 2189,     'Teta' , 'King', 'M' )
;

call position_id_cha_new( 'BB01', 'BB01-13', '2018-04-01', 'BB01-001', 2189, 807, null, null, null, null );








