use lastmile_report;

drop view if exists view_diag_cha_msr_1_cha_id_duplicate;

create view view_diag_cha_msr_1_cha_id_duplicate as

select
      trim( year_reported )     as year_reported,
      trim( month_reported )    as month_reported,
      trim( cha_id )   as cha_id,
      count( * )              as number_id_instance,
      group_concat( distinct cha_name order by cha_name asc separator ', ' ) as cha_name_list 
      
from lastmile_upload.de_cha_monthly_service_report
group by  trim( year_reported   ), 
          trim( month_reported  ), 
          trim( cha_id )
          
having count( * ) > 1

order by cast( trim( year_reported  ) as unsigned ) desc, 
         cast( trim( month_reported ) as unsigned ) desc,
         count( * )                                 desc
;