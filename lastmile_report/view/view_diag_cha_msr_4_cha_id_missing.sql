use lastmile_report;

drop view if exists view_diag_cha_msr_4_cha_id_missing;

create view view_diag_cha_msr_4_cha_id_missing as

select 
      d.year_reported, 
      d.month_reported, 

      v.county,    
      v.health_district,
      v.health_facility,
      
      v.qao,
      
      v.chss_position_id,
      v.chss,
       
      v.position_id,
      v.cha,
      
      v.community_id_list,
      v.community_list
      
from lastmile_report.view_twelve_month as d
    cross join lastmile_cha.view_base_position_cha as v
        left outer join lastmile_upload.de_cha_monthly_service_report as m on ( trim( v.position_id ) like trim( m.cha_id )                                   ) and
                                                                              ( cast( d.year_reported   as unsigned ) = cast( m.year_reported   as unsigned ) ) and
                                                                              ( cast( d.month_reported  as unsigned ) = cast( m.month_reported  as unsigned ) )
where ( ( v.cohort is null ) or  not ( v.cohort like '%UNICEF%' ) ) and ( m.cha_id is null ) 

order by cast( d.year_reported as unsigned ) desc, cast( d.month_reported as unsigned ) desc, v.county asc, v.health_district asc, v.health_facility asc, v.chss_position_id asc, v.position_id
;


