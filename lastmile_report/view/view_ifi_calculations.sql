use lastmile_report;

drop view if exists view_ifi_calculations;
create view view_ifi_calculations as 

select 
        a.county,
        b.county_id,
        
        month( str_to_date( concat( a.month_complete, '/', 
                                    valid_day_month_year( a.day_complete, a.month_complete, a.year_complete ), '/', 
                                    a.year_complete ), '%M/%e/%Y' ) )                                               as `month`,
                    
        a.year_complete                                                                                             as `year`,
        1                                                                                                           as numReports,
            
        str_to_date( concat(  a.month_complete, '/', 
                              valid_day_month_year( a.day_complete, a.month_complete, a.year_complete ), '/', 
                              a.year_complete), '%M/%e/%Y' )                                                        as visitDate,
              
        str_to_date( concat(  a.2_2_supply_restock_month_last,  '/', 
                              a.2_2_supply_restock_day_last,    '/', 
                              a.2_2_supply_restock_year_last ), '%M/%e/%Y')                                         as lastRestockDate,
                              
     
        -- Date survey completed minus last day restock.  If less than 31 days then restock happened in last month. 
        if( ( ( to_days( str_to_date( concat( a.month_complete,   '/',
                                              a.day_complete,     '/',
                                              a.year_complete ),  '%M/%e/%Y'
                                     )
                        )
                        
              - to_days( str_to_date( concat( a.2_2_supply_restock_month_last,  '/',
                                              a.2_2_supply_restock_day_last,    '/',
                                              a.2_2_supply_restock_year_last ), '%M/%e/%Y'
                                            )
                                    )
                        ) 
              <= 31
            ), 1, 0 
            
            ) as restockedInLastMonth,
        
        if( ( ( to_days( str_to_date( concat( a.month_complete, '/',
                                              a.day_complete,   '/',
                                              a.year_complete), '%M/%e/%Y'
                                            )
                                      ) 
              - to_days( str_to_date( concat( a.2_2_supply_restock_month_last,  '/',
                                              a.2_2_supply_restock_day_last,    '/',
                                              a.2_2_supply_restock_year_last),  '%M/%e/%Y'
                                            )
                                    )
                        ) 
                <= 93
            ), 1, 0 
          ) as restockedInLast3Months,
            
        if( ( a.3_1_supervision_chss_4_week >= 1 ), 1, 0 ) as supervisedLastMonth,
        
        if( ( ( a.4_1_incentive_correct_amount = 'Y' ) and ( a.4_2_incentive_on_time = 'Y' ) ), 1, 0 ) as receivedLastIncentiveOnTime,
          
        if( 
            ( trim( a.2_1_f_supply_act_25_67_5_mg_tablet_in_stock  ) like 'Y' or 
              trim( a.2_1_g_supply_act_50_135_mg_tablet_in_stock              ) like 'Y'  
            )
            
            and          
            
            trim( a.2_1_i_supply_amox_250_mg_dispersible_tablet_in_stock ) like 'Y' 
            
            and
            
            trim( a.2_1_j_supply_ors_20_6_1l_sachet_in_stock ) like 'Y' 
            
            and
            
            trim( a.2_1_k_supply_zinc_sulfate_20_mg_scored_tablet_in_stock ) like 'Y' 
            ,
            1,
            0 ) as life_saving_in_stock,
                   
        if( trim( a.2_1_g_supply_act_50_135_mg_tablet_in_stock ) like 'Y', 1, 0 ) as act_50_135_mg_tablet_in_stock        
   
    from lastmile_report.mart_de_integrated_supervision_tool_community as a
        left outer join lastmile_cha.county as b on  convert( a.county using UTF8) = b.county
;