CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_odk_uploads` AS
    SELECT 
        'CHA restock' AS `Form type`,
        CAST(`lastmile_upload`.`odk_chaRestock`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_chaRestock`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_chaRestock`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_chaRestock`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Community Engagement Log' AS `Form type`,
        CAST(`lastmile_upload`.`odk_communityEngagementLog`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_communityEngagementLog`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_communityEngagementLog`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_communityEngagementLog`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Vaccine Tracker' AS `Form type`,
        CAST(`lastmile_upload`.`odk_vaccineTracker`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_vaccineTracker`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_vaccineTracker`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_vaccineTracker`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Supervision Visit Log' AS `Form type`,
        CAST(`lastmile_upload`.`odk_supervisionVisitLog`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_supervisionVisitLog`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_supervisionVisitLog`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_supervisionVisitLog`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Sick Child Form' AS `Form type`,
        CAST(`lastmile_upload`.`odk_sickChildForm`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_sickChildForm`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_sickChildForm`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_sickChildForm`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Routine Visit Form' AS `Form type`,
        CAST(`lastmile_upload`.`odk_routineVisit`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_routineVisit`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_routineVisit`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_routineVisit`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'QAO CHSS Quality Assurance Form' AS `Form type`,
        CAST(`lastmile_upload`.`odk_QAO_CHSSQualityAssuranceForm`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_QAO_CHSSQualityAssuranceForm`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_QAO_CHSSQualityAssuranceForm`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_QAO_CHSSQualityAssuranceForm`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'OSF KAP Survey' AS `Form type`,
        CAST(`lastmile_upload`.`odk_OSFKAPSurvey`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_OSFKAPSurvey`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_OSFKAPSurvey`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_OSFKAPSurvey`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'OSF Routine Form' AS `Form type`,
        CAST(`lastmile_upload`.`odk_osf_routine`.`meta_insert_date_time`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_osf_routine`.`meta_insert_date_time`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_osf_routine`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_osf_routine`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Field Incident Report Form' AS `Form type`,
        CAST(`lastmile_upload`.`odk_FieldIncidentReportForm`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_FieldIncidentReportForm`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_FieldIncidentReportForm`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_FieldIncidentReportForm`
    GROUP BY `Upload date` , `Upload time` 
    UNION SELECT 
        'Field Arrival Log Form' AS `Form type`,
        CAST(`lastmile_upload`.`odk_FieldArrivalLogForm`.`meta_insertDatetime`
            AS DATE) AS `Upload date`,
        DATE_FORMAT(`lastmile_upload`.`odk_FieldArrivalLogForm`.`meta_insertDatetime`,
                '%h:%i %p') AS `Upload time`,
        COUNT(1) AS `# Records`,
        `lastmile_upload`.`odk_FieldArrivalLogForm`.`meta_uploadUser` AS `Upload user`
    FROM
        `lastmile_upload`.`odk_FieldArrivalLogForm`
    GROUP BY `Upload date` , `Upload time`
    ORDER BY `Upload date` DESC , `Upload user` , `Upload time` DESC