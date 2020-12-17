use lastmile_report;

drop view if exists lastmile_report.view_restock_cha_ppe_form;

create view lastmile_report.view_restock_cha_ppe_form as
select
      d.year_report                             as `Year`,
      d.month_report                            as `Month`,
      c.county                                  as County,
      c.health_district                         as District,
      c.health_facility                         as Facility,
      c.chss_position_id                        as CHSSID,
      c.chss                                    as CHSS,
      
      sum( coalesce( r.number_record,     0 ) ) as `#Records`,
      sum( coalesce( r.number_record_ppe, 0 ) ) as `#Records PPE`,
      
      concat( coalesce( round( ( sum( coalesce( r.number_record_ppe, 0 ) ) / sum( coalesce( r.number_record, 0 ) ) ) * 100, 0 ), 0 ), '%' ) 
      as `%Records PPE`,
      
      if( sum( coalesce( r.number_record, 0 ) ) = 0, 'NA', 
          if( group_concat( distinct r.meta_deviceID_list order by r.meta_deviceID_list separator ',' ) like '%,%', 'N', 'Y' )   
      ) as `DCT Unique`
      
      -- group_concat( distinct r.meta_deviceID_list order by r.meta_deviceID_list separator ',' ) as meta_deviceID_list
        
from lastmile_report.mart_view_base_position_cha as c
    cross join lastmile_report.view_restock_level_year_month as d
        left outer join lastmile_report.view_restock_cha_month as r on  c.position_id like  r.cha_id  and
                                                                        d.year_report = r.`year`      and
                                                                        d.month_report =  r.`month`  

where ( c.cohort is null ) or not ( c.cohort like 'UNICEF' ) 
group by d.year_report, d.month_report, c.county, c.health_district, c.health_facility, c.chss_position_id, c.chss
order by d.year_report desc, d.month_report desc, c.county asc, c.health_district asc, c.health_facility asc, c.chss_position_id asc
;