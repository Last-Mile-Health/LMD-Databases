
select
      cast( year_reported as unsigned ),
      cast( month_reported as unsigned ),
      trim( chss_id ),
      count( * ),
      group_concat( distinct trim( chss_id_original ) ),
      group_concat( distinct trim( chss_name ) ),
      group_concat( distinct county )
from lastmile_upload.de_chss_monthly_service_report
where year_reported >= 2020
group by cast( month_reported as unsigned ), trim( chss_id )
having count( * ) > 1
;

select
       year( restock_date ),
       month( restock_date ),
       trim( chss_id ),
       count( * ),
      group_concat( distinct trim( chss_id_original ) ),
      group_concat( distinct trim(  chss ) ),
      group_concat( distinct county )
      
from lastmile_upload.de_chss_commodity_distribution
where year( restock_date ) >= 2020
group by month( restock_date ), trim( chss_id )
having count( * ) > 1




