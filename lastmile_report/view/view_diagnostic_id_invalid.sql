use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_id_invalid;

create view lastmile_report.view_diagnostic_id_invalid as

select
      d.table_name, 
      d.pk_id, 
      d.id_type, 
      d.id_name, 
      d.id_original_value             as id_original, 
      d.id_inserted_value             as id_repair, 
      d.id_inserted_format_value      as id_formatted, 
      d.id_value, 
      
      d.meta_cha,
      d.meta_cha_id,
      d.meta_chss,
      d.meta_chss_id,
      d.meta_facility,
      d.meta_facility_id,
      d.meta_health_district,
      d.meta_county,
      d.meta_community,
      d.meta_community_id,
      d.meta_form_date,
       
      d.meta_insert_date_time         as meta_insert_date_time_original, 
      d.meta_form_version

from lastmile_report.view_diagnostic_id as d
    left outer join lastmile_cha.`position` as p on trim( d.id_inserted_value ) like p.position_id and d.id_type like if( p.job_id = 1, 'cha',  if( p.job_id = 3, 'chss', null ) )
where p.position_id is null
;