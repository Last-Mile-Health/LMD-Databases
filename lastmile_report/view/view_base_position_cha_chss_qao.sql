use lastmile_report;

drop view if exists lastmile_report.view_base_position_person_cha_chss_qao;

create view lastmile_report.view_base_position_person_cha_chss_qao as

select
      c.county,
      c.health_district,
      
      c.qao_position_id,
      c.qao,
      
      c.health_facility,
      
      c.chss_position_id,
      c.chss,
     
      c.position_id,
      c.cha,
      
      c.community_id_list                                                 as community_id,
      c.community_list                                                    as community,
      
      c.module                                                            as cha_train_module,
      c.gender                                                            as cha_gender,
      c.birth_date                                                        as cha_birth_date,
      concat( trim( c.phone_number ), 
              if( c.phone_number_alternate is null or trim( c.phone_number_alternate ) like '', '', ', ' ), 
              coalesce( trim( c.phone_number_alternate ), '' ) )          as cha_phone_number,
      
      c.chss_module                                                       as chss_train_module,
      c.chss_gender                                                       as chss_gender,
      c.chss_birth_date                                                   as chss_birth_date,     
      concat( trim( c.chss_phone_number ), 
              if( c.chss_phone_number_alternate is null or trim( c.chss_phone_number_alternate ) like '', '', ', ' ), 
              coalesce( trim( c.chss_phone_number_alternate ), '' ) )     as chss_phone_number,
      
      c.qao_gender                                                        as qao_gender,
      c.qao_birth_date                                                    as qao_birth_date,
      concat( trim( c.qao_phone_number ), 
              if( c.qao_phone_number_alternate is null or trim( c.qao_phone_number_alternate ) like '', '', ', ' ), 
              coalesce( trim( c.qao_phone_number_alternate ), '' ) )     as qao_phone_number
      
 
from lastmile_ncha.view_base_position_cha as c
order by  c.county asc, 
          c.health_district asc, 
          c.qao_position_id asc, 
          c.health_facility asc, 
          c.chss_position_id asc, 
          c.position_id asc
;