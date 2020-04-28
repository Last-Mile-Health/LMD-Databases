use lastmile_report;

drop view if exists lastmile_report.view_data_entry;

create view lastmile_report.view_data_entry as
select 
      'Household Registration'      as `Form name`,
      trim( u.meta_DE_init )        as `DE Clerk`,
      year( u.meta_DE_date )        as `Year`,
      month( u.meta_DE_date )       as `Month`,
      count( * )                    as `# records entered`,
      sum( if( isnull( u.meta_QA_init ) or  trim( u.meta_QA_init ) like '', 0, 1 ) ) as `# records receiving QA`
      
from lastmile_upload.de_chaHouseholdRegistration as u
group by `Year`, `Month`, trim( u.meta_DE_init )

union all

select 
      'CHA Monthly Service Report'  as `Form name`,
      trim( u.meta_de_init )        as `DE Clerk`,
      year( u.meta_de_date )        as `Year`,
      month( u.meta_de_date )       as `Month`,
      count( * )                    as `# records entered`,
      sum( if( isnull( u.meta_qa_init ) or  trim( u.meta_qa_init ) like '', 0, 1 ) ) as `# records receiving QA`
      
from lastmile_upload.de_cha_monthly_service_report as u
group by `Year`, `Month`, trim( u.meta_de_init )

union all

select 
      'CHSS Monthly Service Report' as `Form name`,
      trim( u.meta_de_init )        as `DE Clerk`,
      year( u.meta_de_date )        as `Year`,
      month( u.meta_de_date )       as `Month`,
      count( * )                    as `# records entered`,
      sum( if( isnull( u.meta_qa_init ) or  trim( u.meta_qa_init ) like '', 0, 1 ) ) as `# records receiving QA`
      
from lastmile_upload.de_chss_monthly_service_report as u
group by `Year`, `Month`, trim( u.meta_de_init )

union all

select 
      'Correct Treatment: Case Scenario 1.0' as `Form name`,
      trim( u.meta_de_init )        as `DE Clerk`,
      year( u.meta_de_date )        as `Year`,
      month( u.meta_de_date )       as `Month`,
      count( * )                    as `# records entered`,
      sum( if( isnull( u.meta_qa_init ) or  trim( u.meta_qa_init ) like '', 0, 1 ) ) as `# records receiving QA`
      
from lastmile_upload.de_case_scenario as u
group by `Year`, `Month`, trim( u.meta_de_init )

union all

select 
      'Correct Treatment: Case Scenario 2.0' as `Form name`,
      trim( u.meta_de_init )        as `DE Clerk`,
      year( u.meta_de_date )        as `Year`,
      month( u.meta_de_date )       as `Month`,
      count( * )                    as `# records entered`,
      sum( if( isnull( u.meta_qa_init ) or  trim( u.meta_qa_init ) like '', 0, 1 ) ) as `# records receiving QA`
      
from lastmile_upload.de_case_scenario_2 as u
group by `Year`, `Month`, trim( u.meta_de_init )

union all

select 
      'CHSS Commodity Distribution Form' as `Form name`,
      trim( u.meta_de_init )        as `DE Clerk`,
      year( u.meta_de_date )        as `Year`,
      month( u.meta_de_date )       as `Month`,
      count( * )                    as `# records entered`,
      sum( if( isnull( u.meta_qa_init ) or  trim( u.meta_qa_init ) like '', 0, 1 ) ) as `# records receiving QA`
      
from lastmile_upload.de_chss_commodity_distribution as u
group by `Year`, `Month`, trim( u.meta_de_init )

order by `Year` desc, `Month` desc, `Form name` asc, `DE Clerk` asc
;