use ihrismanagesitedemo;

drop view if exists ihris_manage_view_staffID; 

create view ihris_manage_view_staffID as

select
      le.record,
      le.string_value as staffID
from last_entry as le
    left outer join form_field as ff on le.form_field = ff.id
        left outer join form as f on ff.form = f.id
        left outer join `field` as fd on ff.field = fd.id 
where f.name like 'person_id' and fd.name like 'id_num'
;