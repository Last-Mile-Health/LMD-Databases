use lastmile_cha;

drop view if exists view_base_cha_basic_info;

create view view_base_cha_basic_info as

select *
from view_base_position_cha_basic_info
where not ( ( cha is null ) or ( trim( cha ) like '' ) )
;