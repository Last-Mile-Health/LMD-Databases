use lastmile_report;

drop view if exists view_vaccine_union;

create view view_vaccine_union as 
select
     
      meta_UUID,
      meta_autoDate,
      meta_dataEntry_startTime,
      meta_dataEntry_endTime,
      meta_dataSource,
      meta_formVersion,
      meta_deviceID,
      meta_uploadUser,
      meta_insertDatetime,
      
      chssID,
      SupervisedchaID,
      communityID,
      manualDate,
      childName,
      childDOB,
      childHHID,
      childGender,
      
      vaccineBridge_bcg,
      vaccineBridge_opv0,
      vaccineBridge_opv1,
      vaccineBridge_rota1,
      vaccineBridge_penta1,
      vaccineBridge_pneumo1,
      vaccineBridge_opv2,
      vaccineBridge_rota2,
      vaccineBridge_penta2,
      vaccineBridge_pneumo2,
      vaccineBridge_opv3,
      vaccineBridge_rota3,
      vaccineBridge_penta3,
      vaccineBridge_pneumo3,
      vaccineBridge_yellowfever,
      vaccineBridge_measles,
      bcgLocation,
      opv0Location,
      opv1Location,
      rota1Location,
      penta1Location,
      pneumo1Location,
      opv2Location,
      rota2Location,
      penta2Location,
      pneumo2Location,
      opv3Location,
      rota3Location,
      penta3Location,
      pneumo3Location,
      yellowfeverLocation,
      measlesLocation AS measlesLocation,
      'upload' AS source
      
from lastmile_upload.odk_vaccineTracker
/*  Filter out position IDs where the CHSSs and CHAs consciously did not know their IDs and entered 999s.  In Winter/Spring 2018, 
    we had over sixty new CHSSs and CHAs in Rivercess who did not have IDs (LMH or NCHAP) for months.  This wrecked havoc on our 
    reporting because records could not be tied together.  The decision was made to filter out all of the 999s for purposes of 
    reporting.
*/
where -- SupervisedchaID is not a null or emtpy string and it is not 999
      ( 
        not ( ( SupervisedchaID is null ) or ( trim( SupervisedchaID ) like '' )  ) and 
        not ( trim( SupervisedchaID ) like '999' )
      )
      and
      -- chssID is not a null or emtpy string and it is not 999
      ( 
        not ( ( chssID is null ) or ( trim( chssID ) like '' )  ) and 
        not ( trim( chssID ) like '999' )
      )

union all

select 
      meta_UUID,
      meta_autoDate,
      meta_dataEntry_startTime,
      meta_dataEntry_endTime,
      meta_dataSource,
      meta_formVersion,
      meta_deviceID,
      meta_uploadUser,
      meta_insertDatetime,
        
      null as chss_id,
      chwID,
      communityID,
      manualDate,
      childName,
      childDOB,
      childHHID,
      childGender,
        
      vaccineBridge_bcg,
      vaccineBridge_opv0,
      vaccineBridge_opv1,
      vaccineBridge_rota1,
      vaccineBridge_penta1,
      vaccineBridge_pneumo1,
      vaccineBridge_opv2,
      vaccineBridge_rota2,
      vaccineBridge_penta2,
      vaccineBridge_pneumo2,
      vaccineBridge_opv3,
      vaccineBridge_rota3,
      vaccineBridge_penta3,
      vaccineBridge_pneumo3,
      vaccineBridge_yellowfever,
      vaccineBridge_measles,
      bcgLocation,
      opv0Location,
      opv1Location,
      rota1Location,
      penta1Location,
      pneumo1Location,
      opv2Location,
      rota2Location,
      penta2Location,
      pneumo2Location,
      opv3Location,
      rota3Location,
      penta3Location,
      pneumo3Location,
      yellowfeverLocation,
      measlesLocation,
      'archive' AS archive
FROM lastmile_archive.chwdb_odk_vaccine_tracker
;  
