use lastmile_report;

drop view if exists lastmile_report.view_restock_level_year_month;

create view lastmile_report.view_restock_level_year_month as
select calendar_year as year_report, year_month_number as month_report
from lastmile_datamart.dimension_date  
where date_key >= ( ( year(   date_sub( current_date(), INTERVAL 3 month ) ) * 10000 ) + 
                    ( month(  date_sub( current_date(), INTERVAL 3 month ) ) * 100 ) +
                      day(    date_sub( current_date(), INTERVAL 3 month ) ) 
                  )
group by calendar_year, year_month_number
;


-- where date_key >= 20200501

                  