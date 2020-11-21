use lastmile_report;

drop view if exists lastmile_report.view_kobo_ifi_calculations;

create view lastmile_report.view_kobo_ifi_calculations as 
select 
      trim( a.county ) as county_id,
      b.county,
      
      year(   a.`date` )                as `year`,
      month(  a.`date` )                as `month`,
      
      1                                 as numReports,
      a.`date`                          as visitDate,
      a.supplyrestockdate               as lastRestockDate,
     
      if( ( not( isnull( a.`date` ) or isnull( a.supplyrestockdate ) )  ) and
          ( a.`date` >= a.supplyrestockdate                             ) and
          ( datediff( a.`date`, a.supplyrestockdate ) <= 31             ),1, 0 )    as restockedInLastMonth,
            
      if( ( not( isnull( a.`date` ) or isnull( a.supplyrestockdate ) )  ) and
          ( a.`date` >= a.supplyrestockdate                             ) and
          ( datediff( a.`date`, a.supplyrestockdate ) <= 93             ),1, 0 )    as restockedInLast3Months,
          
      if( ( a.supervision_last4wks >= 1 ), 1, 0 )                                   as supervisedLastMonth,
      if( ( ( a.incentive_correct = 1 ) and ( a.incentive_ontime = 1 ) ), 1, 0 )    as receivedLastIncentiveOnTime,
        
      if( 
          ( coalesce( a.supply_act50_stock, 0, a.supply_act50_stock ) = 1 or 
            coalesce( a.supply_act25_stock, 0, a.supply_act25_stock ) = 1 ) and
          ( coalesce( a.supply_amox_stock,  0,  a.supply_amox_stock ) = 1 ) and
          ( coalesce( a.supply_ors_stock,   0,  a.supply_ors_stock  ) = 1 ) and
          ( coalesce( a.supply_zinc_stock,  0,  a.supply_zinc_stock ) = 1 ), 1, 0 ) as life_saving_in_stock,
   
      coalesce( a.supply_act50_stock, 0,  a.supply_act50_stock  )                   as act_50_135_mg_tablet_in_stock,
      coalesce( a.supply_act25_stock, 0,  a.supply_act25_stock  )                   as act_25_67_5_mg_tablet_in_stock,
      
      if( coalesce( a.supply_act50_stock, 0, a.supply_act50_stock ) = 1 or 
          coalesce( a.supply_act25_stock, 0, a.supply_act25_stock ) = 1, 1, 0 )     as act_25_or_50_mg_tablet_in_stock,
      
      coalesce( a.supply_amox_stock,  0,  a.supply_amox_stock )                     as amox_250_mg_dispersible_tablet_in_stock,
      coalesce( a.supply_ors_stock,   0,  a.supply_ors_stock  )                     as ors_20_6_1l_sachet_in_stock,
      coalesce( a.supply_zinc_stock,  0,  a.supply_zinc_stock )                     as zinc_sulfate_20_mg_scored_tablet_in_stock,
            
      case
          when  a.sd_scenario_1 = 1 and
                a.sd_scenario_2 = 1 and
                a.sd_scenario_3 = 0 and
                a.sd_scenario_4 = 2
          then 1
          else 0
      end as service_delivery_question_correct_1_4,
      
      if( me_correct_form1  and
          me_correct_form2  and
          me_correct_form3  and
          me_bold_form1     and
          me_bold_form2     and
          me_bold_form3
          , 1, 0  
      ) as correct_treatment
             
    from lastmile_report.view_kobo_ifi_community as a
        left outer join lastmile_ncha.county as b on a.county = b.county_id
;