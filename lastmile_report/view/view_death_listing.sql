use lastmile_report;

drop view if exists lastmile_report.view_death_listing;

create view lastmile_report.view_death_listing as 

select
        m.year_reported       as `Year`,
        m.month_reported      as `Month`,
        m.county              as `County`,
        m.health_facility     as `Health Facility`,
        
        concat( m.cha_name, ' (', m.cha_id, ')' )       as `CHA`,
                
        concat( m.community, ' (', m.community_id, ')') as `Community`,
        
        trim( trailing ', ' from  concat( 
        
                  if( m.num_stillbirths,          concat( 'stillbirth: ',   m.num_stillbirths,          ', ' ), '' ),
                  if( m.num_deaths_neonatal,      concat( 'neonatal: ',     m.num_deaths_neonatal,      ', ' ), '' ),           
                  if( m.num_deaths_postneonatal,  concat( 'postneonatal: ', m.num_deaths_postneonatal,  ', ' ), '' ),                  
                  if( m.num_deaths_child,         concat( 'child: ',        m.num_deaths_child,         ', ' ), '' ),                    
                  if( m.num_deaths_maternal,      concat( 'maternal: ',     m.num_deaths_maternal,      ', ' ), '' )
                
                )    
            ) as `Deaths`

from lastmile_report.view_base_msr as m
where ( 
        m.num_stillbirths         or 
        m.num_deaths_neonatal     or 
        m.num_deaths_postneonatal or 
        m.num_deaths_child        or 
        m.num_deaths_maternal 
      ) and
      not ( m.year_reported is null ) and
      not ( m.month_reported is null )

order by m.year_reported desc , m.month_reported desc , m.county, m.health_facility