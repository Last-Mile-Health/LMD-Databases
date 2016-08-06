CREATE TABLE `tbl_values` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `month` int(2) NOT NULL,
  `year` int(4) NOT NULL,
  `instID` int(6) NOT NULL,
  `instValue` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `unique_index` (`month`,`year`,`instID`)
) ENGINE=InnoDB AUTO_INCREMENT=11406 DEFAULT CHARSET=utf8;
