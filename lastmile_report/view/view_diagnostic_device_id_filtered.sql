use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_device_id_filtered;

create view lastmile_report.view_diagnostic_device_id_filtered as

select
      a.id_type,
      a.meta_device_id,
      if( a.id_value is null or a.id_value like '', null, a.id_value ) as id_value,
      count( * )                as number_instance,
      max( cast( a.date_form as date ) ) as last_instance,
      min( cast( a.date_form as date ) ) as first_instance
      
from lastmile_report.view_diagnostic_device_id_unfiltered as a
-- where not ( a.id_value is null or a.id_value like '' )
where a.date_form >= date_sub( current_date(), INTERVAL 12 month )
group by 
          a.id_type, 
          a.meta_device_id, 
          if( a.id_value is null or a.id_value like '', null, a.id_value )
;