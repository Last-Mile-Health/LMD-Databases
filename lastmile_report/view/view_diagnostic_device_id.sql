use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_device_id;

create view lastmile_report.view_diagnostic_device_id as

select
      a.id_type,
      a.meta_device_id,
      a.id_value,
      a.number_instance,
      
      concat( pr.first_name, ' ', pr.last_name ) as full_name,
      pr.phone_number,
      pr.phone_number_alternate,
      
      f.health_facility,
      f.health_district,
      f.county
      
from lastmile_report.view_diagnostic_device_id_filtered as a
    left outer join lastmile_cha.view_position_person         as pr on replace( a.id_value, ' ', '' ) like pr.position_id and a.id_type like pr.title     
        left outer join lastmile_cha.view_geo_health_facility as f  on pr.health_facility_id like f.health_facility_id
order by meta_device_id asc
;