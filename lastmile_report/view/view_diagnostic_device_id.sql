use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_device_id;

create view lastmile_report.view_diagnostic_device_id as

select
      
      a.meta_device_id                              as `Device ID`,
      a.id_value                                    as `ID`,
      a.id_type                                     as `ID form type`,
      a.number_instance                             as `#instances`,
      if( pr.position_id is null, 'N', 'Y' )        as `ID valid`,
      date_format( a.last_instance, '%Y-%m-%d' )    as `Last instance`,
      date_format( a.first_instance, '%Y-%m-%d' )   as `First instance`,
      
      concat( pr.first_name, ' ', pr.last_name )    as `Person`,
      pr.phone_number                               as `Phone`,
      -- pr.phone_number_alternate,
      
      f.health_facility                             `Facility`,
      f.health_district                             as `District`,
      f.county                                      as `County`
      
from lastmile_report.view_diagnostic_device_id_filtered as a
    left outer join lastmile_cha.view_position_person         as pr on replace( a.id_value, ' ', '' ) like pr.position_id and a.id_type like pr.title     
        left outer join lastmile_cha.view_geo_health_facility as f  on pr.health_facility_id like f.health_facility_id
order by meta_device_id asc, `Last instance` desc
;