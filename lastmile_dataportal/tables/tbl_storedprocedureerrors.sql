CREATE TABLE `tbl_storedprocedureerrors` (
  `id` int(7) unsigned NOT NULL AUTO_INCREMENT,
  `procName` varchar(50) DEFAULT NULL,
  `procParameters` longtext,
  `procTimestamp` datetime DEFAULT NULL,
  `errorMessage` longtext,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=306 DEFAULT CHARSET=latin1;
