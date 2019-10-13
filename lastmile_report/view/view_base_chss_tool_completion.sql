use lastmile_report;

drop view if exists lastmile_report.view_base_chss_tool_completion;

CREATE VIEW `lastmile_report`.`view_base_chss_tool_completion` AS
    SELECT 
        `a`.`county` AS `county`,
        `a`.`chss_id` AS `chss_id`,
        `a`.`chss` AS `chss`,
        `a`.`month` AS `month`,
        `a`.`year` AS `year`,
        COALESCE(`b`.`num_supervision_visit_logs`, 0) AS `num_supervision_visit_logs`,
        COALESCE(`c`.`num_vaccine_trackers`, 0) AS `num_vaccine_trackers`,
        COALESCE(`d`.`num_chss_msrs`, 0) AS `num_chss_msrs`,
        COALESCE(`e`.`num_cha_msrs`, 0) AS `num_cha_msrs`,
        COALESCE(`f`.`num_restock_forms`, 0) AS `num_restock_forms`,
        COALESCE(`g`.`num_cha`, 0) AS `num_cha`
    FROM
        ((((((`lastmile_report`.`view_chss_tool_completion_chss` `a`
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_sup` `b` ON (((`a`.`chss_id` = `b`.`chss_id`)
            AND (`a`.`month` = `b`.`month`)
            AND (`a`.`year` = `b`.`year`))))
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_vac` `c` ON (((`a`.`chss_id` = `c`.`chss_id`)
            AND (`a`.`month` = `c`.`month`)
            AND (`a`.`year` = `c`.`year`))))
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_msr_chss` `d` ON (((`a`.`chss_id` = `d`.`chss_id`)
            AND (`a`.`month` = `d`.`month_reported`)
            AND (`a`.`year` = `d`.`year_reported`))))
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_msr_cha` `e` ON (((`a`.`chss_id` = `e`.`chss_id`)
            AND (`a`.`month` = `e`.`month_reported`)
            AND (`a`.`year` = `e`.`year_reported`))))
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_restock` `f` ON (((`a`.`chss_id` = `f`.`chss_id`)
            AND (`a`.`month` = `f`.`month`)
            AND (`a`.`year` = `f`.`year`))))
        LEFT JOIN `lastmile_report`.`view_chss_tool_completion_cha` `g` ON ((`a`.`chss_id` = `g`.`chss_id`)))