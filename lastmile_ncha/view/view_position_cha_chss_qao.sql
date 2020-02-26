use lastmile_ncha;

drop view if exists lastmile_ncha.view_position_cha_chss_qao;

create view lastmile_ncha.view_position_cha_chss_qao as
select 
        county,
        health_district,
        health_facility,
        position_id,
        cha,
        chss_position_id,
        chss,
        qao_position_id,
        qao
from lastmile_ncha.view_base_position_cha
;