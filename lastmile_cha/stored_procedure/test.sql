select
      d.health_district,
      f.health_facility,
      p.health_facility_id  as hf_id,
      
      substring_index( ps.position_supervisor_id, '-', 1 )    as chss_id_prefix,
      if( p.health_facility_id like substring_index( ps.position_supervisor_id, '-', 1 ), 'match', 'no match' ) as hd_id_chss_match,
            
      substring_index( p.position_id, '-', 1 )                as cha_id_prefix,
      if( p.health_facility_id like substring_index( p.position_id, '-', 1 ), 'match', 'no match' ) as hd_id_cha_match,
      
      
      ps.position_supervisor_id                               as ps_chss_id,
      p.position_id,
      p.position_id_lmh,
      pr.person_id,
      concat( r.first_name, ' ', r.last_name )                as full_name,
          
 -- r.gender,
      pc.community_id                                         as pc_comm_id,
       
      date_format( p.begin_date,  "%Y-%m-%d")                 as begin_date,
      date_format( p.end_date,    "%Y-%m-%d")                 as end_date,
      
      date_format( pr.begin_date, "%Y-%m-%d")                 as pr_begin_date,
      date_format( pr.end_date,   "%Y-%m-%d")                 as pr_end_date,
                                            
      date_format( pc.begin_date, "%Y-%m-%d")                 as pc_begin_date,
      date_format( pc.end_date,   "%Y-%m-%d")                 as pc_end_date,
     
      date_format( ps.begin_date, "%Y-%m-%d")                 as ps_begin_date,
      date_format( ps.end_date,   "%Y-%m-%d")                 as ps_end_date
     

from position as p
     left outer join position_person      as pr on trim( p.position_id ) like trim( pr.position_id )
          left outer join person          as r  on pr.person_id = r.person_id
     left outer join position_community   as pc on trim( p.position_id ) like trim( pc.position_id )
     left outer join position_supervisor  as ps on trim( p.position_id ) like trim( ps.position_id )
     left outer join health_facility      as f  on trim( p.health_facility_id )like trim( f.health_facility_id )
        left outer join health_district   as d  on f.health_district_id = d.health_district_id
where p.job_id = 1 and d.county_id = 14 and not ( p.position_id like '%-%' )
order by d.health_district asc, f.health_facility asc, ps.position_supervisor_id asc, position_id asc
;