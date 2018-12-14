use lastmile_dataquality;

drop table if exists lastmile_dataquality.id_invalid_cleanup;

create table lastmile_dataquality.id_invalid_cleanup (

  id_invalid_cleanup_pk_id        int( 10 ) unsigned not null auto_increment,
  
  table_name                      varchar( 100 )  default null,
  pk_id                           varchar( 100 )  default null,
  
  id_type                         varchar( 100 )  default null,
  id_name                         varchar( 100 )  default null,
  id_original                     varchar( 100 )  default null,
  id_repair                       varchar( 100 )  default null,
  id_formatted                    varchar( 100 )  default null,
  id_value                        varchar( 100 )  default null,
  
  meta_cha                        varchar( 100 )  default null,
  meta_cha_id                     varchar( 100 )  default null,
  meta_chss                       varchar( 100 )  default null,
  meta_chss_id                    varchar( 100 )  default null,
  meta_facility                   varchar( 100 )  default null,
  meta_facility_id                varchar( 100 )  default null,
  meta_health_district            varchar( 100 )  default null,
  meta_county                     varchar( 100 )  default null,
  meta_community                  varchar( 100 )  default null,
  meta_community_id               varchar( 100 )  default null,
  
  meta_insert_date_time_original  varchar( 100 )  default null,
  meta_form_version               varchar( 100 )  default null,
  
  meta_insert_date_time           datetime        default null,

  primary key ( id_invalid_cleanup_pk_id ),
  unique  key UK_id_invalid_cleanup_pk_id ( id_invalid_cleanup_pk_id )
  
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPRESSED
;

drop trigger if exists lastmile_dataquality.id_invalid_cleanup_before_insert;

delimiter //
create trigger lastmile_dataquality.id_invalid_cleanup_before_insert before insert
    on lastmile_dataquality.id_invalid_cleanup for each row
begin

    set new.meta_insert_date_time_original = now();
    
end
//

delimiter ;


