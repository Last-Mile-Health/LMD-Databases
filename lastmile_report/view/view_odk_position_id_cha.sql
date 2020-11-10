use lastmile_report;

drop view if exists lastmile_report.view_odk_position_id_cha;

create view lastmile_report.view_odk_position_id_cha as
select 
      'CHA'           as job,
      d.year_report, 
      d.month_report, 

      v.county,    
      v.health_district,
      v.health_facility,
      
      v.qao,
      
      v.chss_position_id,
      v.chss,
       
      v.position_id,
      v.cha,
      
      v.community_id_list,
      v.community_list,
      coalesce( s.number_record, 0 ) as number_sick_child_record,
      coalesce( r.number_record, 0 ) as number_routine_visit_record
      
from lastmile_report.view_twelve_month as d
    cross join lastmile_report.mart_view_base_position_cha as v
    
        left outer join lastmile_report.view_odk_position_id_cha_sick_child as s on ( trim( v.position_id ) like trim( s.position_id )  ) and
                                                                                    ( cast( d.year_report   as unsigned ) = cast( s.year_report   as unsigned ) ) and
                                                                                    ( cast( d.month_report  as unsigned ) = cast( s.month_report  as unsigned ) )

        left outer join lastmile_report.view_odk_position_id_cha_routine_visit as r on  ( trim( v.position_id ) like trim( r.position_id )  ) and
                                                                                        ( cast( d.year_report   as unsigned ) = cast( r.year_report   as unsigned ) ) and
                                                                                        ( cast( d.month_report  as unsigned ) = cast( r.month_report  as unsigned ) )

where ( v.cohort is null or  not ( v.cohort like '%UNICEF%' ) ) and 
      ( d.month_minus between 1 and 4 ) -- zero is current month
order by v.county asc, v.health_district asc, v.health_facility asc, v.chss_position_id asc, v.position_id, cast( d.year_report as unsigned ) desc, cast( d.month_report as unsigned ) desc
;