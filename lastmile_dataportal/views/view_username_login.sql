use lastmile_dataportal;

drop view if exists view_username_login;

create view view_username_login as

select
        if( u.archived = 0, 'Y', 'N' )            as account_active,
        u.username, 
        concat( u.first_name, ' ', u.last_name )  as full_name,
        max( l.login_time )                       as last_login,
        count( * )                                as number_login
from tbl_utility_users as u
    left outer join tbl_utility_logins as l on u.username = l.username
group by u.archived, u.username, concat( u.first_name, ' ', u.last_name )
order by max( l.login_time ) desc
    