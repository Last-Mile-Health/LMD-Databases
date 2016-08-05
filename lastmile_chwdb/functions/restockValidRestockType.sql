use lastmile_chwdb;
 
drop function if exists restockValidRestockType;

-- The purpose of this function is to take a string and see if it represents a valid
-- restock type.  Empty, null, none, full, partial are all valid
-- restock type strings.

-- Note: All whitespace is removed from strings before an attempt is made to match.
-- So strings such as ' f u l l ' would be considered a match.  Likewise, case is 
-- ignored, so strings such as 'partial' or 'NONE' would also be considerd
-- matches.

-- Return Values:
-- 1, the string represents a valid restock type.
-- 0, the string does not represent a valid restock type.

create function restockValidRestockType( paramStrng varchar( 255 ) ) returns tinyint

begin

declare returnValue tinyint default 0;

case 
    when lower( replace( paramStrng, ' ', '' ) ) is null            then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like ''            then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like 'full'        then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like 'partial'     then
        set returnValue = 1;
    when lower( replace( paramStrng, ' ', '' ) ) like 'none'        then
        set returnValue = 1;
    else
        set returnValue = 0;
end case;

return returnValue;
end;