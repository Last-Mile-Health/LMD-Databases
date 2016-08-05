use lastmile_chwdb;

drop view if exists view_odkSickChildTreatmentVisitSummary;

create view view_odkSickChildTreatmentVisitSummary as

select

      replace( s.chwID, '-', '' ) as chwID,
      replace( s.HHID, '-', '' )  as HHID,
      s.memberInitials,
      s.visitType,
      s.meta_autoDate, 
      s.manualDate,
      if( s.manualDate like s.meta_autoDate, 'yes', 'no' ) as dateMatch,
      l.staffName,
      l.district,
      l.healthDistrict,
      l.healthFacility,
      l.county
          
from staging_odk_sickChildForm as s
      left outer join view_staffTypeLocation as l on ( s.chwID = l.staffID ) and ( l.staffType like 'CHW' )

where
      not ( ( ( trim( s.chwID ) like '' ) or ( s.chwID is null ) ) or
          ( ( trim( s.HHID ) like '' ) or ( s.HHID is null ) ) or
          ( ( trim( s.manualDate ) like '' ) or ( s.manualDate is null ) ) or
          ( ( trim( s.meta_autoDate ) like '' ) or ( s.meta_autoDate is null ) ) ) and
          ( ( trim( s.treatPneumonia ) = '1' )  or
          ( trim( s.treatMalaria ) = '1' )    or
          ( trim( s.treatDiarrhea ) = '1' ) ) and
          
          ( cast( replace( s.chwID, '-', '' ) as unsigned ) > 0 ) and 
          ( cast( replace( s.HHID, '-', '' ) as unsigned ) > 0 )

order by
      s.chwID asc,
      s.HHID asc,
      s.memberInitials asc,
      s.visitType asc,
      s.meta_autoDate desc,
      s.manualDate desc;