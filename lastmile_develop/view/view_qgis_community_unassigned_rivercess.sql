use lastmile_develop;

drop view if exists lastmile_develop.view_qgis_community_unassigned_rivercess;

create view lastmile_develop.view_qgis_community_unassigned_rivercess as

select
      archived,	
      community_id,	
      community,	
      community_alternate,
      district_id,	
      health_facility_id,	
      health_facility_id_orig,	
      health_facility_proximity,	
      health_facility_km,	
      x,
      y,	
      household_map_count,	
      motorbike_access,	
      cell_reception,	
      mining_community,	
      lms_2015,	
      lms_2016,	
      note,	
      meta_insert_date_time

from lastmile_cha.community
where     ( community_id between 500 and 1999 ) and 
          ( archived = 0 ) and
      not ( 
            community_id in ( -- build list of community IDs that are assigned to position IDs in Rivercess
                              select community_id
                              from lastmile_cha.position_community
                              where community_id between 500 and 1999
                              group by community_id
                            ) 
          );