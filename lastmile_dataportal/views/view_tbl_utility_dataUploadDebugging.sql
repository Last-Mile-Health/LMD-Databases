use lastmile_dataportal;

drop view if exists view_tbl_utility_dataUploadDebugging;

create view view_tbl_utility_dataUploadDebugging as
select queryString
from tbl_utility_dataUploadDebugging;