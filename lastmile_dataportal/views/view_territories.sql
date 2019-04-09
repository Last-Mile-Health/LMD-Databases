use lastmile_dataportal;

drop view if exists lastmile_dataportal.view_territories;

create view lastmile_dataportal.view_territories as

    SELECT 
        CONCAT('1_',
                `lastmile_cha`.`county`.`county_id`) AS `territory_id`,
        `lastmile_cha`.`county`.`county` AS `territory_name`,
        'county' AS `territory_type`
    FROM
        `lastmile_cha`.`county` 
    UNION SELECT 
        CONCAT('2_',
                `lastmile_cha`.`health_district`.`health_district_id`) AS `CONCAT('2_',health_district_id)`,
        `lastmile_cha`.`health_district`.`health_district` AS `health_district`,
        'health district' AS `territory_type`
    FROM
        `lastmile_cha`.`health_district` 
    UNION SELECT 
        CONCAT('3_',
                `lastmile_cha`.`district`.`district_id`) AS `CONCAT('3_',district_id)`,
        `lastmile_cha`.`district`.`district` AS `district`,
        'district' AS `territory_type`
    FROM
        `lastmile_cha`.`district` 
    UNION SELECT 
        CONCAT('4_',
                `lastmile_cha`.`health_facility`.`health_facility_id`) AS `CONCAT('4_',health_facility_id)`,
        `lastmile_cha`.`health_facility`.`health_facility` AS `health_facility`,
        'health facility' AS `territory_type`
    FROM
        `lastmile_cha`.`health_facility` 
    UNION SELECT 
        CONCAT('5_',
                `lastmile_cha`.`community`.`community_id`) AS `CONCAT('5_',community_id)`,
        `lastmile_cha`.`community`.`community` AS `community`,
        'community' AS `territory_type`
    FROM
        `lastmile_cha`.`community` 
    UNION SELECT 
        CONCAT('6_',
                `lastmile_dataportal`.`tbl_territories_other`.`territory_other_id`) AS `CONCAT('6_',territory_other_id)`,
        `lastmile_dataportal`.`tbl_territories_other`.`territory_name` AS `territory_name`,
        'other' AS `territory_type`
    FROM
        `lastmile_dataportal`.`tbl_territories_other`
    
     union
     
    select 

      concat( '7_', trim( q.position_id )  )                      as territory_id,
      concat( trim( q.position_id ), ': ', trim( q.last_name ) )  as territory_name,
      'QAO'                                                       as territory_type
      
    from lastmile_cha.view_position_qao_person as q
    ;