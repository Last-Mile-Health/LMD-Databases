use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_odk_id_metadata_community_id;

create view lastmile_report.view_diagnostic_odk_id_metadata_community_id as 

select
      community_id,
      community,
                            
      group_concat( distinct position_id         order by position_id separator ', ' ) as position_id_list,
      group_concat( distinct health_facility_id  order by position_id separator ', ' ) as health_facility_id_list,
      group_concat( distinct health_facility     order by position_id separator ', ' ) as health_facility_list,
      group_concat( distinct health_district     order by position_id separator ', ' ) as health_district_list,
      group_concat( distinct county              order by position_id separator ', ' ) as county_list,
      group_concat( distinct chss_position_id    order by position_id separator ', ' ) as chss_position_id_list,
      group_concat( distinct chss                order by position_id separator ', ' ) as chss_list,
      group_concat( distinct cha                 order by position_id separator ', ' ) as cha_list

from lastmile_ncha.view_community_geo_position_cha
group by community_id, community
;