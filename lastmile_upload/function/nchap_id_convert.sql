use lastmile_upload;

drop function if exists lastmile_upload.nchap_id_convert;

create function lastmile_upload.nchap_id_convert( id varchar( 100 ) ) returns varchar( 100 )


begin


      /* if id is null or zero length or all blanks then bail immediately. */
      if ( id is null ) or ( trim( id ) like '' ) then
      
          return trim( id );
      
      else
      
          
          /* strip all characters not equal to a-z, A-Z, or 0-9 */
          set @lcv = 1; /* loop contral variable */
          set @id_str = '';
                  
          while @lcv <= character_length( id ) do  

                if substring( id, @lcv, 1 ) regexp '^[a-zA-Z0-9]' then 
          
                 set @id_str = concat( @id_str, substring( id, @lcv, 1 ) );
             
                  
              end if;
              
              set @lcv:= @lcv + 1;
          
          end while;
          
          
          /* id string is stripped of all invalid characters, including a hyphen.
           * If it is four characters in length or less then assume it is an integer, since
           * LMH IDs are less than 9999.  
           * 
           * If it is greater than four characters in length, then insert a hyphen
           * after the fourth character.  This is valid because all health facilities in 
           * Rivercess, Grand Gedeh, Grand Bassa have four character health facility IDs.
          
          */
          
          if character_length( @id_str ) > 4 then
     
              set @id_str:= concat( substring( @id_str, 1, 4 ), 
                                    '-', 
                                    substring( @id_str, 5, character_length( @id_str ) - 4 ) 
                                  );

          end if;
          
          return @id_str;
          
      end if;
     
end;