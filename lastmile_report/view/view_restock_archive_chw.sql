use lastmile_report;

drop view if exists view_restock_archive_chw;

create view view_restock_archive_chw as

select

    'lastmile_archive'                                as source_database,
    'chwdb_odk_chw_restock'                           as source_table,
    r.chwRestockID                                    as cha_restock_id,

    trim( r.meta_UUID )                               as meta_uuid,
    trim( r.meta_autoDate )                           as meta_auto_date,
    trim( r.meta_dataEntry_startTime )                as meta_data_entry_time_start,
    trim( r.meta_dataEntry_endTime )                  as meta_data_entry_time_end,
    trim( r.meta_dataSource )                         as meta_data_source,
    trim( r.meta_formVersion )                        as meta_form_version,
    trim( r.meta_deviceID )                           as meta_device_id,

    trim( r.manualDate )                              as manual_date,
    
    null                                              as chss_id,
    null                                              as chss,
    
    'CHWL'                                            as employee_type,
    null                                              as job_type_other,
    
    l.chwl_id, 
    l.full_name                                       as chwl,
   
    trim( r.supervisedChwID )                         as position_id,
    null                                              as cha,
    trim( r.communityID )                             as community_id,

    trim( r.stockOnHand_ACT25mg )                     as stock_on_hand_act_25_mg,
    trim( r.stockOnHand_ACT50mg )                     as stock_on_hand_act_50_mg,
    trim( r.stockOnHand_amoxicillin250mg )            as stock_on_hand_amoxicillin_250_mg,
    trim( r.stockOnHand_disposableGloves )            as stock_on_hand_disposable_glove,
    trim( r.stockOnHand_MalariaRDT )                  as stock_on_hand_malaria_rdt,
    trim( r.stockOnHand_maleCondoms )                 as stock_on_hand_male_condom,
    trim( r.stockOnHand_microgynon )                  as stock_on_hand_microgynon,
    trim( r.stockOnHand_muacStrap )                   as stock_on_hand_muac_strap,
    trim( r.stockOnHand_ORS )                         as stock_on_hand_ors,
    trim( r.stockOnHand_Paracetamol120mg )            as stock_on_hand_paracetamol_100_mg,
    trim( r.stockOnHand_ZincSulfate )                 as stock_on_hand_zinc_sulfate,
    null                                              as stock_on_hand_artesunate_suppository,
    null                                              as stock_on_hand_dispensing_bag,
    null                                              as stock_on_hand_female_condom,
    null                                              as stock_on_hand_microlut,
    null                                              as stock_on_hand_safety_box 

from lastmile_archive.chwdb_odk_chw_restock as r
    left outer join lastmile_cha.view_history_position_person_chwl as l on trim( r.chwlID ) like l.chwl_id
;