CREATE TABLE `tbl_geocuts` (
  `geoID` int(3) unsigned NOT NULL AUTO_INCREMENT,
  `geoName` varchar(50) NOT NULL,
  PRIMARY KEY (`geoID`),
  UNIQUE KEY `geoID_UNIQUE` (`geoID`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
