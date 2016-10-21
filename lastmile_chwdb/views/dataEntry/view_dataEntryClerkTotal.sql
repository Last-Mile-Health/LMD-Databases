-- Note:  This code will form he base of the dataset for totals by clerk report in BIRT. 
--        Need to add paramter where clause by date and username.
--        Also, add username as a paramter, too.  We might just want to look at one guy.

-- Recode view_dataEntry so that all web dates are based on meta_DE_date.  This is beccause the DEs
-- often acculate for weeks before sending records to database, and we will get a bunch of spiked graphs
-- not indicative of their daily work product.  However, for odk docs, it's a one shot deal.

use lastmile_chwdb;

drop view if exists view_dataEntryClerkTotal;

create view view_dataEntryClerkTotal as

select

      if( trim(       e.dataEntryUser ) like '', null, e.dataEntryUser )      as username,
      
      count( * )                                                              as totalSendRecords,
      
      sum( if(        e.formType like 'web', 1 , 0 ) )                        as sumPaperRecords,
      sum( if(        e.formType like 'odk', 1 , 0 ) )                        as sumOdkRecords,
      sum( if( not    e.qualityAssuranceUser is null, 1 , 0 ) )               as sumQARecords,
      
      ( sum( if( not  e.qualityAssuranceUser is null, 1 , 0 ) ) / 
        sum( if(      e.formType like 'web', 1 , 0 ) )               ) * 100  as percentQA

from view_dataEntry as e
group by username
;