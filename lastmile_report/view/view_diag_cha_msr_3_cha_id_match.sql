use lastmile_report;

drop view if exists view_diag_cha_msr_3_cha_id_match;

create view view_diag_cha_msr_3_cha_id_match as

select
      trim( m.year_reported )   as msr_year_reported,
      trim( m.month_reported )  as msr_month_reported,
      
      m.meta_insert_date_time   as msr_insert_date_time,
      m.meta_de_init            as msr_meta_de_init,
      
      v.county                  as db_county,    
      v.health_district         as db_health_district,
      trim( m.district )        as msr_health_district,
      
      v.chss_position_id        as db_chss_position_id,
      trim( m.chss_id )         as msr_chss_position_id,
      
      v.chss                    as db_chss,
      trim( m.chss_name )       as msr_chss,
        
      v.position_id             as db_cha_id,
      trim( m.cha_id )          as msr_cha_id,
      
      v.cha                     as db_cha,
      trim( m.cha_name )        as msr_cha,
      
      if( soundex( v.cha ) = soundex( trim( m.cha_name ) ), 'Y', 'N' ) as soundex_cha_match,
      
      v.community_list          as db_community_list,
      trim( m.community )       as msr_community
            
from lastmile_upload.de_cha_monthly_service_report as m
    left outer join lastmile_ncha.view_base_position_cha as v on trim( m.cha_id ) like v.position_id
where not ( v.position_id is null )
order by cast( trim( m.year_reported  ) as unsigned ) desc, 
         cast( trim( m.month_reported ) as unsigned ) desc,
         v.county                                     asc,
         v.health_district                            asc,
         v.chss_position_id                           asc,
         v.position_id                                asc
;