CREATE TABLE `tbl_indicators` (
  `indID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `indName` varchar(100) NOT NULL,
  `indFormat` varchar(45) NOT NULL,
  `indCategory` varchar(100) NOT NULL,
  `indDefinition` longtext,
  `indTarget` varchar(45) DEFAULT NULL,
  `indNarrative` longtext,
  `archive_indTarget_FY15` varchar(45) DEFAULT NULL,
  `archived` int(1) NOT NULL DEFAULT '0' COMMENT 'Set to "1" if indicator is no longer used',
  PRIMARY KEY (`indID`),
  UNIQUE KEY `indID_UNIQUE` (`indID`)
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8;
