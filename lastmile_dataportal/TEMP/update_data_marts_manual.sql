
-- call updateDataMarts();
-- Run procedure calls


DROP TABLE IF EXISTS lastmile_report.mart_de_integrated_supervision_tool_community;
CREATE TABLE lastmile_report.mart_de_integrated_supervision_tool_community as SELECT * FROM lastmile_liberiamohdata.federated_de_integrated_supervision_tool_community;

DROP TABLE IF EXISTS lastmile_report.mart_de_integrated_supervision_tool_community_spot_check;
CREATE TABLE lastmile_report.mart_de_integrated_supervision_tool_community_spot_check as SELECT * FROM lastmile_liberiamohdata.federated_de_integrated_supervision_tool_community_spot_check;

DROP TABLE IF EXISTS lastmile_report.mart_de_integrated_supervision_tool_facility;
CREATE TABLE lastmile_report.mart_de_integrated_supervision_tool_facility as SELECT * FROM lastmile_liberiamohdata.federated_de_integrated_supervision_tool_facility;

DROP TABLE IF EXISTS lastmile_report.mart_de_integrated_supervision_tool_facility_spot_check;
CREATE TABLE lastmile_report.mart_de_integrated_supervision_tool_facility_spot_check as SELECT * FROM lastmile_liberiamohdata.federated_de_integrated_supervision_tool_facility_spot_check;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_history_person;
CREATE TABLE lastmile_report.mart_view_base_history_person SELECT * FROM lastmile_cha.view_base_history_person;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_history_person_position;
CREATE TABLE lastmile_report.mart_view_base_history_person_position SELECT * FROM lastmile_cha.view_base_history_person_position;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_restock_cha;
CREATE TABLE lastmile_report.mart_view_base_restock_cha SELECT * FROM lastmile_report.view_base_restock_cha;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_odk_supervision;
CREATE TABLE lastmile_report.mart_view_base_odk_supervision SELECT * FROM lastmile_report.view_base_odk_supervision;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_ifi;
CREATE TABLE lastmile_report.mart_view_base_ifi SELECT * FROM lastmile_report.view_base_ifi;

drop table if exists lastmile_report.mart_view_msr;
create table lastmile_report.mart_view_msr as select * from lastmile_report.view_msr;


DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_county;
CREATE TABLE lastmile_report.mart_view_base_msr_county SELECT * FROM lastmile_report.view_base_msr_county;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_community;
CREATE TABLE lastmile_report.mart_view_base_msr_community SELECT * FROM lastmile_report.view_base_msr_community;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_healthdistrict;
CREATE TABLE lastmile_report.mart_view_base_msr_healthdistrict SELECT * FROM lastmile_report.view_base_msr_healthdistrict;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_facility;
CREATE TABLE lastmile_report.mart_view_base_msr_facility SELECT * FROM lastmile_report.view_base_msr_facility;

DROP TABLE IF EXISTS lastmile_report.mart_view_base_msr_chss;
CREATE TABLE lastmile_report.mart_view_base_msr_chss SELECT * FROM lastmile_report.view_base_msr_chss;


DROP TABLE IF EXISTS lastmile_report.mart_view_odk_sickchild;
CREATE TABLE lastmile_report.mart_view_odk_sickchild SELECT * FROM lastmile_report.view_odk_sickchild;



