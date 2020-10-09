use lastmile_report;

drop view if exists lastmile_report.view_restock_level;

create view lastmile_report.view_restock_level as
select 
      'CHA'                                                       as restock_level,
      d.year_report,
      d.month_report,
      c.county,
      
      if( c.chss is null, 'UNASSIGNED', c.chss )                  as chss,
      if( c.cha is null,  'UNASSIGNED', c.cha )                   as cha,
      if( r.restock_date is null, 'NO RESTOCK', r.restock_date )  as restock_date,  -- if null, then no restock record
     
      -- commodities
      r.microlut_restock_type,	
      r.microlut_stock_on_hand,	
      r.microlut_quantity_restock,	
      
      r.microgynon_restock_type,	
      r.microgynon_stock_on_hand,	
      r.microgynon_quantity_restock,	
      
      r.condom_unit_type,	
      r.male_condom_restock_type,	
      r.male_condom_stock_on_hand,	
      r.male_condom_quantity_restock,	
      
      r.female_condom_restock_type,	
      r.female_condom_stock_on_hand,	
      r.female_condom_quantity_restock,	
      
      r.disposable_gloves_restock_type,	
      r.disposable_gloves_stock_on_hand,	
      r.disposable_gloves_quantity_restock,	
      
      r.ACT_25mg_restock_type,	
      r.ACT_25mg_stock_on_hand,	
      r.ACT_25mg_quantity_restock,	
      
      r.ACT_50mg_restock_type,	
      r.ACT_50mg_stock_on_hand,	
      r.ACT_50mg_quantity_restock,	
      
      r.artesunate_suppository_restock_type,	
      r.artesunate_suppository_stock_on_hand,	
      r.artesunate_suppository_quantity_restock,	
      
      r.amoxicillin_250mg_restock_type,	
      r.amoxicillin_250mg_stock_on_hand,	
      r.amoxicillin_250mg_quantity_restock,	
      
      r.amoxicillin_250mg_strips_restock_type,	
      r.amoxicillin_250mg_strips_stock_on_hand,	
      r.amoxicillin_250mg_strips_quantity_restock,	
      
      r.amoxicillin_250mg_suspension_restock_type,	
      r.amoxicillin_250mg_suspension_stock_on_hand,	
      r.amoxicillin_250mg_suspension_quantity_restock,	
      
      r.ors_restock_type,	
      r.ors_stock_on_hand,	
      r.ors_quantity_restock,	
      
      r.zinc_sulfate_restock_type,	
      r.zinc_sulfate_stock_on_hand,	
      r.zinc_sulfate_quantity_restock,	
      
      r.zinc_sulfate_strips_restock_type,	
      r.zinc_sulfate_strips_stock_on_hand,
      r.zinc_sulfate_strips_quantity_restock,	
      
      r.paracetamol_100mg_restock_type,	
      r.paracetamol_100mg_stock_on_hand,	
      r.paracetamol_100mg_quantity_restock,	
      
      r.paracetamol_100mg_suspension_restock_type,	
      r.paracetamol_100mg_suspension_stock_on_hand,	
      r.paracetamol_100mg_quantity_restock_suspension,	
      
      r.malaria_rdt_restock_type,	
      r.malaria_rdt_stock_on_hand,	
      r.malaria_rdt_quantity_restock,	
      
      r.muac_strap_restock_type,	
      r.muac_strap_stock_on_hand,	
      r.muac_strap_quantity_restock,	
      
      r.dispensing_bags_restock_type,	
      r.dispensing_bags_stock_on_hand,	
      r.dispensing_bags_quantity_restock,	
      
      r.safety_box_restock_type,	
      r.safety_box_stock_on_hand,	
      r.safety_box_quantity_restock,
      
      'NA' as gasoline_top_off,
      'NA' as gasoline_initial_stock_on_hand,	
      'NA' as gasoline_amount_restocked,
      
      r.surgical_mask_restock_type,
      r.surgical_mask_stock_on_hand,
      r.surgical_mask_quantity_restock,
      
      r.disposable_gloves_covid19_restock_type,
      r.disposable_gloves_covid19_stock_on_hand,
      r.disposable_gloves_covid19_quantity_restock,
  
      -- geographical and ID data
      c.health_district,
      c.health_facility,
      c.chss_position_id, 
      c.position_id,
      c.community_id_list, 
      c.community_list

from lastmile_report.mart_view_base_position_cha as c
    cross join  lastmile_report.view_restock_level_year_month as d
    left outer join lastmile_report.view_restock_level_cha as r on  c.position_id like r.position_id  and 
                                                                    d.year_report = r.restock_year    and 
                                                                    d.month_report= r.restock_month
where ( c.cohort is null ) or not ( c.cohort like 'UNICEF' )

union all

