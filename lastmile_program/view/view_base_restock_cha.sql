use lastmile_program;

drop view if exists view_base_restock_cha;

create view view_base_restock_cha as 

select 
        'lastmile_upload'                             as source_database,
        'odk_chaRestock'                              as source_table, 
        s.chaRestockID                                as cha_restock_id,
        
        trim( s.meta_UUID )                           as meta_uuid,
        trim( s.meta_autoDate )                       as meta_auto_date,
        trim( s.meta_dataEntry_startTime )            as meta_data_entry_time_start,
        trim( s.meta_dataEntry_endTime )              as meta_data_entry_time_end,
        trim( s.meta_dataSource )                     as meta_data_source,
        trim( s.meta_formVersion )                    as meta_form_version,
        trim( s.meta_deviceID )                       as meta_device_id,
        
        trim( s.manualDate )                          as manual_date,

        trim( s.chssID )                              as chss_id,
        trim( s.chssName )                            as chss,
        b.chss                                        as chss_database,
        
        trim( s.employeeType )                        as employee_type,
        trim( s.jobType_Other )                       as job_type_other,
        
        trim( s.otherID )                             as other_id,
        trim( s.otherName )                           as other_name,
        
        o.staff_id                                    as staff_id_database,
        o.full_name                                   as full_name_database,
        o.job                                         as job_database,
        
        trim( s.supervisedChaID )                     as cha_id,
        trim( s.chaName )                             as cha,
        trim( s.communityID )                         as community_id,

        trim( s.stockOnHand_ACT25mg )                 as stock_on_hand_act_25_mg,
        trim( s.stockOnHand_ACT50mg )                 as stock_on_hand_act_50_mg,
        trim( s.stockOnHand_Amoxicillin250mg )        as stock_on_hand_amoxicillin_250_mg,
        trim( s.stockOnHand_disposableGloves )        as stock_on_hand_disposable_glove,
        trim( s.stockOnHand_MalariaRDT )              as stock_on_hand_malaria_rdt,
        trim( s.stockOnHand_maleCondom )              as stock_on_hand_male_condom,
        trim( s.stockOnHand_microgynon )              as stock_on_hand_microgynon,
        trim( s.stockOnHand_muacStrap )               as stock_on_hand_muac_strap,
        trim( s.stockOnHand_ORS )                     as stock_on_hand_ors,
        trim( s.stockOnHand_Paracetamol100mg )        as stock_on_hand_paracetamol_100_mg,
        trim( s.stockOnHand_ZincSulfate )             as stock_on_hand_zinc_sulfate,
        trim( s.stockOnHand_artesunateSuppository )   as stock_on_hand_artesunate_suppository,
        trim( s.stockOnHand_dispensingBags )          as stock_on_hand_dispensing_bag,
        trim( s.stockOnHand_femaleCondom )            as stock_on_hand_female_condom,
        trim( s.stockOnHand_microlut )                as stock_on_hand_microlut,
        trim( s.stockOnHand_safetyBox )               as stock_on_hand_safety_box
        
from lastmile_upload.odk_chaRestock as s
    left outer join lastmile_cha.view_history_position_person_cea_ceo as o on trim( s.otherID ) like o.staff_id
    left outer join lastmile_cha.view_history_position_person_chss    as b on trim( s.chssID ) like b.chss_id
    
union 

select

    w.source_database,
    w.source_table,
    w.cha_restock_id,

    w.meta_uuid,
    w.meta_auto_date,
    w.meta_data_entry_time_start,
    w.meta_data_entry_time_end,
    w.meta_data_source,
    w.meta_form_version,
    w.meta_device_id,

    w.manual_date,

    w.chss_id,
    w.chss,
    b.chss                        as chss_database,
    
    w.employee_type,
    w.job_type_other,
    
    null                          as other_id,
    null                          as other_name,
    
    w.chwl_id                     as staff_id_database, 
    w.chwl                        as full_name_database,
    'CHWL'                        as job_database,
   
    w.cha_id,
    w.cha,
    w.community_id,

    w.stock_on_hand_act_25_mg,
    w.stock_on_hand_act_50_mg,
    w.stock_on_hand_amoxicillin_250_mg,
    w.stock_on_hand_disposable_glove,
    w.stock_on_hand_malaria_rdt,
    w.stock_on_hand_male_condom,
    w.stock_on_hand_microgynon,
    w.stock_on_hand_muac_strap,
    w.stock_on_hand_ors,
    w.stock_on_hand_paracetamol_100_mg,
    w.stock_on_hand_zinc_sulfate,
    w.stock_on_hand_artesunate_suppository,
    w.stock_on_hand_dispensing_bag,
    w.stock_on_hand_female_condom,
    w.stock_on_hand_microlut,
    w.stock_on_hand_safety_box 

from lastmile_program.view_archive_restock_chw as w
    left outer join lastmile_cha.view_history_position_person_chss as b on trim( w.chss_id ) like b.chss_id
;
