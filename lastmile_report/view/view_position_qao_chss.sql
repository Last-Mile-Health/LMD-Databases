use lastmile_report;

drop view if exists view_position_qao_chss;

create view view_position_qao_chss as 
select 
      a.county                                                      as County,
      if( a.qao_position_id is null, 'Unicef', a.qao_position_id )  as `QAO Position ID`,
      if( a.qao is null, 'Unassigned', a.qao )                      as QAO,
      a.chss_position_id                                            as `CHSS Position_ID`, 
      a.chss                                                        as CHSS,
      a.chss_health_facility                                        as Facility,
      a.health_district                                             as `Health District`
      
from lastmile_cha.view_base_position_cha_basic_info as a
group by  a.county,
          a.qao_position_id,
          a.qao,
          a.chss_position_id, 
          a.chss,
          a.chss_health_facility,
          a.health_district
          
order by  a.county            asc,
          if( a.qao_position_id is null, 'Unicef', a.qao_position_id )   asc,
          a.chss_position_id  asc
;