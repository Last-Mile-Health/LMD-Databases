use lastmile_cha;


-- Back all the tables up in scratchpad first just in case


-- call position_id_cha_rename( health_facility_id, old_position_id, new_position_id, "end_date or null" , old_chss_position_id, new_chss_position_id );

-- ------------------------------------------------------------------------------------------------------
-- Lakpasse
-- ------------------------------------------------------------------------------------------------------

call position_id_cha_rename( 'S0T2', 'S0T2-01', '2031', '2018-04-01', 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-02', 'S0T2-01', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-03', 'S0T2-02', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-04', 'S0T2-03', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-05', 'S0T2-04', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-06', 'S0T2-05', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-07', 'S0T2-06', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-08', 'S0T2-07', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-09', 'S0T2-08', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-10', 'S0T2-09', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-11', 'S0T2-10', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-12', 'S0T2-11', null, 'S0T2-001', 'S0T2-001' );
call position_id_cha_rename( 'S0T2', 'S0T2-13', 'S0T2-12', null, 'S0T2-001', 'S0T2-001' );
-- S0T2-13 gets created in Bodeweah from 3K07-27
call position_id_cha_new(  'S0T2', 'S0T2-14', '2018-04-01', 'S0T2-001', 2345, 566, null, null, null, null );

-- ------------------------------------------------------------------------------------------------------
-- Bodeweah
-- ------------------------------------------------------------------------------------------------------

call position_id_cha_rename( '3K07', '3K07-07', '3K07-31-TEMP', null, '3K07-001', '3K07-002' );
call position_id_cha_rename( '3K07', '3K07-08', '3K07-07', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( '3K07', '3K07-09', '3K07-08', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( '3K07', '3K07-10', '3K07-09', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( '3K07', '3K07-11', '3K07-10', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( '3K07', '3K07-12', '3K07-11', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( '3K07', '3K07-13', '3K07-12', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( '3K07', '3K07-14', '3K07-13', null, '3K07-001', '3K07-001' );
call position_id_cha_rename( 'S0T2', '3K07-27', 'S0T2-13', null, '3K07-002', 'S0T2-001' );
call position_id_cha_rename( '3K07', '3K07-28', '3K07-27', null, '3K07-002', '3K07-002' );
call position_id_cha_rename( '3K07', '3K07-29', '3K07-28', null, '3K07-002', '3K07-002' );
call position_id_cha_rename( '3K07', '3K07-30', '3K07-29', null, '3K07-002', '3K07-002' );
call position_id_cha_rename( '3K07', '3K07-31', '3K07-30', null, '3K07-002', '3K07-002' );
call position_id_cha_rename( '3K07', '3K07-31-TEMP', '3K07-31', null, '3K07-002', '3K07-002' );
call position_id_cha_new( '3K07', '3K07-14', '2018-04-01', '3K07-001', 2167,661,null,null,null,null);
call position_id_cha_new( '3K07', '3K07-32', '2018-04-01', '3K07-002', 2165,815,null,null,null,null);
call position_id_cha_new( '3K07', '3K07-33', '2018-04-01', '3K07-002', 2166,1084,null,null,null,null);

-- ------------------------------------------------------------------------------------------------------
-- Po River
-- ------------------------------------------------------------------------------------------------------

call position_id_cha_rename( '4CB0', '4CB0-20', '4CB0-40', null, '4CB0-002', '4CB0-003' );
call position_id_cha_rename( '4CB0', '4CB0-21', '4CB0-41', null, '4CB0-002', '4CB0-003' );
call position_id_cha_rename( '4CB0', '4CB0-22', '4CB0-20', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-23', '4CB0-21', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-24', '4CB0-22', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-25', '4CB0-42', null, '4CB0-002', '4CB0-003' );
call position_id_cha_rename( '4CB0', '4CB0-26', '4CB0-23', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-27', '4CB0-43', null, '4CB0-002', '4CB0-003' );
call position_id_cha_rename( '4CB0', '4CB0-28', '4CB0-24', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-29', '4CB0-25', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-30', '4CB0-44', null, '4CB0-002', '4CB0-003' );
call position_id_cha_rename( '4CB0', '4CB0-31', '4CB0-45', null, '4CB0-002', '4CB0-003' );
call position_id_cha_rename( '4CB0', '4CB0-32', '4CB0-26', null, '4CB0-002', '4CB0-002' );
call position_id_cha_rename( '4CB0', '4CB0-33', '4CB0-27', null, '4CB0-002', '4CB0-002' );

call position_id_cha_new( '4CB0', '4CB0-12', '2018-04-01', '4CB0-001', 2175,779,null,null,null,null);
call position_id_cha_new( '4CB0', '4CB0-28', '2018-04-01', '4CB0-002', 2177,1101,null,null,null,null);
call position_id_cha_new( '4CB0', '4CB0-29', '2018-04-01', '4CB0-002', 2176,760,null,null,null,null);
call position_id_cha_new( '4CB0', '4CB0-46', '2018-04-01', '4CB0-003', 2173,764,null,null,null,null);
call position_id_cha_new( '4CB0', '4CB0-47', '2018-04-01', '4CB0-003', 2172,1173,null,null,null,null);

-- ------------------------------------------------------------------------------------------------------
-- Kayah
-- ------------------------------------------------------------------------------------------------------

call position_id_cha_rename( 'LTM1', 'LTM1-01', 'LTM1-20', null, 'LTM1-001', 'LTM1-002' );
call position_id_cha_rename( 'LTM1', 'LTM1-02', 'LTM1-01', null, 'LTM1-001', 'LTM1-001' );
call position_id_cha_rename( 'LTM1', 'LTM1-03', 'LTM1-30', null, 'LTM1-001', 'LTM1-002' );
call position_id_cha_rename( 'LTM1', 'LTM1-04', 'LTM1-23', null, 'LTM1-001', 'LTM1-002' );
call position_id_cha_rename( 'LTM1', 'LTM1-05', 'LTM1-03', null, 'LTM1-001', 'LTM1-001' );
call position_id_cha_rename( 'LTM1', 'LTM1-06', 'LTM1-02', null, 'LTM1-001', 'LTM1-001' );
call position_id_cha_rename( 'LTM1', 'LTM1-07', 'LTM1-24', null, 'LTM1-001', 'LTM1-002' );
call position_id_cha_rename( 'LTM1', 'LTM1-09', 'LTM1-04', null, 'LTM1-001', 'LTM1-001' );
call position_id_cha_rename( 'LTM1', 'LTM1-10', 'LTM1-21', null, 'LTM1-001', 'LTM1-002' );

call position_id_cha_new( 'LTM1', 'LTM1-05', '2018-04-01', 'LTM1-001', 2444,643,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-06', '2018-04-01', 'LTM1-001', 2443,1251,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-07', '2018-04-01', 'LTM1-001', 2438,627,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-09', '2018-04-01', 'LTM1-001', 2441,610,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-10', '2018-04-01', 'LTM1-001', 2447,1222,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-22', '2018-04-01', 'LTM1-002', 2439,611,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-25', '2018-04-01', 'LTM1-002', 2446,949,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-26', '2018-04-01', 'LTM1-002', 2442,1252,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-27', '2018-04-01', 'LTM1-002', 2448,946,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-28', '2018-04-01', 'LTM1-002', 2445,933,null,null,null,null);
call position_id_cha_new( 'LTM1', 'LTM1-29', '2018-04-01', 'LTM1-002', 2449,1214,null,null,null,null);

-- ------------------------------------------------------------------------------------------------------
-- Kploh
-- ------------------------------------------------------------------------------------------------------

call position_id_cha_rename( 'BYQ1', 'BYQ1-21', 'BYQ1-01-TEMP', null, 'BYQ1-002', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-22', 'BYQ1-02-TEMP', null, 'BYQ1-002', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-23', 'BYQ1-03-TEMP', null, 'BYQ1-002', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-03', 'BYQ1-04-TEMP', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-25', 'BYQ1-05-TEMP', null, 'BYQ1-002', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-28', 'BYQ1-06-TEMP', null, 'BYQ1-002', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-29', 'BYQ1-07-TEMP', null, 'BYQ1-002', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-07', 'BYQ1-08-TEMP', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-44', 'BYQ1-09-TEMP', null, 'BYQ1-003', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-05', 'BYQ1-10-TEMP', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-42', 'BYQ1-11-TEMP', null, 'BYQ1-003', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-45', 'BYQ1-20-TEMP', null, 'BYQ1-003', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-40', 'BYQ1-21-TEMP', null, 'BYQ1-003', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-41', 'BYQ1-22-TEMP', null, 'BYQ1-003', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-43', 'BYQ1-23-TEMP', null, 'BYQ1-003', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-46', 'BYQ1-24-TEMP', null, 'BYQ1-003', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-20', 'BYQ1-25-TEMP', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-24', 'BYQ1-27-TEMP', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-32', 'BYQ1-28-TEMP', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-01', 'BYQ1-40-TEMP', null, 'BYQ1-001', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-02', 'BYQ1-41-TEMP', null, 'BYQ1-001', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-04', 'BYQ1-42-TEMP', null, 'BYQ1-001', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-06', 'BYQ1-43-TEMP', null, 'BYQ1-001', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-27', 'BYQ1-44-TEMP', null, 'BYQ1-002', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-08', 'BYQ1-45-TEMP', null, 'BYQ1-001', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-30', 'BYQ1-46-TEMP', null, 'BYQ1-002', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-31', 'BYQ1-47-TEMP', null, 'BYQ1-002', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-09', 'BYQ1-48-TEMP', null, 'BYQ1-001', 'BYQ1-003' );

call position_id_cha_rename( 'BYQ1', 'BYQ1-01-TEMP', 'BYQ1-01', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-02-TEMP', 'BYQ1-02', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-03-TEMP', 'BYQ1-03', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-04-TEMP', 'BYQ1-04', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-05-TEMP', 'BYQ1-05', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-06-TEMP', 'BYQ1-06', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-07-TEMP', 'BYQ1-07', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-08-TEMP', 'BYQ1-08', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-09-TEMP', 'BYQ1-09', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-10-TEMP', 'BYQ1-10', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-11-TEMP', 'BYQ1-11', null, 'BYQ1-001', 'BYQ1-001' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-20-TEMP', 'BYQ1-20', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-21-TEMP', 'BYQ1-21', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-22-TEMP', 'BYQ1-22', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-23-TEMP', 'BYQ1-23', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-24-TEMP', 'BYQ1-24', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-25-TEMP', 'BYQ1-25', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-27-TEMP', 'BYQ1-27', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-28-TEMP', 'BYQ1-28', null, 'BYQ1-002', 'BYQ1-002' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-40-TEMP', 'BYQ1-40', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-41-TEMP', 'BYQ1-41', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-42-TEMP', 'BYQ1-42', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-43-TEMP', 'BYQ1-43', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-44-TEMP', 'BYQ1-44', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-45-TEMP', 'BYQ1-45', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-46-TEMP', 'BYQ1-46', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-47-TEMP', 'BYQ1-47', null, 'BYQ1-003', 'BYQ1-003' );
call position_id_cha_rename( 'BYQ1', 'BYQ1-48-TEMP', 'BYQ1-48', null, 'BYQ1-003', 'BYQ1-003' );

call position_id_cha_new( 'BYQ1', 'BYQ1-29', '2018-04-01', 'BYQ1-002', 2154,550,null,null,null,null);
call position_id_cha_new( 'BYQ1', 'BYQ1-49', '2018-04-01', 'BYQ1-003', 2151,502,null,null,null,null);
call position_id_cha_new( 'BYQ1', 'BYQ1-50', '2018-04-01', 'BYQ1-003', 2152,522,null,null,null,null);





