use lastmile_report;

drop view if exists lastmile_report.view_restock_cha_month;

create view lastmile_report.view_restock_cha_month as
select
      year( a.manualDate )                                    as `year`,
      month(  a.manualDate )                                  as `month`,
      a.supervisedChaID                                       as cha_id,
      
      -- county, county_id is based on supervisedChaID joining and retturnig a value from mart_view_history_position_geo.
      -- Therefore, it will always align with supervisedChaID, and so it can be used here in group by 
      b.county,
      b.county_id,
      lastmile_report.territory_id( b.county_id, 1 )          as territory_id,     

      min( a.manualDate )                                     as manualDate,
        
      group_concat( distinct meta_deviceID order by meta_deviceID separator ',' ) as meta_deviceID_list,
      count( * )                                              as number_record,
      sum( if( meta_formVersion like '4.0.0', 1, 0 ) )        as number_record_ppe,
      
      min( a.stockOnHand_ACT25mg )                            as stockOnHand_ACT25mg,
      min( a.stockOnHand_ACT50mg )                            as stockOnHand_ACT50mg,
      max( a.stockout_act_25mg_50mg )                         as stockout_act_25mg_50mg,
        
      min( a.stockOnHand_Amoxicillin250mg )                   as stockOnHand_Amoxicillin250mg,
      min( a.stockOnHand_Amoxicillin250mg_suspension )        as stockOnHand_Amoxicillin250mg_suspension,
      min( a.stockOnHand_Amoxicillin250mg_strips )            as stockOnHand_Amoxicillin250mg_strips,
      max( a.stockout_amoxicillin_250_mg )                    as stockout_amoxicillin_250_mg,
        
      min( a.stockOnHand_artesunateSuppository )              as stockOnHand_artesunateSuppository,
      min( a.stockOnHand_dispensingBags )                     as stockOnHand_dispensingBags,
      min( a.stockOnHand_disposableGloves )                   as stockOnHand_disposableGloves,
      min( a.stockOnHand_femaleCondom )                       as stockOnHand_femaleCondom,
      min( a.stockOnHand_MalariaRDT )                         as stockOnHand_MalariaRDT,
      min( a.stockOnHand_maleCondom )                         as stockOnHand_maleCondom,
      min( a.stockOnHand_microgynon )                         as stockOnHand_microgynon,
      min( a.stockOnHand_microlut )                           as stockOnHand_microlut,
      min( a.stockOnHand_muacStrap )                          as stockOnHand_muacStrap,
      min( a.stockOnHand_ORS )                                as stockOnHand_ORS,
      
      min( a.stockOnHand_Paracetamol100mg )                   as stockOnHand_Paracetamol100mg,
      min( a.stockOnHand_Paracetamol100mg_suspension )        as stockOnHand_Paracetamol100mg_suspension,
      max( a.stockout_paracetamol_100mg )                     as stockout_paracetamol_100mg,
      
      min( a.stockOnHand_safetyBox )                          as stockOnHand_safetyBox,
      min( a.stockOnHand_ZincSulfate )                        as stockOnHand_ZincSulfate,
      min( a.stockOnHand_ZincSulfate_Infidelity )             as stockOnHand_ZincSulfate_Infidelity,
      max( a.stockout_zinc_sulfate )                          as stockout_zinc_sulfate,
        
        -- PPE Covid-19
      min( a.stockOnHand_surgicalMask )                       as stockOnHand_surgicalMask,
      min( a.stockOnHand_glovesCovid19 )                      as stockOnHand_glovesCovid19,
      min( a.stockOnHand_disposable_gloves_regular_covid19 )  as stockOnHand_disposable_gloves_regular_covid19
        
from lastmile_report.view_restock_union as a
        left outer join lastmile_report.mart_view_history_position_geo as b on a.supervisedChaID like b.position_id

-- supervisedChaID will never be an empty string--null or a string > 0 characters long
where not ( a.supervisedChaID is null )
group by year( a.manualDate ), month( a.manualDate ), a.supervisedChaID
;