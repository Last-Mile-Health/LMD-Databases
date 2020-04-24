use lastmile_report;

drop view if exists lastmile_report.view_position_qao_chss;

create view lastmile_report.view_position_qao_chss as 
select
      a.county,
      if( a.qao_position_id is null, 'Unicef', a.qao_position_id )  as `QAO ID`,
      if( a.qao is null, 'Unassigned', a.qao )                      as QAO,
      a.chss_position_id                                            as `CHSS ID`, 
      a.chss                                                        as CHSS,
      
      group_concat( distinct a.health_facility )                    as Facility,
      group_concat( distinct a.health_district )                    as `Health District`
     
from lastmile_ncha.view_base_position_cha as a
group by  a.county,
          a.qao_position_id,
          a.qao,
          a.chss_position_id, 
          a.chss
;