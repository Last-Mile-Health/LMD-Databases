use lastmile_program;

drop view if exists view_train_chss_module;

create view view_train_chss_module as 

select
      t.position_id,
      t.person_id,
      
      replace( 
      trim( replace( concat(  if( not ( ( t.m1_overall_assessment is null  ) or ( trim( t.m1_overall_assessment ) like '' ) ), '1', ''  ), ' ',
                              if( not ( ( t.m2_overall_assessment is null  ) or ( trim( t.m2_overall_assessment ) like '' ) ), '2', ''  ), ' ',
                              if( not ( ( t.m3_overall_assessment is null  ) or ( trim( t.m3_overall_assessment ) like '' ) ), '3', ''  ), ' ',
                              if( not ( ( t.m4_overall_assessment is null  ) or ( trim( t.m4_overall_assessment ) like '' ) ), '4', ''  ), ' '
                            ), '  ', ' ' 
                    ) 
          ), 
          ' ', ', ' ) as module
          
from lastmile_program.view_train_chss_last as t
where ( not ( ( t.position_id is null ) or ( trim( t.position_id ) like '' ) ) ) and 
      ( not (   t.person_id   is null ) ) 
;
