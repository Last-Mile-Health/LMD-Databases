use lastmile_report;

drop view if exists view_diag_ifi_county_count;

create view view_diag_ifi_county_count as
select
      year_complete,
      month( str_to_date( month_complete,'%M' ) ) as month_complete,
      county, 
      count( * ) as number_records
from lastmile_liberiamohdata.federated_de_integrated_supervision_tool_community
group by year_complete, month( str_to_date( month_complete,'%M' ) ), county
order by year_complete desc, month( str_to_date( month_complete,'%M' ) ) desc, county asc
;