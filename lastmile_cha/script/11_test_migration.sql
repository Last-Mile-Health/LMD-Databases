select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'cha' ) and (  ( trim( id_inserted ) like '2001' ) or 
                                            ( trim( id_inserted ) like '34'   ) or 
                                            ( trim( id_inserted ) like '101'  )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'cha' ) and (  ( trim( id_inserted ) like '1'      ) or 
                                            ( trim( id_inserted ) like '206'    )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'cha' ) and (  ( trim( id_inserted ) like '84'      ) or 
                                            ( trim( id_inserted ) like '96'    )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'cha' ) and (  ( trim( id_inserted ) like '2064'      ) or 
                                            ( trim( id_inserted ) like '2164'    )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'cha' ) and (  ( trim( id_inserted ) like '10' ) or 
                                            ( trim( id_inserted ) like '79'   ) or 
                                            ( trim( id_inserted ) like '2017'  )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'cha' ) and (  ( trim( id_inserted ) like '98' ) or 
                                            ( trim( id_inserted ) like '214'   ) or 
                                            ( trim( id_inserted ) like '2600'  )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

-- chss --

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'chss' ) and ( ( trim( id_inserted ) like '2191' ) or 
                                            ( trim( id_inserted ) like '110'   ) or 
                                            ( trim( id_inserted ) like '68'  )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;

select
      table_name,
      id_inserted,
      id
     
from lastmile_upload.view_upload_update_nchap_id_date
where ( trim( id_type ) like 'chss' ) and ( ( trim( id_inserted ) like '991' ) or 
                                            ( trim( id_inserted ) like '999'   ) or 
                                            ( trim( id_inserted ) like '2991'  )
                                          )
group by table_name, id_inserted, id
order by id_inserted asc, id asc, table_name asc
;


