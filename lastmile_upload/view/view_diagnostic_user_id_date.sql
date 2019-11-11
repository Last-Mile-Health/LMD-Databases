use lastmile_upload;

drop view if exists view_diagnostic_user_id_date;

create view view_diagnostic_user_id_date as

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date from odk_FieldArrivalLogForm            union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_FieldIncidentReportForm       union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_OSFKAPSurvey                  union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_QAOSupervisionChecklistForm   union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_QAO_CHSSQualityAssuranceForm  union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_chaRestock                    union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_communityEngagementLog        union all

select meta_uploadUser as user_id, convert( meta_insert_date_time,  date ) as insert_date  from odk_osf_routine                   union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_routineVisit                  union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_sickChildForm                 union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_supervisionVisitLog           union all

select meta_uploadUser as user_id, convert( meta_insertDatetime,    date ) as insert_date  from odk_vaccineTracker                union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_case_scenario                  union all

select meta_de_init    as user_id, convert( meta_insertDatetime,    date ) as insert_date  from de_chaHouseholdRegistration       union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_cha_monthly_service_report     union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_cha_status_change_form         union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_chss_commodity_distribution    union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_chss_monthly_service_report    union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_direct_observation             union all

select meta_de_init    as user_id, convert( meta_insert_date_time,  date ) as insert_date  from de_register_review
;