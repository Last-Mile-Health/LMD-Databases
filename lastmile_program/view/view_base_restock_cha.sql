use lastmile_program;

drop view if exists view_base_restock_cha;

create view view_base_restock_cha as 

select 
        'lastmile_upload'                   as source_database,
        'odk_chaRestock'                    as source_table, 
        chaRestockID                        as cha_restock_id,
        
        meta_UUID                           as meta_uuid,
        meta_autoDate                       as meta_auto_date,
        meta_dataEntry_startTime            as meta_data_entry_time_start,
        meta_dataEntry_endTime              as meta_data_entry_time_end,
        meta_dataSource                     as meta_data_source,
        meta_formVersion                    as meta_form_version,
        meta_deviceID                       as meta_device_id,
        
        trim( manualDate )                  as manual_date,

        employeeType                        as employee_type,
        chssID                              as chss_id,
        chssName                            as chss,
        jobType_Other                       as job_type_other,
        otherName                           as other_name,
        otherID                             as other_id, 

        trim( supervisedChaID )             as cha_id,
        trim( chaName )                     as cha,
        communityID                         as community_id,

        stockOnHand_ACT25mg                 as stock_on_hand_act_25_mg,
        stockOnHand_ACT50mg                 as stock_on_hand_act_50_mg,
        stockOnHand_Amoxicillin250mg        as stock_on_hand_amoxicillin_250_mg,
        stockOnHand_disposableGloves        as stock_on_hand_disposable_glove,
        stockOnHand_MalariaRDT              as stock_on_hand_malaria_rdt,
        stockOnHand_maleCondom              as stock_on_hand_male_condom,
        stockOnHand_microgynon              as stock_on_hand_microgynon,
        stockOnHand_muacStrap               as stock_on_hand_muac_strap,
        stockOnHand_ORS                     as stock_on_hand_ors,
        stockOnHand_Paracetamol100mg        as stock_on_hand_paracetamol_100_mg,
        stockOnHand_ZincSulfate             as stock_on_hand_zinc_sulfate,
        stockOnHand_artesunateSuppository   as stock_on_hand_artesunate_suppository,
        stockOnHand_dispensingBags          as stock_on_hand_dispensing_bag,
        stockOnHand_femaleCondom            as stock_on_hand_female_condom,
        stockOnHand_microlut                as stock_on_hand_microlut,
        stockOnHand_safetyBox               as stock_on_hand_safety_box 
from lastmile_upload.odk_chaRestock 
union 
select
    'lastmile_archive'                      as source_database,
    'chwdb_odk_chw_restock'                 as source_table,
    chwRestockID                            as cha_restock_id,

    meta_UUID                               as meta_uuid,
    meta_autoDate                           as meta_auto_date,
    meta_dataEntry_startTime                as meta_data_entry_time_start,
    meta_dataEntry_endTime                  as meta_data_entry_time_end,
    meta_dataSource                         as meta_data_source,
    meta_formVersion                        as meta_form_version,
    meta_deviceID                           as meta_device_id,

    manualDate                              as manual_date,

    'CHWL'                                  as employee_type,
    null                                    as chss_id,
    null                                    as chss,
    'CHWL'                                  as job_type_other,
    chwlName                                as other_name,
    chwlID                                  as other_id, 

    trim( supervisedChwID )                 as cha_id,
    null                                    as cha,
    communityID                             as community_id,

    stockOnHand_ACT25mg                     as stock_on_hand_act_25_mg,
    stockOnHand_ACT50mg                     as stock_on_hand_act_50_mg,
    stockOnHand_amoxicillin250mg            as stock_on_hand_amoxicillin_250_mg,
    stockOnHand_disposableGloves            as stock_on_hand_disposable_glove,
    stockOnHand_MalariaRDT                  as stock_on_hand_malaria_rdt,
    stockOnHand_maleCondoms                 as stock_on_hand_male_condom,
    stockOnHand_microgynon                  as stock_on_hand_microgynon,
    stockOnHand_muacStrap                   as stock_on_hand_muac_strap,
    stockOnHand_ORS                         as stock_on_hand_ors,
    stockOnHand_Paracetamol120mg            as stock_on_hand_paracetamol_100_mg,
    stockOnHand_ZincSulfate                 as stock_on_hand_zinc_sulfate,
    null                                    AS stock_on_hand_artesunate_suppository,
    null                                    AS stock_on_hand_dispensing_bag,
    null                                    AS stock_on_hand_female_condom,
    null                                    AS stock_on_hand_microlut,
    null                                    AS stock_on_hand_safety_box 

from lastmile_archive.chwdb_odk_chw_restock
;
