use lastmile_report;

drop view if exists view_diag_cha_msr_2_cha_id_invalid;

create view view_diag_cha_msr_2_cha_id_invalid as

select
      trim( m.year_reported )   as year_reported,
      trim( m.month_reported )  as month_reported,
      trim( m.cha_id )          as cha_id,
      trim( m.cha_name )        as cha_name,
      trim( m.chss_id )         as chss_id,
      trim( m.chss_name )       as chss_name,
      trim( m.community )       as community,
      trim( m.district )        as health_district
      
from lastmile_upload.de_cha_monthly_service_report as m
    left outer join lastmile_cha.view_base_position_cha_basic_info as v on trim( m.cha_id ) like v.position_id
where v.position_id is null
order by cast( trim( m.year_reported  ) as unsigned ) desc, 
         cast( trim( m.month_reported ) as unsigned ) desc,
         trim( m.chss_id ) asc
;