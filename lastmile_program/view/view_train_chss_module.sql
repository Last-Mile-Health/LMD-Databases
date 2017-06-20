use lastmile_program;

drop view if exists view_train_chss_module;

create view view_train_chss_module as 

select
      trim( ID ) as chss_id,
      
      replace( 
      trim( replace( concat(  if( not ( ( M1OverallAssessment is null  ) or ( trim( M1OverallAssessment ) like '' ) ), '1', ''  ), ' ',
                              if( not ( ( M2OverallAssessment is null  ) or ( trim( M2OverallAssessment ) like '' ) ), '2', ''  ), ' ',
                              if( not ( ( M3OverallAssessment is null  ) or ( trim( M3OverallAssessment ) like '' ) ), '3', ''  ), ' ',
                              if( not ( ( M4OverallAssessment is null  ) or ( trim( M4OverallAssessment ) like '' ) ), '4', ''  ), ' '
                            ), '  ', ' ' 
                    ) 
          ), 
          ' ', ', ' ) as module
          
from lastmile_temp.chss_training
where not ( ( ID is null ) or ( trim( ID ) like '' ) )
;
