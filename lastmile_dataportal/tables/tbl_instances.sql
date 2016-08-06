CREATE TABLE `tbl_instances` (
  `instID` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `geoID` int(3) unsigned NOT NULL,
  `indID` int(5) unsigned NOT NULL,
  `instShortName` varchar(30) DEFAULT NULL,
  `quarterly` int(1) NOT NULL DEFAULT '0',
  `archived` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`instID`),
  UNIQUE KEY `instID_UNIQUE` (`instID`)
) ENGINE=MyISAM AUTO_INCREMENT=292 DEFAULT CHARSET=latin1;
