use lastmile_report;

drop view if exists lastmile_report.view_chss_tool_completion_months;

create view lastmile_report.view_chss_tool_completion_months as

          select month( ( now() + interval -( 1 )   month ) ) as `month`, year( ( now() + interval -( 1 )   month ) ) as `year`   
union all select month( ( now() + interval -( 2 )   month ) ) as `month`, year( ( now() + interval -( 2 )   month ) ) as `year`    
union all select month( ( now() + interval -( 3 )   month ) ) as `month`, year( ( now() + interval -( 3 )   month ) ) as `year`
union all select month( ( now() + interval -( 4 )   month ) ) as `month`, year( ( now() + interval -( 4 )   month ) ) as `year`
union all select month( ( now() + interval -( 5 )   month ) ) as `month`, year( ( now() + interval -( 5 )   month ) ) as `year`
union all select month( ( now() + interval -( 6 )   month ) ) as `month`, year( ( now() + interval -( 6 )   month ) ) as `year`

union all select month( ( now() + interval -( 7 )   month ) ) as `month`, year( ( now() + interval -( 7 )   month ) ) as `year`
union all select month( ( now() + interval -( 8 )   month ) ) as `month`, year( ( now() + interval -( 8 )   month ) ) as `year`
union all select month( ( now() + interval -( 9 )   month ) ) as `month`, year( ( now() + interval -( 9 )   month ) ) as `year`
union all select month( ( now() + interval -( 10 )  month ) ) as `month`, year( ( now() + interval -( 10 )  month ) ) as `year`
union all select month( ( now() + interval -( 11 )  month ) ) as `month`, year( ( now() + interval -( 11 )  month ) ) as `year`
union all select month( ( now() + interval -( 12 )  month ) ) as `month`, year( ( now() + interval -( 12 )  month ) ) as `year`
;

/*  Leave this here for debug purposes

union all select month( ( now() + interval -( 13 )  month ) ) as `month`, year( ( now() + interval -( 13 )  month ) ) as `year`
union all select month( ( now() + interval -( 14 )  month ) ) as `month`, year( ( now() + interval -( 14 )  month ) ) as `year`
union all select month( ( now() + interval -( 15 )  month ) ) as `month`, year( ( now() + interval -( 15 )  month ) ) as `year`
union all select month( ( now() + interval -( 16 )  month ) ) as `month`, year( ( now() + interval -( 16 )  month ) ) as `year`
union all select month( ( now() + interval -( 17 )  month ) ) as `month`, year( ( now() + interval -( 17 )  month ) ) as `year`
union all select month( ( now() + interval -( 18 )  month ) ) as `month`, year( ( now() + interval -( 18 )  month ) ) as `year`
union all select month( ( now() + interval -( 19 )  month ) ) as `month`, year( ( now() + interval -( 19 )  month ) ) as `year`
union all select month( ( now() + interval -( 20 )  month ) ) as `month`, year( ( now() + interval -( 20 )  month ) ) as `year`
union all select month( ( now() + interval -( 21 )  month ) ) as `month`, year( ( now() + interval -( 21 )  month ) ) as `year`
union all select month( ( now() + interval -( 22 )  month ) ) as `month`, year( ( now() + interval -( 22 )  month ) ) as `year`
union all select month( ( now() + interval -( 23 )  month ) ) as `month`, year( ( now() + interval -( 23 )  month ) ) as `year`
union all select month( ( now() + interval -( 24 )  month ) ) as `month`, year( ( now() + interval -( 24 )  month ) ) as `year`
*/



