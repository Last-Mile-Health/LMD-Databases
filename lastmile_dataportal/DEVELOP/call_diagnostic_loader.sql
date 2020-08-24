use lastmile_dataportal;

-- call diagnostic_loader_materialize_view();

-- Delete all recrods from tbl_values_diagnostic
-- delete from  lastmile_dataportal.tbl_values_diagnostic;

call lastmile_dataportal.diagnostic_loader( '2018-11-01',  now() );


