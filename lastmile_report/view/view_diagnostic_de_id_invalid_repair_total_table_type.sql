use lastmile_report;

drop view if exists lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type;

create view lastmile_report.view_diagnostic_de_id_invalid_repair_total_table_type as

select

      year( d.meta_form_date )                                                                    as year_form,
      month( d.meta_form_date )                                                                   as month_form,
      
      d.table_name, 
      d.id_type,
      
      if( d.meta_county is null, 'unknown', d.meta_county )                                       as county,

      -- total number of IDs
      count( * )                                                                                  as id_total,
      sum( if( p.position_id is null, 0, 1 ) )                                                    as id_valid,
      
      count( * ) - sum( if( p.position_id is null, 0, 1 ) )                                       as id_invalid,
       
      -- Number of 999 IDs (Specifically, any string that only contains the number 9 and spaces)
      sum( replace( d.id_value, ' ', '' ) regexp '^[9]+$' )                                       as id_invalid_999,
      
      -- Number of IDs that are exclusively digits, but are not exclusively 9s.
      sum( if(      replace( d.id_value, ' ', '' ) regexp '^[0-9]+$' and 
                not replace( d.id_value, ' ', '' ) regexp '^[9]+$', 
                1, 
                0 ) )                                                                             as id_invalid_lmh_integer,
      
      /* ( id_total - id_valid ) - ( id_invalid_999 + id_invalid_lmh_integer ) */
      ( count( * ) - sum( if( p.position_id is null, 0, 1 ) ) ) - 
      
      ( sum( replace( d.id_value, ' ', '' ) regexp '^[9]+$' )     + 
      
        sum( if(      replace( d.id_value, ' ', '' ) regexp '^[0-9]+$' and 
                  not replace( d.id_value, ' ', '' ) regexp '^[9]+$', 
                  1, 
                  0 ) )  
      )                                                                                           as id_invalid_other
   
         
from lastmile_report.view_diagnostic_de_id as d
    left outer join lastmile_cha.`position` as p on replace( d.id_value, ' ', '' ) like p.position_id and d.id_type like if( p.job_id = 1, 'cha',  if( p.job_id = 3, 'chss', null ) )
where d.meta_form_date >= '2018-08-01'
group by year( d.meta_form_date ), month( d.meta_form_date ), d.table_name, d.id_type, d.meta_county
;