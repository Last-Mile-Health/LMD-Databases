/*
 *
 *
 *
*/

use lastmile_ncha;

drop view if exists lastmile_ncha.view_geo_health_facility;

create view lastmile_ncha.view_geo_health_facility as
select
      k.county_id,
      trim( k.county )              as county,
      h.health_district_id,
      trim( h.health_district )     as health_district,
      trim( h.cohort )              as cohort,
      trim( f.health_facility_id )  as health_facility_id,
      trim( f.health_facility )     as health_facility  
from lastmile_ncha.county as k
    inner join lastmile_ncha.health_district as h on k.county_id = h.county_id
        inner join lastmile_ncha.health_facility as f on h.health_district_id = f.health_district_id
;