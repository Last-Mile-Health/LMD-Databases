use lastmile_chwdb;

drop view if exists view_staffIDCohortCounty;

create view view_staffIDCohortCounty as

select
      s.n as staffID,
      
      case
      
          when  ( ( ( s.n >= 1    ) and ( s.n <= 78   ) )   or 
                  ( ( s.n >= 200  ) and ( s.n <= 1999 ) ) ) then 4
                
          when  ( s.n >= 79  ) and ( s.n <= 199 )           then 5
          
          when  ( s.n >= 2000  ) and ( s.n <= 2199 )        then 6
          
          when  ( s.n >= 2200  ) and ( s.n < 2699 )         then 7
          
          else null
          
      end as cohortID,
      
      case
      
          when  ( ( ( s.n >= 1    ) and ( s.n <= 78   ) )   or 
                  ( ( s.n >= 200  ) and ( s.n <= 1999 ) ) ) then 'Konobo'
                
          when  ( s.n >= 79  ) and ( s.n <= 199 )           then 'Gboe-Ploe'
          
          when  ( s.n >= 2000  ) and ( s.n <= 2199 )        then 'Rivercess 1'
          
          when  ( s.n >= 2200  ) and ( s.n < 2699 )         then 'Rivercess 2'
          
          else null
          
      end as cohort,
      
      case
      
          when  ( ( s.n >= 1      ) and ( s.n <= 1999 ) ) then 6
          
          when  ( ( s.n >= 2000   ) and ( s.n <= 2699 ) ) then 14
          
          else null
          
      end as countyID,
      
      case
      
          when  ( ( s.n >= 1      ) and ( s.n <= 1999 ) ) then 'Grand Gedeh'
          
          when  ( ( s.n >= 2000   ) and ( s.n <= 2699 ) ) then 'Rivercess'
          
          else null
          
      end as county
      
from view_sequentialUnsignedInteger as s
;