use lastmile_report;

drop view if exists lastmile_report.view_qao_supervision_rate_county;

create view lastmile_report.view_qao_supervision_rate_county as

select
      trim( substring_index( c.county_list, ',', 1 ) )              as county,
      if( t.territory_id like '1\\_6', '6_31', t.territory_id )     as territory_id, -- case of Grand Gedeh use 6_31 GG (LMH)
      year(  q.TodayDate )                                          as year_reported,
      month( q.TodayDate )                                          as month_reported,
      count( * )                                                    as number_supervision_visit
from lastmile_upload.odk_QAOSupervisionChecklistForm as q
    left outer join lastmile_cha.view_position_qao_person_geo as c on trim( q.QAOID ) like c.position_id
        left outer join lastmile_dataportal.view_territories as t on ( trim( substring_index( c.county_list, ',', 1 ) ) like t.territory_name ) and ( 'county' like t.territory_type )
group by 
        trim( substring_index( c.county_list, ',', 1 ) ),
        t.territory_id,
        year( q.TodayDate ), 
        month( q.TodayDate )
;