select 
      'CHSS'                                                        as restock_level,
      d.year_report,
      d.month_report,
      c.county,
      if( c.chss is null, 'UNASSIGNED', c.chss )                    as chss,
      'NA'                                                          as cha,
      
      if( r.restock_date is null, 'NO RESTOCK', r.restock_date )    as restock_date,  -- if null, then no restock record
     
      -- commodities
      
      '30 packs of 3 strips'                                        as microlut_restock_type,
      r.microlut_initial_stock_on_hand,	
      r.microlut_amount_restocked,	
      
      '60 packs of 3 strips'                                        as microgynon_restock_type,
      r.microgynon_initial_stock_on_hand,	
      r.microgynon_amount_restocked,	
      
      'NA'                                                          as condom_unit_type,
      '30 boxes of 100'                                             as male_condom_restock_type,
      r.male_condom_initial_stock_on_hand,	
      r.male_condom_amount_restocked,	
      
      '60 pieces'                                                   as female_condom_restock_type,
      r.female_condom_initial_stock_on_hand,	
      r.female_condom_amount_restocked,	
      
      '6 boxes of 100'                                              as disposable_glove_restock_type,
      r.disposable_glove_initial_stock_on_hand,	
      r.disposable_glove_amount_restocked,	
      
      '50 strips of 3 tablets'                                      as act_25_restock_type,
      r.act_25_initial_stock_on_hand,	
      r.act_25_amount_restocked,	
      
      '100 strips of 3 tablets'                                     as act_50_restock_type,
      r.act_50_initial_stock_on_hand,	
      r.act_50_amount_restocked,	
      
      '5 units'                                                     as artesunate_suppository_5_unit_restock_type,
      r.artesunate_suppository_5_unit_initial_stock_on_hand,	
      r.artesunate_suppository_5_unit_amount_restocked,	
      
      '2 bottles of 1000'                                           as amoxicillin_250_tablet_bottle_1000_restock_type,
      r.amoxicillin_250_tablet_bottle_1000_initial_stock_on_hand,	
      r.amoxicillin_250_tablet_bottle_1000_amount_restocked,	
        
      '200 strips of 10'                                            as amoxicillin_250_tablet_200_strip_10_restock_type,
      r.amoxicillin_250_tablet_200_strip_10_initial_stock_on_hand,	
      r.amoxicillin_250_tablet_200_strip_10_amount_restocked,	
      
      '120 bottles'                                                 as amoxicillin_250_suspension_restock_type,
      r.amoxicillin_250_suspension_initial_stock_on_hand,	
      r.amoxicillin_250_suspension_amount_restocked,	
      
      '120 sachets'                                                 as ors_restock_type,
      r.ors_initial_stock_on_hand,	
      r.ors_amount_restocked,	
      
      '5 bottles of 100'                                            as zinc_sulfate_bottle_restock_type,
      r.zinc_sulfate_bottle_initial_stock_on_hand,	
      r.zinc_sulfate_bottle_amount_restocked,	
      
      '120 strips of 10'                                            as zinc_sulfate_strip_restock_type,
      r.zinc_sulfate_strip_initial_stock_on_hand,	
      r.zinc_sulfate_strip_amount_restocked,	
      
      '4 bottles of 1000'                                           as paracetamol_tablet_restock_type,
      r.paracetamol_tablet_initial_stock_on_hand,	
      r.paracetamol_tablet_amount_restocked,	
      
      '120 bottles'                                                 as paracetamol_suspension_restock_type,
      r.paracetamol_suspension_initial_stock_on_hand,	
      r.paracetamol_suspension_amount_restocked,	
      
      '10 boxes of 25'                                              as rdt_restock_type,
      r.RDT_initial_stock_on_hand,	
      r.RDT_amount_restocked,	
      
      '2 units'                                                     as muac_restock_type,
      r.MUAC_initial_stock_on_hand,	
      r.MUAC_amount_restocked,	
      
      '5 boxes of 100'                                              as dispensing_bag_restock_type,
      r.dispensing_bag_initial_stock_on_hand,	
      r.dispensing_bag_amount_restocked,	
      
      '4 boxes'                                                     as safety_box_restock_type,
      r.safety_box_initial_stock_on_hand,	
      r.safety_box_amount_restocked,	
      
      '12 Gallons'                                                  as gasoline_top_off,
      r.gasoline_initial_stock_on_hand,	
      r.gasoline_amount_restocked,						
      
      '15 Packs of 50'                                              as mask_covid_restock_type,
      r.mask_covid_initial_stock_on_hand,    
      r.mask_covid_amount_restocked,
      
      '12 boxes of 100'                                             as disposable_glove_covid_restock_type,
      r.disposable_glove_covid_initial_stock_on_hand,      
      r.disposable_glove_covid_amount_restocked,

      -- geographical and ID data
      c.health_district,
      c.health_facility,
      c.position_id                                                 as chss_position_id, 
      
      'NA'                                                          as position_id,
      'NA'                                                          as community_id_list, 
      'NA'                                                          as community_list
        
from lastmile_report.mart_view_base_position_chss as c
    cross join lastmile_report.view_restock_level_year_month as d
        left outer join lastmile_report.view_restock_level_chss as r on c.position_id like r.chss_id            and 
                                                                        d.year_report   = r.restock_date_year   and 
                                                                        d.month_report  = r.restock_date_month                                                                
where ( c.cohort is null ) or not ( c.cohort like 'UNICEF' )

-- order by clause orders resultset of the union of the two select statements.
order by year_report asc, month_report asc, county asc, health_district asc, health_facility asc, chss_position_id asc, restock_level asc, position_id asc
;

