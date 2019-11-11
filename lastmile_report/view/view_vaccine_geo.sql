CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_vaccine_geo` AS
    SELECT 
        `b`.`county_id` AS `county_id`,
        `b`.`county` AS `county`,
        `b`.`health_district_id` AS `health_district_id`,
        `b`.`health_district` AS `health_district`,
        `b`.`community_id` AS `community_id`,
        `b`.`community` AS `community`,
        MONTH(`a`.`manualDate`) AS `vaccMonth`,
        YEAR(`a`.`manualDate`) AS `vaccYear`,
        (TO_DAYS(`a`.`manualDate`) - TO_DAYS(`a`.`childDOB`)) AS `childAge`,
        `a`.`vaccineBridge_bcg` AS `vaccineBridge_bcg`,
        `a`.`vaccineBridge_opv0` AS `vaccineBridge_opv0`,
        `a`.`vaccineBridge_opv1` AS `vaccineBridge_opv1`,
        `a`.`vaccineBridge_rota1` AS `vaccineBridge_rota1`,
        `a`.`vaccineBridge_penta1` AS `vaccineBridge_penta1`,
        `a`.`vaccineBridge_pneumo1` AS `vaccineBridge_pneumo1`,
        `a`.`vaccineBridge_opv2` AS `vaccineBridge_opv2`,
        `a`.`vaccineBridge_rota2` AS `vaccineBridge_rota2`,
        `a`.`vaccineBridge_penta2` AS `vaccineBridge_penta2`,
        `a`.`vaccineBridge_pneumo2` AS `vaccineBridge_pneumo2`,
        `a`.`vaccineBridge_opv3` AS `vaccineBridge_opv3`,
        `a`.`vaccineBridge_rota3` AS `vaccineBridge_rota3`,
        `a`.`vaccineBridge_penta3` AS `vaccineBridge_penta3`,
        `a`.`vaccineBridge_pneumo3` AS `vaccineBridge_pneumo3`,
        `a`.`vaccineBridge_yellowfever` AS `vaccineBridge_yellowfever`,
        `a`.`vaccineBridge_measles` AS `vaccineBridge_measles`
    FROM
        (`lastmile_report`.`view_vaccine_union` `a`
        JOIN `lastmile_cha`.`view_base_geo_community` `b` ON ((`a`.`communityID` = CONVERT( `b`.`community_id` USING UTF8))))