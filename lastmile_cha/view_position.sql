use lastmile_cha;

drop view if exists view_position;

create view view_position as

select
      c.county,
      h.healthDistrict,
      f.healthFacility,
      f.description       as healthFacilityDescription,
      p.positionID,
      p.beginDate         as positionBeginDate,
      p.endDate           as positionEndDate,
      j.title             as job
      
from county as c
    left outer join healthDistrict as h on c.countyID = h.countyID
        left outer join healthFacility as f on h.healthDistrictID = f.healthDistrictID
            left outer join `position` as p on trim( f.healthFacilityID ) like trim( p.healthFacilityID )
                left outer join job as j on trim( p.jobID ) = trim( j.jobID )

where ( ( trim( c.county ) like 'Grand Gedeh' ) and ( ( trim( h.healthDistrict ) like 'Konobo' ) or ( trim( h.healthDistrict ) like 'B''hai' ) ) ) 
      or 
      ( trim( c.county ) like 'Rivercess' )
;
