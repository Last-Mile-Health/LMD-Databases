use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_odk_id;

create view lastmile_report.view_diagnostic_odk_id as

select  
      d.table_name, 
      d.pk_id, 
      d.id_type, 
      d.id_name, 
      d.id_original_value, 
      d.id_inserted_value, 
      d.id_inserted_format_value, 
      d.id_value,
    
      -- if metadata doesn't exist, the display the metadata generated from a valid community_id if one exists
      if( d.meta_cha              is null, g.cha_list,                d.meta_cha )              as meta_cha,
      if( d.meta_cha_id           is null, g.position_id_list,        d.meta_cha_id )           as meta_cha_id,
      if( d.meta_chss             is null, g.chss_list,               d.meta_chss )             as meta_chss,
      if( d.meta_chss_id          is null, g.chss_position_id_list,   d.meta_chss_id )          as meta_chss_id,
      if( d.meta_facility         is null, g.health_facility_list,    d.meta_facility )         as meta_facility,
      if( d.meta_facility_id      is null, g.health_facility_id_list, d.meta_facility_id )      as meta_facility_id,
      if( d.meta_health_district  is null, g.health_district_list,    d.meta_health_district )  as meta_health_district,
      if( d.meta_county           is null, g.county_list,             d.meta_county )           as meta_county,
      if( d.meta_community        is null, g.community,               d.meta_community )        as meta_community,
      
      d.meta_community_id,
      d.meta_form_date,
       
      d.meta_insert_date_time, 
      d.meta_form_version
          
from lastmile_report.view_diagnostic_odk_id_unfiltered as d
    left outer join lastmile_report.view_diagnostic_odk_id_metadata_community_id as g on d.meta_community_id = g.community_id
                    -- if record has a valid community_id, then derive the metadata from the community_id
where 
      -- filter out valid null ID values
      not ( d.table_name like 'odk_chaRestock'                  and d.id_type like 'cha'  and d.id_name like 'chaID'            and ( d.meta_form_version like '3.1.1' or d.meta_form_version like '3.3.1' )  and d.id_original_value is null )
      and
      not ( d.table_name like 'odk_chaRestock'                  and d.id_type like 'cha'  and d.id_name like 'supervisedChaID'  and   d.meta_form_version like '3.2.2'                                        and d.id_original_value is null )
      and
      not ( d.table_name like 'odk_chaRestock'                  and d.id_type like 'chss' and d.id_name like 'user_id'          and ( d.meta_form_version like '3.1.1' or d.meta_form_version like '3.3.1' )  and d.id_original_value is null )
      and
      not ( d.table_name like 'odk_chaRestock'                  and d.id_type like 'chss' and d.id_name like 'chssID'           and   d.meta_form_version like '3.2.2'                                        and d.id_original_value is null )  
;
