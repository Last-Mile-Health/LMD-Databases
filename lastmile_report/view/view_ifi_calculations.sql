use lastmile_report;

-- Note:  In the ifi database the dates are broken up into three discrete fields.
--        Month is the full name. e.g. January, February,...
--        Day is an integer between 1 and 31
--        Years is an integer between 2017 and 2030
--
--        If a day in the month falls outside the parameters of a valid date (Feb 29 in a non leap year, for example) then
--        the function valid_day_month_year sets the day to the last valid day in a month.  One minor issue we have been 
--        having is when data entry folks enter the current month instead of the month the ifi form was filled out.

drop view if exists view_ifi_calculations;
create view view_ifi_calculations as 

select 
        a.county,
        b.county_id,
        
        month( str_to_date( concat( trim( a.month_complete ), '/', 
                                    valid_day_month_year( trim( a.day_complete ), trim( a.month_complete ), trim( a.year_complete ) ), '/', 
                                    trim( a.year_complete ) ), '%M/%e/%Y' ) )                                               as `month`,
                    
        trim( a.year_complete )                                                                                             as `year`,
        1                                                                                                           as numReports,
            
        str_to_date( concat(  trim( a.month_complete ), '/', 
                              valid_day_month_year( trim( a.day_complete ), trim( a.month_complete ), trim( a.year_complete ) ), '/', 
                              trim( a.year_complete )), '%M/%e/%Y' )                                                        as visitDate,
              
        str_to_date( concat(  trim( a.2_2_supply_restock_month_last ),  '/', 
        
                              -- a.2_2_supply_restock_day_last,    '/', 
                              
                              valid_day_month_year( trim( a.2_2_supply_restock_day_last ), trim( a.2_2_supply_restock_month_last ), trim( a.2_2_supply_restock_year_last ) ),    '/',                             
                              
                              trim( a.2_2_supply_restock_year_last ) ), '%M/%e/%Y')                                         as lastRestockDate,
                              
     
        -- Date survey completed minus last day restock.  If less than 31 days then restock happened in last month. 
        if( ( ( to_days( str_to_date( concat( trim( a.month_complete ),   '/',
        
                                              -- trim( a.day_complete ),     '/',
                                              valid_day_month_year( trim( a.day_complete ), trim( a.month_complete ), trim( a.year_complete ) ), '/', 
                                          
                                              trim( a.year_complete ) ),  '%M/%e/%Y'
                                     )
                        )
                        
              - to_days( str_to_date( concat( a.2_2_supply_restock_month_last,  '/',
              
                                              -- a.2_2_supply_restock_day_last,    '/',
                                              valid_day_month_year( trim( a.2_2_supply_restock_day_last ), trim( a.2_2_supply_restock_month_last ), trim( a.2_2_supply_restock_year_last ) ),    '/',                             
                              
                                              a.2_2_supply_restock_year_last ), '%M/%e/%Y'
                                            )
                                    )
                        ) 
              <= 31
            ), 1, 0 
            
            ) as restockedInLastMonth,
        
        if( ( ( to_days( str_to_date( concat( trim( a.month_complete ), '/',
        
                                              -- trim( a.day_complete ),   '/',
                                              valid_day_month_year( trim( a.day_complete ), trim( a.month_complete ), trim( a.year_complete ) ), '/', 

                                              trim( a.year_complete ) ), '%M/%e/%Y'
                                            )
                                      ) 
              - to_days( str_to_date( concat( a.2_2_supply_restock_month_last,  '/',
              
                                              -- a.2_2_supply_restock_day_last,    '/',
                                              valid_day_month_year( trim( a.2_2_supply_restock_day_last ), trim( a.2_2_supply_restock_month_last ), trim( a.2_2_supply_restock_year_last ) ),    '/',                             
                              
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
                   
        if( trim( a.2_1_g_supply_act_50_135_mg_tablet_in_stock )  like 'Y', 1, 0 )            as act_50_135_mg_tablet_in_stock,
        if( trim( a.2_1_f_supply_act_25_67_5_mg_tablet_in_stock ) like 'Y', 1, 0 )            as act_25_67_5_mg_tablet_in_stock,      
        if( trim( a.2_1_f_supply_act_25_67_5_mg_tablet_in_stock ) like 'Y' or 
            trim( a.2_1_g_supply_act_50_135_mg_tablet_in_stock )  like 'Y', 1, 0 )            as act_25_or_50_mg_tablet_in_stock,
            
        if( trim( a.2_1_i_supply_amox_250_mg_dispersible_tablet_in_stock ) like 'Y', 1, 0 )   as amox_250_mg_dispersible_tablet_in_stock,
        if( trim( a.2_1_j_supply_ors_20_6_1l_sachet_in_stock ) like 'Y', 1, 0 )               as ors_20_6_1l_sachet_in_stock,
        if( trim( a.2_1_k_supply_zinc_sulfate_20_mg_scored_tablet_in_stock ) like 'Y', 1, 0 ) as zinc_sulfate_20_mg_scored_tablet_in_stock,
        
        
        -- On the IFI community form section 6.2, these are the four answers to the questions for the CHAs.
        -- We don't differentiabe between those who have completed which module.  We just check if they
        -- have answered all four correctly.
        case 
            when  coalesce( trim( a.6_2_service_delivery_question_1 ), '' ) like 'B' and
                  coalesce( trim( a.6_2_service_delivery_question_2 ), '' ) like 'B' and
                  coalesce( trim( a.6_2_service_delivery_question_3 ), '' ) like 'A' and
                  coalesce( trim( a.6_2_service_delivery_question_4 ), '' ) like 'C' 
            then 1
            else 0
        end as service_delivery_question_correct_1_4,
        
        if(
                upper( 5_3_me_module_3_row_marked_form_1 )      like 'Y' and
                upper( 5_3_me_module_3_row_marked_form_2 )      like 'Y' and
                upper( 5_3_me_module_3_row_marked_form_3 )      like 'Y' and
                upper( 5_4_me_module_3_row_bolded_box_form_1 )  like 'Y' and
                upper( 5_4_me_module_3_row_bolded_box_form_2 )  like 'Y' and
                upper( 5_4_me_module_3_row_bolded_box_form_3 )  like 'Y',
                1, 0  
            ) as correct_treatment
         
    from lastmile_report.mart_de_integrated_supervision_tool_community as a
        left outer join lastmile_cha.county as b on  convert( a.county using UTF8 ) = b.county
;