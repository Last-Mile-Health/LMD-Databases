use lastmile_archive;

drop view if exists view_staffSupervisionCommunityActiveReport;

create view view_staffSupervisionCommunityActiveReport as

select 
      a.ccsID,
      a.ccs,
      a.ccsDateOfBirth,
      a.ccsGender,
      a.ccsPhoneNumber,
      
      a.chwlID, 
      a.chwl, 
      a.chwlDateOfBirth, 
      a.chwlGender,
      a.chwlPhoneNumber,

      a.chwID, 
      a.chw, 
      a.chwDateOfBirth, 
      a.chwGender, 
      a.chwPhoneNumber,
      
      group_concat( distinct a.communityID    separator ', '  ) as communityID,
      group_concat( distinct a.community      separator ', '  ) as community,
      group_concat( distinct a.district       separator ', '  ) as district,
      group_concat( distinct a.healthDistrict separator ', '  ) as healthDistrict,
      group_concat( distinct a.healthFacility separator ', '  ) as healthFacility,
      
      -- I don't think calling the mapStaffIDToCounty function is going to cause a big performance hit 
      -- with this report.  Most of the rows will have a county, so it will just get passed through.  
      -- Otherwise, first check if there is a chwID and calculate her county from her ID number.  If
      -- there is no chwId, then try chwlID, followed by ccsID.
      case
          when not ( ( a.county is null ) or ( trim( a.county ) like '' ) ) then a.county
          when not ( ( a.chwID  is null ) or ( trim( a.chwID  ) like '' ) ) then mapStaffIDToCounty( a.chwID )
          when not ( ( a.chwlID is null ) or ( trim( a.chwlID ) like '' ) ) then mapStaffIDToCounty( a.chwlID )
          when not ( ( a.ccsID  is null ) or ( trim( a.ccsID  ) like '' ) ) then mapStaffIDToCounty( a.ccsID )
          else 'Unknown'
      end as county
      
from view_staffSupervisionCommunityActive as a
group by 

      a.ccsID,
      a.ccs,
      a.ccsDateOfBirth,
      a.ccsGender,
      a.ccsPhoneNumber,
      
      a.chwlID, 
      a.chwl, 
      a.chwlDateOfBirth, 
      a.chwlGender,
      a.chwlPhoneNumber,

      a.chwID, 
      a.chw, 
      a.chwDateOfBirth, 
      a.chwGender, 
      a.chwPhoneNumber
order by county, a.ccs asc, a.chwl asc, a.chw asc, a.community asc
;

