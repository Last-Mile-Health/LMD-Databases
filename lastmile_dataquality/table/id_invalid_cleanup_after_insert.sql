use lastmile_dataquality;

drop trigger if exists lastmile_dataquality.id_invalid_cleanup_after_insert;

delimiter //
create trigger lastmile_dataquality.id_invalid_cleanup_after_insert after insert
    on lastmile_dataquality.id_invalid_cleanup for each row
begin

case

    -- 1. de_case_scenario_2 ----------------------------------------------------

    when  trim( new.table_name )  like 'de_case_scenario_2'             and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chss_id'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_case_scenario_2 as u
              set u.chss_id_inserted  = new.id_repair
          where u.de_case_scenario_2_id = new.pk_id;
    
         
    when  trim( new.table_name )  like 'de_case_scenario_2'             and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id'                         and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_case_scenario_2 as u
              set u.cha_id_inserted   = new.id_repair
          where u.de_case_scenario_2_id = new.pk_id;
     
    -- 2. de_case_scenario ----------------------------------------------------

    when  trim( new.table_name )  like 'de_case_scenario'               and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chss_id'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_case_scenario as u
              set u.chss_id_inserted  = new.id_repair
          where u.de_case_scenario_id = new.pk_id;
    
         
    when  trim( new.table_name )  like 'de_case_scenario'               and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id'                         and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_case_scenario as u
              set u.cha_id_inserted   = new.id_repair
          where u.de_case_scenario_id = new.pk_id;
     

    -- 3.  ------------------------------------------

    when  trim( new.table_name )  like 'de_chaHouseholdRegistration'    and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chssID'                         and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chaHouseholdRegistration as u
              set u.chss_id_inserted  = new.id_repair
          where u.chaHouseholdRegistrationID = new.pk_id;
    
         
    when  trim( new.table_name )  like 'de_chaHouseholdRegistration'    and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'chaID'                          and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chaHouseholdRegistration as u
              set u.cha_id_inserted   = new.id_repair
          where u.chaHouseholdRegistrationID = new.pk_id;
     

    -- 4. CHA Monthly Service Report ------------------------------------------
    
    when  trim( new.table_name )  like 'de_cha_monthly_service_report'  and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chss_id'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_cha_monthly_service_report as u
              set u.chss_id_inserted = new.id_repair
          where u.cha_monthly_service_report_id = new.pk_id;
    
         
    when  trim( new.table_name )  like 'de_cha_monthly_service_report'  and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id'                         and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_cha_monthly_service_report as u
              set u.cha_id_inserted = new.id_repair
          where u.cha_monthly_service_report_id = new.pk_id;
     
 
    -- 5. de_chss_commodity_distribution ---------------------------------------
 
    when  trim( new.table_name )  like 'de_chss_commodity_distribution' and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chss_id'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_commodity_distribution as u
              set u.chss_id_inserted = new.id_repair
          where u.chss_commodity_distribution_id = new.pk_id;
    
  
    -- 6. CHSS Monthly Service Report ------------------------------------------
          
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chss_id'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.chss_id_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_1'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_1_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
 
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_2'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_2_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_3'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_3_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_4'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_4_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_5'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_5_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_6'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_6_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_7'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_7_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_8'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_8_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_9'                       and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_9_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_10'                      and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_10_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_11'                      and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_11_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_12'                      and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_12_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_13'                      and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_13_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
    
    
    when  trim( new.table_name )  like 'de_chss_monthly_service_report' and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'cha_id_14'                      and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.de_chss_monthly_service_report as u
              set u.cha_id_14_inserted = new.id_repair
          where u.chss_monthly_service_report_id = new.pk_id;
   
         
    -- 7. odk_chaRestock  ------------------------------------------
    
    when  trim( new.table_name )  like 'odk_chaRestock'                 and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chssID'                         and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_chaRestock as u
              set u.chss_id_inserted = new.id_repair
          where u.chaRestockID = new.pk_id;
   
    
    when  trim( new.table_name )  like 'odk_chaRestock'                 and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'user_id'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_chaRestock as u
              set u.user_id_inserted = new.id_repair
          where u.chaRestockID = new.pk_id;
   
         
    when  trim( new.table_name )  like 'odk_chaRestock'                 and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'chaID'                          and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_chaRestock as u
              set u.cha_id_inserted = new.id_repair
          where u.chaRestockID = new.pk_id;
 
         
    when  trim( new.table_name )  like 'odk_chaRestock'                 and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'supervisedChaID'                and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_chaRestock as u
              set u.supervised_cha_id_inserted = new.id_repair
          where u.chaRestockID = new.pk_id;
      
    
    -- 8. odk_routineVisit ------------------------------------------
     
    when  trim( new.table_name )  like 'odk_routineVisit'               and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'chaID'                          and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_routineVisit as u
              set u.cha_id_inserted = new.id_repair
          where u.routineVisitID = new.pk_id;
     
   
    -- 9. odk_sickChildForm ------------------------------------------

    when  trim( new.table_name )  like 'odk_sickChildForm'        and 
          trim( new.id_type )     like 'cha'                      and 
          trim( new.id_name )     like 'chwID'                    and 
          not ( new.id_repair is null )                           and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_sickChildForm as u
              set u.cha_id_inserted   = new.id_repair
          where u.sickChildFormID = new.pk_id;
       
    
    -- 10. odk_supervisionVisitLog ------------------------------------------
    
    when  trim( new.table_name )  like 'odk_supervisionVisitLog'        and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chssID'                        and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_supervisionVisitLog as u
              set u.chss_id_orig_inserted  = new.id_repair
          where u.supervisionVisitLogID = new.pk_id;
    
         
    when  trim( new.table_name )  like 'odk_supervisionVisitLog'        and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'supervisedCHAID'                and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_supervisionVisitLog as u
              set u.supervised_cha_id_inserted   = new.id_repair
          where u.supervisionVisitLogID = new.pk_id;
          
          
        
    -- 11. odk_vaccineTracker  ------------------------------------------
    
    when  trim( new.table_name )  like 'odk_vaccineTracker'             and 
          trim( new.id_type )     like 'chss'                           and 
          trim( new.id_name )     like 'chssID'                         and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_vaccineTracker as u
              set u.chss_id_inserted  = new.id_repair
          where u.vaccineTrackerID = new.pk_id;
    
         
    when  trim( new.table_name )  like 'odk_vaccineTracker'             and 
          trim( new.id_type )     like 'cha'                            and 
          trim( new.id_name )     like 'SupervisedchaID'                and 
          not ( new.id_repair is null )                                 and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_vaccineTracker as u
              set u.cha_id_inserted   = new.id_repair
          where u.vaccineTrackerID = new.pk_id;
          
          
    -- 12. odk_QAOSupervisionChecklistForm ------------------------------------------
        
    
    when  trim( new.table_name )  like 'odk_QAOSupervisionChecklistForm'  and 
          trim( new.id_type )     like 'chss'                             and 
          trim( new.id_name )     like 'CHSSID'                           and 
          not ( new.id_repair is null )                                   and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_QAOSupervisionChecklistForm as u
              set u.chss_id_inserted  = new.id_repair
          where u.odk_QAOSupervisionChecklistForm_id = new.pk_id;
    
         
    when  trim( new.table_name )  like 'odk_QAOSupervisionChecklistForm'  and 
          trim( new.id_type )     like 'cha'                              and 
          trim( new.id_name )     like 'CHAID'                            and 
          not ( new.id_repair is null )                                   and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_QAOSupervisionChecklistForm as u
              set u.cha_id_inserted   = new.id_repair
          where u.odk_QAOSupervisionChecklistForm_id = new.pk_id;
      
              
    -- 13. odk_QCA_GPSForm ------------------------------------------
                 
    when  trim( new.table_name )  like 'odk_QCA_GPSForm'  and 
          trim( new.id_type )     like 'cha'                              and 
          trim( new.id_name )     like 'Cha_id'                           and 
          not ( new.id_repair is null )                                   and
          not ( new.pk_id     is null )
         
    then
          update lastmile_upload.odk_QCA_GPSForm as u
              set u.cha_id_inserted   = new.id_repair
          where u.odk_QCA_GPSForm_id = new.pk_id;
  
  
    -- else fall through
end case
;
  
end
//

delimiter ;
