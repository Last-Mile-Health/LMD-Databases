CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `lastmile_admin`@`%` 
    SQL SECURITY DEFINER
VIEW `lastmile_report`.`view_chss_tool_completion_months` AS
    SELECT 
        MONTH((NOW() + INTERVAL -(1) MONTH)) AS `month`,
        YEAR((NOW() + INTERVAL -(1) MONTH)) AS `year`
    
    UNION ALL SELECT 
        MONTH((NOW() + INTERVAL -(2) MONTH)) AS `month`,
        YEAR((NOW() + INTERVAL -(2) MONTH)) AS `year`
    
    UNION ALL SELECT 
        MONTH((NOW() + INTERVAL -(3) MONTH)) AS `month`,
        YEAR((NOW() + INTERVAL -(3) MONTH)) AS `year`
    
    UNION ALL SELECT 
        MONTH((NOW() + INTERVAL -(4) MONTH)) AS `month`,
        YEAR((NOW() + INTERVAL -(4) MONTH)) AS `year`
    
    UNION ALL SELECT 
        MONTH((NOW() + INTERVAL -(5) MONTH)) AS `month`,
        YEAR((NOW() + INTERVAL -(5) MONTH)) AS `year`
    
    UNION ALL SELECT 
        MONTH((NOW() + INTERVAL -(6) MONTH)) AS `month`,
        YEAR((NOW() + INTERVAL -(6) MONTH)) AS `year`