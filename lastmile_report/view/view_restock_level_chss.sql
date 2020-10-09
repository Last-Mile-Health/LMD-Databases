use lastmile_report;

drop view if exists lastmile_report.view_restock_level_chss;

create view lastmile_report.view_restock_level_chss as
select
      restock_year,
      restock_month,
      restock_date_year,
      restock_date_month,
      restock_date,
      chss_id,
      
      -- commodities
  
      microlut_initial_stock_on_hand,   
      microlut_amount_restocked,
      
      microgynon_initial_stock_on_hand, 
      microgynon_amount_restocked,

      male_condom_initial_stock_on_hand,
      male_condom_amount_restocked,
       
      female_condom_initial_stock_on_hand,  
      female_condom_amount_restocked,
      
      disposable_glove_initial_stock_on_hand, 
      disposable_glove_amount_restocked,
 
      act_25_initial_stock_on_hand,
      act_25_amount_restocked,

      act_50_initial_stock_on_hand,
      act_50_amount_restocked,
 
      artesunate_suppository_5_unit_initial_stock_on_hand,
      artesunate_suppository_5_unit_amount_restocked,     

      if( amoxicillin_250_tablet_2_bottle_1000_initial_stock_on_hand is null or trim( amoxicillin_250_tablet_2_bottle_1000_initial_stock_on_hand ) like '',   
          if( 
              amoxicillin_250_tablet_4_bottle_1000_initial_stock_on_hand is null or trim( amoxicillin_250_tablet_4_bottle_1000_initial_stock_on_hand ) like '', 
              null, 
              amoxicillin_250_tablet_4_bottle_1000_initial_stock_on_hand 
            ),
          amoxicillin_250_tablet_2_bottle_1000_initial_stock_on_hand 
        ) as amoxicillin_250_tablet_bottle_1000_initial_stock_on_hand,
        
      if( amoxicillin_250_tablet_2_bottle_1000_amount_restocked is null or trim( amoxicillin_250_tablet_2_bottle_1000_amount_restocked ) like '',   
          if( 
              amoxicillin_250_tablet_4_bottle_1000_amount_restocked is null or trim( amoxicillin_250_tablet_4_bottle_1000_amount_restocked ) like '', 
              null, 
              amoxicillin_250_tablet_4_bottle_1000_amount_restocked 
            ),
          amoxicillin_250_tablet_2_bottle_1000_amount_restocked 
        ) as amoxicillin_250_tablet_bottle_1000_amount_restocked,
        
      amoxicillin_250_tablet_200_strip_10_initial_stock_on_hand,
      amoxicillin_250_tablet_200_strip_10_amount_restocked,
         
      amoxicillin_250_suspension_initial_stock_on_hand,
      amoxicillin_250_suspension_amount_restocked,

      ors_initial_stock_on_hand,
      ors_amount_restocked,

      zinc_sulfate_bottle_initial_stock_on_hand, 
      zinc_sulfate_bottle_amount_restocked,
        
      zinc_sulfate_strip_initial_stock_on_hand,
      zinc_sulfate_strip_amount_restocked,

      paracetamol_tablet_initial_stock_on_hand,
      paracetamol_tablet_amount_restocked,
 
      paracetamol_suspension_initial_stock_on_hand,
      paracetamol_suspension_amount_restocked,
       
      RDT_initial_stock_on_hand,
      RDT_amount_restocked,

      MUAC_initial_stock_on_hand,
      MUAC_amount_restocked,

      dispensing_bag_initial_stock_on_hand,
      dispensing_bag_amount_restocked,
     
      safety_box_initial_stock_on_hand,
      safety_box_amount_restocked,

      gasoline_initial_stock_on_hand,
      gasoline_amount_restocked,
      
      mask_covid_initial_stock_on_hand,    
      mask_covid_amount_restocked,
        
      disposable_glove_covid_initial_stock_on_hand,      
      disposable_glove_covid_amount_restocked
        

from lastmile_report.view_base_restock_chss
;