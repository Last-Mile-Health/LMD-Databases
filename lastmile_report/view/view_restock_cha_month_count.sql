use lastmile_report;

drop view if exists view_restock_cha_month_count;

create view view_restock_cha_month_count as

select

      a.position_id,
      
      -- Total times the CHA was restocked in the current month
      sum( if( extract( year_month from r.manual_date ) =             extract( year_month from now() ),        1, 0 ) ) as month_current,
      
      -- Totol time the CHA was restocked in the preceding 12 months
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -1  ), 1, 0 ) ) as month_minus_1,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -2  ), 1, 0 ) ) as month_minus_2,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -3  ), 1, 0 ) ) as month_minus_3,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -4  ), 1, 0 ) ) as month_minus_4,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -5  ), 1, 0 ) ) as month_minus_5,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -6  ), 1, 0 ) ) as month_minus_6,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -7  ), 1, 0 ) ) as month_minus_7,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -8  ), 1, 0 ) ) as month_minus_8,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -9  ), 1, 0 ) ) as month_minus_9,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -10 ), 1, 0 ) ) as month_minus_10,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -11 ), 1, 0 ) ) as month_minus_11,
      sum( if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -12 ), 1, 0 ) ) as month_minus_12,
  
      -- Build list of person who probably did the actual restock of the CHA for the given year/month
      group_concat( distinct if( extract( year_month from r.manual_date ) =             extract( year_month from now() ),        if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_current_person_list,
      
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -1  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_1_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -2  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_2_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -3  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_3_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -4  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_4_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -5  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_5_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -6  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_6_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -7  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_7_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -8  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_8_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -9  ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_9_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -10 ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_10_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -11 ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_11_person_list,
      group_concat( distinct if( extract( year_month from r.manual_date ) = period_add( extract( year_month from now() ), -12 ), if( not r.full_name_database is null, r.full_name_database, r.chss_database ), null ) order by r.manual_date desc separator ', ' ) as month_minus_12_person_list

from lastmile_cha.view_base_position_cha as a
    left outer join lastmile_program.view_history_restock_cha as r on a.position_id like r.position_id
group by a.position_id
;