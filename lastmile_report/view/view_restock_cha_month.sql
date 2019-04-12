use lastmile_report;

drop view if exists view_restock_cha_month;

create view view_restock_cha_month as
select
        a.chaRestockID,
        a.supervisedChaID                                                     as cha_id,
        b.county,
        b.county_id,
        
        lastmile_report.territory_id( b.county_id, 1 )        as territory_id,     
        month( a.manualDate )                                 as `month`,
        year( a.manualDate )                                  as `year`,
        a.manualDate,
        
        min( a.stockOnHand_ACT25mg )                          as stockOnHand_ACT25mg,
        min( a.stockOnHand_ACT50mg )                          as stockOnHand_ACT50mg,
        min( a.stockOnHand_Amoxicillin250mg )                 as stockOnHand_Amoxicillin250mg,
        min( a.stockOnHand_Amoxicillin250mg_suspension )      as stockOnHand_Amoxicillin250mg_suspension,
        min( a.stockOnHand_artesunateSuppository )            as stockOnHand_artesunateSuppository,
        min( a.stockOnHand_dispensingBags )                   as stockOnHand_dispensingBags,
        min( a.stockOnHand_disposableGloves )                 as stockOnHand_disposableGloves,
        min( a.stockOnHand_femaleCondom )                     as stockOnHand_femaleCondom,
        min( a.stockOnHand_MalariaRDT )                       as stockOnHand_MalariaRDT,
        min( a.stockOnHand_maleCondom )                       as stockOnHand_maleCondom,
        min( a.stockOnHand_microgynon )                       as stockOnHand_microgynon,
        min( a.stockOnHand_microlut )                         as stockOnHand_microlut,
        min( a.stockOnHand_muacStrap )                        as stockOnHand_muacStrap,
        min( a.stockOnHand_ORS )                              as stockOnHand_ORS,
        min( a.stockOnHand_Paracetamol100mg )                 as stockOnHand_Paracetamol100mg,
        min( a.stockOnHand_Paracetamol100mg_suspension )      as stockOnHand_Paracetamol100mg_suspension,
        min( a.stockOnHand_safetyBox )                        as stockOnHand_safetyBox,
        min( a.stockOnHand_ZincSulfate )                      as stockOnHand_ZincSulfate,
        min( a.stockOnHand_ZincSulfate_Infidelity )           as stockOnHand_ZincSulfate_Infidelity
        
from lastmile_report.view_restock_union as a
        left outer join mart_view_base_history_person_position as b on  (  
                                                                          ( a.supervisedChaID like b.position_id )          and 
                                                                          ( a.manualDate >= b.position_person_begin_date )  and 
                                                                          ( ( a.manualDate <= b.position_person_end_date )  or 
                                                                            isnull( b.position_person_end_date ) )                                                                        
                                                                        )  
where not ( a.supervisedChaID is null )
group by a.supervisedChaID, month( a.manualDate ), year( a.manualDate )
;