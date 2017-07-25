use lastmile_report;

drop view if exists view_restock_cha_chss_month_count;

create view view_restock_cha_chss_month_count as

select
      a.county,
      a.health_district,
      a.cohort,
      a.health_facility,
      a.health_facility_id, 
      
      a.cha_id, -- same as position_id for CHAs
      a.cha,
      a.position_begin_date,
      a.hire_date,
      a.position_person_begin_date,
      a.position_filled,
      a.position_filled_last_date,
      a.phone_number,
      a.phone_number_alternate,
      
      a.community_id_list,
      a.community_list,
     
      a.chss_position_id,
      a.chss_id,
      a.chss,
      a.chss_position_begin_date,
      a.chss_hire_date,
      a.chss_supervision_begin_date,
      a.chss_phone_number,
      a.chss_phone_number_alternate,
      a.chss_gender,
      
      c.month_current,
      c.month_minus_1,
      c.month_minus_2,
      c.month_minus_3,
      c.month_minus_4,
      c.month_minus_5,
      c.month_minus_6,
      c.month_minus_7,
      c.month_minus_8,
      c.month_minus_9,
      c.month_minus_10,
      c.month_minus_11,
      c.month_minus_12,
      
      c.month_current_person_list,
      c.month_minus_1_person_list,
      c.month_minus_2_person_list,
      c.month_minus_3_person_list,
      c.month_minus_4_person_list,
      c.month_minus_5_person_list,
      c.month_minus_6_person_list,
      c.month_minus_7_person_list,
      c.month_minus_8_person_list,
      c.month_minus_9_person_list,
      c.month_minus_10_person_list,
      c.month_minus_11_person_list,
      c.month_minus_12_person_list
      
from lastmile_cha.view_base_position_cha as a
    left outer join view_restock_cha_month_count c on a.cha_id like c.cha_id
order by a.county asc, a.health_district asc, a.health_facility asc, a.chss asc, a.cha asc
;