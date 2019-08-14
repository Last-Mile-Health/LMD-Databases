use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_restock;
    
create view lastmile_report.view_chss_tool_completion_restock as
select  
      if( chssID is null, trim( user_id ), trim( chssID ) ) as chss_id,
      year( manualDate )                                    as `year`,
      month( manualDate )                                   as `month`,
      count( * )                                            as num_restock_forms

from lastmile_upload.odk_chaRestock
group by if( chssID is null, trim( user_id ), trim( chssID ) ), year( manualDate ), month( manualDate )
;