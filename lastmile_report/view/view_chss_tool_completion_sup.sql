CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_chss_tool_completion_sup` AS
    SELECT 
        `lastmile_archive`.`staging_odk_supervisionvisitlog`.`ccsID` AS `chss_id`,
        YEAR(`lastmile_archive`.`staging_odk_supervisionvisitlog`.`manualDate`) AS `year`,
        MONTH(`lastmile_archive`.`staging_odk_supervisionvisitlog`.`manualDate`) AS `month`,
        COUNT(`lastmile_archive`.`staging_odk_supervisionvisitlog`.`meta_UUID`) AS `num_supervision_visit_logs`
    FROM
        `lastmile_archive`.`staging_odk_supervisionvisitlog`
    WHERE
        (`lastmile_archive`.`staging_odk_supervisionvisitlog`.`ccsID` <> '')
    GROUP BY `year` , `month` , `chss_id` 
    UNION SELECT 
        `lastmile_upload`.`odk_supervisionVisitLog`.`chssID` AS `chss_id`,
        YEAR(`lastmile_upload`.`odk_supervisionVisitLog`.`manualDate`) AS `year`,
        MONTH(`lastmile_upload`.`odk_supervisionVisitLog`.`manualDate`) AS `month`,
        COUNT(`lastmile_upload`.`odk_supervisionVisitLog`.`meta_UUID`) AS `num_supervision_visit_logs`
    FROM
        `lastmile_upload`.`odk_supervisionVisitLog`
    WHERE
        ((`lastmile_upload`.`odk_supervisionVisitLog`.`chssID` <> '')
            AND (`lastmile_upload`.`odk_supervisionVisitLog`.`meta_fabricated` <> 1))
    GROUP BY `year` , `month` , `lastmile_upload`.`odk_supervisionVisitLog`.`chssID`