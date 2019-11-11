use lastmile_upload;

drop view if exists view_diagnostic_user_id_date_total;

create view view_diagnostic_user_id_date_total as

select 
      user_id,
      insert_date,
      count( * )    as total
from view_diagnostic_user_id_date
group by user_id, insert_date
order by user_id asc, insert_date desc
;