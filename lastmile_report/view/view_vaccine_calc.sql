CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_vaccine_calc` AS
    SELECT 
        `view_vaccine_geo`.`county_id` AS `county_id`,
        `view_vaccine_geo`.`county` AS `county`,
        `view_vaccine_geo`.`health_district_id` AS `health_district_id`,
        `view_vaccine_geo`.`health_district` AS `health_district`,
        `view_vaccine_geo`.`community_id` AS `community_id`,
        `view_vaccine_geo`.`community` AS `community`,
        `view_vaccine_geo`.`vaccMonth` AS `vaccMonth`,
        `view_vaccine_geo`.`vaccYear` AS `vaccYear`,
        `view_vaccine_geo`.`childAge` AS `childAge`,
        (`view_vaccine_geo`.`childAge` BETWEEN 7 AND 364) AS `infantNeedsRound1`,
        (`view_vaccine_geo`.`childAge` BETWEEN 70 AND 364) AS `infantNeedsRound2`,
        (`view_vaccine_geo`.`childAge` BETWEEN 98 AND 364) AS `infantNeedsRound3`,
        (`view_vaccine_geo`.`childAge` BETWEEN 126 AND 364) AS `infantNeedsRound4`,
        (`view_vaccine_geo`.`childAge` BETWEEN 315 AND 364) AS `infantNeedsRound5`,
        (`view_vaccine_geo`.`childAge` > 364) AS `childNeedsAllRounds`,
        IF(((`view_vaccine_geo`.`vaccineBridge_opv0` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_bcg` <> 0)
                AND (`view_vaccine_geo`.`childAge` BETWEEN 7 AND 364)),
            1,
            0) AS `infantReceivedRound1`,
        IF(((`view_vaccine_geo`.`vaccineBridge_opv1` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_penta1` <> 0)
                AND (`view_vaccine_geo`.`childAge` BETWEEN 70 AND 364)),
            1,
            0) AS `infantReceivedRound2`,
        IF(((`view_vaccine_geo`.`vaccineBridge_opv2` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_penta2` <> 0)
                AND (`view_vaccine_geo`.`childAge` BETWEEN 98 AND 364)),
            1,
            0) AS `infantReceivedRound3`,
        IF(((`view_vaccine_geo`.`vaccineBridge_opv3` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_penta3` <> 0)
                AND (`view_vaccine_geo`.`childAge` BETWEEN 126 AND 364)),
            1,
            0) AS `infantReceivedRound4`,
        IF(((`view_vaccine_geo`.`vaccineBridge_yellowfever` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_measles` <> 0)
                AND (`view_vaccine_geo`.`childAge` BETWEEN 315 AND 364)),
            1,
            0) AS `infantReceivedRound5`,
        IF(((`view_vaccine_geo`.`vaccineBridge_penta1` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_penta2` <> 0)
                AND (`view_vaccine_geo`.`vaccineBridge_penta3` <> 0)
                AND (`view_vaccine_geo`.`childAge` BETWEEN 126 AND 364)),
            1,
            0) AS `infantReceivedPenta3`,
        `view_vaccine_geo`.`vaccineBridge_bcg` AS `vaccineBridge_bcg`,
        `view_vaccine_geo`.`vaccineBridge_opv0` AS `vaccineBridge_opv0`,
        `view_vaccine_geo`.`vaccineBridge_opv1` AS `vaccineBridge_opv1`,
        `view_vaccine_geo`.`vaccineBridge_rota1` AS `vaccineBridge_rota1`,
        `view_vaccine_geo`.`vaccineBridge_penta1` AS `vaccineBridge_penta1`,
        `view_vaccine_geo`.`vaccineBridge_pneumo1` AS `vaccineBridge_pneumo1`,
        `view_vaccine_geo`.`vaccineBridge_opv2` AS `vaccineBridge_opv2`,
        `view_vaccine_geo`.`vaccineBridge_rota2` AS `vaccineBridge_rota2`,
        `view_vaccine_geo`.`vaccineBridge_penta2` AS `vaccineBridge_penta2`,
        `view_vaccine_geo`.`vaccineBridge_pneumo2` AS `vaccineBridge_pneumo2`,
        `view_vaccine_geo`.`vaccineBridge_opv3` AS `vaccineBridge_opv3`,
        `view_vaccine_geo`.`vaccineBridge_rota3` AS `vaccineBridge_rota3`,
        `view_vaccine_geo`.`vaccineBridge_penta3` AS `vaccineBridge_penta3`,
        `view_vaccine_geo`.`vaccineBridge_pneumo3` AS `vaccineBridge_pneumo3`,
        `view_vaccine_geo`.`vaccineBridge_yellowfever` AS `vaccineBridge_yellowfever`,
        `view_vaccine_geo`.`vaccineBridge_measles` AS `vaccineBridge_measles`
    FROM
        `lastmile_report`.`view_vaccine_geo`