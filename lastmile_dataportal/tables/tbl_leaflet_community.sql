CREATE TABLE `tbl_leaflet_community` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `communityID` int(5) DEFAULT NULL,
  `indID_1` varchar(45) DEFAULT NULL,
  `indID_2` varchar(45) DEFAULT NULL,
  `indID_4` varchar(45) DEFAULT NULL,
  `indID_5` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=678 DEFAULT CHARSET=latin1;
