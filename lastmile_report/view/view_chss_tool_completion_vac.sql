CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_chss_tool_completion_vac` AS
    SELECT 
        `lastmile_upload`.`odk_vaccineTracker`.`chssID` AS `chss_id`,
        YEAR(`lastmile_upload`.`odk_vaccineTracker`.`meta_autoDate`) AS `year`,
        MONTH(`lastmile_upload`.`odk_vaccineTracker`.`meta_autoDate`) AS `month`,
        COUNT(`lastmile_upload`.`odk_vaccineTracker`.`meta_UUID`) AS `num_vaccine_trackers`
    FROM
        `lastmile_upload`.`odk_vaccineTracker`
    WHERE
        (`lastmile_upload`.`odk_vaccineTracker`.`chssID` <> '')
    GROUP BY `year` , `month` , `chss_id`