use lastmile_report;

drop view if exists lastmile_report.view_base_chss_tool_completion;

create view lastmile_report.view_base_chss_tool_completion as
select 
      a.county,
      a.chss_id,
      a.chss,
      a.`month`,
      a.`year`,
      
      coalesce( b.num_supervision_visit_logs, 0 ) as num_supervision_visit_logs,
      coalesce( c.num_vaccine_trackers,       0 ) as num_vaccine_trackers,
      coalesce( d.num_chss_msrs,              0 ) as num_chss_msrs,
      coalesce( e.num_cha_msrs,               0 ) as num_cha_msrs,
      coalesce( f.num_restock_forms,          0 ) as num_restock_forms,
      coalesce( g.num_cha,                    0 ) as num_cha

from lastmile_report.view_chss_tool_completion_chss a
    left outer join lastmile_report.view_chss_tool_completion_sup       as b on a.chss_id like b.chss_id and a.`month` = b.`month`        and a.`year` = b.`year`
    left outer join lastmile_report.view_chss_tool_completion_vac       as c on a.chss_id like c.chss_id and a.`month` = c.`month`        and a.`year` = c.`year`
    left outer join lastmile_report.view_chss_tool_completion_msr_chss  as d on a.chss_id like d.chss_id and a.`month` = d.month_reported and a.`year` = d.year_reported
    left outer join lastmile_report.view_chss_tool_completion_msr_cha   as e on a.chss_id like e.chss_id and a.`month` = e.month_reported and a.`year` = e.year_reported
    left outer join lastmile_report.view_chss_tool_completion_restock   as f on a.chss_id like f.chss_id and a.`month` = f.`month`        and a.`year` = f.`year`
    left outer join lastmile_report.view_chss_tool_completion_cha       as g on a.chss_id like g.chss_id
;