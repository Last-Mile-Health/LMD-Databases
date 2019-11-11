CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_base_vaccine` AS
    SELECT 
        `view_vaccine_calc`.`county_id` AS `county_id`,
        `view_vaccine_calc`.`county` AS `county`,
        `view_vaccine_calc`.`health_district_id` AS `health_district_id`,
        `view_vaccine_calc`.`health_district` AS `health_district`,
        `view_vaccine_calc`.`community_id` AS `community_id`,
        `view_vaccine_calc`.`community` AS `community`,
        `view_vaccine_calc`.`vaccMonth` AS `vaccMonth`,
        `view_vaccine_calc`.`vaccYear` AS `vaccYear`,
        `view_vaccine_calc`.`childAge` AS `childAge`,
        `view_vaccine_calc`.`infantNeedsRound1` AS `infantNeedsRound1`,
        `view_vaccine_calc`.`infantNeedsRound2` AS `infantNeedsRound2`,
        `view_vaccine_calc`.`infantNeedsRound3` AS `infantNeedsRound3`,
        `view_vaccine_calc`.`infantNeedsRound4` AS `infantNeedsRound4`,
        `view_vaccine_calc`.`infantNeedsRound5` AS `infantNeedsRound5`,
        `view_vaccine_calc`.`childNeedsAllRounds` AS `childNeedsAllRounds`,
        `view_vaccine_calc`.`infantReceivedRound1` AS `infantReceivedRound1`,
        `view_vaccine_calc`.`infantReceivedRound2` AS `infantReceivedRound2`,
        `view_vaccine_calc`.`infantReceivedRound3` AS `infantReceivedRound3`,
        `view_vaccine_calc`.`infantReceivedRound4` AS `infantReceivedRound4`,
        `view_vaccine_calc`.`infantReceivedRound5` AS `infantReceivedRound5`,
        `view_vaccine_calc`.`infantReceivedPenta3` AS `infantReceivedPenta3`,
        `view_vaccine_calc`.`vaccineBridge_bcg` AS `vaccineBridge_bcg`,
        `view_vaccine_calc`.`vaccineBridge_opv0` AS `vaccineBridge_opv0`,
        `view_vaccine_calc`.`vaccineBridge_opv1` AS `vaccineBridge_opv1`,
        `view_vaccine_calc`.`vaccineBridge_rota1` AS `vaccineBridge_rota1`,
        `view_vaccine_calc`.`vaccineBridge_penta1` AS `vaccineBridge_penta1`,
        `view_vaccine_calc`.`vaccineBridge_pneumo1` AS `vaccineBridge_pneumo1`,
        `view_vaccine_calc`.`vaccineBridge_opv2` AS `vaccineBridge_opv2`,
        `view_vaccine_calc`.`vaccineBridge_rota2` AS `vaccineBridge_rota2`,
        `view_vaccine_calc`.`vaccineBridge_penta2` AS `vaccineBridge_penta2`,
        `view_vaccine_calc`.`vaccineBridge_pneumo2` AS `vaccineBridge_pneumo2`,
        `view_vaccine_calc`.`vaccineBridge_opv3` AS `vaccineBridge_opv3`,
        `view_vaccine_calc`.`vaccineBridge_rota3` AS `vaccineBridge_rota3`,
        `view_vaccine_calc`.`vaccineBridge_penta3` AS `vaccineBridge_penta3`,
        `view_vaccine_calc`.`vaccineBridge_pneumo3` AS `vaccineBridge_pneumo3`,
        `view_vaccine_calc`.`vaccineBridge_yellowfever` AS `vaccineBridge_yellowfever`,
        `view_vaccine_calc`.`vaccineBridge_measles` AS `vaccineBridge_measles`,
        IF(((`view_vaccine_calc`.`childAge` > 7)
                AND (`view_vaccine_calc`.`childAge` < 365)),
            IF((((((((1 + `view_vaccine_calc`.`infantReceivedRound1`) - `view_vaccine_calc`.`infantNeedsRound1`) * ((1 + `view_vaccine_calc`.`infantReceivedRound2`) - `view_vaccine_calc`.`infantNeedsRound2`)) * ((1 + `view_vaccine_calc`.`infantReceivedRound3`) - `view_vaccine_calc`.`infantNeedsRound3`)) * ((1 + `view_vaccine_calc`.`infantReceivedRound4`) - `view_vaccine_calc`.`infantNeedsRound4`)) * ((1 + `view_vaccine_calc`.`infantReceivedRound5`) - `view_vaccine_calc`.`infantNeedsRound5`)) > 0),
                1,
                0),
            NULL) AS `onTrack`,
        IF(((`view_vaccine_calc`.`childAge` >= 126)
                AND (`view_vaccine_calc`.`childAge` < 365)),
            IF((`view_vaccine_calc`.`infantReceivedPenta3` <> 0),
                1,
                0),
            NULL) AS `penta3`
    FROM
        `lastmile_report`.`view_vaccine_calc`