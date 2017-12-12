use lastmile_upload;

insert into odk_sickChildForm ( chwID, meta_uuid ) values ( '666', uuid() );
insert into odk_sickChildForm ( chwID, meta_uuid ) values ( null, uuid() );
    
insert into odk_chaRestock ( supervisedChaID, chaID, chssID, meta_uuid ) values ( '666', '667', '668', uuid() );
insert into odk_chaRestock ( supervisedChaID, chaID, chssID, meta_uuid ) values ( null, null, null, uuid() );

insert into odk_supervisionVisitLog ( supervisedCHAID, cha_id, chssID, chss_id, meta_uuid ) values ( '666', '667', '668', '669', uuid() );
insert into odk_supervisionVisitLog ( supervisedCHAID, cha_id, chssID, chss_id, meta_uuid ) values ( null, null, null, null, uuid() );

insert into odk_vaccineTracker ( SupervisedchaID, chssID, meta_uuid ) values ( '666', '667', uuid() );
insert into odk_vaccineTracker ( SupervisedchaID, chssID, meta_uuid ) values ( null, null, uuid() );

insert into odk_routineVisit ( chaID, meta_uuid ) values ( '666', uuid() );
insert into odk_routineVisit ( chaID, meta_uuid ) values ( null, uuid() );
    
insert into de_cha_monthly_service_report ( cha_id, chss_id, meta_uuid ) values ( '666', '667', uuid() );
insert into de_cha_monthly_service_report ( cha_id, chss_id, meta_uuid ) values ( null, null, uuid() );

insert into de_chaHouseholdRegistration ( chaID, chssID, meta_uuid ) values ( '666', '667', uuid() );
insert into de_chaHouseholdRegistration ( chaID, chssID, meta_uuid ) values ( null, null, uuid() );

insert into de_chss_monthly_service_report (  chss_id, cha_id_1, cha_id_2, cha_id_3, cha_id_4, cha_id_5, 
                                              cha_id_6, cha_id_7, cha_id_8, cha_id_9, cha_id_10, cha_id_11, 
                                              cha_id_12, cha_id_13, cha_id_14, meta_uuid ) 
values ( '660', '661', '662', '663', '664', '665', '666', '667', '668', '669', '670', '671', '672', '673', '674', uuid() );

insert into de_chss_monthly_service_report (  chss_id, cha_id_1, cha_id_2, cha_id_3, cha_id_4, cha_id_5, 
                                              cha_id_6, cha_id_7, cha_id_8, cha_id_9, cha_id_10, cha_id_11, 
                                              cha_id_12, cha_id_13, cha_id_14, meta_uuid ) 
values ( null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,  uuid() );

insert into de_chss_commodity_distribution ( chss_id, meta_uuid ) values ( '666', uuid() );
insert into de_chss_commodity_distribution ( chss_id, meta_uuid ) values ( null, uuid() );

insert into de_cha_status_change_form ( cha_id, chss_id, meta_uuid ) values ( '666', '667', uuid() );
insert into de_cha_status_change_form ( cha_id, chss_id, meta_uuid ) values ( null, null, uuid() );
 
insert into odk_communityEngagementLog ( data_collector_id, meta_uuid ) values ( '666', uuid() );
insert into odk_communityEngagementLog ( data_collector_id, meta_uuid ) values ( null, uuid() );
 
insert into odk_QAO_CHSSQualityAssuranceForm ( chss_id, meta_uuid ) values ( '666', uuid() );
insert into odk_QAO_CHSSQualityAssuranceForm ( chss_id, meta_uuid ) values ( null, uuid() );

insert into odk_FieldArrivalLogForm ( SupervisedCHAID, LMHID, meta_uuid ) values ( '666', '667', uuid() );
insert into odk_FieldArrivalLogForm ( SupervisedCHAID, LMHID, meta_uuid ) values ( null, null, uuid() );

insert into odk_FieldIncidentReportForm ( IDNumber, meta_uuid ) values ( '666', uuid() );
insert into odk_FieldIncidentReportForm ( IDNumber, meta_uuid ) values ( null, uuid() );

insert into de_register_review ( cha_id, chss_id, meta_uuid ) values ( '666', '667', uuid() );
insert into de_register_review ( cha_id, chss_id, meta_uuid ) values ( null, null, uuid() );

insert into de_direct_observation ( cha_id, chss_id, meta_uuid ) values ( '666', '667', uuid() );
insert into de_direct_observation ( cha_id, chss_id, meta_uuid ) values ( null, null, uuid() );

insert into de_case_scenario ( cha_id, chss_id, meta_uuid ) values ( '666', '667', uuid() );
insert into de_case_scenario ( cha_id, chss_id, meta_uuid ) values ( null, null, uuid() );

