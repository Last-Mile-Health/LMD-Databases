use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_cha;

create view lastmile_ncha.view_base_cha as

select *
from lastmile_ncha.view_base_position_cha
where not ( ( cha is null ) or ( trim( cha ) like '' ) )
;