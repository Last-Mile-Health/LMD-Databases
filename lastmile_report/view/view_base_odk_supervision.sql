use lastmile_report;

drop view if exists lastmile_report.view_base_odk_supervision;

create view lastmile_report.view_base_odk_supervision as

select
      ( year(a.manualDate) * 10000 ) + ( month(a.manualDate) * 100 ) + 1  as date_key,
          
        b.county_id AS county_id,
        lastmile_report.territory_id(b.county_id, 1) AS territory_id,
        
        b.county,
        MONTH(a.manualDate) AS manualMonth,
        YEAR(a.manualDate) AS manualYear,
        
        a.supervisionVisitLogID,
        a.meta_UUID,
        a.meta_autoDate,
        a.meta_dataEntry_startTime,
        a.meta_dataEntry_endTime,
        a.meta_dataSource,
        a.meta_formVersion,
        a.meta_deviceID,
        a.meta_uploadUser,
        a.meta_insertDatetime,
        a.gpsCoordinate,
        a.noGPSReason,
        
        trim( a.chssID )                                        as chssID,
        
        a.manualDate,
        a.timeOfArrival,
        
        trim( a.supervisedCHAID )                               as supervisedCHAID,
        
        a.communityID,
        a.supervisionAttendance,
        a.chaExcusedAbsence,
        a.reasonCHAAbsence,
        a.restockedCHA,
        a.formReviewCorrectTreatment,
        a.formReviewIncorrectTreatment,
        a.patientAudit,
        a.patientAuditResult,
        a.CHAhasDCT,
        a.noDCTReason,
        a.DCTCharge,
        a.correctDate,
        a.ReportedmHealthProblems,
        a.mHealthProblemDescription,
        a.disciplinaryAction,
        a.disciplinaryActionDescription,
        a.fieldEmergencies,
        a.fieldEmergencyDescription
        
from lastmile_upload.odk_supervisionVisitLog a
    left outer join lastmile_ncha.view_base_history_position as b on trim( a.supervisedCHAID ) like  b.position_id
where a.meta_fabricated <> 1
;
/* Owen: Again, I don't think we need to be checking date ranges for IDs.  There's going to be spillover from
         month-to-month
    left outer join lastmile_report.mart_view_base_history_person_position b ON 
        
        ( trim( a.supervisedCHAID ) like  b.position_id ) and
        ( a.manualDate >= b.position_person_begin_date  ) and
        ( isnull( b.position_person_end_date ) or ( a.manualDate <= b.position_person_end_date ) )          
*/


            
            
            
            