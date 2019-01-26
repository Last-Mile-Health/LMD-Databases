use lastmile_cha;

-- Description: View returns all the health_districts and their associated and counties.

-- The county, health district, and health facility foreign key relationships are all mandatory, so inner joins can be used.

drop view if exists view_geo_health_district;

create view view_geo_health_district as
select
      k.county_id,
      trim( k.county )              as county,
      h.health_district_id,
      trim( h.health_district )     as health_district
from county as k
    inner join health_district as h on k.county_id = h.county_id
;