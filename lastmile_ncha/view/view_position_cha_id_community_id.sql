use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_cha_id_community_id;

create view lastmile_ncha.view_position_cha_id_community_id as

select
      p.position_id_pk,
      p.position_id,
      pc.community_id
      
from lastmile_ncha.view_position_cha as p
    left outer join lastmile_ncha.position_community as pc on p.position_id_pk = pc.position_id_pk and ( pc.end_date is null )
;       