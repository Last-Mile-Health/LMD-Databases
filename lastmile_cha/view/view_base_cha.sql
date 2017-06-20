use lastmile_cha;

drop view if exists view_base_cha;

create view view_base_cha as

select *
from view_base_position_cha
where not ( ( cha is null ) or ( trim( cha ) like '' ) )
;