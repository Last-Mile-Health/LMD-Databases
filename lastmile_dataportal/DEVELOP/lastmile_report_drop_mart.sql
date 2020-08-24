
-- data_mart_other.sql:

drop table if exists lastmile_report.mart_de_integrated_supervision_tool_community;

drop table if exists lastmile_report.mart_de_integrated_supervision_tool_community_spot_check;
drop table if exists lastmile_report.mart_de_integrated_supervision_tool_facility;
drop table if exists lastmile_report.mart_de_integrated_supervision_tool_facility_spot_check;
drop table if exists lastmile_report.mart_view_base_history_person;
drop table if exists lastmile_report.mart_view_base_history_person_position;
drop table if exists lastmile_report.mart_view_history_position_geo;
drop table if exists lastmile_report.mart_view_base_history_position;
drop table if exists lastmile_report.mart_view_base_restock_cha;
drop table if exists lastmile_report.mart_view_base_restock_chss;
drop table if exists lastmile_report.mart_view_base_odk_supervision;
drop table if exists lastmile_report.mart_view_base_ifi;
drop table if exists lastmile_report.mart_view_odk_sickchild;


-- data_mart_msr_1.sql

drop table if exists lastmile_report.mart_view_msr;
drop table if exists lastmile_report.mart_view_base_msr_county;
drop table if exists lastmile_report.mart_view_base_msr_community;

-- data_marts_msr_2.sql:
DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_healthdistrict;
DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_facility;


-- data_marts_msr_3.sql:
DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_chss;