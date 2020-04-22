use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_cha;

create view lastmile_report.view_chss_tool_completion_cha as 

select 
        a.chss_position_id    as chss_id,
        count( a.cha )        as num_cha
        
from lastmile_ncha.view_base_position_cha as a
where not( a.position_id is null ) and ( ( a.cohort is null ) or not ( a.cohort like '%UNICEF%' ) )
group by a.chss_position_id
;