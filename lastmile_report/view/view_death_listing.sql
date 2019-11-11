CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_death_listing` AS
    SELECT 
        `view_base_msr`.`year_reported` AS `Year`,
        `view_base_msr`.`month_reported` AS `Month`,
        `view_base_msr`.`county` AS `County`,
        `view_base_msr`.`health_facility` AS `Health Facility`,
        CONCAT(`view_base_msr`.`cha_name`,
                ' (',
                `view_base_msr`.`cha_id`,
                ')') AS `CHA`,
        CONCAT(`view_base_msr`.`community`,
                ' (',
                `view_base_msr`.`community_id`,
                ')') AS `Community`,
        TRIM(TRAILING ', ' FROM CONCAT(IF(`view_base_msr`.`num_stillbirths`,
                        CONCAT('stillbirth: ',
                                `view_base_msr`.`num_stillbirths`,
                                ', '),
                        ''),
                    IF(`view_base_msr`.`num_deaths_neonatal`,
                        CONCAT('neonatal: ',
                                `view_base_msr`.`num_deaths_neonatal`,
                                ', '),
                        ''),
                    IF(`view_base_msr`.`num_deaths_postneonatal`,
                        CONCAT('postneonatal: ',
                                `view_base_msr`.`num_deaths_postneonatal`,
                                ', '),
                        ''),
                    IF(`view_base_msr`.`num_deaths_child`,
                        CONCAT('child: ',
                                `view_base_msr`.`num_deaths_child`,
                                ', '),
                        ''),
                    IF(`view_base_msr`.`num_deaths_maternal`,
                        CONCAT('maternal: ',
                                `view_base_msr`.`num_deaths_maternal`,
                                ', '),
                        ''))) AS `Deaths`
    FROM
        `lastmile_report`.`view_base_msr`
    WHERE
        ((`view_base_msr`.`num_stillbirths`
            OR `view_base_msr`.`num_deaths_neonatal`
            OR `view_base_msr`.`num_deaths_postneonatal`
            OR `view_base_msr`.`num_deaths_child`
            OR `view_base_msr`.`num_deaths_maternal`)
            AND (`view_base_msr`.`year_reported` IS NOT NULL)
            AND (`view_base_msr`.`month_reported` IS NOT NULL))
    ORDER BY `view_base_msr`.`year_reported` DESC , `view_base_msr`.`month_reported` DESC , `view_base_msr`.`county` , `view_base_msr`.`health_facility`