use lastmile_cha;

-- Description: View shows all the facilities and their associated health districts and counties.

-- The county, health district, and health facility foreign key relationships are all mandatory, so inner joins can be used.

drop view if exists view_geo_health_facility;

create view view_geo_health_facility as
select
      k.county_id,
      trim( k.county )              as county,
      h.health_district_id,
      trim( h.health_district )     as health_district,
      trim( h.cohort )              as cohort,
      trim( f.health_facility_id )  as health_facility_id,
      trim( f.health_facility )     as health_facility  
from county as k
    inner join health_district as h on k.county_id = h.county_id
        inner join health_facility as f on h.health_district_id = f.health_district_id
;