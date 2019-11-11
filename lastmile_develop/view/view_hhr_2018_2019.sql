use lastmile_develop;

drop view if exists lastmile_develop.view_hhr_2018_2019;

create view lastmile_develop.view_hhr_2018_2019 as

select
      h.county                                      as County,
      h.health_district                             as District,
      substring_index( h.health_facility, ' ', 1 )  as Facility,
      h.chss_position_id                            as `CHSS ID`,
      h.chss                                        as CHSS,
      h.position_id                                 as `CHA ID`,
      h.cha                                         as CHA,
      h.hhr_2018                                    as `#HH 2018`,
      v.hhr_2019                                    as `#HH 2019`,
      -- v.hhr_2019 - h.hhr_2018                       as diff,
      concat( round( ( ( v.hhr_2019 - h.hhr_2018 ) / h.hhr_2018 ) * 100, 0 ), '%' ) as `% Change`,
      h.community_list                              as Community,
      h.community_id_list                           as ID
      
from lastmile_develop.view_hhr_2018 as h
    left outer join lastmile_develop.view_hhr_2019 as v on h.position_id like v.position_id
order by h.county, h.health_district, h.health_facility, h.chss_position_id, h.position_id
;