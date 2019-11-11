CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_odk_sickchild` AS
    SELECT 
        `b`.`county` AS `county`,
        `b`.`county_id` AS `county_id`,
        `lastmile_report`.`territory_id`(`b`.`county_id`, 1) AS `territory_id`,
        MONTH(`a`.`manualDate`) AS `month`,
        YEAR(`a`.`manualDate`) AS `year`,
        SUM(`a`.`treatMalaria`) AS `malaria_odk`,
        SUM(`a`.`treatDiarrhea`) AS `diarrhea_odk`,
        SUM(`a`.`treatPneumonia`) AS `ari_odk`
    FROM
        (`lastmile_upload`.`odk_sickChildForm` `a`
        LEFT JOIN `lastmile_report`.`mart_view_base_history_person_position` `b` ON (((`a`.`chwID` = `b`.`position_id`)
            AND (`a`.`manualDate` >= `b`.`position_person_begin_date`)
            AND ((`a`.`manualDate` <= `b`.`position_person_end_date`)
            OR ISNULL(`b`.`position_person_end_date`)))))
    WHERE
        ((`a`.`visitType` = 'initialVisit')
            AND (`b`.`county_id` IS NOT NULL))
    GROUP BY YEAR(`a`.`manualDate`) , MONTH(`a`.`manualDate`) , `b`.`county_id`
    ORDER BY YEAR(`a`.`manualDate`) , MONTH(`a`.`manualDate`) , `b`.`county_id`