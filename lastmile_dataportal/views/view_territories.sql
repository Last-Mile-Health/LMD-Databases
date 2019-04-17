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
    
    union
    
    select 
          concat('6_', t.territory_other_id) as `concat( '6_', territory_other_id )`,
      
          if( q.position_id is null, 
              t.territory_name, 
              -- concat( trim( q.position_id ), ': ', trim( coalesce( concat( q.first_name, ' ', q.last_name ), 'Unassigned' ) ) ) 
              -- concat( trim( q.position_id ), ': ', trim( coalesce( q.last_name, 'Unassigned' ) ) )
              -- concat( substring_index( trim( q.position_id ), '-', 1 ), ':', trim( coalesce( concat( q.first_name, ' ', q.last_name ), 'Unassigned' ) ) ) 
              -- concat( trim( q.position_id ), ': ', trim( coalesce( concat( substring( q.first_name, 1, 1 ), '. ', q.last_name ), 'Unassigned' ) ) ) 
          
              concat( trim( coalesce( concat( substring( q.first_name, 1, 1 ), '. ', q.last_name ), 'Unassigned' ) ), ' (', trim( q.position_id ), ')' )
           
          
          ) as territory_name,
          
          'other' AS territory_type
          
    from lastmile_dataportal.tbl_territories_other as t
        left outer join lastmile_cha.view_position_qao_person as q on trim( t.territory_name ) like trim( q.position_id )
;
