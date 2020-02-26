use lastmile_ncha;

drop view if exists lastmile_ncha.view_base_chss;

create view lastmile_ncha.view_base_chss as

select 
        *
from lastmile_ncha.view_base_position_chss
where not ( ( chss is null ) or ( trim( chss ) like '' ) )
;