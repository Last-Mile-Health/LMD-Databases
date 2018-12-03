use lastmile_dataportal;

drop view if exists view_moh_dhis2_chss_msr_matrix;

create view view_moh_dhis2_chss_msr_matrix as

select

      month( str_to_date( substring_index( trim( d.periodname ), ' ', 1 ), '%M' ) )   as month_report,
      substring_index( trim( d.periodname ), ' ', -1 )                                as year_report,
      
      d.dataname                                                                      as indicator_name,
      
      d.bomi              as `1_1`,		
      d.bong              as `1_2`,		
      d.gbarpolu          as `1_3`,	
      d.grand_bassa       as `1_4`,	
      d.grand_cape_mount  as `1_5`,
      d.grand_gedeh       as `1_6`,
      d.grand_kru         as `1_7`,
      d.lofa              as `1_8`,
      d.margibi           as `1_9`,
      d.maryland          as `1_10`,
      d.montserrado       as `1_11`,
      d.nimba             as `1_12`,
      d.river_gee         as `1_13`,
      d.rivercess         as `1_14`,	
      d.sinoe             as `1_15`,
      
      a.ind_id
      
from lastmile_dataportal.tbl_moh_dhis2_chss_msr_upload as d
    left outer join lastmile_dataportal.tbl_moh_dhis2_chss_msr_map_indicator_id as a on d.dataname like trim( a.indicator_name )
;