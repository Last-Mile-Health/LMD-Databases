use lastmile_upload;

drop view if exists view_cha_status_change_request;

create view view_cha_status_change_request as 

select
        first_name,
        last_name,
        cha_id,
        
        county,
        health_district,
        health_facility,
        health_facility_id,
        chss,
        chss_id,
        comment_feedback,
               
        if( trim( cha_new )                             like '1', 'yes', null ) as cha_new,  
        if( trim( cha_left_program )                    like '1', 'yes', null ) as cha_left_program,       
        if( trim( cha_left_program_performance_issue )  like '1', 'yes', null ) as cha_left_program_performance_issue,        
        if( trim( cha_left_program_personal_reason )    like '1', 'yes', null ) as cha_left_program_personal_reason,       
        if( trim( cha_left_program_relocation )         like '1', 'yes', null ) as cha_left_program_relocation,        
        if( trim( cha_left_program_abandoned_post )     like '1', 'yes', null ) as cha_left_program_abandoned_post,       
        if( trim( cha_left_program_promoted )           like '1', 'yes', null ) as cha_left_program_promoted,       
        if( trim( cha_left_program_other )              like '1', 'yes', null ) as cha_left_program_other,
        
        case
            when ( trim( male )   like '1' ) and ( trim( female ) like '' or ( female is null ) ) then 'M'
            when ( trim( female ) like '1' ) and ( trim( male )   like '' or ( male   is null ) ) then 'F'
            else 'Unknown'
        end as gender,
       
        birth_date,
        phone_number,
        
        today_date as form_date,

        if( trim( training_module_1 ) like '1', 'yes', null) as training_module_1,
        if( trim( training_module_2 ) like '1', 'yes', null) as training_module_2,      
        if( trim( training_module_3 ) like '1', 'yes', null) as training_module_3,       
        if( trim( training_module_4 ) like '1', 'yes', null) as training_module_4,

        meta_de_init          as form_entry_clerk,
        meta_de_date          as form_entry_date,
        meta_insert_date_time as form_send_date_time

from de_cha_status_change_form
where ( meta_insert_date_time >= curdate() - INTERVAL 1 DAY ) and ( meta_insert_date_time < curdate() )
;