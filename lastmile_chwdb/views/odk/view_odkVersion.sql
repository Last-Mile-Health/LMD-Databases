use lastmile_chwdb;

drop view if exists view_odkVersion;

create view view_odkVersion as
select 
      'CHW Restock'                               as formName,
      'CHW-L'                                     as staffType,
      replace( chwlID, ' ', '' )                  as staffID,
      replace ( meta_formVersion, ' ', '' )       as formVersion,
      meta_autoDate                               as formDate

from staging_odk_chwrestock
union
select 
      'Sick Child'                                as formName,
      'CHW'                                       as staffType,
       replace( chwID, ' ', '' )                  as chwID, 
       replace ( meta_formVersion, ' ', '' )      as formVersion,
       meta_autoDate                              as formDate
       
from staging_odk_sickChildForm
;
-- union
-- select 'routinevisit' as tablename, chwID, 'unknown' as chwName, meta_formVersion from staging_odk_routinevisit
-- union
-- select 'arrivalcheck' as tablename, chwlID, 'unknown' as chwlName, meta_formVersion from staging_odk_arrivalchecklog
-- union
-- select 'departurecheck' as tablename, chwlID, 'unknown' as chwlName, meta_formVersion from staging_odk_departurechecklog
-- union
-- select 'healthsurvey' as tablename, chwID, 'unknown' as chwName, meta_formVersion from staging_odk_healthsurvey
-- union in children and  vaccine tables