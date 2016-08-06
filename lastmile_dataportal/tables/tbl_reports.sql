CREATE TABLE `tbl_reports` (
  `reportID` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `reportName` varchar(100) NOT NULL,
  PRIMARY KEY (`reportID`),
  UNIQUE KEY `reportID_UNIQUE` (`reportID`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
