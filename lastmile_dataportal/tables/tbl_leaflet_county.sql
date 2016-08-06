CREATE TABLE `tbl_leaflet_county` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `countyID` int(2) DEFAULT NULL,
  `indID_1` varchar(45) DEFAULT NULL,
  `indID_2` varchar(45) DEFAULT NULL,
  `indID_4` varchar(45) DEFAULT NULL,
  `indID_5` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
