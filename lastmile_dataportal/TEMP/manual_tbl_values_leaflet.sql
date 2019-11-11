
-- Set @variables based on parameters (always use @variables below to avoid ambiguity)
SET @p_month := 9;
SET @p_year := 2018;


-- Set @variables for dates
SET @p_date               := date( concat( @p_year, '-', @p_month, '-01' ) );

SET @p_monthMinus1        := month( date_add( @p_date, interval -1 month ) );
SET @p_monthMinus2        := month( date_add( @p_date, interval -2 month ) );
SET @p_monthMinus5        := month( date_add( @p_date, interval -5 month ) );

SET @p_yearMinus1         := year(  date_add( @p_date, interval -1 month ) );
SET @p_yearMinus2         := year(  date_add( @p_date, interval -2 month ) );
SET @p_yearMinus5         := year(  date_add( @p_date, interval -5 month ) );

SET @p_totalMonths        := @p_month       +( 12 * @p_year );
SET @p_totalMonthsMinus2  := @p_monthMinus2 +( 12 * @p_yearMinus2 );
SET @p_totalMonthsMinus5  := @p_monthMinus5 +( 12 * @p_yearMinus5 );

SET @isEndOfQuarter       := if( @p_month in ( 3, 6, 9, 12 ), 1, 0 );



-- 28. Number of CHAs deployed (NCHA)
-- This needs to be recoded.  These values should be pulled directly out of the tbl_nchap_scale_chss_cha table, which is William's
-- monthly updates.
/*
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_1',1,28,107);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_2',1,28,238);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_3',1,28,160);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_4',1,28,101);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_5',1,28,120);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_6',1,28,219);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_7',1,28,129);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_8',1,28,353);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_9',1,28,110);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_10',1,28,113);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_11',1,28,0);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_12',1,28,767);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_13',1,28,147);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_14',1,28,259);
REPLACE INTO lastmile_dataportal.tbl_values_leaflet (`territory_id`,`period_id`,`ind_id`,`value`) VALUES ('1_15',1,28,195);
*/


replace into lastmile_dataportal.tbl_values_leaflet ( territory_id, period_id, ind_id, value ) 

-- Assisted Areas
select t.territory_id, 1 as period_id, 29, s.chss_number_active
from lastmile_dataportal.tbl_nchap_scale_chss_cha as s
    left outer join lastmile_dataportal.view_territories as t on  ( trim( s.county )          like trim( t.territory_name ) ) and 
                                                                  ( trim( t.territory_type )  like 'county' )
where not ( s.county like '%Grand%Bassa%' or s.county like '%Grand%Gedeh%' or s.county like '%Rivercess%' )

union all

-- LMH Managed Areas
select s.territory_id, 1 as period_id, 29, s.num_chss 
from lastmile_report.mart_program_scale as s
where s.territory_id like '1\\_%'

union all

select concat('2_',health_district_id), 1 as period_id, 29, count( * ) 
from lastmile_cha.view_base_chss 
group by health_district_id
;




