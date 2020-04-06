use lastmile_ncha;

drop view if exists lastmile_ncha.view_history_person_geo;

create view lastmile_ncha.view_history_person_geo as
select
      -- person_id	full_name	birth_date	gender	phone_number	phone_number_alternate	
      r.person_id,
      trim( concat( r.first_name, ' ', r.last_name ) )      as full_name,
      r.birth_date,
      trim( r.gender )                                      as gender,
      trim( r.phone_number )                                as phone_number,
      trim( r.phone_number_alternate )                      as phone_number_alternate,

      -- job	position_id	position_person_begin_date	position_person_end_date	position_person_active	
      gl.job,
      pl.position_id_pk,
      pl.position_id,
      pl.position_person_begin_date,
      pl.position_person_end_date,
      if( pl.position_person_end_date is null, 'Y', 'N' ) as position_person_active,
      pl.position_id_begin_date,
      pl.position_id_end_date,

      -- health_facility	health_facility_id	cohort	health_district	health_district_id	county	county_id	
      gl.health_facility,
      gl.health_facility_id,
      gl.cohort,
      gl.health_district,
      gl.health_district_id,
      gl.county,
      gl.county_id,
     
      -- job_first	position_id_first	position_person_begin_date_first	position_person_end_date_first	position_person_active_first
      gf.job                                              as job_first,
      pf.position_id                                      as position_id_first,
      pf.position_person_begin_date                       as position_person_begin_date_first,
      pf.position_person_end_date                         as position_person_end_date_first,
      if( pf.position_person_end_date is null, 'Y', 'N' ) as position_person_active_first 


from lastmile_ncha.person as r
    left outer join lastmile_ncha.view_history_person_position_id_pk_position_id_last as pl on r.person_id = pl.person_id
        left outer join lastmile_ncha.view_history_position_geo as gl on  ( ( pl.position_id_pk = gl.position_id_pk ) and
                                                                            ( trim( pl.position_id ) like trim( gl.position_id ) ) )
                                                                            
    left outer join lastmile_ncha.view_history_person_position_id_pk_position_id_first as pf on r.person_id = pf.person_id
        left outer join lastmile_ncha.view_history_position_geo as gf on  ( ( pf.position_id_pk = gf.position_id_pk ) and
                                                                            ( trim( pf.position_id ) like trim( gf.position_id ) ) )                                                                      
;                                                                         
   