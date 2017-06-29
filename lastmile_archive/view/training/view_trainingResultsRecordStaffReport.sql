-- This is the base query for the traiining results record report of all
-- CCSs, CHWLs, CHWs that have been trained in the CHW[1-4] and LMA[1-4]
-- modules.  Training participants must have IDs that match a staffID in 
-- the admin_staff table.  Otherwise, the record will not be reported.

-- Put pop up parameters for trainingType, trainingDate, and county

use lastmile_archive;

drop view if exists view_trainingResultsRecordStaffReport;

create view view_trainingResultsRecordStaffReport as
select
      p.trainingResultsRecordID,
      -- If participantPosition is CHW, CHWL, or CCS then a particpantID is required and it needs to match
      -- staffID in the admin_staff table; otherwise, the record will be held in the data quality table until
      -- there is a matching staffID in the admin_staff table.  So use the name and gender in the admin table
      -- for reporting purposes.
      p.participantID                                         as staffID,
      concat( trim( s.firstName ), ' ', trim( s.lastName ) )  as staffName,
      trim( p.participantPosition )                           as participantPosition,
      s.gender,
      
      trim( p.trainingType )                                  as trainingType,
      trim( p.trainingName )                                  as trainingName,
      c.cohortID,
      c.cohort,
      c.county,
      p.trainingDate,
      trim( p.city )                                          as city,
      
      -- scores
      p.preTest,
      p.postTest,
      p.score_LV,
      p.score_K,
      p.score_PE,
      p.score_total,
      
      facilitatorName,
      facilitatorID,
      
      -- Tie record back to original form that was entered. formID is the same as
      -- trainingResultsRecordStep1ID in the staging_trainingResultsRecordStep1 
      -- table.  formRow is the row on the form data was captured in.
      p.formID,
      p.formRow,
      
		  case
          when a.staffID is null then 'no'
          else 'yes'
      end as active
      
from chwdb_program_trainingResultsRecord p
    inner join chwdb_admin_staff as s on p.participantID = s.staffID
    inner join view_staffIDCohortCounty as c on s.staffID = c.staffID
        left outer join view_staffActive as a on s.staffID = a.staffID
where trim( p.participantPosition ) in ( 'CHW', 'CHWL', 'CCS' )                             and
      not ( ( p.participantID is null ) or ( trim( p.participantID ) like '' ) )            and
      ( ( trim( p.trainingType ) like 'CHW%' ) or ( trim( p.trainingType ) like 'LMA%' ) )  and
      not ( ( p.trainingDate is null ) or ( trim( p.trainingDate ) like '' ) )
order by c.county asc, staffName asc, p.participantPosition asc, p.trainingType asc, p.trainingDate desc
;