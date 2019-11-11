use lastmile_report;

drop view if exists lastmile_report.view_grand_bassa_unassigned_community;

create view lastmile_report.view_grand_bassa_unassigned_community as 

select 
        master_list_id, 
        town_name, 
        health_facility, 
        map_remoteness  as remoteness, 
        map_dist_km     as dist_km, 
        map_adm_distri  as adm_distri, 
        X, 
        Y, 
        alt_name, 
        CD_cell, 
        mining, 
        numHH, 
        numHH_original
from lastmile_temp.community_grand_bassa_master
where not master_list_id in (
    select master_list_id from lastmile_report.view_community_household_grand_bassa
)
