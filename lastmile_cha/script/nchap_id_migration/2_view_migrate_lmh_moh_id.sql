use lastmile_cha;

-- --------------------------------------------------------------------------------------------------------------------
--                        Create views to map position_id to historical cha_id
-- --------------------------------------------------------------------------------------------------------------------

drop view if exists lastmile_cha.view_base_history_moh_lmh_cha_id;

create view lastmile_cha.view_base_history_moh_lmh_cha_id as

select

      p.position_id,
       
      if( p.position_id_lmh is null or  trim( p.position_id_lmh ) like '', 
      
          null,
          
          if( p.position_id_lmh like r.person_id_lmh, p.position_id_lmh, r.person_id_lmh ) 
      
      ) as cha_id_historical,
      
      p.position_id_lmh,
      p.begin_date        as position_begin_date,
      p.end_date          as position_end_date,
      
      pr.begin_date       as position_person_begin_date,
      pr.end_date         as position_person_end_date,
      
      r.person_id,
      r.person_id_lmh
      
from lastmile_cha.position as p
    left outer join lastmile_cha.position_person as pr on p.position_id  like pr.position_id
        left outer join lastmile_cha.person      as r  on pr.person_id   like r.person_id
where ( p.job_id = 1 ) 
;

-- Note: view_base_history_moh_lmh_cha_id is too slow.  When integrated into view_base_position_cha it
-- takes about a minute and 45 secs to run.  So I create a "temp" table to act as a stand in for this view.
-- The execution time drops down to about 2-4 secs.  Doable.

drop table if exists lastmile_cha.temp_view_base_history_moh_lmh_cha_id;

create table lastmile_cha.temp_view_base_history_moh_lmh_cha_id as 
select * from lastmile_cha.view_base_history_moh_lmh_cha_id;


-- The performance on the chss lmh to moh ids is not an issue so let's stay with the view 

drop view if exists lastmile_cha.view_base_history_moh_lmh_chss_id;

create view lastmile_cha.view_base_history_moh_lmh_chss_id as

select
      trim( p.position_id ) as position_id,
      trim( pr.person_id )  as chss_id_historical,
      trim( pr.person_id )  as person_id
from lastmile_cha.position as p
    left outer join lastmile_cha.position_person as pr on trim( p.position_id ) like trim( pr.position_id ) 
where ( p.job_id = 3 )
;

