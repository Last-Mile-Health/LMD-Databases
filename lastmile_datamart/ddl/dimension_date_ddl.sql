use lastmile_datamart;

drop table if exists dimension_date;

create table dimension_date (

  date_key                  int( 10 ) unsigned  not null,
  date_lmh                  char( 10 )          not null, -- YYYY-mm-dd
  date_full                 date                    null,
  
  date_name                 char( 10 )          not null, -- YYYY/mm/dd
  date_us                   char( 10 )          not null, -- mm/dd/YYYY
  date_eu                   char( 10 )          not null, -- dd/mm/YYYY
 
  week_day                  tinyint             not null,
  week_day_name             char( 10 )          not null,
  month_day                 tinyint             not null,
  year_day                  smallint            not null,
  weekday_weekend           char( 10 )          not null,
  year_week                 tinyint             not null,
  month_name                char( 10 )          not null,
  year_month_number         tinyint             not null,
  month_day_last            char(1)             not null,
  calendar_quarter          tinyint             not null,
  calendar_year             smallint            not null,
  calendar_year_month       char( 10 )          not null,
  calendar_year_quarter     char( 10 )          not null,
  fiscal_month_year         tinyint             not null,
  fiscal_quarter            tinyint             not null,
  fiscal_year               int                 not null,
  fiscal_year_month         char( 10 )          not null,
  fiscal_year_quarter       char( 10 )          not null,

  primary key ( date_key )
  
) engine = InnoDB default charset = utf8; 




