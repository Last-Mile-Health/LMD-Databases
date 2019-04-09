use lastmile_datamart;

drop table if exists fact_restock_cha_commodity;

create table fact_restock_cha_commodity (

  -- composite key
  record_id                           int( 10 )       unsigned  not null,
  date_key                            int( 10 )       unsigned  not null,
  position_id                         varchar( 50 )             not null,
  commodity_type                      varchar( 50 )             not null,
 
  stock_on_hand                       int( 10 )       unsigned      null,
  restock_type                        varchar( 50 )                 null,
  restock_partial                     int( 10 )       unsigned      null,
  stock_out_reason                    varchar( 255 )                null,
  fullstock                           int( 10 )       unsigned      null,
  stockout                            tinyint( 1 )    unsigned      null, -- boolean 0 or 1
  
  meta_insert_date_time               datetime                null,
 
  primary key ( record_id, date_key, position_id, commodity_type )

) engine = InnoDB default charset = utf8;

alter table lastmile_datamart.fact_restock_cha_commodity add index index_fact_restock_cha_commodity_position_id_date_key  ( date_key, position_id, commodity_type );

