CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_chss_tool_completion_chss` AS
    SELECT 
        `view_base_chss`.`county` AS `county`,
        `view_base_chss`.`position_id` AS `chss_id`,
        `view_base_chss`.`chss` AS `chss`,
        `a`.`month` AS `month`,
        `a`.`year` AS `year`
    FROM
        (`lastmile_cha`.`view_base_chss`
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_months` `a` ON ((1 = 1)))