use lastmile_temp;

drop view if exists view_community_grand_bassa_master;

create view view_community_grand_bassa_master as

select

  m.archived	      as 	archived,
  m.community_id	  as 	community_id,
  m.town_name 	    as 	community,
  m.alt_name 	      as 	community_alternate,
  m.health_district as  health_district,
  
  -- if( trim( m.adm_distri ) like '%2%', 25, if( trim( m.adm_distri ) like '%3%', 26, null ) ) as 	district_id,
  
  case
  
      when trim( m.adm_distri ) like '1'          THEN '24' -- district 1
      when trim( m.adm_distri ) like '2'          THEN '25' -- district 2
      when trim( m.adm_distri ) like '3'          THEN '26' -- district 3
      when trim( m.adm_distri ) like '4'          THEN '27' -- district 4
      when trim( m.adm_distri ) like '%neek%'     THEN '28' -- district Neekreen
      when trim( m.adm_distri ) like '%owen%'     THEN '29' -- district Owensgrove
      when trim( m.adm_distri ) like '%st%john%'  THEN '30' -- district St. John River City

      else '999'
  end as district_id,

  case
  
      when cast( community_id as unsigned ) between 3000 and 3299 THEN 'ZZZZ' -- Molons
      when cast( community_id as unsigned ) between 3300 and 3399 THEN '88Y2' -- Senyah
      
      when cast( community_id as unsigned ) between 3500 and 3539 THEN 'QU46' -- Desoe
      when cast( community_id as unsigned ) between 3540 and 3599 THEN 'ZKV3' -- 
      when cast( community_id as unsigned ) between 3600 and 3699 THEN '8GK2' -- 
      
      when cast( community_id as unsigned ) between 3700 and 3899 THEN '1CC1' -- St John
      when cast( community_id as unsigned ) between 3900 and 4199 THEN 'AUZ8' -- Compound 2
    
      when cast( community_id as unsigned ) between 4200 and 4399 THEN '0GZ8' -- Barseegiah
      when cast( community_id as unsigned ) between 4400 and 4499 THEN 'C0U4' -- Boeglay
      when cast( community_id as unsigned ) between 4500 and 4599 THEN 'KH28' -- Compound 3
   
      else '999'
  end as health_facility_id,
  
  m.remoteness 	    as 	health_facility_proximity,
  m.dist_km 	      as 	health_facility_km,
  m.X 	            as 	x,
  m.Y 	            as 	y,
  m.numHH 	        as 	household_map_count,
  m.moto_reach 	    as 	motorbike_access,
  m.CD_cell 	      as 	cell_reception,
  m.mining 	        as 	mining_community,

  concat( 'community_grand_bassa_master.master_list_id: (', m.master_list_id, ') ', coalesce( m.notes, '' ) ) as note
 
from lastmile_temp.community_grand_bassa_master as m
    
where not ( community_id is null )
      -- and ( health_district like '%camp%wood%' or health_district like '%3%c%' )
order by cast( community_id as unsigned ) asc

