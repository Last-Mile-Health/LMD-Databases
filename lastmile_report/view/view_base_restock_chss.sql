use lastmile_report;

drop view if exists lastmile_report.view_base_restock_chss;

create view lastmile_report.view_base_restock_chss as 

select 
      lastmile_report.territory_id(a.county, 1) as territory_id,
        
      month(  a.restock_date )                  as restock_month,
      year(   a.restock_date )                  as restock_year,
        
      a.chss_commodity_distribution_id,
        
      a.meta_uuid,
      a.meta_de_init,
      a.meta_de_date,
      a.meta_de_time_start,
      a.meta_de_time_end,
      a.meta_qa_init,
      a.meta_qa_date,
      a.meta_data_source,
      a.meta_form_version,
      a.meta_insert_date_time,
      a.meta_fabricated,
        
      a.chss,
      trim( a.chss_id )                         as chss_id,
      a.chss_id_inserted,
      a.restock_date,
      a.restock_driver,
      a.health_facility,
      a.county,
        
      if( ( ( coalesce( a.act_25_initial_stock_on_hand, 0 ) > 0 ) or 
          ( coalesce( a.act_50_initial_stock_on_hand, 0 ) > 0 )   
          ) 
          and
          ( coalesce( a.ors_initial_stock_on_hand, 0 ) > 0 ) 
          and
          ( ( coalesce( a.amoxicillin_250_tablet_2_bottle_1000_initial_stock_on_hand, 0 ) > 0 ) or
            ( coalesce( a.amoxicillin_250_tablet_4_bottle_1000_initial_stock_on_hand, 0 ) > 0 ) or
            ( coalesce( a.amoxicillin_250_tablet_200_strip_10_initial_stock_on_hand,  0 ) > 0 ) or
            ( coalesce( a.amoxicillin_250_suspension_initial_stock_on_hand,           0 ) > 0 )
          ),
            1, 0
        ) as important_initial_stock_on_hand,

        a.microlut_initial_stock_on_hand,
        a.microlut_stock_damaged_expiring,
        a.microlut_amount_restocked,
        a.microlut_ending_balance,
        a.microlut_stock_returned,
        
        a.microgynon_initial_stock_on_hand,
        a.microgynon_stock_damaged_expiring,
        a.microgynon_amount_restocked,
        a.microgynon_ending_balance,
        a.microgynon_stock_returned,
        
        a.male_condom_initial_stock_on_hand,
        a.male_condom_stock_damaged_expiring,
        a.male_condom_amount_restocked,
        a.male_condom_ending_balance,
        a.male_condom_stock_returned,
        
        a.female_condom_initial_stock_on_hand,
        a.female_condom_stock_damaged_expiring,
        a.female_condom_amount_restocked,
        a.female_condom_ending_balance,
        a.female_condom_stock_returned,
        
        a.disposable_glove_initial_stock_on_hand,
        a.disposable_glove_stock_damaged_expiring,
        a.disposable_glove_amount_restocked,
        a.disposable_glove_ending_balance,
        a.disposable_glove_stock_returned,
        
        a.act_25_initial_stock_on_hand,
        a.act_25_stock_damaged_expiring,
        a.act_25_amount_restocked,
        a.act_25_ending_balance,
        a.act_25_stock_returned,
        
        a.act_50_initial_stock_on_hand,
        a.act_50_stock_damaged_expiring,
        a.act_50_amount_restocked,
        a.act_50_ending_balance,
        a.act_50_stock_returned,
        
        a.artesunate_suppository_5_unit_initial_stock_on_hand,
        a.artesunate_suppository_5_unit_stock_damaged_expiring,
        a.artesunate_suppository_5_unit_amount_restocked,
        a.artesunate_suppository_5_unit_ending_balance,
        a.artesunate_suppository_5_unit_stock_returned,
               
        if(
            ( coalesce( a.amoxicillin_250_tablet_2_bottle_1000_initial_stock_on_hand, 0 ) > 0 ) or
            ( coalesce( a.amoxicillin_250_tablet_4_bottle_1000_initial_stock_on_hand, 0 ) > 0 ) or
            ( coalesce( a.amoxicillin_250_tablet_200_strip_10_initial_stock_on_hand,  0 ) > 0 ) or
            ( coalesce( a.amoxicillin_250_suspension_initial_stock_on_hand,           0 ) > 0 )
            , 1, 0   
        ) as amoxicillin_250_initial_stock_on_hand,
                
        a.amoxicillin_250_tablet_2_bottle_1000_initial_stock_on_hand,
        a.amoxicillin_250_tablet_2_bottle_1000_stock_damaged_expiring,
        a.amoxicillin_250_tablet_2_bottle_1000_amount_restocked,
        a.amoxicillin_250_tablet_2_bottle_1000_ending_balance,
        a.amoxicillin_250_tablet_2_bottle_1000_stock_returned,
   
        a.amoxicillin_250_tablet_4_bottle_1000_initial_stock_on_hand,
        a.amoxicillin_250_tablet_4_bottle_1000_stock_damaged_expiring,
        a.amoxicillin_250_tablet_4_bottle_1000_amount_restocked,
        a.amoxicillin_250_tablet_4_bottle_1000_ending_balance,
        a.amoxicillin_250_tablet_4_bottle_1000_stock_returned,
        
        a.amoxicillin_250_tablet_200_strip_10_initial_stock_on_hand,
        a.amoxicillin_250_tablet_200_strip_10_stock_damaged_expiring,
        a.amoxicillin_250_tablet_200_strip_10_amount_restocked,
        a.amoxicillin_250_tablet_200_strip_10_ending_balance,
        a.amoxicillin_250_tablet_200_strip_10_stock_returned,
        
        a.amoxicillin_250_suspension_initial_stock_on_hand,
        a.amoxicillin_250_suspension_stock_damaged_expiring,
        a.amoxicillin_250_suspension_amount_restocked,
        a.amoxicillin_250_suspension_ending_balance,
        a.amoxicillin_250_suspension_stock_returned,
        
        a.ors_initial_stock_on_hand,
        a.ors_stock_damaged_expiring,
        a.ors_amount_restocked,
        a.ors_ending_balance,
        a.ors_stock_returned,
        
        a.zinc_sulfate_bottle_initial_stock_on_hand,
        a.zinc_sulfate_bottle_stock_damaged_expiring,
        a.zinc_sulfate_bottle_amount_restocked,
        a.zinc_sulfate_bottle_ending_balance,
        a.zinc_sulfate_bottle_stock_returned,
        
        a.zinc_sulfate_strip_initial_stock_on_hand,
        a.zinc_sulfate_strip_stock_damaged_expiring,
        a.zinc_sulfate_strip_amount_restocked,
        a.zinc_sulfate_strip_ending_balance,
        a.zinc_sulfate_strip_stock_returned,
        
        a.paracetamol_tablet_initial_stock_on_hand,
        a.paracetamol_tablet_stock_damaged_expiring,
        a.paracetamol_tablet_amount_restocked,
        a.paracetamol_tablet_ending_balance,
        a.paracetamol_tablet_stock_returned,
        
        a.paracetamol_suspension_initial_stock_on_hand,
        a.paracetamol_suspension_stock_damaged_expiring,
        a.paracetamol_suspension_amount_restocked,
        a.paracetamol_suspension_ending_balance,
        a.paracetamol_suspension_stock_returned,
        
        a.RDT_initial_stock_on_hand,
        a.RDT_stock_damaged_expiring,
        a.RDT_amount_restocked,
        a.RDT_ending_balance,
        a.RDT_stock_returned,
        
        a.MUAC_initial_stock_on_hand,
        a.MUAC_stock_damaged_expiring,
        a.MUAC_amount_restocked,
        a.MUAC_ending_balance,
        a.MUAC_stock_returned,
        
        a.dispensing_bag_initial_stock_on_hand,
        a.dispensing_bag_stock_damaged_expiring,
        a.dispensing_bag_amount_restocked,
        a.dispensing_bag_ending_balance,
        a.dispensing_bag_stock_returned,
        
        a.safety_box_initial_stock_on_hand,
        a.safety_box_stock_damaged_expiring,
        a.safety_box_amount_restocked,
        a.safety_box_ending_balance,
        a.safety_box_stock_returned,
        
        a.gasoline_initial_stock_on_hand,
        a.gasoline_amount_restocked,
        a.gasoline_ending_balance,
        a.gasoline_stock_returned,
        a.chss_signature,
        a.oic_signature,
        a.comment
    
from lastmile_upload.de_chss_commodity_distribution a
where trim( a.chss_id ) in (  select position_id 
                              from lastmile_cha.view_base_history_person
                              where view_base_history_person.job like 'CHSS' 
                            )
;