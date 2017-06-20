select
      p.id              as person_id,
      p.parent          as person_parent,
      p.last_modified   as person_last_modified,
      p.created         as person_created,
      p.csd_uuid        as person_csd_uuid,
      p.firstname       as person_firstname,
      p.nationality     as person_nationality,
      p.othername       as person_othername,
      p.residence       as person_residence,
      p.surname         as person_surname,
      
      r.id              as record_id,
      r.last_modified   as record_last_modified,
      r.created         as record_created,
      r.form            as record_form,
      r.parent_form     as record_parent_form,
      r.parent_id       as record_parent_id,
      s.staffID
      
      
--      l.record          as last_entry_record, 
--      l.form_field      as last_entry_form_field, 
--      l.`date`          as last_entry_date, 
--      l.who             as last_entry_who, 
--      l.change_type     as last_entry_change_type, 
--      l.string_value    as staffID 
      
      
from hippo_person as p

    left outer join record as r on  ( trim( substring_index( p.id, '|', 1   ) ) like trim( r.parent_form ) )  and 
                                    ( trim( substring_index( p.id, '|', -1  ) ) like trim( r.parent_id   ) )
                                    
        left outer join ihris_manage_view_staffID as s on r.id = s.record
          
-- where trim( p.id ) like 'person|23717%' and ( trim( r.form ) like '27' ) 
-- and l.form_field like '98' and l.who like '53'

-- select record, form_field, `date`, who, change_type, string_value as staffID  
-- from last_entry
-- where form_field like '98' and who like '53'
