use lastmile_cha;

drop view if exists view_base_chss;

create view view_base_chss as

select 
        *
from view_base_position_chss
where not ( ( chss is null ) or ( trim( chss ) like '' ) )
;