CREATE TABLE `tbl_markdown` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mdName` varchar(45) NOT NULL,
  `mdText` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mdName_UNIQUE` (`mdName`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8;
