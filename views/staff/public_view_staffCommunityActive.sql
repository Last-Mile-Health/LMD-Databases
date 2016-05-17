use lastmile_chwdb;

drop view if exists public_view_staffCommunityActive;

create view public_view_staffCommunityActive as
select
      county,
      healthDistrict,
      district,
      ccs,
      ccsID,
      chwl,
      chwlID,
      chw,
      chwID,
      group_concat( community   ) as community,
      group_concat( communityID ) as communityID
from view_territoryCommunityStaffHouseholdRegistered
where ( ( county like 'Rivercess' ) or ( county like 'Grand Gedeh' ) ) and ( not chw is null )
group by county,
          healthDistrict,
          district,
          ccs,
          ccsID,
          chwl,
          chwlID,
          chw,
          chwID
order by  county,
          healthDistrict,
          district,
          ccs,
          ccsID,
          chwl,
          chwlID,
          chw,
          chwID
;