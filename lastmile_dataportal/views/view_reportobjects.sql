CREATE ALGORITHM=UNDEFINED VIEW `lastmile_dataportal`.`view_reportobjects` AS select `lastmile_dataportal`.`tbl_reportobjects`.`id` AS `id`,`lastmile_dataportal`.`tbl_reports`.`reportID` AS `reportID`,`lastmile_dataportal`.`tbl_reports`.`reportName` AS `reportName`,`lastmile_dataportal`.`tbl_reportobjects`.`displayOrder` AS `displayOrder`,`lastmile_dataportal`.`tbl_reportobjects`.`roMetaData_target` AS `roMetadata_target`,`lastmile_dataportal`.`tbl_reportobjects`.`roMetadata_narrative` AS `roMetadata_narrative`,if((isnull(`lastmile_dataportal`.`tbl_reportobjects`.`roMetadata_name`) or (`lastmile_dataportal`.`tbl_reportobjects`.`roMetadata_name` = '')),`view_instances`.`indName`,`lastmile_dataportal`.`tbl_reportobjects`.`roMetadata_name`) AS `roName` from ((`lastmile_dataportal`.`tbl_reports` join `lastmile_dataportal`.`tbl_reportobjects` on((`lastmile_dataportal`.`tbl_reports`.`reportID` = `lastmile_dataportal`.`tbl_reportobjects`.`reportID`))) join `lastmile_dataportal`.`view_instances` on((substring_index(`lastmile_dataportal`.`tbl_reportobjects`.`instIDs`,',',1) = `view_instances`.`instID`)));
