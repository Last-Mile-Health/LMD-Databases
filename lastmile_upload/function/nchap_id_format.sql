/*
 * Function: nchap_id_format()
 *
 * This functioin takes a string up to 255 characters in a lenghth, strips it of all characters
 * that are not [a-z], [A-Z], [0-9], including hypthens, and returns a string of characters in
 * a format that is valid LMH ID or a NCHAP ID, assuming the sequence of characters is a valid ID.
 * 
 * Examples:
 *            1. '  B B 0 1   0 1   '.  Function returns 'BB01-01'
 *                      
 *            2. 'BB 01  -  0  1 ',     Function returns 'BB01-01' 
 *
 *            3. '  2   0  2  0  ',     Functions returns '2020'
 *    
 *          ` and so on...
*/

use lastmile_upload;

drop function if exists lastmile_upload.nchap_id_format;

create function lastmile_upload.nchap_id_format( id varchar( 255 ) ) returns varchar( 255 )

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
                  
          /* id string has been stripped of all invalid characters, including a hyphen.
           * If it is four characters in length or less then assume it is an integer, since
           * LMH IDs are less than 9999.  
           * 
           * If it is greater than four characters in length, then insert a hyphen
           * after the fourth character.  For now, this is valid because all health facilities in 
           * Rivercess, Grand Gedeh, Grand Bassa have four character health facility IDs.
          
          */
          
          if character_length( @id_str ) > 4 then
     
              set @id_str:= concat( substring( @id_str, 1, 4 ), 
                                    '-', 
                                    substring( @id_str, 5, character_length( @id_str ) - 4 ) 
                                  );

          end if;
          
          return upper( @id_str );
          
      end if;
     
end;