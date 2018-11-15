use lastmile_report;

drop view if exists view_twelve_month;

create view view_twelve_month as

-- last month
select date_format( curdate() - interval 1 month, '%Y' ) as year_reported, date_format( curdate() - interval 1 month, '%c' ) as month_reported

union

-- two months ago
select date_format( curdate() - interval 2 month, '%Y' ) as year_reported, date_format( curdate() - interval 2 month, '%c' ) as month_reported


union

-- three months ago
select date_format( curdate() - interval 3 month, '%Y' ) as year_reported, date_format( curdate() - interval 3 month, '%c' ) as month_reported

union

-- four months ago
select date_format( curdate() - interval 4 month, '%Y' ) as year_reported, date_format( curdate() - interval 4 month, '%c' ) as month_reported

union

-- five months ago
select date_format( curdate() - interval 5 month, '%Y' ) as year_reported, date_format( curdate() - interval 5 month, '%c' ) as month_reported

union

-- six months ago
select date_format( curdate() - interval 6 month, '%Y' ) as year_reported, date_format( curdate() - interval 6 month, '%c' ) as month_reported

union

-- seven months ago
select date_format( curdate() - interval 7 month, '%Y' ) as year_reported, date_format( curdate() - interval 7 month, '%c' ) as month_reported

union

-- eight months ago
select date_format( curdate() - interval 8 month, '%Y' ) as year_reported, date_format( curdate() - interval 8 month, '%c' ) as month_reported

union

-- nine months ago
select date_format( curdate() - interval 9 month, '%Y' ) as year_reported, date_format( curdate() - interval 9 month, '%c' ) as month_reported

union

-- ten months ago
select date_format( curdate() - interval 10 month, '%Y' ) as year_reported, date_format( curdate() - interval 10 month, '%c' ) as month_reported

union

-- eleven months ago
select date_format( curdate() - interval 11 month, '%Y' ) as year_reported, date_format( curdate() - interval 11 month, '%c' ) as month_reported

union

-- twelve months ago
select date_format( curdate() - interval 12 month, '%Y' ) as year_reported, date_format( curdate() - interval 12 month, '%c' ) as month_reported
;