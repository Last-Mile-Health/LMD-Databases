use lastmile_report;

drop view if exists lastmile_report.view_supervision_visit_log_position_id_gps;

create view lastmile_report.view_supervision_visit_log_position_id_gps as

select
      trim( supervisedCHAID )                                                                       as position_id,
      communityID                                                                                   as community_id,
      -- gpsCoordinate,
      trim( substring_index( trim( substring_index( trim( gpsCoordinate ), ' ', 2 ) ), ' ', -1 ) )  as x,
      trim( substring_index( trim( gpsCoordinate ), ' ', 1 ) )                                      as y,
      
      manualDate                                                                                    as manualDate
      
from lastmile_upload.odk_supervisionVisitLog
where not ( ( gpsCoordinate is null ) or ( trim( gpsCoordinate ) like '' ) )
;