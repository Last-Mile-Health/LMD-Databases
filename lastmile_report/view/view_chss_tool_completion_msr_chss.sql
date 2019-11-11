CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_chss_tool_completion_msr_chss` AS
    SELECT 
        `lastmile_upload`.`de_chss_monthly_service_report`.`chss_id` AS `chss_id`,
        `lastmile_upload`.`de_chss_monthly_service_report`.`month_reported` AS `month_reported`,
        `lastmile_upload`.`de_chss_monthly_service_report`.`year_reported` AS `year_reported`,
        1 AS `num_chss_msrs`
    FROM
        `lastmile_upload`.`de_chss_monthly_service_report`
    GROUP BY `lastmile_upload`.`de_chss_monthly_service_report`.`chss_id` , `lastmile_upload`.`de_chss_monthly_service_report`.`month_reported` , `lastmile_upload`.`de_chss_monthly_service_report`.`year_reported`