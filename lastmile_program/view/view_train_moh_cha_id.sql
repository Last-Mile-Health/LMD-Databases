use lastmile_program;
  
drop view if exists view_train_moh_cha_id;

create view view_train_moh_cha_id as 
  
select                                               
      -- A. If there is no historical cha id assocaited with record, then pass the orgininal chaID as the valid cha_id; otherwise use 
      -- the position_id (moh id), which has been mapped.
      if( m.cha_id_historical is null, trim( t.cha_id ), m.position_id ) as cha_id,
      module

from lastmile_program.view_train_cha_last as t
    -- B.
    left outer join lastmile_cha_moh_id.temp_view_base_history_moh_lmh_cha_id as m on  (  ( trim( t.cha_id ) like m.position_id ) or 
                                                                                          ( trim( t.cha_id ) like m.cha_id_historical ) )
;