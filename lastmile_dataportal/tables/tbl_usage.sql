CREATE TABLE `tbl_usage` (
  `pk` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `reportName` varchar(100) DEFAULT NULL,
  `linkURL` varchar(150) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `accessDate` date DEFAULT NULL,
  `accessTime` time DEFAULT NULL,
  PRIMARY KEY (`pk`),
  UNIQUE KEY `pk_UNIQUE` (`pk`)
) ENGINE=MyISAM AUTO_INCREMENT=12342 DEFAULT CHARSET=latin1;
