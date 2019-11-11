CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_chss_GroupSupervisionVisit` AS
    SELECT 
        CAST(SUBSTR(TRIM(`lastmile_upload`.`odk_supervisionVisitLog`.`manualDate`),
                6,
                2)
            AS SIGNED) AS `SubmissionMonth`,
        `lastmile_upload`.`odk_supervisionVisitLog`.`chssID` AS `chssID`,
        COUNT(0) AS `numberSupervision`
    FROM
        `lastmile_upload`.`odk_supervisionVisitLog`
    GROUP BY `SubmissionMonth` , `lastmile_upload`.`odk_supervisionVisitLog`.`chssID`
    ORDER BY `SubmissionMonth` , `lastmile_upload`.`odk_supervisionVisitLog`.`chssID`