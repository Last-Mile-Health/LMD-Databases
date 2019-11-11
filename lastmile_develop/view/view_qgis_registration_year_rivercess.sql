use lastmile_develop;

drop view if exists lastmile_develop.view_qgis_registration_year_rivercess;

create view lastmile_develop.view_qgis_registration_year_rivercess as 

select
      year( trim( registrationDate ) )                                        as registration_year,
      trim( communityID )                                                     as community_id,
      trim( chaID )                                                           as position_id,
      max( trim( registrationDate ) )                                         as registration_date,
      sum( cast( 1_1_A_total_number_households as unsigned ) )                as total_household
  
from lastmile_upload.de_chaHouseholdRegistration as g
where ( meta_insertDatetime >= '2019-01-01' ) and 
      ( 
            -- Rivercess communityIDs fall between 500 and 1999, excluding 999
            ( cast( communityID as unsigned ) between 500 and 1999 ) and 
        not ( trim( communityID ) like '999' ) 
        
      )
group by registration_year, community_id, position_id
;