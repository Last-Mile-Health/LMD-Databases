CREATE TABLE `tbl_storedprocedurelog` (
  `id` int(7) unsigned NOT NULL AUTO_INCREMENT,
  `procName` varchar(50) DEFAULT NULL,
  `procParameters` longtext,
  `procTimestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=99 DEFAULT CHARSET=latin1;
