use lastmile_report;

drop view if exists lastmile_report.view_odk_sickchild;

create view lastmile_report.view_odk_sickchild as 
select 

        b.county,
        b.county_id,
        
        lastmile_report.territory_id( b.county_id, 1 ) as territory_id,
        
        month(  a.manualDate ) as `month`,
        year(   a.manualDate ) as `year`,
        
        sum( a.treatMalaria   ) as malaria_odk,
        sum( a.treatDiarrhea  ) as diarrhea_odk,
        sum( a.treatPneumonia ) as ari_odk
        
from lastmile_upload.odk_sickChildForm a
    left outer join lastmile_report.mart_view_base_history_position b on trim( a.chwID ) like b.position_id

/* *** Again, don't need to check date range for CHA ID
    left outer join lastmile_report.mart_view_base_history_person_position b on (((a.chwID = b.position_id)
            AND (a.manualDate >= b.position_person_begin_date)
            AND ((a.manualDate <= b.position_person_end_date)
            OR ISNULL(b.position_person_end_date))))
*** */

where ( trim( a.visitType ) like 'initialVisit' ) and not ( b.county_id is null )
group by year(a.manualDate), month(a.manualDate), b.county_id
order by year(a.manualDate), month(a.manualDate), b.county_id