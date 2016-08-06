CREATE TABLE `tbl_json_objects` (
  `id` int(5) unsigned NOT NULL AUTO_INCREMENT,
  `objectName` varchar(50) NOT NULL,
  `objectData` blob NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`objectName`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
