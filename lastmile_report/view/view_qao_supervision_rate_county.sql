use lastmile_report;

drop view if exists lastmile_report.view_qao_supervision_rate_county;

create view lastmile_report.view_qao_supervision_rate_county as

select
      /*  
          Hard code the territories rather than join with view_territories.  GG will need to be manually mapped to 
          6_31 GG (LMH) anyway.
      */
      case substring_index( c.position_id, '-', 1 )
            when 'GG' then '6_31'
            when 'GB' then '1_4'
            when 'RI' then '1_14'
            else null
      end                                                   as territory_id,
      
      year(  q.TodayDate )                                  as year_reported,
      month( q.TodayDate )                                  as month_reported,
      count( * )                                            as number_supervision_visit
      
from lastmile_upload.odk_QAOSupervisionChecklistForm as q
    left outer join lastmile_cha.view_position_qao_person_geo as c on trim( q.QAOID ) like c.position_id
where not( c.position_id is null )
group by 
        substring_index( position_id, '-', 1 ),
        year( q.TodayDate ), 
        month( q.TodayDate )
;