use lastmile_chwdb;

drop view if exists view_staffIDfromSoundex;

create view view_staffIDfromSoundex as
select 
      staffID, 
      concat( firstName, ' ', lastName ) as staffName, 
      soundex( concat( firstName, ' ', lastName ) ) as staffNameSoundex
from admin_staff
;